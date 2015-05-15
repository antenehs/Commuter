//
//  Properties.m
//
//  Created by Anteneh Sahledengel on 14/5/15
//  Copyright (c) 2015 shaby ltd. All rights reserved.
//

#import "Properties.h"


NSString *const kPropertiesLineid = @"lineid";
NSString *const kPropertiesId = @"id";
NSString *const kPropertiesBearing = @"bearing";
NSString *const kPropertiesDistanceFromStart = @"distanceFromStart";
NSString *const kPropertiesDeparture = @"departure";
NSString *const kPropertiesLastUpdate = @"lastUpdate";
NSString *const kPropertiesType = @"type";
NSString *const kPropertiesName = @"name";
NSString *const kPropertiesDiff = @"diff";


@interface Properties ()

- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict;

@end

@implementation Properties

@synthesize lineid = _lineid;
@synthesize propertiesIdentifier = _propertiesIdentifier;
@synthesize bearing = _bearing;
@synthesize distanceFromStart = _distanceFromStart;
@synthesize departure = _departure;
@synthesize lastUpdate = _lastUpdate;
@synthesize type = _type;
@synthesize name = _name;
@synthesize diff = _diff;


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
            self.lineid = [self objectOrNilForKey:kPropertiesLineid fromDictionary:dict];
            self.propertiesIdentifier = [self objectOrNilForKey:kPropertiesId fromDictionary:dict];
            self.bearing = [[self objectOrNilForKey:kPropertiesBearing fromDictionary:dict] doubleValue];
            self.distanceFromStart = [[self objectOrNilForKey:kPropertiesDistanceFromStart fromDictionary:dict] doubleValue];
            self.departure = [self objectOrNilForKey:kPropertiesDeparture fromDictionary:dict];
            self.lastUpdate = [self objectOrNilForKey:kPropertiesLastUpdate fromDictionary:dict];
            self.type = [self objectOrNilForKey:kPropertiesType fromDictionary:dict];
            self.name = [self objectOrNilForKey:kPropertiesName fromDictionary:dict];
            self.diff = [[self objectOrNilForKey:kPropertiesDiff fromDictionary:dict] doubleValue];

    }
    
    return self;
    
}

- (NSDictionary *)dictionaryRepresentation
{
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
    [mutableDict setValue:self.lineid forKey:kPropertiesLineid];
    [mutableDict setValue:self.propertiesIdentifier forKey:kPropertiesId];
    [mutableDict setValue:[NSNumber numberWithDouble:self.bearing] forKey:kPropertiesBearing];
    [mutableDict setValue:[NSNumber numberWithDouble:self.distanceFromStart] forKey:kPropertiesDistanceFromStart];
    [mutableDict setValue:self.departure forKey:kPropertiesDeparture];
    [mutableDict setValue:self.lastUpdate forKey:kPropertiesLastUpdate];
    [mutableDict setValue:self.type forKey:kPropertiesType];
    [mutableDict setValue:self.name forKey:kPropertiesName];
    [mutableDict setValue:[NSNumber numberWithDouble:self.diff] forKey:kPropertiesDiff];

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

    self.lineid = [aDecoder decodeObjectForKey:kPropertiesLineid];
    self.propertiesIdentifier = [aDecoder decodeObjectForKey:kPropertiesId];
    self.bearing = [aDecoder decodeDoubleForKey:kPropertiesBearing];
    self.distanceFromStart = [aDecoder decodeDoubleForKey:kPropertiesDistanceFromStart];
    self.departure = [aDecoder decodeObjectForKey:kPropertiesDeparture];
    self.lastUpdate = [aDecoder decodeObjectForKey:kPropertiesLastUpdate];
    self.type = [aDecoder decodeObjectForKey:kPropertiesType];
    self.name = [aDecoder decodeObjectForKey:kPropertiesName];
    self.diff = [aDecoder decodeDoubleForKey:kPropertiesDiff];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{

    [aCoder encodeObject:_lineid forKey:kPropertiesLineid];
    [aCoder encodeObject:_propertiesIdentifier forKey:kPropertiesId];
    [aCoder encodeDouble:_bearing forKey:kPropertiesBearing];
    [aCoder encodeDouble:_distanceFromStart forKey:kPropertiesDistanceFromStart];
    [aCoder encodeObject:_departure forKey:kPropertiesDeparture];
    [aCoder encodeObject:_lastUpdate forKey:kPropertiesLastUpdate];
    [aCoder encodeObject:_type forKey:kPropertiesType];
    [aCoder encodeObject:_name forKey:kPropertiesName];
    [aCoder encodeDouble:_diff forKey:kPropertiesDiff];
}

- (id)copyWithZone:(NSZone *)zone
{
    Properties *copy = [[Properties alloc] init];
    
    if (copy) {

        copy.lineid = [self.lineid copyWithZone:zone];
        copy.propertiesIdentifier = [self.propertiesIdentifier copyWithZone:zone];
        copy.bearing = self.bearing;
        copy.distanceFromStart = self.distanceFromStart;
        copy.departure = [self.departure copyWithZone:zone];
        copy.lastUpdate = [self.lastUpdate copyWithZone:zone];
        copy.type = [self.type copyWithZone:zone];
        copy.name = [self.name copyWithZone:zone];
        copy.diff = self.diff;
    }
    
    return copy;
}


@end
