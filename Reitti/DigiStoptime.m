//
//  DigiStoptimes.m
//
//  Created by Anteneh Sahledengel on 19/5/16
//  Copyright (c) 2016 shaby ltd. All rights reserved.
//

#import "DigiStoptime.h"
#import "DigiDataModels.h"


NSString *const kDigiStoptimesServiceDay = @"serviceDay";
NSString *const kDigiStoptimesScheduledDeparture = @"scheduledDeparture";
NSString *const kDigiStoptimesTrip = @"trip";
NSString *const kDigiStoptimesRealtime = @"realtime";
NSString *const kDigiStoptimesRealtimeDeparture = @"realtimeDeparture";
NSString *const kDigiStoptimesRealtimeState = @"realtimeState";


@interface DigiStoptime ()

- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict;

@end

@implementation DigiStoptime

@synthesize serviceDay = _serviceDay;
@synthesize scheduledDeparture = _scheduledDeparture;
@synthesize trip = _trip;
@synthesize realtime = _realtime;
@synthesize realtimeDeparture = _realtimeDeparture;
@synthesize realtimeState = _realtimeState;


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
            self.serviceDay = [self objectOrNilForKey:kDigiStoptimesServiceDay fromDictionary:dict];
            self.scheduledDeparture = [self objectOrNilForKey:kDigiStoptimesScheduledDeparture fromDictionary:dict];
            self.trip = [DigiTrip modelObjectWithDictionary:[dict objectForKey:kDigiStoptimesTrip]];
            self.realtime = [self objectOrNilForKey:kDigiStoptimesRealtime fromDictionary:dict];
            self.realtimeDeparture = [self objectOrNilForKey:kDigiStoptimesRealtimeDeparture fromDictionary:dict];
            self.realtimeState = [self objectOrNilForKey:kDigiStoptimesRealtimeState fromDictionary:dict];

    }
    
    return self;
    
}

- (NSDictionary *)dictionaryRepresentation
{
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
    [mutableDict setValue:self.serviceDay forKey:kDigiStoptimesServiceDay];
    [mutableDict setValue:self.scheduledDeparture forKey:kDigiStoptimesScheduledDeparture];
    [mutableDict setValue:[self.trip dictionaryRepresentation] forKey:kDigiStoptimesTrip];
    [mutableDict setValue:self.realtime forKey:kDigiStoptimesRealtime];
    [mutableDict setValue:self.realtimeDeparture forKey:kDigiStoptimesRealtimeDeparture];
    [mutableDict setValue:self.realtimeState forKey:kDigiStoptimesRealtimeState];

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

    self.serviceDay = [aDecoder decodeObjectForKey:kDigiStoptimesServiceDay];
    self.scheduledDeparture = [aDecoder decodeObjectForKey:kDigiStoptimesScheduledDeparture];
    self.trip = [aDecoder decodeObjectForKey:kDigiStoptimesTrip];
    self.realtime = [aDecoder decodeObjectForKey:kDigiStoptimesRealtime];
    self.realtimeDeparture = [aDecoder decodeObjectForKey:kDigiStoptimesRealtimeDeparture];
    self.realtimeState = [aDecoder decodeObjectForKey:kDigiStoptimesRealtimeState];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{

    [aCoder encodeObject:_serviceDay forKey:kDigiStoptimesServiceDay];
    [aCoder encodeObject:_scheduledDeparture forKey:kDigiStoptimesScheduledDeparture];
    [aCoder encodeObject:_trip forKey:kDigiStoptimesTrip];
    [aCoder encodeObject:_realtime forKey:kDigiStoptimesRealtime];
    [aCoder encodeObject:_realtimeDeparture forKey:kDigiStoptimesRealtimeDeparture];
    [aCoder encodeObject:_realtimeState forKey:kDigiStoptimesRealtimeState];
}

- (id)copyWithZone:(NSZone *)zone
{
    DigiStoptime *copy = [[DigiStoptime alloc] init];
    
    if (copy) {
        copy.serviceDay = self.serviceDay;
        copy.scheduledDeparture = self.scheduledDeparture;
        copy.trip = [self.trip copyWithZone:zone];
        copy.realtime = self.realtime;
        copy.realtimeDeparture = self.realtimeDeparture;
        copy.realtimeState = [self.realtimeState copyWithZone:zone];
    }
    
    return copy;
}

-(NSDate *)parsedScheduledDepartureDate {
    if (!_parsedScheduledDepartureDate) {
        double departureTime = [self.serviceDay doubleValue] + [self.scheduledDeparture doubleValue];
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:departureTime];
        if (date) _parsedScheduledDepartureDate = date;
    }
    
    return _parsedScheduledDepartureDate;
}

-(NSDate *)parsedRealtimeDepartureDate {
    if (!_parsedRealtimeDepartureDate) {
        double departureTime = [self.serviceDay doubleValue] + [self.realtimeDeparture doubleValue];
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:departureTime];
        if (date) _parsedRealtimeDepartureDate = date;
    }
    
    return _parsedRealtimeDepartureDate;
}

+(NSDictionary *)mappingDictionary {
    return @{
              @"serviceDay"         : @"serviceDay",
              @"scheduledDeparture" : @"scheduledDeparture",
              @"realtimeDeparture"  : @"realtimeDeparture",
              @"realtimeState"      : @"realtimeState",
              @"realtime"           : @"realtime"
              };
}

+(MappingDescriptor *)mappingDescriptorForPath:(NSString *)path {
    MappingRelationShip *tripRelationShip = [MappingRelationShip relationShipFromKeyPath:@"trip"
                                                                               toKeyPath:@"trip"
                                                                        withMappingClass:[DigiTrip class]];
    
    return [MappingDescriptor descriptorFromPath:path
                                        forClass:[self class]
                           withMappingDictionary:[self mappingDictionary]
                                andRelationShips:@[tripRelationShip]];
}

@end
