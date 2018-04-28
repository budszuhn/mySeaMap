//
//  FBTile.h
//  MapEditor
//
//  Created by Frank Budszuhn on 13.12.13.
//  Copyright (c) 2013 Frank Budszuhn. See LICENSE.
//

#import <Foundation/Foundation.h>

@interface FBTile : NSObject

@property (nonatomic) NSInteger x;
@property (nonatomic) NSInteger y;
@property (nonatomic) NSInteger z;

- (NSDictionary *) dict; // für JSON-Serialisierung

@end
