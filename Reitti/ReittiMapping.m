//
//  ReittiMapping.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 5/17/17.
//  Copyright © 2017 Anteneh Sahledengel. All rights reserved.
//

#import "ReittiMapping.h"

@implementation MappingDescriptor

+(instancetype)descriptorFromPath:(NSString *)path forClass:(Class)classType withMappingDictionary:(NSDictionary *)mapping {
    return [MappingDescriptor descriptorFromPath:(NSString *)path forClass:classType withMappingDictionary:mapping andRelationShips:nil];
}

+(instancetype)descriptorFromPath:(NSString *)path forClass:(Class)classType withMappingDictionary:(NSDictionary *)mapping andRelationShips:(NSArray *)relations {
    MappingDescriptor *descriptor = [self new];
    descriptor.path = path;
    descriptor.classType = classType;
    descriptor.mappingDictionary = mapping;
    descriptor.relationShips = relations;
    return descriptor;
}

@end


@implementation MappingHelper

+(NSArray *)mapDictionaryArray:(NSArray *)dictArray toArrayOfClassType:(Class<DictionaryMappable>)classType {
    if (!dictArray) return nil;
    
    NSMutableArray *mappedObjects = [NSMutableArray array];
    if ([dictArray isKindOfClass:[NSArray class]]) {
        for (NSDictionary *item in (NSArray *)dictArray) {
            if ([item isKindOfClass:[NSDictionary class]]) {
                [mappedObjects addObject:[classType modelObjectWithDictionary:item]];
            }
        }
    } else if ([dictArray isKindOfClass:[NSDictionary class]]) {
        [mappedObjects addObject:[classType modelObjectWithDictionary:(NSDictionary *)dictArray]];
    }
    
    return mappedObjects;
}

+(NSArray *)mapObjectArrayToDictionary:(NSArray *)dictArray {
    if (!dictArray) return nil;
    
    NSMutableArray *dictionaryArray = [NSMutableArray array];
    for (NSObject *subArrayObject in dictArray) {
        if([subArrayObject conformsToProtocol:@protocol(DictionaryMappable)]) {
            [dictionaryArray addObject:[(NSObject<DictionaryMappable> *)subArrayObject dictionaryRepresentation]];
        } else {
            // Generic object
            [dictionaryArray addObject:subArrayObject];
        }
    }
    
    return [NSArray arrayWithArray:dictionaryArray];
}

@end



