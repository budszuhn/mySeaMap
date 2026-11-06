//
//  MSMUtils.h
//  mySeaMap
//
//  Created by Frank Budszuhn on 07.11.13.
//  Copyright (c) 2013 - 2016 Frank Budszuhn. See LICENSE.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface MSMUtils : NSObject

+ (BOOL) isIPad;
+ (BOOL) isIPhone;
+ (BOOL) isRetina;

/// YES, wenn viel Platz da ist (Größenklasse "regular" in beiden Richtungen):
/// iPad sowie der Innenbildschirm des aufgeklappten iPhone Duo.
/// Bitte statt isIPad verwenden - das Gerät allein sagt nichts mehr über die Bildschirmgröße.
+ (BOOL) isLargeLayoutForTraitCollection: (UITraitCollection *) traitCollection;
+ (BOOL) userDefaultForKey: (NSString *) key; // defaults to YES
+ (BOOL) userDefaultForKey: (NSString *) key withDefault: (BOOL) aDefault;
+ (NSString *) preparePhoneNumber: (NSString *) phoneNumber; // Blanks aus einer Telefonnummer entfernen, damit sie 'anrufbar' wird
+ (MSMCacheDuration) cacheDuration;
+ (NSTimeInterval) cacheDurationInSeconds;

+ (NSString *) userFriendlyDate: (NSDate *) aDate;
+ (NSString *) userFriendlyTimeInterval: (NSTimeInterval) interval;
+ (NSDateFormatter *) iso8601Formatter;


@end
