//
//  MSMCache.m
//  mySeaMap
//
//  Created by Frank Budszuhn on 11.03.14.
//  Copyright (c) 2014 Frank Budszuhn. See LICENSE.
//

#import <TMCache/TMCache.h>
#import "MSMCache.h"
#import "MSMUtils.h"
#import "MSMOverPassQuery.h"


#define ZOOM            10
#define MAX_TILE_LOAD   4

@interface MSMCache ()

@property (strong, nonatomic) TMCache *cache;
@property (strong, nonatomic) NSMutableDictionary *requestQueue; // fb, 25.3.14, wir schreiben die Anforderungen nicht mehr in den Cache, sondern extra hier hinein
@property (strong, nonatomic) MSMOverPassQuery *overpassQuery;

@end

@implementation MSMCache

+ (MSMCache *) sharedInstance
{
    static dispatch_once_t once;
    static MSMCache *_sharedInstance;
    dispatch_once(&once, ^ { _sharedInstance = [[self alloc] init]; });
    return _sharedInstance;
}

- (instancetype) init
{
    self = [super init];
    
    if (self)
    {
        _cache = [[TMCache alloc] initWithName: CACHE_OVERPASS];
        _cache.diskCache.ageLimit = [MSMUtils cacheDurationInSeconds]; 
        _overpassQuery = [[MSMOverPassQuery alloc] init];
        _requestQueue = [NSMutableDictionary dictionary];
    }
    
    return self;
}

+ (void) queryMapObjectsForMapRect: (MKMapRect) mapRect
                           success:(void (^)(NSArray *mapObjects))success
{
    [[self sharedInstance] queryMapObjectsForMapRect: mapRect success: success];
}

- (void) queryMapObjectsForMapRect: (MKMapRect) mapRect
                           success:(void (^)(NSArray *mapObjects))success
{
    NSArray *keys = [self keysForMapRect: mapRect];
    
    // TODO: das kann man auch machen, indem man auszählt, wieviele schon im Cache sind
    if ([keys count] > MAX_TILE_LOAD)
    {
        // TODO: oder hier nur die gecacheten zurück geben?
        NSLog(@"#### to many tiles requests at once ####");
        NSLog(@"keys = %@", keys);
        return;
    }
    
    for (NSString *aKey in keys)
    {
        NSArray *result = [self.cache objectForKey: aKey];
        // prüfen, ob es auch wirklich ein Array ist
        if (result)
        {
            success(result);
        }
        else
        {
            // ggf. ist schon ein Timestamp im Cache, d.h. die Anforderung läuft noch
            // an dieser Stelle könnte man einen Timeout implementieren
            NSDate *requestDate = [self.requestQueue valueForKey: aKey];
            if (! requestDate)
            {
                // Timestamp als Platzhalter für die laufende Anforderung in den Cache schreiben
                [self.requestQueue setObject: [NSDate date] forKey: aKey];

                WEAK_SELF(weakSelf);
                [self.overpassQuery queryMapObjectsForMapRect:[self mapRectForKey: aKey] success:^(NSArray *mapObjects) {
                    
                    NSLog(@"-- speichere daten im Cache, abgelaufene Zeit %f, key=%@, Anzahl: %lu", [[NSDate date] timeIntervalSinceDate: [self.requestQueue objectForKey: aKey]], aKey, (unsigned long)[mapObjects count]);
                    [weakSelf.cache setObject: mapObjects forKey: aKey];
                    [weakSelf.requestQueue removeObjectForKey: aKey];
                    success(mapObjects);
                }];
            }
        }
    }
}

- (NSArray *) keysForMapRect: (MKMapRect) mapRect
{
    CLLocationCoordinate2D nw = MKCoordinateForMapPoint(mapRect.origin);
    CLLocationCoordinate2D se = MKCoordinateForMapPoint(MKMapPointMake(MKMapRectGetMaxX(mapRect), MKMapRectGetMaxY(mapRect)) );

    NSMutableArray *result = [NSMutableArray array];
    
    int west = long2tilex(nw.longitude, ZOOM);
    int north = lat2tiley(nw.latitude, ZOOM);
    int east = long2tilex(se.longitude, ZOOM);
    int south = lat2tiley(se.latitude, ZOOM);
    
    for (int x=west; x<=east; x++)
    {
        for (int y=north; y<=south;  y++)
        {
            [result addObject: [self keyStringWithX:x Y:y Z:ZOOM]];
        }
    }
    
    return [result copy];
}


