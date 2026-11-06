//
//  MSMUtils.m
//  mySeaMap
//
//  Created by Frank Budszuhn on 07.11.13.
//  Copyright (c) 2013 - 2016 Frank Budszuhn. See LICENSE.
//

#import "MSMUtils.h"

@implementation MSMUtils


+ (BOOL) isIPad
{
    return [UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad;
}

+ (BOOL) isLargeLayoutForTraitCollection: (UITraitCollection *) traitCollection
{
    return traitCollection.horizontalSizeClass == UIUserInterfaceSizeClassRegular
        && traitCollection.verticalSizeClass == UIUserInterfaceSizeClassRegular;
}

+ (BOOL) isIPhone
{
    return [UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone;
}

+ (BOOL) isRetina
{
    return [UITraitCollection currentTraitCollection].displayScale >= 2.0;
}

// helper für user defaults

+ (BOOL) userDefaultForKey:(NSString *)key
{
    return [self userDefaultForKey: key withDefault: YES];
}

+ (BOOL) userDefaultForKey: (NSString *) key withDefault: (BOOL) aDefault
{
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    if ([def objectForKey:key])
    {
        return [def boolForKey: key];
    }
    else
    {
        return aDefault;
    }
}

// Blanks aus einer Telefonnummer entfernen, damit sie 'anrufbar' wird
+ (NSString *) preparePhoneNumber: (NSString *) phoneNumber
{
    return [[phoneNumber componentsSeparatedByCharactersInSet :[NSCharacterSet whitespaceCharacterSet]] componentsJoinedByString:@""];
}

+ (MSMCacheDuration) cacheDuration
{
    NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
    if ([defs objectForKey: USER_DEFAULTS_CACHE_DURATION] == nil)
    {
        return MSMCacheDurationOneMonth;
    }
    else
    {
        return [defs integerForKey: USER_DEFAULTS_CACHE_DURATION];
    }
}

+ (NSTimeInterval) cacheDurationInSeconds
{
    MSMCacheDuration duration = [MSMUtils cacheDuration];
    if (duration == MSMCacheDurationOneWeek)
    {
        return 604800.0;
    }
    else if (duration == MSMCacheDurationOneMonth)
    {
        return 2592000.0;
    }
    else
    {
        return 0.0;
    }
}

+ (NSString *) userFriendlyDate: (NSDate *) aDate
{
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setTimeStyle: NSDateFormatterNoStyle];
    [df setDateStyle: NSDateFormatterMediumStyle];
    
    return [df stringFromDate: aDate];
}

+ (NSString *) userFriendlyTimeInterval: (NSTimeInterval) interval
{
    NSUInteger seconds = (NSUInteger)round(interval);
    return [NSString stringWithFormat:@"%02lu:%02lu:%02lu", (unsigned long)(seconds / 3600), (unsigned long)((seconds / 60) % 60), (unsigned long)(seconds % 60)];
}

+ (NSDateFormatter *) iso8601Formatter
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSLocale *enUSPOSIXLocale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
    [dateFormatter setLocale:enUSPOSIXLocale];
    [dateFormatter setTimeZone: [NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZZZ"];

    return dateFormatter;
}

@end
