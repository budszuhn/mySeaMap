//
//  MSMDiskCache.h
//  mySeaMap
//
//  Ersatz für TMCache (CocoaPods). Einfacher Schlüssel/Wert-Cache mit
//  Speicher- und Plattenablage im Caches-Verzeichnis der App.
//  Gespeichert werden NSData-Objekte direkt und alle anderen Objekte
//  über NSKeyedArchiver (NSCoding).
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class MSMDiskCache;

typedef void (^MSMDiskCacheBlock)(MSMDiskCache *cache);

@interface MSMDiskCache : NSObject

- (instancetype) initWithName: (NSString *) name NS_DESIGNATED_INITIALIZER;
- (instancetype) init NS_UNAVAILABLE;

@property (nonatomic, readonly) NSString *name;

/// Maximales Alter eines Eintrags in Sekunden, 0 = unbegrenzt.
/// Beim Setzen werden ältere Einträge im Hintergrund entfernt.
@property (nonatomic) NSTimeInterval ageLimit;

/// Belegter Plattenplatz in Bytes.
@property (nonatomic, readonly) NSUInteger diskByteCount;

- (nullable id) objectForKey: (NSString *) key;
- (void) setObject: (nullable id) object forKey: (NSString *) key;

/// Löscht alle Einträge im Hintergrund, der Block wird danach auf dem Main-Thread aufgerufen.
- (void) removeAllObjects: (nullable MSMDiskCacheBlock) block;

@end

NS_ASSUME_NONNULL_END
