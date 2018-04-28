//
//  MSMNavigationalObject.h
//  mySeaMap
//
//  Created by Frank Budszuhn on 14.03.14.
//  Copyright (c) 2014 Frank Budszuhn. See LICENSE.
//
//  Ein NavigationalObject fasst bestimmte Objekte zusammen, die zur Navigation dienen, z.B. Tonnen, Lichter, Beacons...

#import "MSMMapObject.h"

@interface MSMNavigationalObject : MSMMapObject

- (NSString *) lightShortString;

@end
