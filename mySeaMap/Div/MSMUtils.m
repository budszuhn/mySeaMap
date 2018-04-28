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
    return UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad;
}

+ (BOOL) isIPhone
{
    return UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone;
}

+ (BOOL) isRetina
{
    return [UIScreen mainScreen].scale == 2.0;
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
    return [NSString stringWithFormat:@"%02u:%02u:%02u", seconds / 3600, (seconds / 60) % 60, seconds % 60];
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

/*
 * Diese Methode ist für die Behandlung des Elends mit MKMapView -> setCenterCoordinate
 * Leider wird je nach iOS-Version und Sichtbarkeit der StatusBar die Karte verschieden 'ge-centered'
 * Dazu kommt das weitere Elend mit der "In-CAll-Erhöhung" der StatusBar (einkommender Anruf oder andere Vergrößerung der Status-Bar). Dafür brauchen wir den Parameter isForRead
 * denn setCenterCoordinate und die Methode convertToPoint gehen in diesem Fall scheinbar von unterschiedlichen Bedingungen aus
 *
 */
+ (CGFloat) statusBarOffsetForRead: (BOOL) isForRead;
{
    CGFloat statusBarHeight = [UIApplication sharedApplication].statusBarFrame.size.height;
    BOOL os9 = [[UIDevice currentDevice].systemVersion floatValue] < 10.0;
    BOOL isInCall = statusBarHeight > 20.0;
    
    if (os9) {
        if (isInCall && isForRead) {
            return 30.0;
        }
        else {
            return 10.0;
        }
    }
    else { // ab iOS 10
        if (isForRead) {
            if (isInCall) {
                return 30.0;
            }
            else {
                return statusBarHeight / 2.0;
            }
        }
        else if (statusBarHeight > 0.0) {
            return 10.0;
        }
        else {
            return 0.0;
        }
    }
}

@end
