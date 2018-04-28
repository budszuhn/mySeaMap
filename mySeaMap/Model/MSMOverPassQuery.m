//
//  MSMOverPassQuery.m
//  mySeaMap
//
//  Created by Frank Budszuhn on 02.12.13.
//  Copyright (c) 2013 Frank Budszuhn. See LICENSE.
//

#import <AFNetworking.h>
#import "MSMOverpassServer.h"
#import "MSMOverPassQuery.h"
#import "FBOSMNode.h"
#import "FBOSMWay.h"
#import "MSMMapObject.h"

//#define QUERY   @"[out:json];node['seamark:type'~'buoy_lateral|harbour|bridge|buoy_cardinal|buoy_special_purpose|beacon_special_purpose|beacon_lateral|light_major|light_minor']({{bbox}});out;"
#define QUERY   @"[out:json];(node['seamark:type'~'harbour|lock_basin|bridge']({{bbox}}); way['seamark:type'~'harbour|lock_basin|bridge']({{bbox}});node['seamark:small_craft_facility:category'~'fuel_station|boatyard']({{bbox}}););out;>;out;"

@interface MSMOverPassQuery () <FOQueryDelegate>

@end

@implementation MSMOverPassQuery

- (void) queryMapObjectsForMapRect: (MKMapRect) mapRect
                         success:(void (^)(NSArray *mapObjects))success
{
    CLLocationCoordinate2D nw = MKCoordinateForMapPoint(mapRect.origin);
    CLLocationCoordinate2D se = MKCoordinateForMapPoint(MKMapPointMake(MKMapRectGetMaxX(mapRect), MKMapRectGetMaxY(mapRect)) );
    
    FOBoundingBox bbox = FOBoundingBoxMakeFromCoordinates(nw, se);
    FOQueryManager *qm = [FOQueryManager managerWithServer:[MSMOverpassServer server] queryLanguage:OVQueryLanguageQL delegate:self];
    [qm performQuery: QUERY forBoundingBox:bbox success:^(NSArray *nodes, NSArray *ways, NSArray *relations) {
        
        success([[self mapObjectsForWays:ways] arrayByAddingObjectsFromArray:[self mapObjectsForNodes: nodes]]);
    } failure:^(NSError *error) {
        NSLog(@"Fehler: %@", error);
    }];
}


- (NSArray *) mapObjectsForWays: (NSArray *) ways
{
    NSMutableArray *result = [NSMutableArray arrayWithCapacity: [ways count]];
    for (FBOSMWay *way in ways)
    {
        //NSLog(@"add way - %@", way);
        [result addObject: [MSMMapObject objectForWay: way]];
    }
    
    return [result copy];
}

- (NSArray *) mapObjectsForNodes: (NSArray *) nodes
{
    NSMutableArray *result = [NSMutableArray arrayWithCapacity: [nodes count]];
    for (FBOSMNode *node in nodes)
    {
        if ([node isMapObject])
        {
            //NSLog(@"add node - %@", node);
            [result addObject: [MSMMapObject objectForNode: node]];
        }
    }
    
    return [result copy];
}

#pragma mark - FOQueryDelegate

- (id <OSMNode>) nodeWithOsmId: (NSNumber *) osmId coordinate: (CLLocationCoordinate2D) coordinate tags: (NSDictionary *) tags
{
    return [[FBOSMNode alloc] initWithId:osmId coordinate: coordinate tags: tags];
}

- (id <OSMWay>) wayWithOsmId:(NSNumber *)osmId nodes:(NSArray *)nodes tags:(NSDictionary *)tags
{
    return [[FBOSMWay alloc] initWithId:osmId nodes:nodes tags:tags];
}


@end
