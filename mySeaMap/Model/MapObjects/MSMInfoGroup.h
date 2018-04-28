//
//  MSMInfoGroup.h
//  mySeaMap
//
//  Created by Frank Budszuhn on 16.03.14.
//  Copyright (c) 2014 Frank Budszuhn. See LICENSE.
//
//  Eine Infogruppe ist soetwas wie "Kontaktinformation", "Name & Beschreibung", "Leuchtfeuer" (o.ä)

#import <Foundation/Foundation.h>

#define INFO_GROUP_NAME_AND_DESCRIPTION @"info_group_name_and_description"
#define INFO_GROUP_CONTACT              @"info_group_contact"
#define INFO_GROUP_TIMES                @"info_group_times"
#define INFO_GROUP_METRICS              @"info_group_metrics"
#define INFO_GROUP_LIGHTS               @"info_group_lights"
#define INFO_GROUP_FACILITIES           @"info_group_facilities"
#define INFO_GROUP_IMAGE                @"info_group_image"

#define GENERAL_INFO_GROUPS             @[INFO_GROUP_NAME_AND_DESCRIPTION, INFO_GROUP_CONTACT, INFO_GROUP_METRICS, INFO_GROUP_TIMES]

@interface MSMInfoGroup : NSObject

@property (strong, nonatomic, readonly) NSString *name;
@property (nonatomic, readonly) NSString *cellIdentifier;
@property (strong, nonatomic, readonly) NSArray *keys;
@property (strong, nonatomic, readonly) NSArray *values;

+ (MSMInfoGroup *) groupWithName:(NSString *)name andTags:(NSDictionary *)tags andLookupTable: (NSDictionary *) lookup;

- (NSString *) localizedName;
- (CGFloat) heightForPopover;


@end
