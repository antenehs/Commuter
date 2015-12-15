//
//  BaseClass.m
//
//  Created by Anteneh Sahledengel on 14/5/15
//  Copyright (c) 2015 shaby ltd. All rights reserved.
//

#import "BaseClass.h"
#import "Features.h"


NSString *const kBaseClassType = @"type";
NSString *const kBaseClassFeatures = @"features";


@interface BaseClass ()

- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict;

@end

@implementation BaseClass

@synthesize type = _type;
@synthesize features = _features;


+ (instancetype)modelObjectWithDictionary:(NSDictionary *)dict
{
    return [[self alloc] initWithDictionary:dict];
}

- (instancetype)initWithDictionary:(NSDictionary *)dict
{
    self = [super init];
    
    // This check serves to make sure that a non-NSDictionary object
    // passed into the model class doesn't break the parsing.
    if(self && [dict isKindOfClass:[NSDictionary class]]) {
        self.type = [self objectOrNilForKey:kBaseClassType fromDictionary:dict];
        NSObject *receivedFeatures = [dict objectForKey:kBaseClassFeatures];
        NSMutableArray *parsedFeatures = [NSMutableArray array];
        if ([receivedFeatures isKindOfClass:[NSArray class]]) {
            for (NSDictionary *item in (NSArray *)receivedFeatures) {
                if ([item isKindOfClass:[NSDictionary class]]) {
                    [parsedFeatures addObject:[Features modelObjectWithDictionary:item]];
                }
           }
        } else if ([receivedFeatures isKindOfClass:[NSDictionary class]]) {
           [parsedFeatures addObject:[Features modelObjectWithDictionary:(NSDictionary *)receivedFeatures]];
        }

        self.features = [NSArray arrayWithArray:parsedFeatures];
    }
    
    return self;
    
}

- (NSDictionary *)dictionaryRepresentation
{
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
    [mutableDict setValue:self.type forKey:kBaseClassType];
    NSMutableArray *tempArrayForFeatures = [NSMutableArray array];
    for (NSObject *subArrayObject in self.features) {
        if([subArrayObject respondsToSelector:@selector(dictionaryRepresentation)]) {
            // This class is a model object
            [tempArrayForFeatures addObject:[subArrayObject performSelector:@selector(dictionaryRepresentation)]];
        } else {
            // Generic object
            [tempArrayForFeatures addObject:subArrayObject];
        }
    }
    [mutableDict setValue:[NSArray arrayWithArray:tempArrayForFeatures] forKey:kBaseClassFeatures];

    return [NSDictionary dictionaryWithDictionary:mutableDict];
}

- (NSString *)description 
{
    return [NSString stringWithFormat:@"%@", [self dictionaryRepresentation]];
}

#pragma mark - Helper Method
- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict
{
    id object = [dict objectForKey:aKey];
    return [object isEqual:[NSNull null]] ? nil : object;
}


#pragma mark - NSCoding Methods

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];

    self.type = [aDecoder decodeObjectForKey:kBaseClassType];
    self.features = [aDecoder decodeObjectForKey:kBaseClassFeatures];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{

    [aCoder encodeObject:_type forKey:kBaseClassType];
    [aCoder encodeObject:_features forKey:kBaseClassFeatures];
}

- (id)copyWithZone:(NSZone *)zone
{
    BaseClass *copy = [[BaseClass alloc] init];
    
    if (copy) {

        copy.type = [self.type copyWithZone:zone];
        copy.features = [self.features copyWithZone:zone];
    }
    
    return copy;
}


@end
