//
//  MSMDiskCache.m
//  mySeaMap
//
//  Ersatz für TMCache (CocoaPods).
//

#import "MSMDiskCache.h"

static NSString * const kDataExtension = @"data";
static NSString * const kObjectExtension = @"obj";

@interface MSMDiskCache ()

@property (nonatomic, readwrite) NSString *name;
@property (nonatomic, strong) NSURL *directoryURL;
@property (nonatomic, strong) NSCache *memoryCache;
@property (nonatomic, strong) dispatch_queue_t queue;

@end

@implementation MSMDiskCache

- (instancetype) initWithName: (NSString *) name
{
    self = [super init];
    if (self)
    {
        _name = [name copy];
        _memoryCache = [[NSCache alloc] init];
        _memoryCache.countLimit = 300;
        _queue = dispatch_queue_create([[@"de.myseamap.cache." stringByAppendingString: name] UTF8String], DISPATCH_QUEUE_SERIAL);

        NSURL *caches = [[[NSFileManager defaultManager] URLsForDirectory: NSCachesDirectory inDomains: NSUserDomainMask] firstObject];
        _directoryURL = [caches URLByAppendingPathComponent: [@"MSMDiskCache." stringByAppendingString: name] isDirectory: YES];
        [[NSFileManager defaultManager] createDirectoryAtURL: _directoryURL withIntermediateDirectories: YES attributes: nil error: nil];
    }
    return self;
}

#pragma mark - Dateinamen

- (NSString *) fileNameForKey: (NSString *) key
{
    NSString *encoded = [key stringByAddingPercentEncodingWithAllowedCharacters: [NSCharacterSet alphanumericCharacterSet]];
    return encoded ?: [NSString stringWithFormat: @"%lu", (unsigned long)key.hash];
}

- (NSURL *) fileURLForKey: (NSString *) key extension: (NSString *) extension
{
    return [[self.directoryURL URLByAppendingPathComponent: [self fileNameForKey: key]] URLByAppendingPathExtension: extension];
}

- (BOOL) isExpired: (NSURL *) fileURL
{
    if (self.ageLimit <= 0.0)
        return NO;

    NSDate *modified = nil;
    [fileURL getResourceValue: &modified forKey: NSURLContentModificationDateKey error: nil];
    return modified != nil && -[modified timeIntervalSinceNow] > self.ageLimit;
}

#pragma mark - Lesen / Schreiben

- (id) objectForKey: (NSString *) key
{
    if (key == nil)
        return nil;

    id object = [self.memoryCache objectForKey: key];
    if (object)
        return object;

    __block id result = nil;
    dispatch_sync(self.queue, ^{
        NSFileManager *fm = [NSFileManager defaultManager];

        NSURL *dataURL = [self fileURLForKey: key extension: kDataExtension];
        NSURL *objectURL = [self fileURLForKey: key extension: kObjectExtension];

        for (NSURL *url in @[dataURL, objectURL])
        {
            if (! [fm fileExistsAtPath: url.path])
                continue;

            if ([self isExpired: url])
            {
                [fm removeItemAtURL: url error: nil];
                continue;
            }

            NSData *data = [NSData dataWithContentsOfURL: url];
            if (data == nil)
                continue;

            if (url == dataURL)
            {
                result = data;
            }
            else
            {
                NSError *error = nil;
                NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingFromData: data error: &error];
                unarchiver.requiresSecureCoding = NO;
                @try {
                    result = [unarchiver decodeObjectForKey: NSKeyedArchiveRootObjectKey];
                }
                @catch (NSException *exception) {
                    result = nil;
                    [fm removeItemAtURL: url error: nil];
                }
                [unarchiver finishDecoding];
            }
            break;
        }
    });

    if (result)
        [self.memoryCache setObject: result forKey: key];

    return result;
}

- (void) setObject: (id) object forKey: (NSString *) key
{
    if (key == nil)
        return;

    if (object == nil)
    {
        [self.memoryCache removeObjectForKey: key];
        dispatch_async(self.queue, ^{
            NSFileManager *fm = [NSFileManager defaultManager];
            [fm removeItemAtURL: [self fileURLForKey: key extension: kDataExtension] error: nil];
            [fm removeItemAtURL: [self fileURLForKey: key extension: kObjectExtension] error: nil];
        });
        return;
    }

    [self.memoryCache setObject: object forKey: key];

    dispatch_async(self.queue, ^{
        NSData *data;
        NSURL *url;

        if ([object isKindOfClass: [NSData class]])
        {
            data = object;
            url = [self fileURLForKey: key extension: kDataExtension];
        }
        else
        {
            NSError *error = nil;
            data = [NSKeyedArchiver archivedDataWithRootObject: object requiringSecureCoding: NO error: &error];
            url = [self fileURLForKey: key extension: kObjectExtension];
            if (data == nil)
            {
                NSLog(@"MSMDiskCache: Objekt für %@ konnte nicht archiviert werden: %@", key, error);
                return;
            }
        }

        [data writeToURL: url options: NSDataWritingAtomic error: nil];
    });
}

#pragma mark - Verwaltung

- (void) removeAllObjects: (MSMDiskCacheBlock) block
{
    [self.memoryCache removeAllObjects];

    dispatch_async(self.queue, ^{
        NSFileManager *fm = [NSFileManager defaultManager];
        [fm removeItemAtURL: self.directoryURL error: nil];
        [fm createDirectoryAtURL: self.directoryURL withIntermediateDirectories: YES attributes: nil error: nil];

        if (block)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                block(self);
            });
        }
    });
}

- (void) setAgeLimit: (NSTimeInterval) ageLimit
{
    _ageLimit = ageLimit;

    if (ageLimit <= 0.0)
        return;

    // abgelaufene Einträge im Hintergrund entfernen
    dispatch_async(self.queue, ^{
        NSFileManager *fm = [NSFileManager defaultManager];
        NSArray *files = [fm contentsOfDirectoryAtURL: self.directoryURL
                           includingPropertiesForKeys: @[NSURLContentModificationDateKey]
                                              options: NSDirectoryEnumerationSkipsHiddenFiles
                                                error: nil];
        for (NSURL *url in files)
        {
            if ([self isExpired: url])
                [fm removeItemAtURL: url error: nil];
        }
    });
}

- (NSUInteger) diskByteCount
{
    __block NSUInteger total = 0;
    dispatch_sync(self.queue, ^{
        NSFileManager *fm = [NSFileManager defaultManager];
        NSArray *files = [fm contentsOfDirectoryAtURL: self.directoryURL
                           includingPropertiesForKeys: @[NSURLTotalFileAllocatedSizeKey]
                                              options: NSDirectoryEnumerationSkipsHiddenFiles
                                                error: nil];
        for (NSURL *url in files)
        {
            NSNumber *size = nil;
            [url getResourceValue: &size forKey: NSURLTotalFileAllocatedSizeKey error: nil];
            total += size.unsignedIntegerValue;
        }
    });
    return total;
}

@end
