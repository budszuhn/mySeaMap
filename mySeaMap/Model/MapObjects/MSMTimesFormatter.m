//
//  MSMTimesFormatter.m
//  mySeaMap
//
//  Created by Frank Budszuhn on 21.03.14.
//  Copyright (c) 2014 Frank Budszuhn. See LICENSE.
//
//  aus irgend einem komischen Grund ist diese Datei nicht Teil des Targets (Linker Error wg. Duplicate Symbol)

#import "MSMTimesFormatter.h"

@implementation MSMTimesFormatter

- (NSString *) formatValue: (NSString *) value forKey: (NSString *) key
{
    if ([self isStringNumeric: value] && [key isEqualToString:@"passage_time"])
    {
        return [self formatNumber:value withSuffix:@"min"];
    }
    else
    {
        return value;
    }
}


@end
