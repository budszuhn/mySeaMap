//
//  MSMLocationManager.h
//  mySeaMap
//
//  Created by Frank Budszuhn on 20.12.13.
//  Copyright (c) 2013 - 2016 Frank Budszuhn. See LICENSE.
//

@import Foundation;

#import "FBGeoLocation.h"


@interface MSMLocationManager : NSObject <MKAnnotation>

@property (nonatomic, readonly) BOOL available; // haben wir location services?

+ (MSMLocationManager *) manager;

- (FBGeoLocation *) currentLocation;
- (void) setAllowsBackgroundUpdates: (BOOL) on;



@end
