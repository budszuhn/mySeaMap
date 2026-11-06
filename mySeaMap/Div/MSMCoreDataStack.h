//
//  MSMCoreDataStack.h
//  mySeaMap
//
//  Ersatz für MagicalRecord (CocoaPods): ein schlichter Core-Data-Stack
//  auf Basis von NSPersistentContainer. Die Datenbank liegt wie bisher unter
//  "Application Support/<App-Name>/<Store-Name>", damit vorhandene Tracks
//  weiterverwendet werden können.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

NS_ASSUME_NONNULL_BEGIN

@interface MSMCoreDataStack : NSObject

+ (void) setupWithStoreNamed: (NSString *) storeName;

/// Kontext für den Main-Thread
+ (NSManagedObjectContext *) context;

/// Speichert offene Änderungen (falls vorhanden)
+ (void) save;

@end

NS_ASSUME_NONNULL_END
