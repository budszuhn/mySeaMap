//
//  MSMOverpassServer.m
//  mySeaMap
//
//  Created by Frank Budszuhn on 13.05.14.
//  Copyright (c) 2014 - 2016 Frank Budszuhn. See LICENSE.
//

#import "MSMOverpassServer.h"
#import "FOQueryManager.h"

@interface MSMOverpassServer ()

@property (strong, nonatomic) NSString *server;

@end

@implementation MSMOverpassServer

+ (MSMOverpassServer *) sharedInstance
{
    static dispatch_once_t once;
    static MSMOverpassServer *_sharedInstance;
    dispatch_once(&once, ^ { _sharedInstance = [[self alloc] init]; });
    return _sharedInstance;
}

+ (NSString *) server
{
    return [[MSMOverpassServer sharedInstance] server];
}



- (instancetype) init
{
    self = [super init];
    if (self)
    {
        NSArray *serverList = [self serverList];
        
        // Idee: wir schicken eine kleinen Test-Request an alle Server und messen die Antwort-Geschwindigkeit. Wer zuerst antwortet, gewinnt
        // wie könnte der Request aussehen?
        
       _server = [[serverList objectAtIndex: arc4random_uniform([serverList count])] valueForKey:@"url"];
        NSLog(@"using overpass server = %@", _server);
    }
    return self;
}

- (NSString *) server
{
    return _server;
}


// liest die Liste aus der Conf-Datei aus dem Bundle
- (NSArray *) serverList
{
    NSString *filePath = [[NSBundle mainBundle] pathForResource: @"myseamap" ofType:@"json"];
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
   return [json valueForKey:@"overpass-server-list"];
}

@end
