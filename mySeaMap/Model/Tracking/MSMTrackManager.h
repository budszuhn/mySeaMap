//
//  MSMTrackManager.h
//  mySeaMap
//
//  Created by Frank Budszuhn on 21.09.16.
//  Copyright © 2016 Frank Budszuhn. See LICENSE.
//

#import <Foundation/Foundation.h>
#import "Track.h"
#import "TrackEntry.h"


@interface MSMTrackManager : NSObject

+ (MSMTrackManager *) sharedInstance;

- (void) startTrack;
- (void) stopTrack;
- (BOOL) isTracking;


- (NSArray<Track *> *) allTracks;

- (BOOL) isVisibleOnMap: (Track *) track;     // wird der Track auf der Karte angezeigt?
- (void) toggleTrackDisplay: (Track *) track; // auf der Karte
- (MKPolyline *) polyLineForTrack: (Track *) track;
- (void) deleteTrack: (Track *) track;

@end
