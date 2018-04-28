//
//  MSMFeatureManager.m
//  mySeaMap
//
//  Created by Frank Budszuhn on 16.05.14.
//  Copyright (c) 2014 Frank Budszuhn. See LICENSE.
//

#import "MSMFeatureManager.h"

@implementation MSMFeatureManager

+ (BOOL) hasFeature: (MSMFeature) feature
{
#if MSM_DEVELOPER
    switch (feature) {
        case MSMFeatureExternalDisplay:
            return YES;  // fb, 29.9.15, wir wollen das erstmal wieder schön in die Gänge bringen, da belibt das erstmal aus
        case MSMFeatureNightMode:
            return NO;
            
        default:
            return NO;
    }
#else
    return NO;
#endif
}

@end
