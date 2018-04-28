//
//  MSMFeatureManager.h
//  mySeaMap
//
//  Created by Frank Budszuhn on 16.05.14.
//  Copyright (c) 2014 Frank Budszuhn. See LICENSE.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, MSMFeature) {
    MSMFeatureNightMode = 0,
    MSMFeatureExternalDisplay
};


@interface MSMFeatureManager : NSObject

+ (BOOL) hasFeature: (MSMFeature) feature;

@end
