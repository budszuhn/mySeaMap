//
//  MSMOverPassQuery.h
//  mySeaMap
//
//  Created by Frank Budszuhn on 02.12.13.
//  Copyright (c) 2013 Frank Budszuhn. See LICENSE.
//

#import <Foundation/Foundation.h>

@interface MSMOverPassQuery : NSObject

- (void) queryMapObjectsForMapRect: (MKMapRect) mapRect
                         success:(void (^)(NSArray *mapObjects))success;

@end
