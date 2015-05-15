//
//  Features.m
//
//  Created by Anteneh Sahledengel on 14/5/15
//  Copyright (c) 2015 shaby ltd. All rights reserved.
//

#import "Features.h"
#import "Geometry.h"
#import "Properties.h"


NSString *const kFeaturesType = @"type";
NSString *const kFeaturesGeometry = @"geometry";
NSString *const kFeaturesProperties = @"properties";


@interface Features ()

- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict;

@end

@implementation Features

@synthesize type = _type;
@synthesize geometry = _geometry;
@synthesize properties = _properties;


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
            self.type = [self objectOrNilForKey:kFeaturesType fromDictionary:dict];
            self.geometry = [Geometry modelObjectWithDictionary:[dict objectForKey:kFeaturesGeometry]];
            self.properties = [Properties modelObjectWithDictionary:[dict objectForKey:kFeaturesProperties]];

    }
    
    return self;
    
}

- (NSDictionary *)dictionaryRepresentation
{
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
    [mutableDict setValue:self.type forKey:kFeaturesType];
    [mutableDict setValue:[self.geometry dictionaryRepresentation] forKey:kFeaturesGeometry];
    [mutableDict setValue:[self.properties dictionaryRepresentation] forKey:kFeaturesProperties];

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

    self.type = [aDecoder decodeObjectForKey:kFeaturesType];
    self.geometry = [aDecoder decodeObjectForKey:kFeaturesGeometry];
    self.properties = [aDecoder decodeObjectForKey:kFeaturesProperties];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{

    [aCoder encodeObject:_type forKey:kFeaturesType];
    [aCoder encodeObject:_geometry forKey:kFeaturesGeometry];
    [aCoder encodeObject:_properties forKey:kFeaturesProperties];
}

- (id)copyWithZone:(NSZone *)zone
{
    Features *copy = [[Features alloc] init];
    
    if (copy) {

        copy.type = [self.type copyWithZone:zone];
        copy.geometry = [self.geometry copyWithZone:zone];
        copy.properties = [self.properties copyWithZone:zone];
    }
    
    return copy;
}


@end
