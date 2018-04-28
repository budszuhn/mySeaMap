//
//  MSMMetricsFormatter.m
//  mySeaMap
//
//  Created by Frank Budszuhn on 21.03.14.
//  Copyright (c) 2014 Frank Budszuhn. See LICENSE.
//

#import "MSMMetricsFormatter.h"

@implementation MSMMetricsFormatter

- (NSString *) formatValue: (NSString *) value forKey: (NSString *) key
{
    if ([self isStringNumeric: value])
    {
        return [self formatNumber:value withSuffix:@"m"];
    }
    else
    {
        return value;
    }
}

@end
