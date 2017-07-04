//
//  NSArray+Helper.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 29/11/15.
//  Copyright © 2015 Anteneh Sahledengel. All rights reserved.
//

#import "NSArray+Helper.h"

@implementation NSArray(Helper)

- (NSArray *)reversedArray {
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:[self count]];
    NSEnumerator *enumerator = [self reverseObjectEnumerator];
    for (id element in enumerator) {
        [array addObject:element];
    }
    return array;
}

-(NSArray *)asa_mapWith:(ArrayMappingBlock)mappingBlock {
    
    NSMutableArray *mappedArray = [@[] mutableCopy];
    for (id element in self) {
        id mapped = mappingBlock(element);
        if (mapped) [mappedArray addObject:mapped];
    }
    
    return [NSArray arrayWithArray:mappedArray];
}

@end
