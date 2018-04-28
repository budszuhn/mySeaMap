//
//  MSMLockBasin.m
//  mySeaMap
//
//  Created by Frank Budszuhn on 18.03.14.
//  Copyright (c) 2014 Frank Budszuhn. See LICENSE.
//

#import "MSMLockBasin.h"
#import "MSMInfoGroup.h"

@implementation MSMLockBasin

- (NSString *) seamarkType
{
    return @"lock_basin";
}

// das ist erst mal optional
- (NSString *) s100
{
    return @"LOKBSN";
}

- (NSArray *) nameLookup
{
    return @[@"seamark:name",@"lock_name",@"name"];
}

@end
