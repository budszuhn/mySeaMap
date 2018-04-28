//
//  MSMTrackExporter.m
//  mySeaMap
//
//  Created by Frank Budszuhn on 26.09.16.
//  Copyright © 2016 Frank Budszuhn. See LICENSE.
//

#import "MSMTrackExporter.h"
#import "GRMustache.h"
#import "TrackEntry.h"
#import "MSMUtils.h"

@interface MSMTrackExporter ()

@property (nonatomic) Track *track;
@property (nonatomic) NSURL *tempFile;

@end

@implementation MSMTrackExporter

- (instancetype) initWithTrack: (Track *) track
{
    self = [super init];
    if (self) {
        self.track = track;
    }
    
    return self;
}


- (NSString *) mustacheTemplate
{
    return nil; // to be implemented by subclass
}

- (NSURL *) exportTrack
{
    // wir sortieren die Einträge nach Datum
    // nee, wir versuchen es mal mit einer ordered realtionship
//    NSSortDescriptor *sorting = [NSSortDescriptor sortDescriptorWithKey:@"timeStamp" ascending:YES];
//    NSArray *sortedEntries = [self.track.trackEntries sortedArrayUsingDescriptors:@[sorting]];
    
    
    // aus einem mir nicht bekannten Grund, kann Mustache nicht auf die selbst hinzugefügten Methoden der Managed Objects zugreifen
    // wir packen daher alles in Dictionaries um. Dabei können wir die Daten gleich richtig formatieren, wie praktisch
    NSMutableArray *renderData = [NSMutableArray arrayWithCapacity:[self.track.trackEntries count]];
    NSDateFormatter *dateFormatter = [MSMUtils iso8601Formatter];
    for (TrackEntry *te in self.track.trackEntries) {
        
        [renderData addObject: @{@"latitude" : te.latitude, @"longitude" : te.longitude, @"timeStamp" : [dateFormatter stringFromDate: te.timeStamp]}];
    }

    NSString *rendering = [GRMustacheTemplate renderObject:@{ @"trackEntries": renderData } fromResource: [self mustacheTemplate] bundle:nil error:NULL];

    
    self.tempFile = [self tempFileUrl];
    
    // write content into temp file
    NSData *data = [rendering dataUsingEncoding:NSUTF8StringEncoding];
    [data writeToURL:self.tempFile options:NSDataWritingAtomic error:nil];

    return self.tempFile;
}

- (NSURL *) tempFileUrl {
    NSString *fileName = @"myseaMap.gpx"; // TODO: Dateinamen aus dem Track bestimmen
    return [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:fileName]];
}

- (void) deleteTempFile {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtURL: self.tempFile error: nil];
}

@end
