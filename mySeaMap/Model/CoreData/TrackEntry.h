//
//  TrackEntry.h
//  
//
//  Created by Frank Budszuhn on 21.09.16.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

NS_ASSUME_NONNULL_BEGIN

@interface TrackEntry : NSManagedObject

- (NSString *) tester;

@end

NS_ASSUME_NONNULL_END

#import "TrackEntry+CoreDataProperties.h"
