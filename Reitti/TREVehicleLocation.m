//
//  TREVehicleLocation.m
//
//  Created by Anteneh Sahledengel on 3/4/16
//  Copyright (c) 2016 shaby ltd. All rights reserved.
//

#import "TREVehicleLocation.h"


NSString *const kTREVehicleLocationLongitude = @"longitude";
NSString *const kTREVehicleLocationLatitude = @"latitude";


@interface TREVehicleLocation ()

- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict;

@end

@implementation TREVehicleLocation

@synthesize longitude = _longitude;
@synthesize latitude = _latitude;


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
            self.longitude = [self objectOrNilForKey:kTREVehicleLocationLongitude fromDictionary:dict];
            self.latitude = [self objectOrNilForKey:kTREVehicleLocationLatitude fromDictionary:dict];

    }
    
    return self;
    
}

- (NSDictionary *)dictionaryRepresentation
{
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
    [mutableDict setValue:self.longitude forKey:kTREVehicleLocationLongitude];
    [mutableDict setValue:self.latitude forKey:kTREVehicleLocationLatitude];

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

    self.longitude = [aDecoder decodeObjectForKey:kTREVehicleLocationLongitude];
    self.latitude = [aDecoder decodeObjectForKey:kTREVehicleLocationLatitude];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{

    [aCoder encodeObject:_longitude forKey:kTREVehicleLocationLongitude];
    [aCoder encodeObject:_latitude forKey:kTREVehicleLocationLatitude];
}

- (id)copyWithZone:(NSZone *)zone
{
    TREVehicleLocation *copy = [[TREVehicleLocation alloc] init];
    
    if (copy) {

        copy.longitude = [self.longitude copyWithZone:zone];
        copy.latitude = [self.latitude copyWithZone:zone];
    }
    
    return copy;
}


@end
