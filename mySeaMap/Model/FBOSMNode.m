//
//  FBOSMNode.m
//  mySeaMap
//
//  Created by Frank Budszuhn on 03.12.13.
//  Copyright (c) 2013 Frank Budszuhn. See LICENSE.
//

#import "FBOSMNode.h"

@implementation FBOSMNode

@synthesize tags=_tags, coordinate=_coordinate, osmId=_osmId;

- (instancetype) initWithId: (NSNumber *) osmId coordinate: (CLLocationCoordinate2D) coordinate tags: (NSDictionary *) tags
{
    self = [super init];
    
    if (self)
    {
        _coordinate = coordinate;
        _osmId = osmId;
        _tags = tags;
    }
    
    return self;
}

#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeDouble:_coordinate.latitude forKey:@"latitude"];
    [aCoder encodeDouble:_coordinate.longitude forKey:@"longitude"];
    [aCoder encodeObject:_osmId forKey:@"osmId"];
    [aCoder encodeObject:_tags forKey:@"tags"];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self)
    {
        _coordinate.latitude = [aDecoder decodeDoubleForKey:@"latitude"];
        _coordinate.longitude = [aDecoder decodeDoubleForKey:@"longitude"];
        _osmId = [aDecoder decodeObjectForKey:@"osmId"];
        _tags = [aDecoder decodeObjectForKey:@"tags"];
    }
    
    return self;
}


// repräsentiert dieser Knoten ein eigenständiges Kartenobjekt?
- (BOOL) isMapObject
{
    return self.tags && [self.tags valueForKey:@"seamark:type"];
}


// zum Anzeigen sollen bestimmte Daten herausgefiltert werden
- (NSDictionary *) filteredData
{
    //NSArray *keysToFilter = @[@"seamark:type",@"seamark:harbour:category"]; FIXME:
    NSArray *keysToFilter = @[];
    
    NSArray *keys = [self.tags allKeys];
    NSMutableDictionary *result = [NSMutableDictionary dictionary];
    
    for (NSString *key in keys)
    {
        if (! [keysToFilter containsObject: key])
            [result setObject:[self.tags objectForKey:key] forKey:key];
    }
    
    return [NSDictionary dictionaryWithDictionary: result];
}



// schau mal hier:
// http://nshipster.com/equality/
- (BOOL) isEqualToNode: (FBOSMNode *) anotherNode
{
    if (!anotherNode) {
        return NO;
    }

    return [self.osmId isEqualToNumber: anotherNode.osmId];
}

 - (BOOL) isEqual:(id)object
 {
     if (self == object) {
         return YES;
     }
     
     if (![object isKindOfClass:[FBOSMNode class]]) {
         return NO;
     }
     
     return [self isEqualToNode:(FBOSMNode *) object];
 }

- (NSUInteger)hash
{
    return [self.osmId hash];
}

- (NSString *) description
{
    return _tags ? [_tags description] : [_osmId stringValue];
}

// accessors

- (NSString *) title
{
    if ([self.tags valueForKey:@"seamark:name"])
        return [self.tags valueForKey:@"seamark:name"];
    else if ([self.tags valueForKey:@"name"])
        return [self.tags valueForKey:@"name"];
    else if ([self.tags valueForKey:@"seamark:type"])
        return [self.tags valueForKey:@"seamark:type"];
    else
        return nil;
}

@end
