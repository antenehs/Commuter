
//
//  ReittiMapping.h
//  Reitti
//
//  Created by Anteneh Sahledengel on 5/17/17.
//  Copyright © 2017 Anteneh Sahledengel. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MappingRelationShip;

@interface MappingDescriptor : NSObject

+(instancetype)descriptorFromPath:(NSString *)path forClass:(Class)classType withMappingDictionary:(NSDictionary *)mapping;
+(instancetype)descriptorFromPath:(NSString *)path forClass:(Class)classType withMappingDictionary:(NSDictionary *)mapping andRelationShips:(NSArray *)relations;

@property(nonatomic)NSString *path;
@property(nonatomic)Class classType;
@property(nonatomic, strong)NSDictionary *mappingDictionary;
@property(nonatomic, strong)NSArray<MappingRelationShip *> *relationShips;

@end


@protocol Mappable <NSObject>
+(MappingDescriptor *)mappingDescriptorForPath:(NSString *)path;
@end

@protocol DictionaryMappable <NSObject>
+ (instancetype)modelObjectWithDictionary:(NSDictionary *)dict;
- (NSDictionary *)dictionaryRepresentation;

@optional
- (instancetype)initWithDictionary:(NSDictionary *)dict;
@end

@interface MappingHelper : NSObject

+(NSArray *)mapDictionaryArray:(NSArray *)dictArray toArrayOfClassType:(Class<DictionaryMappable>)classType;
+(NSArray *)mapObjectArrayToDictionary:(NSArray *)dictArray;

@end
