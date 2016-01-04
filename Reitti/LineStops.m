//
//  LineStops.m
//
//  Created by Anteneh Sahledengel on 18/6/15
//  Copyright (c) 2015 shaby ltd. All rights reserved.
//

#import "LineStops.h"


NSString *const kLineStopsCoords = @"coords";
NSString *const kLineStopsAddress = @"address";
NSString *const kLineStopsTime = @"time";
NSString *const kLineStopsCode = @"code";
NSString *const kLineStopsCodeShort = @"codeShort";
NSString *const kLineStopsPlatformNumber = @"platform_number";
NSString *const kLineStopsCityName = @"city_name";
NSString *const kLineStopsName = @"name";


@interface LineStops ()

- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict;

@end

@implementation LineStops

@synthesize coords = _coords;
@synthesize address = _address;
@synthesize time = _time;
@synthesize code = _code;
@synthesize codeShort = _codeShort;
@synthesize platformNumber = _platformNumber;
@synthesize cityName = _cityName;
@synthesize name = _name;

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
            self.coords = [self objectOrNilForKey:kLineStopsCoords fromDictionary:dict];
            self.address = [self objectOrNilForKey:kLineStopsAddress fromDictionary:dict];
            self.time = [[self objectOrNilForKey:kLineStopsTime fromDictionary:dict] doubleValue];
            self.code = [self objectOrNilForKey:kLineStopsCode fromDictionary:dict];
            self.codeShort = [self objectOrNilForKey:kLineStopsCodeShort fromDictionary:dict];
            self.platformNumber = [self objectOrNilForKey:kLineStopsPlatformNumber fromDictionary:dict];
            self.cityName = [self objectOrNilForKey:kLineStopsCityName fromDictionary:dict];
            self.name = [self objectOrNilForKey:kLineStopsName fromDictionary:dict];

    }
    
    return self;
    
}

- (NSDictionary *)dictionaryRepresentation
{
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
    [mutableDict setValue:self.coords forKey:kLineStopsCoords];
    [mutableDict setValue:self.address forKey:kLineStopsAddress];
    [mutableDict setValue:[NSNumber numberWithDouble:self.time] forKey:kLineStopsTime];
    [mutableDict setValue:self.code forKey:kLineStopsCode];
    [mutableDict setValue:self.codeShort forKey:kLineStopsCodeShort];
    [mutableDict setValue:self.platformNumber forKey:kLineStopsPlatformNumber];
    [mutableDict setValue:self.cityName forKey:kLineStopsCityName];
    [mutableDict setValue:self.name forKey:kLineStopsName];

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

    self.coords = [aDecoder decodeObjectForKey:kLineStopsCoords];
    self.address = [aDecoder decodeObjectForKey:kLineStopsAddress];
    self.time = [aDecoder decodeDoubleForKey:kLineStopsTime];
    self.code = [aDecoder decodeObjectForKey:kLineStopsCode];
    self.codeShort = [aDecoder decodeObjectForKey:kLineStopsCodeShort];
    self.platformNumber = [aDecoder decodeObjectForKey:kLineStopsPlatformNumber];
    self.cityName = [aDecoder decodeObjectForKey:kLineStopsCityName];
    self.name = [aDecoder decodeObjectForKey:kLineStopsName];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{

    [aCoder encodeObject:_coords forKey:kLineStopsCoords];
    [aCoder encodeObject:_address forKey:kLineStopsAddress];
    [aCoder encodeDouble:_time forKey:kLineStopsTime];
    [aCoder encodeObject:_code forKey:kLineStopsCode];
    [aCoder encodeObject:_codeShort forKey:kLineStopsCodeShort];
    [aCoder encodeObject:_platformNumber forKey:kLineStopsPlatformNumber];
    [aCoder encodeObject:_cityName forKey:kLineStopsCityName];
    [aCoder encodeObject:_name forKey:kLineStopsName];
}

- (id)copyWithZone:(NSZone *)zone
{
    LineStops *copy = [[LineStops alloc] init];
    
    if (copy) {

        copy.coords = [self.coords copyWithZone:zone];
        copy.address = [self.address copyWithZone:zone];
        copy.time = self.time;
        copy.code = [self.code copyWithZone:zone];
        copy.codeShort = [self.codeShort copyWithZone:zone];
        copy.platformNumber = [self.platformNumber copyWithZone:zone];
        copy.cityName = [self.cityName copyWithZone:zone];
        copy.name = [self.name copyWithZone:zone];
    }
    
    return copy;
}


@end
