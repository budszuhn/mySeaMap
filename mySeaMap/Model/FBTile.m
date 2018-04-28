//
//  FBTile.m
//  MapEditor
//
//  Created by Frank Budszuhn on 13.12.13.
//  Copyright (c) 2013 Frank Budszuhn. See LICENSE.
//

#import "FBTile.h"

@implementation FBTile

- (NSString *) description
{
    return [NSString stringWithFormat:@"x=%ld, y=%ld, z=%ld", (long)_x, (long)_y, (long)_z];
}

// zur JSON-Serialisierung
- (NSDictionary *) dict
{
    return @{@"x": [NSNumber numberWithInteger:_x], @"y": [NSNumber numberWithInteger:_y], @"z": [NSNumber numberWithInteger:_z]};
}

@end
