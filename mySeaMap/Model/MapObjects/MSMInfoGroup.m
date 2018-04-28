//
//  MSMInfoGroup.m
//  mySeaMap
//
//  Created by Frank Budszuhn on 16.03.14.
//  Copyright (c) 2014 Frank Budszuhn. See LICENSE.
//

#import "MSMInfoGroup.h"
#import "MSMValueFormatter.h"

@interface MSMInfoGroup ()

@property (strong, nonatomic, readonly) MSMValueFormatter *formatter;

@end

@implementation MSMInfoGroup

@synthesize keys=_keys, values=_values, name=_name, formatter=_formatter;

+ (MSMInfoGroup *) groupWithName:(NSString *)name andTags:(NSDictionary *)tags andLookupTable: (NSDictionary *) lookup
{
    return [[MSMInfoGroup alloc] initWithName: name andTags: tags andLookupTable:lookup];
}


- (instancetype) initWithName: (NSString *) name andTags: (NSDictionary *) tags andLookupTable: (NSDictionary *) lookup
{
    self = [super init];
    if (self)
    {
        _name = name;
        MSMValueFormatter *formatter = [self formatter];
        
        NSMutableArray *keys = [NSMutableArray array];
        NSMutableArray *values = [NSMutableArray array];
        
        NSArray *lookupKeys = [lookup valueForKey:_name];
        for (NSDictionary *lookupDict in lookupKeys)
        {
            NSString *key = [[lookupDict allKeys] firstObject];
            NSArray *lookupKeys = [[lookupDict allValues] firstObject];
            NSString *value = [self anyTagValueForTags: tags keys:lookupKeys fallback:nil];
            if (value)
            {
                // TODO: multiple Values (Telefon, Öffnungszeiten)
                // Ein HAck für die Öffnungszeiten, den wir erstmal so lassen, gell?
                if ([key isEqualToString:@"opening_hours"])
                {
                    NSArray *vals = [value componentsSeparatedByString:@";"];
                    for (NSString *aValue in vals)
                    {
                        [keys addObject: key];
                        [values addObject: aValue];
                    }
                }
                else // Normalfall
                {
                    [keys addObject: key];
                    [values addObject: formatter ? [formatter formatValue: value forKey: key] : value];
                }
            }
        }
        
        _keys = [keys copy];
        _values = [values copy];
    }
    
    return self;
}


- (NSString *) anyTagValueForTags: (NSDictionary *) tags keys: (NSArray *) keys fallback: (NSString *) fallbackValue
{
    for (NSString *aKey in keys)
    {
        NSString *aValue = [tags valueForKey: aKey];
        if (aValue) {
            return aValue;
        }
    }
    
    return fallbackValue;
}

- (NSString *) localizedName
{
    return NSLocalizedString(self.name, nil);
}

- (CGFloat) heightForPopover
{
    if ([INFO_GROUP_NAME_AND_DESCRIPTION isEqualToString: self.name])
    {
        return 88.0 * [self.keys count];
    }
    else
    {
        return 44.0 * [self.keys count];
    }
}


// accessors

- (NSString *) cellIdentifier
{
    NSDictionary *lookup = @{INFO_GROUP_NAME_AND_DESCRIPTION: @"MapObjectNameAndDescription", INFO_GROUP_CONTACT: @"MapObjectContact", INFO_GROUP_METRICS: @"MapObjectSimpleValues", INFO_GROUP_TIMES: @"MapObjectSimpleValues"};
    
    return [lookup valueForKey: self.name];
}

- (MSMValueFormatter *) formatter
{
    if (! _formatter)
    {
        _formatter = [MSMValueFormatter formatterForInfoGroupWithName: _name];
    }
    
    return _formatter;
}


@end
