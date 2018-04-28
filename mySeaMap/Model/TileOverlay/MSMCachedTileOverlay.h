//
//  MSMCachedTileOverlay.h
//  mySeaMap
//
//  Created by Frank Budszuhn on 22.03.14.
//  Copyright (c) 2014 Frank Budszuhn. See LICENSE.
//

#import <MapKit/MapKit.h>

@interface MSMCachedTileOverlay : MKTileOverlay

- (instancetype) initWithURLTemplate:(NSString *)URLTemplate andCacheName: (NSString *) cacheName;

@end
