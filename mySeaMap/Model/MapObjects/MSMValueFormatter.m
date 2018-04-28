//
//  MSMValueFormatter.m
//  mySeaMap
//
//  Created by Frank Budszuhn on 21.03.14.
//  Copyright (c) 2014 Frank Budszuhn. See LICENSE.
//

#import "MSMValueFormatter.h"
#import "MSMMetricsFormatter.h"
#import "MSMTimesFormatter.m"
#import "MSMInfoGroup.h"

@implementation MSMValueFormatter

+ (MSMValueFormatter *) formatterForInfoGroupWithName: (NSString *) infoGroupName
{
    NSDictionary *classLookup = @{INFO_GROUP_METRICS: [MSMMetricsFormatter class],
                                  INFO_GROUP_TIMES: [MSMTimesFormatter class]};
    
    Class result = [classLookup valueForKey: infoGroupName];
    if (result)
    {
        return [[result alloc] init];
    }
    else
    {
        return nil;
    }

}

// Formatters seem to be very expensive to create
// http://nshipster.com/nsformatter/
+ (NSNumberFormatter *) numberFormatter
{
    static NSNumberFormatter *_numberFormatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _numberFormatter = [[NSNumberFormatter alloc] init];
        [_numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
    });
    
    return _numberFormatter;
}

+ (NSRegularExpression *) numericRegex
{
    static NSRegularExpression *_regex = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _regex = [NSRegularExpression regularExpressionWithPattern:@"^(?:|0|[1-9]\\d*)(?:\\.\\d*)?$" options:NSRegularExpressionAllowCommentsAndWhitespace error:nil];
    });
 
    return _regex;
}

- (NSString *) formatValue: (NSString *) value forKey: (NSString *) key
{
    return value; // sub classes should do something more intelligent
}

- (NSString *) formatNumber: (NSString *) numberString withSuffix: (NSString *) suffix
{
    NSString *result = [[MSMValueFormatter numberFormatter] stringFromNumber:[NSNumber numberWithDouble:[numberString doubleValue]]];
    
    return [result stringByAppendingString: suffix];
}

- (BOOL) isStringNumeric: (NSString *) aString
{
    NSUInteger numberOfMatches = [[MSMValueFormatter numericRegex] numberOfMatchesInString:aString
                                                        options:0
                                                          range:NSMakeRange(0, [aString length])];
    return numberOfMatches == 1;
}

@end
