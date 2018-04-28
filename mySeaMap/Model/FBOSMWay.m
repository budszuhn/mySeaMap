//
//  FBOSMWay.m
//  mySeaMap
//
//  Created by Frank Budszuhn on 14.03.14.
//  Copyright (c) 2014 Frank Budszuhn. See LICENSE.
//

#import "FBOSMWay.h"
#import "FBOSMNode.h"

@implementation FBOSMWay

@synthesize osmId=_osmId, nodes=_nodes, tags=_tags, coordinate=_coordinate;

- (instancetype) initWithId: (NSNumber *) osmId nodes: (NSArray *) nodes tags: (NSDictionary *) tags
{
    self = [super init];
    
    if (self)
    {
        _osmId = osmId;
        _nodes = nodes;
        _tags = tags;
        _coordinate = kCLLocationCoordinate2DInvalid; // lazy eval
    }
    
    return self;
}


#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:_osmId forKey:@"osmId"];
    [aCoder encodeObject:_tags forKey:@"tags"];
    [aCoder encodeObject:_nodes forKey:@"nodes"];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self)
    {
        _osmId = [aDecoder decodeObjectForKey:@"osmId"];
        _tags = [aDecoder decodeObjectForKey:@"tags"];
        _nodes = [aDecoder decodeObjectForKey:@"nodes"];
        _coordinate = kCLLocationCoordinate2DInvalid; // lazy eval
    }
    
    return self;
}



- (CLLocationCoordinate2D) coordinate
{
    if (! CLLocationCoordinate2DIsValid(_coordinate))
    {
        _coordinate = [self calcCoordinate];
    }
    
    return _coordinate;
}

- (CLLocationCoordinate2D) calcCoordinate
{
    FBOSMNode *node = [self.nodes firstObject];
    if ([self.nodes count] == 1)
    {
        return node.coordinate;
    }
    else
    {
        // FIXME: Wrap über die Datumslinie !!!!
        CLLocationDegrees minLat = node.coordinate.latitude;
        CLLocationDegrees maxLat = minLat;
        CLLocationDegrees minLon = node.coordinate.longitude;
        CLLocationDegrees maxLon = minLon;
        
        for (FBOSMNode *aNode in self.nodes)
        {
            CLLocationCoordinate2D cord = aNode.coordinate;
            if (cord.latitude < minLat)
            {
                minLat = cord.latitude;
            }
            if (cord.latitude > maxLat)
            {
                maxLat = cord.latitude;
            }
            if (cord.longitude < minLon)
            {
                minLon = cord.longitude;
            }
            if (cord.longitude > maxLon)
            {
                maxLon = cord.longitude;
            }
        }
        
        CLLocationCoordinate2D center;
        center.latitude = ((maxLat - minLat) / 2.0 + minLat);
        center.longitude = ((maxLon - minLon) / 2.0 + minLon);
        
        return center;
    }
}

@end