- (NSString *) keyStringWithX: (int) x Y: (int) y Z: (int) z
{
    return [NSString stringWithFormat:@"%d_%d_%d", x, y, z];
}

- (MKMapRect) mapRectForKey: (NSString *) key
{
    NSArray *parts = [key componentsSeparatedByString:@"_"];
    int x = [[parts objectAtIndex:0] intValue];
    int y = [[parts objectAtIndex:1] intValue];
    int z = [[parts objectAtIndex:2] intValue];
    
    CLLocationCoordinate2D nw = CLLocationCoordinate2DMake(tiley2lat(y, z), tilex2long(x, z));
    CLLocationCoordinate2D se = CLLocationCoordinate2DMake(tiley2lat(y+1, z), tilex2long(x+1, z));
    
    MKMapPoint upperLeft = MKMapPointForCoordinate(nw);
    MKMapPoint lowerRight = MKMapPointForCoordinate(se);
    
    MKMapRect mapRect = MKMapRectMake(upperLeft.x,
                                      upperLeft.y,
                                      lowerRight.x - upperLeft.x,
                                      lowerRight.y - upperLeft.y);
    return mapRect;
}


+ (MSMMapObject *) nearestMapObjectToLocation: (CLLocationCoordinate2D) location maxDistance: (CLLocationDistance) maxDistance
{
    return [[self sharedInstance] nearestMapObjectToLocation: location maxDistance: maxDistance];
}

+ (MSMMapObject *) nearestMapObjectToLocation: (CLLocationCoordinate2D)location maxDistance: (CLLocationDistance) maxDistance withSeamarkType: (NSString *) seamarkType;
{
    return [[self sharedInstance] nearestMapObjectToLocation: location maxDistance: maxDistance withSeamarkType: seamarkType];
}


- (MSMMapObject *) nearestMapObjectToLocation: (CLLocationCoordinate2D) location maxDistance: (CLLocationDistance) maxDistance withSeamarkType: (NSString *) seamarkType
{
    // auf welcher Kachel befindet sich die angegebene Location?
    // TODO: später auch Positionen betrachten die an Kachelgrenzen sind
    int x = long2tilex(location.longitude, ZOOM);
    int y = lat2tiley(location.latitude, ZOOM);
    
    NSString *key = [self keyStringWithX:x Y:y Z:ZOOM];
    NSArray *tileEntries = [self.cache objectForKey: key];
    if (tileEntries && [tileEntries isKindOfClass: [NSArray class]]) // könnte auch ein 'Loading Marker' Timestamp sein
    {
        CLLocation *myLoc = [[CLLocation alloc] initWithLatitude:location.latitude longitude:location.longitude];
        CLLocationDistance dist = MAXFLOAT;
        MSMMapObject *result = nil;
        for (MSMMapObject *mapObject in tileEntries)
        {
            CLLocation *l = [[CLLocation alloc] initWithLatitude:mapObject.coordinate.latitude longitude:mapObject.coordinate.longitude];
            CLLocationDistance d = [myLoc distanceFromLocation:l];
            if (d < dist
                    && (seamarkType == nil || [seamarkType isEqualToString:mapObject.seamarkType]))
            {
                dist = d;
                result = mapObject;
            }
        }
        
        //NSLog(@"dist = %f", dist);
        
        return dist < maxDistance ? result : nil;
    }
    else
    {
        return nil;
    }
}

- (MSMMapObject *) nearestMapObjectToLocation: (CLLocationCoordinate2D) location maxDistance: (CLLocationDistance) maxDistance
{
    return [self nearestMapObjectToLocation:location maxDistance: maxDistance withSeamarkType: nil];
}



// guckst Du hier:
// http://wiki.openstreetmap.org/wiki/Slippy_map_tilenames

int long2tilex(double lon, int z)
{
	return (int)(floor((lon + 180.0) / 360.0 * pow(2.0, z)));
}

int lat2tiley(double lat, int z)
{
	return (int)(floor((1.0 - log( tan(lat * M_PI/180.0) + 1.0 / cos(lat * M_PI/180.0)) / M_PI) / 2.0 * pow(2.0, z)));
}

double tilex2long(int x, int z)
{
	return x / pow(2.0, z) * 360.0 - 180;
}

double tiley2lat(int y, int z)
{
	double n = M_PI - 2.0 * M_PI * y / pow(2.0, z);
	return 180.0 / M_PI * atan(0.5 * (exp(n) - exp(-n)));
}

@end
