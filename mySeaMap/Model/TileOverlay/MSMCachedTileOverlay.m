//
//  MSMCachedTileOverlay.m
//  mySeaMap
//
//  Created by Frank Budszuhn on 22.03.14.
//  Copyright (c) 2014 Frank Budszuhn. See LICENSE.
//

#import "MSMDiskCache.h"
#import "MSMUtils.h"
#import "MSMCachedTileOverlay.h"

@interface MSMCachedTileOverlay ()

@property (strong, nonatomic) MSMDiskCache *cache;

@end

@implementation MSMCachedTileOverlay

- (instancetype) initWithURLTemplate:(NSString *)URLTemplate andCacheName: (NSString *) cacheName
{
    self = [super initWithURLTemplate:URLTemplate];
    if (self)
    {        
        _cache = [[MSMDiskCache alloc] initWithName: cacheName];
        // das Trimmen des Caches kann recht lange dauern und blockiert den aktuellen Thread
        [self performSelectorInBackground:@selector(setCacheAgeLimit) withObject:nil];
    }
    
    return self;
}

- (void) loadTileAtPath:(MKTileOverlayPath)path result:(void (^)(NSData *, NSError *))result
{
    //NSLog(@"--- tile %@ ---", [self keyStringForPath:path]);
    
    NSData *data = [self.cache objectForKey:[self keyStringForPath:path]];
    if (data)
    {
        result(data, nil);
    }
    else
    {
        [self loadFileForPath: path result:result];
    }
}

- (void) setCacheAgeLimit
{
    self.cache.ageLimit = [MSMUtils cacheDurationInSeconds];
}

- (void) loadFileForPath: (MKTileOverlayPath) path result:(void (^)(NSData *, NSError *))result
{
    WEAK_SELF(weakSelf);
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithURL: [self URLForTilePath:path]
                                                             completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSInteger statusCode = [response isKindOfClass: [NSHTTPURLResponse class]] ? [(NSHTTPURLResponse *)response statusCode] : 0;

        if (statusCode == 200 && data != nil)
        {
            [weakSelf.cache setObject:data forKey:[weakSelf keyStringForPath:path]];
            result(data, nil);
        }
        else
        {
            // leere Kachel statt Fehlerbild, MapKit zeigt dann einfach nichts an
            result(nil, error ?: [NSError errorWithDomain: NSURLErrorDomain code: NSURLErrorBadServerResponse userInfo: nil]);
        }
    }];
    [task resume];
}

- (NSString *) keyStringForPath: (MKTileOverlayPath) path
{
    return [NSString stringWithFormat:@"%ld_%ld_%ld", (long)path.x, (long)path.y, (long)path.z];
}


@end
