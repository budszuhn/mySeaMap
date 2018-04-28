//
//  MSMGeoUtils.h
//  mySeaMap
//
//  Created by Frank Budszuhn on 11.11.13.
//  Copyright (c) 2013 - 2016 Frank Budszuhn. See LICENSE.
//

#import <Foundation/Foundation.h>

@interface MSMGeoUtils : NSObject

+ (double) scaleWidthForMapWidth: (double) mapWidth inOrientation: (UIInterfaceOrientation) orientation;
+ (float) getHeadingForDirectionFromCoordinate:(CLLocationCoordinate2D)fromLoc toCoordinate:(CLLocationCoordinate2D)toLoc; // FIXME: methodenname, float

+ (CLLocationDistance) distanceFrom: (CLLocationCoordinate2D) fromLocation to: (CLLocationCoordinate2D) toLocation;

+ (CLLocationCoordinate2D) destinationForStart: (CLLocationCoordinate2D) start distance: (CLLocationDistance) distance bearing: (CLLocationDirection) bearing;
+ (void) reverseGeocodeLocation: (CLLocationCoordinate2D) location
                        success: (void (^)(NSString *locationDescription))success
                        failure: (void (^)(NSError *error)) failure;
@end
