//
//  MSMPolygonRenderer.m
//  mySeaMap
//
//  Created by Frank Budszuhn on 16.12.13.
//  Copyright (c) 2013 Frank Budszuhn. See LICENSE.
//

#import "MSMPolygonRenderer.h"

@implementation MSMPolygonRenderer


#define TILE_SIZE 256.0

- (BOOL)canDrawMapRect:(MKMapRect)mapRect zoomScale:(MKZoomScale)zoomScale
{
    NSInteger zoomLevel = zoomScaleToZoomLevel(zoomScale);
    NSLog(@"zoom level in renderer is %d", zoomLevel);
    return zoomLevel < 12;
}

// Convert an MKZoomScale to a zoom level where level 0 contains 4 256px square tiles,
// which is the convention used by gdal2tiles.py.
static NSInteger zoomScaleToZoomLevel(MKZoomScale scale) {
    double numTilesAt1_0 = MKMapSizeWorld.width / TILE_SIZE;
    NSInteger zoomLevelAt1_0 = log2(numTilesAt1_0);  // add 1 because the convention skips a virtual level with 1 tile.
    NSInteger zoomLevel = MAX(0, zoomLevelAt1_0 + floor(log2f(scale) + 0.5));
    return zoomLevel;
}

@end
