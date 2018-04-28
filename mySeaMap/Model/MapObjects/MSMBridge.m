//
//  MSMBridge.m
//  mySeaMap
//
//  Created by Frank Budszuhn on 13.03.14.
//  Copyright (c) 2014 Frank Budszuhn. See LICENSE.
//

#import "MSMBridge.h"

@implementation MSMBridge

- (NSString *) seamarkType
{
    return @"bridge";
}

// das ist erst mal optional
- (NSString *) s100
{
    return @"BRIDGE";
}

- (NSArray *) nameLookup
{
    return @[@"seamark:name",@"obstacle_name",@"name"];
}


// Durchfahrtshöhe
- (NSString *) clearance
{
    // öffnende Brücken
    NSString *clearanceClosed = [self tagValue:@"seamark:bridge:clearance_height_closed"];
    NSString *clearanceOpen = [self tagValue:@"seamark:bridge:clearance_height_open"];
    if (clearanceClosed)
    {
        if (clearanceOpen)
        {
            return [[NSString stringWithFormat:@"%@m/%@m", clearanceClosed, clearanceOpen] stringByReplacingOccurrencesOfString:@"." withString:@","];
        }
        else
        {
            return [[NSString stringWithFormat:@"%@m/-", clearanceClosed] stringByReplacingOccurrencesOfString:@"." withString:@","];
        }
    }
    else
    {
        NSString *clearance = [[self tags] valueForKey: @"seamark:bridge:clearance_height"];
        if (clearance)
        {
            return [[NSString stringWithFormat:@"%@m", clearance] stringByReplacingOccurrencesOfString:@"." withString:@","];
        }
        else
        {
            return nil;
        }
    }
}

@end
