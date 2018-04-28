//
//  MSMMapObject.m
//  mySeaMap
//
//  Created by Frank Budszuhn on 13.03.14.
//  Copyright (c) 2014 Frank Budszuhn. See LICENSE.
//

#import "MSMMapObject.h"
#import "MSMInfoGroup.h"
#import "MSMHarbour.h"
#import "MSMBridge.h"
#import "MSMLockBasin.h"
#import "MSMBuoyLateral.h"
#import "MSMBuoyCardinal.h"
#import "MSMSmallCraftFacility.h"

@interface MSMMapObject ()


@end

@implementation MSMMapObject

@synthesize infoGroups=_infoGroups;

+ (id) objectForNode: (FBOSMNode *) node;
{
    return [[[self classForSeamarkType:[node.tags valueForKey:@"seamark:type"]] alloc] initWithNode: node];
}

+ (id) objectForWay: (FBOSMWay *) way
{
    return [[[self classForSeamarkType:[way.tags valueForKey:@"seamark:type"]] alloc] initWithWay: way];
}


+ (Class) classForSeamarkType: (NSString *) seamarkType
{
    NSDictionary *classLookup = @{@"harbour": [MSMHarbour class],
                                  @"bridge": [MSMBridge class],
                                  @"lock_basin": [MSMLockBasin class],
                                  @"buoy_lateral": [MSMBuoyLateral class],
                                  @"buoy_cardinal": [MSMBuoyCardinal class],
                                  @"small_craft_facility": [MSMSmallCraftFacility class]};
    
    Class result = [classLookup valueForKey: seamarkType];
    if (result)
    {
        return result;
    }
    else
    {
#ifdef DEBUG
        //[NSException raise:@"unbekannter typ" format:@"Type ist %@", seamarkType];
        NSLog(@"unbekannter typ, Type ist %@", seamarkType);
#endif
        return [MSMMapObject class];
    }
}

#pragma mark - NSCoding

// wird für TMCache gebraucht

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject: _node forKey:@"node"];
    [aCoder encodeObject: _way forKey:@"way"];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self)
    {
        _node = [aDecoder decodeObjectForKey:@"node"];
        _way = [aDecoder decodeObjectForKey:@"way"];
        
        _infoGroups = nil; // werden bei Anfrage neu erzeugt
    }
    
    return self;
}


- (instancetype) initWithNode:(FBOSMNode *)node
{
    self = [super init];
    if (self)
    {
        _node = node;
    }
    
    return self;
}

- (instancetype) initWithWay:(FBOSMWay *) way
{
    self = [super init];
    if (self)
    {
        _way = way;
    }
    
    return self;
}

- (NSString *) seamarkType
{
    return nil; // to be implemented by subclass
}

- (NSDictionary *) tags
{
    if (self.way)
    {
        return self.way.tags;
    }
    else if (self.node)
    {
        return self.node.tags;
    }
    
    return nil;
}



- (NSString *) tagValue: (NSString *) key
{
    return [[self tags] valueForKey: key];
}


- (NSString *) anyTagValueWithKeys: (NSArray *) keys fallback: (NSString *) fallbackValue
{
    for (NSString *aKey in keys)
    {
        NSString *aValue = [[self tags] valueForKey: aKey];
        if (aValue) {
            return aValue;
        }
    }
    
    return fallbackValue;
}

- (NSString *) nauticalDescription
{
    FBGeoLocation *geoLocation = [[FBGeoLocation alloc] init];
    geoLocation.coordinate = self.coordinate;
    return [geoLocation nauticalDescription];
}

- (CGFloat) heightForPopover
{
    CGFloat height = 70.0 + 48.0 * [self.infoGroups count];
    for (MSMInfoGroup *infoGroup in self.infoGroups)
    {
        height += [infoGroup heightForPopover];
    }
    
    return height;
}


// Getter / Setter

- (NSArray *) infoGroups
{
    if (! _infoGroups)
    {
        NSMutableArray *groups = [NSMutableArray array];
        
        // info groups anlegen
        for (NSString *groupName in GENERAL_INFO_GROUPS)
        {
            MSMInfoGroup *group = [MSMInfoGroup groupWithName:groupName andTags: [self tags] andLookupTable:[self lookup]];
            if ([group.keys count] > 0)
            {
                [groups addObject: group];
            }
            
        }

        _infoGroups = [groups copy];
    }
    
    return _infoGroups;
}

- (NSString *) title
{
    NSString *translatedFallbackKey = [NSString stringWithFormat:@"seamark_type_%@", [self seamarkType]];
    return [self anyTagValueWithKeys:[self nameLookup] fallback: NSLocalizedString(translatedFallbackKey, nil)];
}

- (CLLocationCoordinate2D) coordinate
{
    if (self.way)
    {
        return self.way.coordinate;
    }
    else if (self.node)
    {
        return self.node.coordinate;
    }
    else
    {
        return kCLLocationCoordinate2DInvalid;
    }
}

// lookup stuff

- (NSDictionary *) lookup
{
    // die eingebetteten Dicts haben immer nur einen Eintrag, sind also nur Key-Value Paare
    // fb, 4.4.16 - nee, stimmt so nicht mehr
    return @{INFO_GROUP_NAME_AND_DESCRIPTION:
                 @[@{@"name": [self nameLookup]},
                   @{@"description": @[@"description"]}],
             
             INFO_GROUP_CONTACT:
                 @[@{@"website": @[@"website", @"contact:website"]},
                   @{@"email": @[@"email", @"contact:email"]},
                   @{@"vhf": @[@"vhf", @"contact:vhf"]},
                   @{@"phone": @[@"phone", @"contact:phone"]}],
             
             INFO_GROUP_METRICS:
                 @[@{@"maxlength": @[@"maxlength"]},
                   @{@"maxwidth": @[@"maxwidth"]},
                   @{@"maxdraft": @[@"maxdraft", @"draft"]},
                   //@{@"clearance_width": @[@"seamark:bridge:clearance_width"]}, # Kollision mit maxwidth
                   @{@"clearance_height": @[@"seamark:bridge:clearance_height", @"maxheight"]},
                   @{@"clearance_height_safe": @[@"seamark:bridge:clearance_height_safe"]},
                   @{@"clearance_height_closed": @[@"seamark:bridge:clearance_height_closed"]},
                   @{@"clearance_height_open": @[@"seamark:bridge:clearance_height_open"]}],
             
             INFO_GROUP_TIMES:
                 @[@{@"opening_hours": @[@"opening_hours"]},
                   @{@"passage_time": @[@"passage_time"]}]};
}

- (NSArray *) nameLookup
{
    return @[@"seamark:name",@"name"];
}



// debug / log

- (NSString *) description
{
    return self.title;
}

@end
