//
//  MSMMapSource.h
//  mySeaMap
//
//  Created by Frank Budszuhn on 03.06.14.
//  Copyright (c) 2014 Frank Budszuhn. See LICENSE.
//
//  TODO: die Zoomstufen sollten dann irgendwann auch mal hierein übernommen werden

#import <Foundation/Foundation.h>
#import "TMCache.h"

@import MapKit;

typedef NS_ENUM(NSInteger, MSMMapSourceType) {
    MSMMapSourceTypeApple,
    MSMMapSourceTypeBackground,
    MSMMapSourceTypeOverlay,
    MSMMapSourceTypeStandalone
};


@interface MSMMapSource : NSObject

@property (nonatomic, strong, readonly) NSString *name;
@property (nonatomic, strong, readonly) NSString *key;
@property (nonatomic, strong, readonly) NSString *url;
@property (nonatomic, readonly) BOOL flipped;
@property (nonatomic, readonly) MSMMapSourceType type;

@property (nonatomic, strong, readonly) TMCache *cache;

+ (NSArray *) mapSources;
+ (NSArray *) cachableMapSources;
+ (NSArray *) cachableBasemapSources;

+ (NSArray *) baseMapSources; // Apple, Standalone & background
+ (NSArray *) overlaySources; // Seamarks, Sports ...
+ (MSMMapSource *) mapSourceFromUserDefaults;
+ (MSMMapSource *) seamarks; // gibt die MapSource für den OpenSeaMap-Seamarks-Layer zurück

- (MKMapType) appleMapType;          // auch unsere Basiskarten müssen einen Apple-Type setzen wegen des Hintergrundes (hell / dunkel)
- (UIColor *) controllsDrawColour;   // für Fadenkreuz etc.
- (void) saveAsUserDefault;

@end
