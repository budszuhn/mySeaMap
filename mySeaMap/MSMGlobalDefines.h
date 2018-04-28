//
//  MSMGlobalDefines.h
//  mySeaMap
//
//  Created by Frank Budszuhn on 04.11.13.
//  Copyright (c) 2013 - 2017 Frank Budszuhn. See LICENSE.
//

#define MSM_DEVELOPER   0 // fb, 30.9.15, das Dev-Menü muss weg
#define MSM_DEMO_MODE   0 // fixe Position und Geschwindigkeit simulieren, um Screenshots mit dem Simulator für den AppStore machen zu können 

// TMCache names
#define CACHE_OVERPASS                      @"Overpass"
#define CACHE_SEAMARKS                      @"Seamarks"

// user defaults
#define USER_DEFAULTS_MAP_SOURCE            @"map source"
#define USER_DEFAULTS_CROSSHAIRS            @"crosshairs"
#define USER_DEFAULTS_SCALE                 @"scale"
#define USER_DEFAULTS_BIG_INSTRUMENTS       @"big instruments"
#define USER_DEFAULTS_LOCATION_SOURCE       @"location source"
#define USER_DEFAULTS_MAP_CENTER_LAT        @"map center lat"
#define USER_DEFAULTS_MAP_CENTER_LON        @"map center lon"
#define USER_DEFAULTS_MAP_SCALE_FACTOR      @"map scale factor"
#define USER_DEFAULTS_MAP_SPAN_LAT          @"map span lat"
#define USER_DEFAULTS_MAP_SPAN_LON          @"map span lon"
#define USER_DEFAULTS_ROTATE_TILT           @"rotate and tilt" // fb, 21.3.2014, das lassen wir so, auch wenn es kein tilt mehr gibt
#define USER_DEFAULTS_CACHE_DURATION        @"cache duration"
#define USER_DEFAULTS_SHIP_NAME             @"ship name"
#define USER_DEFAULTS_UNITS_METRIC          @"units metric"

// Notification
#define NOTIFICATION_NEW_MAP_INSTALLED          @"new map installed"
#define NOTIFICATION_POSITION_CHANGED           @"position changed"
#define NOTIFICATION_LOCATION_MANAGER_CHANGE    @"location manager change" // auth status oder so hat sich geändert
#define NOTIFICATION_OPEN_URL                   @"open url"
#define NOTIFICATION_MAP_SOURCE_CHANGED         @"map source changed"

#define NAUTICAL_MILE                       1852.216 // Meter
#define TAP_DISTANCE                        80.0  // meter. Wie weit soll ein Tap daneben erkannt werden?


#define WEAK_SELF(x)                        __weak typeof(self) x = self

#define SEGUE_ABOUT                         @"about"
#define SEGUE_SETTINGS                      @"settings"
#define SEGUE_MAPOBJECT_DETAIL              @"mapobject detail"
#define SEGUE_RAW_DATA                      @"raw data"
#define SEGUE_SEARCH                        @"search"
#define SEGUE_CACHE_SETTINGS                @"cache settings"
#define SEGUE_OFFLINE_MAP_LIST              @"offline map list"
#define SEGUE_OFFLINE_MAP_DETAILS           @"offline map details"
#define SEGUE_TRACK_LIST                    @"track list"
#define SEGUE_TRACK_LIST_DETAILS            @"track list details"
#define SEGUE_ZOOM_SETTINGS                 @"zoom settings"

#define STORYBOARD_NAV_INFO_CONTROLLER      @"NavInfoController"
#define STORYBOARD_ABOUT_CONTROLLER         @"AboutController"
#define STORYBOARD_SETTINGS_CONTROLLER      @"SettingsController"



typedef NS_ENUM(NSUInteger, MSMMapLayer) {
    MSMMapLayerWorld = 0,
    MSMMapLayerOutline,    // outline wird zwar wohl nicht als Tile-Layer in Erscheinung treten, aber wir nehmen ihn vorsichtshalber mal auf
    MSMMapLayerBase,
    MSMMapLayerSeamark
};

typedef NS_ENUM(NSUInteger, MSMCacheDuration) {
    MSMCacheDurationOneWeek,
    MSMCacheDurationOneMonth,
    MSMCacheDurationIndefinite
};

typedef NS_ENUM(NSUInteger, MSMMapTrackingType) {
    MSMMapTrackingTypeOff,
    MSMMapTrackingTypeOn,
    MSMMapTrackingTypeHeading
};
