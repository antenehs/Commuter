//
//  RoutableLocation.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 15/7/16.
//  Copyright © 2016 Anteneh Sahledengel. All rights reserved.
//

#import "RoutableLocation.h"

@implementation RoutableLocation

+(instancetype)initFromDictionary:(nonnull NSDictionary *)dictionary {
    RoutableLocation *location = [RoutableLocation new];
    location.name = dictionary[@"name"];
    location.coords = dictionary[@"coords"];
    
    return location;
}

-(NSDictionary *)dictionaryRepresentation {
    return @{@"name": self.name , @"coords": self.coords};
}

@end
