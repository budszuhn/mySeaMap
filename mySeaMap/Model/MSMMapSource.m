//
//  MSMMapSource.m
//  mySeaMap
//
//  Created by Frank Budszuhn on 03.06.14.
//  Copyright (c) 2014 Frank Budszuhn. See LICENSE.
//

#import "MSMMapSource.h"


#define TILE_SERVER_MAPNIK                  @"http://a.tile.openstreetmap.org/{z}/{x}/{y}.png"
#define TILE_SERVER_SEAMARKS                @"http://t1.openseamap.org/seamark/{z}/{x}/{y}.png"


@implementation MSMMapSource

@synthesize cache = _cache;

+ (NSArray *) mapSources
{
    static NSMutableArray *sources = nil;
    if (! sources)
    {
        sources = [NSMutableArray array];
        [sources addObjectsFromArray: [MSMMapSource appleSources]];     // Straßenkarte, Saltellit, Hybrid
        [sources addObjectsFromArray: [MSMMapSource defaultSources]];  // MapQuest & Mapnik
        
        
        NSString *filePath = [[NSBundle mainBundle] pathForResource: @"mapsources" ofType:@"json"];
        NSData *data = [NSData dataWithContentsOfFile:filePath];
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
                
        for (NSDictionary *aSource in [json valueForKey:@"mapsources"])
        {
            [sources addObject: [[MSMMapSource alloc] initWithDictionary: aSource]];
        }
    }
    
    return sources;
}


+ (NSArray *) baseMapSources
{
    // FIXME: xxx
    return nil;
}

+ (NSArray *) overlaySources
{
    // FIXME: xxx
    return nil;
}


+ (NSArray *) cachableMapSources
{
    return [[MSMMapSource mapSources] filteredArrayUsingPredicate: [NSPredicate predicateWithFormat:@"type <> %d", MSMMapSourceTypeApple]];
}

+ (NSArray *) cachableBasemapSources
{
    return [[MSMMapSource mapSources] filteredArrayUsingPredicate: [NSPredicate predicateWithFormat:@"type == %d OR type == %d", MSMMapSourceTypeBackground, MSMMapSourceTypeStandalone]];
}

+ (MSMMapSource *) mapSourceFromUserDefaults
{
    NSString *key = [[NSUserDefaults standardUserDefaults] valueForKey: USER_DEFAULTS_MAP_SOURCE];
    return [MSMMapSource withKey: key];
}

// gibt die MapSource mit diesem Key zurück. Falls der key nicht gefunden wird, dann die erste MapSource, also normalerweise die Apple Straßenkarte
+ (MSMMapSource *) withKey: (NSString *) key
{
    NSArray *mapSources = [MSMMapSource mapSources];
    
    NSUInteger idx = [mapSources indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        MSMMapSource *aMapSource = obj;
        if ([aMapSource.key isEqualToString: key])
        {
            *stop = YES;
            return YES;
        }
        else
        {
            return NO;
        }
    }];
    
    if (idx == NSNotFound)
    {
        return [mapSources firstObject];
    }
    else
    {
        return [mapSources objectAtIndex: idx];
    }
}

+ (MSMMapSource *) seamarks
{
    static dispatch_once_t once;
    static MSMMapSource *seamarksSource;
    
    dispatch_once(&once, ^ { seamarksSource = [[MSMMapSource alloc] initWithName:@"Seamarks" key:CACHE_SEAMARKS type:MSMMapSourceTypeOverlay flipped:NO url:TILE_SERVER_SEAMARKS]; });

    return seamarksSource;
}



+ (MSMMapSourceType) typeWithString: (NSString *) typeString
{
    if ([typeString isEqualToString:@"standalone"])
    {
        return MSMMapSourceTypeStandalone;
    }
    else if ([typeString isEqualToString:@"overlay"])
    {
        return MSMMapSourceTypeOverlay;
    }
    else
    {
        return MSMMapSourceTypeBackground;
    }
}


+ (NSArray *) appleSources
{
    return @[[[MSMMapSource alloc] initWithName:NSLocalizedString(@"MAP_TYPE_MAP", nil) key:@"apple-standard" type:MSMMapSourceTypeApple flipped:NO url:nil],
             [[MSMMapSource alloc] initWithName:NSLocalizedString(@"MAP_TYPE_SATELLITE", nil) key:@"apple-satellite" type:MSMMapSourceTypeApple flipped:NO url:nil],
             [[MSMMapSource alloc] initWithName:NSLocalizedString(@"MAP_TYPE_HYBRID", nil) key:@"apple-hybrid" type:MSMMapSourceTypeApple flipped:NO url:nil]];
}

+ (NSArray *) defaultSources
{
    return @[[[MSMMapSource alloc] initWithName:@"OpenSeaMap" key:@"mapnik" type:MSMMapSourceTypeBackground flipped:NO url:TILE_SERVER_MAPNIK]];
}

- (instancetype) initWithName: (NSString *) name key: (NSString *) key type: (MSMMapSourceType) type flipped: (BOOL) isFlipped url: (NSString *) url
{
    self = [super init];
    if (self)
    {
        _name = name;
        _key = key;
        _type = type;
        _url = url;
        _flipped = isFlipped;
    }
    
    return self;
}


- (instancetype) initWithDictionary: (NSDictionary *) dict
{
    self = [super init];
    if (self)
    {
        _key = [dict valueForKey: @"key"];
        _name = [dict valueForKey: @"name"];
        _url = [dict valueForKey:@"url"];
        _type = [MSMMapSource typeWithString:[dict valueForKey:@"type"]];
        _flipped = [[dict valueForKey:@"flipped"] boolValue];
    }
    return self;
}


- (MKMapType) appleMapType
{
    if (self.type == MSMMapSourceTypeApple)
    {
        if ([self.key isEqualToString:@"apple-satellite"])
        {
            return MKMapTypeSatellite;
        }
        else if ([self.key isEqualToString:@"apple-hybrid"])
        {
            return MKMapTypeHybrid;
        }
    }

    return MKMapTypeStandard; // unsere Overlays immer auf hellem Hintergrund
}

- (UIColor *) controllsDrawColour
{
    if ([self appleMapType] == MKMapTypeStandard)
    {
        return [UIColor darkGrayColor];
    }
    else
    {
        return [UIColor whiteColor];
    }
}

- (void) saveAsUserDefault
{
    NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
    
    [defs setObject: self.key forKey:USER_DEFAULTS_MAP_SOURCE];
    [defs synchronize];
}


- (TMCache *) cache
{
    if (! _cache)
    {
        _cache = [[TMCache alloc] initWithName: self.key];
    }
    
    return _cache;
}

@end
