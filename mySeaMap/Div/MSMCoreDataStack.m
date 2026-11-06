//
//  MSMCoreDataStack.m
//  mySeaMap
//
//  Ersatz für MagicalRecord (CocoaPods).
//

#import "MSMCoreDataStack.h"

static NSPersistentContainer *sContainer = nil;

@implementation MSMCoreDataStack

+ (NSURL *) storeURLForName: (NSString *) storeName
{
    NSFileManager *fm = [NSFileManager defaultManager];
    NSURL *appSupport = [[fm URLsForDirectory: NSApplicationSupportDirectory inDomains: NSUserDomainMask] firstObject];
    NSString *appName = [[NSBundle mainBundle] objectForInfoDictionaryKey: (NSString *)kCFBundleNameKey] ?: @"mySeaMap";
    NSURL *directory = [appSupport URLByAppendingPathComponent: appName isDirectory: YES];
    [fm createDirectoryAtURL: directory withIntermediateDirectories: YES attributes: nil error: nil];

    return [directory URLByAppendingPathComponent: storeName];
}

+ (void) setupWithStoreNamed: (NSString *) storeName
{
    if (sContainer)
        return;

    NSManagedObjectModel *model = [NSManagedObjectModel mergedModelFromBundles: nil];
    NSPersistentContainer *container = [[NSPersistentContainer alloc] initWithName: @"mySeaMap" managedObjectModel: model];

    NSPersistentStoreDescription *description = [NSPersistentStoreDescription persistentStoreDescriptionWithURL: [self storeURLForName: storeName]];
    description.shouldMigrateStoreAutomatically = YES;
    description.shouldInferMappingModelAutomatically = YES;
    description.shouldAddStoreAsynchronously = NO;
    container.persistentStoreDescriptions = @[description];

    [container loadPersistentStoresWithCompletionHandler: ^(NSPersistentStoreDescription *desc, NSError *error) {
        if (error)
        {
            NSLog(@"Core Data: Datenbank konnte nicht geöffnet werden: %@", error);
        }
    }];

    container.viewContext.automaticallyMergesChangesFromParent = YES;
    container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy;

    sContainer = container;
}

+ (NSManagedObjectContext *) context
{
    if (! sContainer)
    {
        [self setupWithStoreNamed: @"myseamap.db"];
    }
    return sContainer.viewContext;
}

+ (void) save
{
    NSManagedObjectContext *context = [self context];
    [context performBlockAndWait: ^{
        if (! context.hasChanges)
            return;

        NSError *error = nil;
        if (! [context save: &error])
        {
            NSLog(@"Core Data: Fehler beim Speichern: %@", error);
        }
    }];
}

@end
