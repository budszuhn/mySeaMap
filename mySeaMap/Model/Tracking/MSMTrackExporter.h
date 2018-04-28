//
//  MSMTrackExporter.h
//  mySeaMap
//
//  Created by Frank Budszuhn on 26.09.16.
//  Copyright © 2016 Frank Budszuhn. See LICENSE.
//

#import <Foundation/Foundation.h>
#import "Track.h"


@interface MSMTrackExporter : NSObject

- (instancetype) initWithTrack: (Track *) track;

- (NSURL *) exportTrack;
- (NSString *) mustacheTemplate;
- (void) deleteTempFile;


@end
