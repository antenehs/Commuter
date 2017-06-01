//
//  NSDictionary+Helper.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 5/31/17.
//  Copyright © 2017 Anteneh Sahledengel. All rights reserved.
//

#import "NSDictionary+Helper.h"

@implementation NSDictionary (Helper)

- (id)objectOrNilForKey:(id)aKey {
    id object = [self objectForKey:aKey];
    return [object isEqual:[NSNull null]] ? nil : object;
}

@end
