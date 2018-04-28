//
//  FBOSMWay.h
//  mySeaMap
//
//  Created by Frank Budszuhn on 14.03.14.
//  Copyright (c) 2014 Frank Budszuhn. See LICENSE.
//

#import <Foundation/Foundation.h>
#import "FOFlyover.h"

@interface FBOSMWay : NSObject <OSMWay, NSCoding>

@property (nonatomic, readonly) CLLocationCoordinate2D coordinate; // berechnet als Mittelpunkt der Fläche

@end
