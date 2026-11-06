//
//  MKMapView+MSMZoomLevel.m
//  mySeaMap
//
//  Ersatz für MKMapViewZoom (CocoaPods).
//

#import "MKMapView+MSMZoomLevel.h"

@implementation MKMapView (MSMZoomLevel)

// Breite der Welt in Punkten bei Zoomstufe 0 (eine 256er Kachel)
static const double kTileSize = 256.0;

- (double) zoomLevel
{
    double width = self.bounds.size.width;
    if (width <= 0.0 || self.visibleMapRect.size.width <= 0.0)
        return 0.0;

    double worldPoints = MKMapSizeWorld.width * width / self.visibleMapRect.size.width;
    return MAX(0.0, log2(worldPoints / kTileSize));
}

- (void) setCenterCoordinate: (CLLocationCoordinate2D) centerCoordinate
                   zoomLevel: (NSUInteger) zoomLevel
                    animated: (BOOL) animated
{
    zoomLevel = MIN(zoomLevel, (NSUInteger)20);

    double worldPoints = kTileSize * pow(2.0, (double)zoomLevel);
    double mapPointsPerScreenPoint = MKMapSizeWorld.width / worldPoints;

    MKMapPoint center = MKMapPointForCoordinate(centerCoordinate);
    double width = self.bounds.size.width * mapPointsPerScreenPoint;
    double height = self.bounds.size.height * mapPointsPerScreenPoint;

    MKMapRect rect = MKMapRectMake(center.x - width / 2.0, center.y - height / 2.0, width, height);
    [self setVisibleMapRect: rect animated: animated];
}

@end
