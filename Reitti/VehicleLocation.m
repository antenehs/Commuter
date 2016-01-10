//
//  VehicleLocation.m
//
//  Created by Anteneh Sahledengel on 10/1/16
//  Copyright (c) 2016 shaby ltd. All rights reserved.
//

#import "VehicleLocation.h"


NSString *const kVehicleLocationLatitude = @"Latitude";
NSString *const kVehicleLocationLongitude = @"Longitude";


@interface VehicleLocation ()

- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict;

@end

@implementation VehicleLocation

@synthesize latitude = _latitude;
@synthesize longitude = _longitude;


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
            self.latitude = [[self objectOrNilForKey:kVehicleLocationLatitude fromDictionary:dict] doubleValue];
            self.longitude = [[self objectOrNilForKey:kVehicleLocationLongitude fromDictionary:dict] doubleValue];

    }
    
    return self;
    
}

- (NSDictionary *)dictionaryRepresentation
{
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
    [mutableDict setValue:[NSNumber numberWithDouble:self.latitude] forKey:kVehicleLocationLatitude];
    [mutableDict setValue:[NSNumber numberWithDouble:self.longitude] forKey:kVehicleLocationLongitude];

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

    self.latitude = [aDecoder decodeDoubleForKey:kVehicleLocationLatitude];
    self.longitude = [aDecoder decodeDoubleForKey:kVehicleLocationLongitude];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{

    [aCoder encodeDouble:_latitude forKey:kVehicleLocationLatitude];
    [aCoder encodeDouble:_longitude forKey:kVehicleLocationLongitude];
}

- (id)copyWithZone:(NSZone *)zone
{
    VehicleLocation *copy = [[VehicleLocation alloc] init];
    
    if (copy) {

        copy.latitude = self.latitude;
        copy.longitude = self.longitude;
    }
    
    return copy;
}


@end
