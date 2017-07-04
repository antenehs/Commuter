//
//  NSArray+Helper.h
//  Reitti
//
//  Created by Anteneh Sahledengel on 29/11/15.
//  Copyright © 2015 Anteneh Sahledengel. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef id(^ArrayMappingBlock)(id element);

@interface NSArray (Helper)

- (NSArray *)reversedArray;
-(NSArray *)asa_mapWith:(ArrayMappingBlock)mappingBlock;

@end
