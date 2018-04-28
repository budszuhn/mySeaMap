//
//  TrackEntry+CoreDataProperties.h
//  
//
//  Created by Frank Budszuhn on 21.09.16.
//
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "TrackEntry.h"

NS_ASSUME_NONNULL_BEGIN

@interface TrackEntry (CoreDataProperties)

@property (nullable, nonatomic, retain) NSNumber *heading;
@property (nullable, nonatomic, retain) NSNumber *latitude;
@property (nullable, nonatomic, retain) NSNumber *longitude;
@property (nullable, nonatomic, retain) NSNumber *speed;
@property (nullable, nonatomic, retain) NSDate *timeStamp;
@property (nullable, nonatomic, retain) NSManagedObject *track;

@end

NS_ASSUME_NONNULL_END
