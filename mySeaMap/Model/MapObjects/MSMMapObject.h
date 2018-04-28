//
//  MSMMapObject.h
//  mySeaMap
//
//  Created by Frank Budszuhn on 13.03.14.
//  Copyright (c) 2014 Frank Budszuhn. See LICENSE.
//

@import Foundation;

#import "FBOSMNode.h"
#import "FBOSMWay.h"
#import "FBGeoLocation.h"

@interface MSMMapObject : NSObject <NSCoding>

@property (strong, nonatomic) FBOSMNode *node;
@property (strong, nonatomic) FBOSMWay *way;
@property (strong, readonly, nonatomic) NSArray *infoGroups;


+ (id) objectForNode: (FBOSMNode *) node;
+ (id) objectForWay: (FBOSMWay *) way;

- (instancetype) initWithNode: (FBOSMNode *) node;
- (instancetype) initWithWay: (FBOSMWay *) way;

- (NSString *) seamarkType; // OSM: seamark:type
- (NSDictionary *) tags;
- (NSString *) tagValue: (NSString *) key;
- (NSString *) anyTagValueWithKeys: (NSArray *) keys fallback: (NSString *) fallbackValue;
- (NSString *) nauticalDescription;
- (CGFloat) heightForPopover;
- (NSDictionary *) lookup;


@property (nonatomic, readonly) NSString *title;
@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;

@end
