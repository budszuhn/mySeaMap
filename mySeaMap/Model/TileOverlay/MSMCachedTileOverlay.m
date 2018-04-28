//
//  MSMCachedTileOverlay.m
//  mySeaMap
//
//  Created by Frank Budszuhn on 22.03.14.
//  Copyright (c) 2014 Frank Budszuhn. See LICENSE.
//

#import <TMCache/TMCache.h>
#import "MSMUtils.h"
#import "MSMCachedTileOverlay.h"

@interface MSMCachedTileOverlay ()

@property (strong, nonatomic) TMCache *cache;

@end

@implementation MSMCachedTileOverlay

- (instancetype) initWithURLTemplate:(NSString *)URLTemplate andCacheName: (NSString *) cacheName
{
    self = [super initWithURLTemplate:URLTemplate];
    if (self)
    {        
        _cache = [[TMCache alloc] initWithName: cacheName];
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
    self.cache.diskCache.ageLimit = [MSMUtils cacheDurationInSeconds];
}

- (void) loadFileForPath: (MKTileOverlayPath) path result:(void (^)(NSData *, NSError *))result
{
    // fb, 26.3.2014, lokale Variable für request entfernt (Pointer auf Stack). Mal sehen ob das hilft, den Msg-Send Bug zu fixen!
    // fb, 28.3.2014, nope, Fehler ist immer noch da. Fehler hat irgendetwas mit Tiles zu tun, NSData???
    WEAK_SELF(weakSelf);
    [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:[self URLForTilePath:path]]
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               /*
                               if (error)
                               {
                                   NSLog(@"#### error --- %@", error);
                               }*/
                               
                               if ([(NSHTTPURLResponse*)response statusCode] == 200)
                               {
                                   [weakSelf.cache setObject:data forKey:[weakSelf keyStringForPath:path]];
                               }
                               
                               result(data, error);
                           }];
}

- (NSString *) keyStringForPath: (MKTileOverlayPath) path
{
    return [NSString stringWithFormat:@"%ld_%ld_%ld", (long)path.x, (long)path.y, (long)path.z];
}


@end
