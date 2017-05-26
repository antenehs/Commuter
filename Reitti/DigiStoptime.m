//
//  DigiStoptimes.m
//
//  Created by Anteneh Sahledengel on 19/5/16
//  Copyright (c) 2016 shaby ltd. All rights reserved.
//

#import "DigiStoptime.h"
#import "DigiDataModels.h"
#import "ASA_Helpers.h"


NSString *const kDigiStoptimesServiceDay = @"serviceDay";
NSString *const kDigiStoptimesScheduledDeparture = @"scheduledDeparture";
NSString *const kDigiStoptimesRouteLongName = @"routeLongName";
NSString *const kDigiStoptimesRouteShortName = @"routeShortName";
NSString *const kDigiStoptimesRouteDestination = @"destination";
NSString *const kDigiStoptimesRealtime = @"realtime";
NSString *const kDigiStoptimesRealtimeDeparture = @"realtimeDeparture";
NSString *const kDigiStoptimesRealtimeState = @"realtimeState";


@interface DigiStoptime ()

- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict;

@end

@implementation DigiStoptime

@synthesize serviceDay = _serviceDay;
@synthesize scheduledDeparture = _scheduledDeparture;
//@synthesize trip = _trip;
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
    //TODO: Think of this later. Such a hackkkkkk!!!!!
    if(self && [dict isKindOfClass:[NSDictionary class]]) {
        self.serviceDay = [self objectOrNilForKey:kDigiStoptimesServiceDay fromDictionary:dict];
        self.scheduledDeparture = [self objectOrNilForKey:@"scheduledDeparture" fromDictionary:dict];
        self.routeLongName = [dict valueForKeyPath:@"trip.route.longName"];
        self.routeShortName = [dict valueForKeyPath:@"trip.route.shortName"];
        self.destination = [dict valueForKeyPath:@"trip.route.tripHeadsign"];
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
    [mutableDict setValue:self.routeLongName forKey:kDigiStoptimesRouteLongName];
    [mutableDict setValue:self.routeShortName forKey:kDigiStoptimesRouteShortName];
    [mutableDict setValue:self.destination forKey:kDigiStoptimesRouteDestination];
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
    self.routeLongName = [aDecoder decodeObjectForKey:kDigiStoptimesRouteLongName];
    self.routeShortName = [aDecoder decodeObjectForKey:kDigiStoptimesRouteShortName];
    self.destination = [aDecoder decodeObjectForKey:kDigiStoptimesRouteDestination];
    self.realtime = [aDecoder decodeObjectForKey:kDigiStoptimesRealtime];
    self.realtimeDeparture = [aDecoder decodeObjectForKey:kDigiStoptimesRealtimeDeparture];
    self.realtimeState = [aDecoder decodeObjectForKey:kDigiStoptimesRealtimeState];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{

    [aCoder encodeObject:_serviceDay forKey:kDigiStoptimesServiceDay];
    [aCoder encodeObject:_scheduledDeparture forKey:kDigiStoptimesScheduledDeparture];
    [aCoder encodeObject:_routeLongName forKey:kDigiStoptimesRouteLongName];
    [aCoder encodeObject:_routeShortName forKey:kDigiStoptimesRouteShortName];
    [aCoder encodeObject:_destination forKey:kDigiStoptimesRouteDestination];
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
        copy.routeLongName = [self.routeLongName copyWithZone:zone];
        copy.routeShortName = [self.routeShortName copyWithZone:zone];
        copy.destination = [self.destination copyWithZone:zone];
        copy.realtime = self.realtime;
        copy.realtimeDeparture = self.realtimeDeparture;
        copy.realtimeState = [self.realtimeState copyWithZone:zone];
    }
    
    return copy;
}

#pragma mark - Computed properties
-(NSString *)destination {
    if (!_destination) {
        _destination = [DigiRouteShort routeDestinationFromLongName:self.routeLongName];
    }
    
    return _destination;
}

-(NSDate *)parsedScheduledDepartureDate {
    if (!_parsedScheduledDepartureDate) {
        NSDate *date = [self parseTime:self.scheduledDeparture];
        if (date) _parsedScheduledDepartureDate = date;
    }
    
    return _parsedScheduledDepartureDate;
}

-(NSDate *)parsedRealtimeDepartureDate {
    if (!_parsedRealtimeDepartureDate) {
        NSDate *date = [self parseTime:self.realtimeDeparture];
        if (date) _parsedRealtimeDepartureDate = date;
    }
    
    return _parsedRealtimeDepartureDate;
}

-(NSDate *)parsedScheduledArrivalDate {
    if (!_parsedScheduledArrivalDate) {
        NSDate *date = [self parseTime:self.scheduledArrival];
        if (date) _parsedScheduledArrivalDate = date;
    }
    
    return _parsedScheduledArrivalDate;
}

-(NSDate *)parsedRealtimeArrivalDate {
    if (!_parsedRealtimeArrivalDate) {
        NSDate *date = [self parseTime:self.realtimeArrival];
        if (date) _parsedRealtimeArrivalDate = date;
    }
    
    return _parsedRealtimeArrivalDate;
}

-(NSDate *)parseTime:(NSNumber *)unixTime {
    double dateSeconds = self.serviceDay && ![self.serviceDay  isEqual: @0] ? [self.serviceDay doubleValue]
    : [[[NSDate date] asa_dateIgnoringTime] timeIntervalSince1970];
    double time = dateSeconds + [unixTime doubleValue];
    return [NSDate dateWithTimeIntervalSince1970:time];
}

#pragma mark - conversion
-(StopDeparture *)reittiStopDeparture {
    StopDeparture *departure = [StopDeparture new];
    
    //TODO: Full info when needed. Now we are only interested in the realtime times.
    departure.code = self.routeShortName;
    departure.date = nil;
    departure.name = self.routeLongName;
    departure.time = nil;
    departure.direction = nil;
    departure.destination = self.destination;
    departure.parsedScheduledDate = self.parsedScheduledDepartureDate;
    departure.parsedRealtimeDate = self.parsedRealtimeDepartureDate;
    departure.isRealTime = [self.realtime boolValue];
    
    return departure;
}

#pragma mark - mapping
+(NSDictionary *)mappingDictionary {
    return @{
              @"trip.route.longName"    : @"routeLongName",
              @"trip.route.shortName"   : @"routeShortName",
              @"stop.name"              : @"stopName",
              @"stop.gtfsId"            : @"stopGtfsId",
              @"trip.tripHeadsign"      : @"destination",
              @"serviceDay"             : @"serviceDay",
              @"scheduledDeparture"     : @"scheduledDeparture",
              @"realtimeDeparture"      : @"realtimeDeparture",
              @"realtimeArrival"        : @"realtimeArrival",
              @"scheduledArrival"       : @"scheduledArrival",
              @"realtimeState"          : @"realtimeState",
              @"realtime"               : @"realtime"
              };
}

+(MappingDescriptor *)mappingDescriptorForPath:(NSString *)path {
//    MappingRelationShip *tripRelationShip = [MappingRelationShip relationShipFromKeyPath:@"trip"
//                                                                               toKeyPath:@"trip"
//                                                                        withMappingClass:[DigiTrip class]];
    
    return [MappingDescriptor descriptorFromPath:path
                                        forClass:[self class]
                           withMappingDictionary:[self mappingDictionary]];
}

@end
