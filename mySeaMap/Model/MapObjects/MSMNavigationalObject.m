//
//  MSMNavigationalObject.m
//  mySeaMap
//
//  Created by Frank Budszuhn on 14.03.14.
//  Copyright (c) 2014 Frank Budszuhn. See LICENSE.
//

#import "MSMNavigationalObject.h"

@implementation MSMNavigationalObject


- (NSString *) title
{
    NSString *name = [self anyTagValueWithKeys:@[@"seamark:name",@"name"] fallback:nil];
    NSString *lights = [self lightShortString];
    
    if (name)
    {
        if (lights)
        {
            return [NSString stringWithFormat:@"%@: %@", name, lights];
        }
        else
        {
            return name;
        }
    }
    else
    {
        if (lights)
        {
            return lights;
        }
        else
        {
            return [self seamarkType]; // TODO
        }
    }
    
}


// erzeugt die in Karten übliche kurze Beschreibung eines Feuers wie z.B. Oc(2)G.9s
- (NSString *) lightShortString
{
    NSString *character = [self tagValue:@"seamark:light:character"];
    NSString *group = [self tagValue:@"seamark:light:group"];
    NSString *colour = [self tagValue:@"seamark:light:colour"];
    NSString *period = [self tagValue:@"seamark:light:period"];

    if (character)
    {
        NSString *result = character;
        if (group)
        {
            result = [result stringByAppendingFormat:@"(%@)", group];
        }
        else
        {
            result = [result stringByAppendingString:@"."];
        }
        
        if (colour)
        {
            result = [result stringByAppendingFormat:@"%@.", [self colourCode: colour]];
        }
        
        if (period)
        {
            result = [result stringByAppendingFormat:@"%@s", period];
        }
        
        return result;
    }
    else if (colour)
    {
        // Licht ohne Character ist möglich
        return [self colourCode: colour];
    }
    
    return nil;
}



- (NSString *) colourCode: (NSString *) colour
{
    NSDictionary *lookup = @{@"green": @"G", @"red": @"R", @"white": @""};
    
    return [lookup valueForKey:colour];
}

@end
