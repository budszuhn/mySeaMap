//
//  MSMValueFormatter.h
//  mySeaMap
//
//  Created by Frank Budszuhn on 21.03.14.
//  Copyright (c) 2014 Frank Budszuhn. See LICENSE.
//

#import <Foundation/Foundation.h>

@interface MSMValueFormatter : NSObject

+ (MSMValueFormatter *) formatterForInfoGroupWithName: (NSString *) infoGroupName;

- (NSString *) formatValue: (NSString *) value forKey: (NSString *) key;
- (NSString *) formatNumber: (NSString *) numberString withSuffix: (NSString *) suffix;
- (BOOL) isStringNumeric: (NSString *) aString;

@end
