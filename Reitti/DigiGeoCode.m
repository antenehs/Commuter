//
//  DigiGeoCode.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 12/19/16.
//  Copyright © 2016 Anteneh Sahledengel. All rights reserved.
//

#import "DigiGeoCode.h"

NSString *const kDigiFeaturesType = @"type";
NSString *const kDigiFeaturesGeometry = @"geometry";
NSString *const kDigiFeaturesProperties = @"properties";

@interface DigiGeoCode ()

- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict;

@end

@implementation DigiGeoCode

@synthesize type = _type;
@synthesize geometry = _geometry;
@synthesize properties = _properties;

-(LocationType)locationType {
    if (_locationType == LocationTypeUnknown && self.properties.layer) {
        if ([self.properties.layer isEqualToString:@"address"] || [self.properties.layer isEqualToString:@"street"]) {
            _locationType = LocationTypeAddress;
        } else if ([self.properties.layer isEqualToString:@"stop"]) {
            _locationType = LocationTypeStop;
        } else if ([self.properties.layer isEqualToString:@"venue"]) {
            _locationType = LocationTypePOI;
        } else {
            _locationType = LocationTypePOI;
        } //TODO: More coming
    }
    
    return _locationType;
}

-(NSString *)city {
    if (self.properties.locality) {
        return self.properties.locality;
    } else if (self.properties.localadmin) {
        return self.properties.localadmin;
    } else {
        return self.properties.region;
    }
}

#pragma mark - Initialization and factory methods
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
        self.type = [self objectOrNilForKey:kDigiFeaturesType fromDictionary:dict];
        self.geometry = [Geometry modelObjectWithDictionary:[dict objectForKey:kDigiFeaturesGeometry]];
        self.properties = [DigiFeatureProperties modelObjectWithDictionary:[dict objectForKey:kDigiFeaturesProperties]];
    }
    
    return self;
    
}

- (NSDictionary *)dictionaryRepresentation
{
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
    [mutableDict setValue:self.type forKey:kDigiFeaturesType];
    [mutableDict setValue:[self.geometry dictionaryRepresentation] forKey:kDigiFeaturesGeometry];
    [mutableDict setValue:[self.properties dictionaryRepresentation] forKey:kDigiFeaturesProperties];
    
    return [NSDictionary dictionaryWithDictionary:mutableDict];
}

#pragma mark - NSCoding Methods

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    
    self.type = [aDecoder decodeObjectForKey:kDigiFeaturesType];
    self.geometry = [aDecoder decodeObjectForKey:kDigiFeaturesGeometry];
    self.properties = [aDecoder decodeObjectForKey:kDigiFeaturesProperties];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    
    [aCoder encodeObject:_type forKey:kDigiFeaturesType];
    [aCoder encodeObject:_geometry forKey:kDigiFeaturesGeometry];
    [aCoder encodeObject:_properties forKey:kDigiFeaturesProperties];
}

- (id)copyWithZone:(NSZone *)zone
{
    DigiGeoCode *copy = [[DigiGeoCode alloc] init];
    
    if (copy) {
        
        copy.type = [self.type copyWithZone:zone];
        copy.geometry = [self.geometry copyWithZone:zone];
        copy.properties = [self.properties copyWithZone:zone];
    }
    
    return copy;
}

#pragma mark - Helper Method
- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict
{
    id object = [dict objectForKey:aKey];
    return [object isEqual:[NSNull null]] ? nil : object;
}

#pragma mark - Mappable protocol implemention
#ifndef APPLE_WATCH
+(RKResponseDescriptor *)responseDiscriptorForPath:(NSString *)path {
    return [RKResponseDescriptor responseDescriptorWithMapping:[DigiGeoCode objectMapping]
                                                        method:RKRequestMethodAny
                                                   pathPattern:nil
                                                       keyPath:path
                                                   statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
}

+(RKObjectMapping *)objectMapping {
    RKObjectMapping* geocodeMapping = [RKObjectMapping mappingForClass:[DigiGeoCode class] ];
    [geocodeMapping addAttributeMappingsFromDictionary:@{
                                                      @"type" : @"type"
                                                      }];
    
    [geocodeMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"properties"
                                                                                toKeyPath:@"properties"
                                                                              withMapping:[DigiFeatureProperties objectMapping]]];
    
    [geocodeMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"geometry"
                                                                                toKeyPath:@"geometry"
                                                                              withMapping:[Geometry objectMapping]]];
    
    return geocodeMapping;
}
#endif

@end
