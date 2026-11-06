//
//  MSMTrackExporter.m
//  mySeaMap
//
//  Created by Frank Budszuhn on 26.09.16.
//  Copyright © 2016 Frank Budszuhn. See LICENSE.
//

#import "MSMTrackExporter.h"
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
    
    
    // GPX-Datei direkt erzeugen (früher über GRMustache und GPX.mustache)
    NSDateFormatter *dateFormatter = [MSMUtils iso8601Formatter];
    NSMutableString *rendering = [NSMutableString string];
    [rendering appendString:@"<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"];
    [rendering appendString:@"<gpx creator=\"mySeaMap\" version=\"1.1\" xmlns=\"http://www.topografix.com/GPX/1/1\">\n<trk>\n<trkseg>\n"];
    for (TrackEntry *te in self.track.trackEntries) {
        [rendering appendFormat:@"<trkpt lat=\"%.7f\" lon=\"%.7f\"><time>%@</time></trkpt>\n",
         te.latitude.doubleValue, te.longitude.doubleValue, te.timeStamp ? [dateFormatter stringFromDate: te.timeStamp] : @""];
    }
    [rendering appendString:@"</trkseg>\n</trk>\n</gpx>\n"];

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
