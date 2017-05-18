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




