//
//  DigiBikeRentalStation.m
//
//  Created by Anteneh Sahledengel on 28/5/16
//  Copyright (c) 2016 shaby ltd. All rights reserved.
//

#import "DigiBikeRentalStation.h"


NSString *const kDigiBikeRentalStationBikesAvailable = @"bikesAvailable";
NSString *const kDigiBikeRentalStationStationId = @"stationId";
NSString *const kDigiBikeRentalStationRealtime = @"realtime";
NSString *const kDigiBikeRentalStationName = @"name";
NSString *const kDigiBikeRentalStationSpacesAvailable = @"spacesAvailable";


@interface DigiBikeRentalStation ()

- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict;

@end

@implementation DigiBikeRentalStation

@synthesize bikesAvailable = _bikesAvailable;
@synthesize stationId = _stationId;
@synthesize realtime = _realtime;
@synthesize name = _name;
@synthesize spacesAvailable = _spacesAvailable;


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
            self.bikesAvailable = [self objectOrNilForKey:kDigiBikeRentalStationBikesAvailable fromDictionary:dict];
            self.stationId = [self objectOrNilForKey:kDigiBikeRentalStationStationId fromDictionary:dict];
            self.realtime = [[self objectOrNilForKey:kDigiBikeRentalStationRealtime fromDictionary:dict] boolValue];
            self.name = [self objectOrNilForKey:kDigiBikeRentalStationName fromDictionary:dict];
            self.spacesAvailable = [self objectOrNilForKey:kDigiBikeRentalStationSpacesAvailable fromDictionary:dict];

    }
    
    return self;
    
}

- (NSDictionary *)dictionaryRepresentation
{
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
    [mutableDict setValue:self.bikesAvailable forKey:kDigiBikeRentalStationBikesAvailable];
    [mutableDict setValue:self.stationId forKey:kDigiBikeRentalStationStationId];
    [mutableDict setValue:[NSNumber numberWithBool:self.realtime] forKey:kDigiBikeRentalStationRealtime];
    [mutableDict setValue:self.name forKey:kDigiBikeRentalStationName];
    [mutableDict setValue:self.spacesAvailable forKey:kDigiBikeRentalStationSpacesAvailable];

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

    self.bikesAvailable = [aDecoder decodeObjectForKey:kDigiBikeRentalStationBikesAvailable];
    self.stationId = [aDecoder decodeObjectForKey:kDigiBikeRentalStationStationId];
    self.realtime = [[aDecoder decodeObjectForKey:kDigiBikeRentalStationRealtime] boolValue];
    self.name = [aDecoder decodeObjectForKey:kDigiBikeRentalStationName];
    self.spacesAvailable = [aDecoder decodeObjectForKey:kDigiBikeRentalStationSpacesAvailable];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{

    [aCoder encodeObject:_bikesAvailable forKey:kDigiBikeRentalStationBikesAvailable];
    [aCoder encodeObject:_stationId forKey:kDigiBikeRentalStationStationId];
    [aCoder encodeObject:[NSNumber numberWithBool:_realtime] forKey:kDigiBikeRentalStationRealtime];
    [aCoder encodeObject:_name forKey:kDigiBikeRentalStationName];
    [aCoder encodeObject:_spacesAvailable forKey:kDigiBikeRentalStationSpacesAvailable];
}

- (id)copyWithZone:(NSZone *)zone
{
    DigiBikeRentalStation *copy = [[DigiBikeRentalStation alloc] init];
    
    if (copy) {

        copy.bikesAvailable = self.bikesAvailable;
        copy.stationId = [self.stationId copyWithZone:zone];
        copy.realtime = self.realtime;
        copy.name = [self.name copyWithZone:zone];
        copy.spacesAvailable = self.spacesAvailable;
    }
    
    return copy;
}

#pragma mark - mapping
-(BikeStation *)bikeStation {
    BikeStation *station = [BikeStation new];
    
    station.stationId = self.stationId;
    station.name = self.name;
    station.lon = self.lon;
    station.lat = self.lat;
    station.bikesAvailable = self.bikesAvailable;
    station.spacesAvailable = self.spacesAvailable;
    station.allowDropoff = self.allowDropoff;
    station.realTimeData = self.realtime;
    station.distance = self.distance;
    
    return station;
}


+(NSDictionary *)mappingDictionary {
    return @{
             @"place.stationId"       : @"stationId",
             @"place.name"            : @"name",
             @"place.lon"             : @"lon",
             @"place.lat"             : @"lat",
             @"place.bikesAvailable"  : @"bikesAvailable",
             @"place.spacesAvailable" : @"spacesAvailable",
             @"place.allowDropoff"    : @"allowDropoff",
             @"place.realtime"        : @"realtime",
             @"distance"              : @"distance"
             };
    
}

+(MappingDescriptor *)mappingDescriptorForPath:(NSString *)path {
    
    return [MappingDescriptor descriptorFromPath:path
                                        forClass:[self class]
                           withMappingDictionary:[self mappingDictionary]];
}

@end
