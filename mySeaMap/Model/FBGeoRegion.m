//
//  FBGeoRegion.m
//  mySeaMap
//
//  Created by Frank Budszuhn on 19.12.13.
//  Copyright (c) 2013 Frank Budszuhn. See LICENSE.
//

#import "FBGeoRegion.h"

@implementation FBGeoRegion

+ (instancetype) withNorth: (CLLocationDegrees) north east: (CLLocationDegrees) east south: (CLLocationDegrees) south west: (CLLocationDegrees) west
{
    FBGeoRegion *result = [[FBGeoRegion alloc] init];
    
    result.northEast = CLLocationCoordinate2DMake(north, east);
    result.southWest = CLLocationCoordinate2DMake(south, west);
    
    return result;
}

- (MKCoordinateRegion) region
{    
    CLLocationCoordinate2D center = CLLocationCoordinate2DMake(_southWest.latitude + (_northEast.latitude - _southWest.latitude) / 2.0, _southWest.longitude + (_northEast.longitude - _southWest.longitude) / 2.0);
    MKCoordinateSpan span = MKCoordinateSpanMake(_northEast.latitude - _southWest.latitude, _northEast.longitude - _southWest.longitude);
    MKCoordinateRegion region = MKCoordinateRegionMake(center, span);
    
    return region;
}


- (NSString *) description
{
    return [NSString stringWithFormat:@"FBGeoRegion, north: %f, east: %f, south: %f, west %f", _northEast.latitude, _northEast.longitude, _southWest.latitude, _southWest.longitude];
}

@end
