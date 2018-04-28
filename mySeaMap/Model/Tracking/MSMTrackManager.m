//
//  MSMTrackManager.m
//  mySeaMap
//
//  Created by Frank Budszuhn on 21.09.16.
//  Copyright © 2016 Frank Budszuhn. See LICENSE.
//

#import "MSMTrackManager.h"
#import "FBGeoLocation.h"
#import "MSMLocationManager.h"


@interface MSMTrackManager ()

// current track
@property (strong, nonatomic) Track *currentTrack;
@property (strong, nonatomic) NSMutableSet *visibleTracks;
@property (strong, nonatomic) NSMutableDictionary *polylineLookup; // Cache für Polylines

@end



@implementation MSMTrackManager


+ (MSMTrackManager *) sharedInstance
{
    static dispatch_once_t once;
    static MSMTrackManager *_sharedInstance;
    dispatch_once(&once, ^ { _sharedInstance = [[self alloc] init]; });
    return _sharedInstance;
}


- (instancetype) init
{
    self = [super init];
    
    if (self) {
        self.visibleTracks = [NSMutableSet set];
        self.polylineLookup = [NSMutableDictionary dictionary];
    }
    
    return self;
}


- (void)saveContext {
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreWithCompletion:^(BOOL success, NSError *error) {
        if (success) {
            NSLog(@"You successfully saved your context.");
        } else if (error) {
            NSLog(@"Error saving context: %@", error.description);
        }
    }];
}

- (void) startTrack
{
    // so, versuch mal einen Eintrag zu schreiben
    self.currentTrack = [Track MR_createEntity];
    self.currentTrack.startDate = [NSDate date];
    
    // für Location-Events anmelden
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(positionChanged:)
                                                 name: NOTIFICATION_POSITION_CHANGED
                                               object: nil];
    [self saveContext];
    
    // außerdem auf Background-Operation umschalten
    [[MSMLocationManager manager] setAllowsBackgroundUpdates: YES];
}

- (void) stopTrack
{    
    [[NSNotificationCenter defaultCenter] removeObserver: self];
    
    self.currentTrack.endDate = [NSDate date];
    
    [self saveContext];
    
    self.currentTrack = nil;
    [[MSMLocationManager manager] setAllowsBackgroundUpdates: NO]; // TODO: das scheint nicht zu funktionieren :-(
}

- (BOOL) isTracking {
    return self.currentTrack != nil;
}



- (NSArray<Track *> *) allTracks
{
    return [Track MR_findAllSortedBy:@"startDate" ascending:NO];
}

- (BOOL) isVisibleOnMap: (Track *) track
{
    return [self.visibleTracks containsObject: track];
}

- (void) toggleTrackDisplay:(Track *)track
{
    if ([self.visibleTracks containsObject: track]) {
        [self.visibleTracks removeObject: track];
    }
    else {
        [self.visibleTracks addObject: track];
    }
}


- (MKPolyline *) polyLineForTrack: (Track *) track
{
    MKPolyline *polyLine = [self.polylineLookup objectForKey:track.objectID];
    if (polyLine == nil) {
        
        NSLog(@"## must create ##");
    
        NSUInteger count = [track.trackEntries count];
        CLLocationCoordinate2D coordinates[count];
        
        for (int i=0; i<count; i++) {
            TrackEntry *te = [track.trackEntries objectAtIndex:i];
            coordinates[i] = CLLocationCoordinate2DMake([te.latitude doubleValue], [te.longitude doubleValue]);
        }
        
        polyLine = [MKPolyline polylineWithCoordinates:coordinates count:count];
        [self.polylineLookup setObject:polyLine forKey:track.objectID];
    }
    else {
        NSLog(@"got from cache ###");
    }
    
    return polyLine;
}


- (void) deleteTrack: (Track *) track;
{
    [track MR_deleteEntity];
    [self saveContext];
}


#pragma mark - Location Event

// TODO: ich denke wir sollten auch die accuracy speichern. Das ist später bei Entferungsberechnungen und Startbestimmung wichtig.
- (void) positionChanged: (NSNotification *) notification
{
    NSDictionary *userInfo = [notification userInfo];
    FBGeoLocation *loc = [userInfo valueForKey:@"loc"];
    
    TrackEntry *entry = [TrackEntry MR_createEntity];
    
    entry.track = self.currentTrack;
    entry.latitude = [NSNumber numberWithDouble: loc.coordinate.latitude];
    entry.longitude = [NSNumber numberWithDouble: loc.coordinate.longitude];
    entry.timeStamp = [NSDate date];
    
    // TODO: ggf. sollten wir die Codierung mit -1 einfach übernehmen?
    if (loc.course > -1) { entry.heading =  [NSNumber numberWithDouble:loc.course]; }
    if (loc.speed > -1) { entry.speed = [NSNumber numberWithDouble:loc.speed]; }// Einheit???
    
    [self saveContext];
}


@end
