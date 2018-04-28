//
//  FBGeoValue.h
//  mySeaMap
//
//  Created by Frank Budszuhn on 08.11.13.
//  Copyright (c) 2013 Frank Budszuhn. See LICENSE.
//

@import Foundation;
@import CoreLocation;

@interface FBGeoValue : NSObject

@property (nonatomic) CLLocationDegrees locationDegrees;

@property (nonatomic, readonly) NSInteger sign;
@property (nonatomic, readonly) NSInteger degrees;
@property (nonatomic, readonly) double minutes;

@end
