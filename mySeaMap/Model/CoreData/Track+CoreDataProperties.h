//
//  Track+CoreDataProperties.h
//  
//
//  Created by Frank Budszuhn on 21.09.16.
//
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Track.h"

NS_ASSUME_NONNULL_BEGIN

@interface Track (CoreDataProperties)

@property (nullable, nonatomic, retain) NSDate *endDate;
@property (nullable, nonatomic, retain) NSDate *startDate;
@property (nullable, nonatomic, retain) NSOrderedSet<TrackEntry *> *trackEntries;

@end

@interface Track (CoreDataGeneratedAccessors)

- (void)addTrackEntriesObject:(TrackEntry *)value;
- (void)removeTrackEntriesObject:(TrackEntry *)value;
- (void)addTrackEntries:(NSSet<TrackEntry *> *)values;
- (void)removeTrackEntries:(NSSet<TrackEntry *> *)values;

@end

NS_ASSUME_NONNULL_END
