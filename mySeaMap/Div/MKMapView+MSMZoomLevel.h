//
//  MKMapView+MSMZoomLevel.h
//  mySeaMap
//
//  Ersatz für MKMapViewZoom (CocoaPods): Zoomstufen wie bei Web-Karten (0...20).
//

#import <MapKit/MapKit.h>

@interface MKMapView (MSMZoomLevel)

/// aktuelle Zoomstufe (0 = ganze Welt, 18 ≈ Straßenebene)
- (double) zoomLevel;

- (void) setCenterCoordinate: (CLLocationCoordinate2D) centerCoordinate
                   zoomLevel: (NSUInteger) zoomLevel
                    animated: (BOOL) animated;

@end
