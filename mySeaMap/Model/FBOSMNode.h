//
//  FBOSMNode.h
//  mySeaMap
//
//  Created by Frank Budszuhn on 03.12.13.
//  Copyright (c) 2013 Frank Budszuhn. See LICENSE.
//

#import <Foundation/Foundation.h>
#import "FOFlyover.h"

@interface FBOSMNode : NSObject <OSMNode, NSCoding>

@property (nonatomic, readonly) NSString *title;

- (BOOL) isMapObject;
- (NSDictionary *) filteredData;

@end
