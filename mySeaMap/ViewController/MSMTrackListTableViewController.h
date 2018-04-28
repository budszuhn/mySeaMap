//
//  MSMTrackListTableViewController.h
//  mySeaMap
//
//  Created by Frank Budszuhn on 22.09.16.
//  Copyright © 2016 Frank Budszuhn. See LICENSE.
//

@import UIKit;


@protocol MSMTrackDisplayDelegate <NSObject>

- (void) addTrack: (MKPolyline *) trackLine;
- (void) removeTrack: (MKPolyline *) trackLine;


@end


@interface MSMTrackListTableViewController : UITableViewController

@property (weak, nonatomic) id <MSMTrackDisplayDelegate> trackDisplayDelegate;

@end
