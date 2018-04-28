//
//  FBGeoRegion.h
//  mySeaMap
//
//  Created by Frank Budszuhn on 19.12.13.
//  Copyright (c) 2013 Frank Budszuhn. See LICENSE.
//

#import <Foundation/Foundation.h>

@interface FBGeoRegion : NSObject

@property(nonatomic) CLLocationCoordinate2D northEast;
@property(nonatomic) CLLocationCoordinate2D southWest;

+ (instancetype) withNorth: (CLLocationDegrees) north east: (CLLocationDegrees) east south: (CLLocationDegrees) south west: (CLLocationDegrees) west;

- (MKCoordinateRegion) region;

@end
