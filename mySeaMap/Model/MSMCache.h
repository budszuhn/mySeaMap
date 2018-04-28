//
//  MSMCache.h
//  mySeaMap
//
//  Created by Frank Budszuhn on 11.03.14.
//  Copyright (c) 2014 Frank Budszuhn. See LICENSE.
//
//  ein Cache-Key ist so aufgebaut: 243_295_10  (x_y_z)

#import <Foundation/Foundation.h>
#import "FBOSMNode.h"
#import "MSMMapObject.h"

@interface MSMCache : NSObject


+ (void) queryMapObjectsForMapRect: (MKMapRect) mapRect
                           success:(void (^)(NSArray *mapObjects))success;

+ (MSMMapObject *) nearestMapObjectToLocation: (CLLocationCoordinate2D) location maxDistance: (CLLocationDistance) maxDistance;
+ (MSMMapObject *) nearestMapObjectToLocation: (CLLocationCoordinate2D)location maxDistance: (CLLocationDistance) maxDistance withSeamarkType: (NSString *) seamarkType;

@end
