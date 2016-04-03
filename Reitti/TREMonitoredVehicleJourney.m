//
//  TREMonitoredVehicleJourney.m
//
//  Created by Anteneh Sahledengel on 3/4/16
//  Copyright (c) 2016 shaby ltd. All rights reserved.
//

#import "TREMonitoredVehicleJourney.h"
#import "TREFramedVehicleJourneyRef.h"
#import "TREVehicleLocation.h"
#import "TREOnwardCalls.h"


NSString *const kTREMonitoredVehicleJourneySpeed = @"speed";
NSString *const kTREMonitoredVehicleJourneyDestinationShortName = @"destinationShortName";
NSString *const kTREMonitoredVehicleJourneyBearing = @"bearing";
NSString *const kTREMonitoredVehicleJourneyVehicleRef = @"vehicleRef";
NSString *const kTREMonitoredVehicleJourneyDelay = @"delay";
NSString *const kTREMonitoredVehicleJourneyLineRef = @"lineRef";
NSString *const kTREMonitoredVehicleJourneyFramedVehicleJourneyRef = @"framedVehicleJourneyRef";
NSString *const kTREMonitoredVehicleJourneyVehicleLocation = @"vehicleLocation";
NSString *const kTREMonitoredVehicleJourneyOriginShortName = @"originShortName";
NSString *const kTREMonitoredVehicleJourneyJourneyPatternRef = @"journeyPatternRef";
NSString *const kTREMonitoredVehicleJourneyDirectionRef = @"directionRef";
NSString *const kTREMonitoredVehicleJourneyOnwardCalls = @"onwardCalls";
NSString *const kTREMonitoredVehicleJourneyOperatorRef = @"operatorRef";
NSString *const kTREMonitoredVehicleJourneyOriginAimedDepartureTime = @"originAimedDepartureTime";


@interface TREMonitoredVehicleJourney ()

- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict;

@end

@implementation TREMonitoredVehicleJourney

@synthesize speed = _speed;
@synthesize destinationShortName = _destinationShortName;
@synthesize bearing = _bearing;
@synthesize vehicleRef = _vehicleRef;
@synthesize delay = _delay;
@synthesize lineRef = _lineRef;
@synthesize framedVehicleJourneyRef = _framedVehicleJourneyRef;
@synthesize vehicleLocation = _vehicleLocation;
@synthesize originShortName = _originShortName;
@synthesize journeyPatternRef = _journeyPatternRef;
@synthesize directionRef = _directionRef;
@synthesize onwardCalls = _onwardCalls;
@synthesize operatorRef = _operatorRef;
@synthesize originAimedDepartureTime = _originAimedDepartureTime;


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
            self.speed = [self objectOrNilForKey:kTREMonitoredVehicleJourneySpeed fromDictionary:dict];
            self.destinationShortName = [self objectOrNilForKey:kTREMonitoredVehicleJourneyDestinationShortName fromDictionary:dict];
            self.bearing = [self objectOrNilForKey:kTREMonitoredVehicleJourneyBearing fromDictionary:dict];
            self.vehicleRef = [self objectOrNilForKey:kTREMonitoredVehicleJourneyVehicleRef fromDictionary:dict];
            self.delay = [self objectOrNilForKey:kTREMonitoredVehicleJourneyDelay fromDictionary:dict];
            self.lineRef = [self objectOrNilForKey:kTREMonitoredVehicleJourneyLineRef fromDictionary:dict];
            self.framedVehicleJourneyRef = [TREFramedVehicleJourneyRef modelObjectWithDictionary:[dict objectForKey:kTREMonitoredVehicleJourneyFramedVehicleJourneyRef]];
            self.vehicleLocation = [TREVehicleLocation modelObjectWithDictionary:[dict objectForKey:kTREMonitoredVehicleJourneyVehicleLocation]];
            self.originShortName = [self objectOrNilForKey:kTREMonitoredVehicleJourneyOriginShortName fromDictionary:dict];
            self.journeyPatternRef = [self objectOrNilForKey:kTREMonitoredVehicleJourneyJourneyPatternRef fromDictionary:dict];
            self.directionRef = [self objectOrNilForKey:kTREMonitoredVehicleJourneyDirectionRef fromDictionary:dict];
    NSObject *receivedTREOnwardCalls = [dict objectForKey:kTREMonitoredVehicleJourneyOnwardCalls];
    NSMutableArray *parsedTREOnwardCalls = [NSMutableArray array];
    if ([receivedTREOnwardCalls isKindOfClass:[NSArray class]]) {
        for (NSDictionary *item in (NSArray *)receivedTREOnwardCalls) {
            if ([item isKindOfClass:[NSDictionary class]]) {
                [parsedTREOnwardCalls addObject:[TREOnwardCalls modelObjectWithDictionary:item]];
            }
       }
    } else if ([receivedTREOnwardCalls isKindOfClass:[NSDictionary class]]) {
       [parsedTREOnwardCalls addObject:[TREOnwardCalls modelObjectWithDictionary:(NSDictionary *)receivedTREOnwardCalls]];
    }

    self.onwardCalls = [NSArray arrayWithArray:parsedTREOnwardCalls];
            self.operatorRef = [self objectOrNilForKey:kTREMonitoredVehicleJourneyOperatorRef fromDictionary:dict];
            self.originAimedDepartureTime = [self objectOrNilForKey:kTREMonitoredVehicleJourneyOriginAimedDepartureTime fromDictionary:dict];

    }
    
    return self;
    
}

- (NSDictionary *)dictionaryRepresentation
{
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
    [mutableDict setValue:self.speed forKey:kTREMonitoredVehicleJourneySpeed];
    [mutableDict setValue:self.destinationShortName forKey:kTREMonitoredVehicleJourneyDestinationShortName];
    [mutableDict setValue:self.bearing forKey:kTREMonitoredVehicleJourneyBearing];
    [mutableDict setValue:self.vehicleRef forKey:kTREMonitoredVehicleJourneyVehicleRef];
    [mutableDict setValue:self.delay forKey:kTREMonitoredVehicleJourneyDelay];
    [mutableDict setValue:self.lineRef forKey:kTREMonitoredVehicleJourneyLineRef];
    [mutableDict setValue:[self.framedVehicleJourneyRef dictionaryRepresentation] forKey:kTREMonitoredVehicleJourneyFramedVehicleJourneyRef];
    [mutableDict setValue:[self.vehicleLocation dictionaryRepresentation] forKey:kTREMonitoredVehicleJourneyVehicleLocation];
    [mutableDict setValue:self.originShortName forKey:kTREMonitoredVehicleJourneyOriginShortName];
    [mutableDict setValue:self.journeyPatternRef forKey:kTREMonitoredVehicleJourneyJourneyPatternRef];
    [mutableDict setValue:self.directionRef forKey:kTREMonitoredVehicleJourneyDirectionRef];
    NSMutableArray *tempArrayForOnwardCalls = [NSMutableArray array];
    for (NSObject *subArrayObject in self.onwardCalls) {
        if([subArrayObject respondsToSelector:@selector(dictionaryRepresentation)]) {
            // This class is a model object
            [tempArrayForOnwardCalls addObject:[subArrayObject performSelector:@selector(dictionaryRepresentation)]];
        } else {
            // Generic object
            [tempArrayForOnwardCalls addObject:subArrayObject];
        }
    }
    [mutableDict setValue:[NSArray arrayWithArray:tempArrayForOnwardCalls] forKey:kTREMonitoredVehicleJourneyOnwardCalls];
    [mutableDict setValue:self.operatorRef forKey:kTREMonitoredVehicleJourneyOperatorRef];
    [mutableDict setValue:self.originAimedDepartureTime forKey:kTREMonitoredVehicleJourneyOriginAimedDepartureTime];

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

    self.speed = [aDecoder decodeObjectForKey:kTREMonitoredVehicleJourneySpeed];
    self.destinationShortName = [aDecoder decodeObjectForKey:kTREMonitoredVehicleJourneyDestinationShortName];
    self.bearing = [aDecoder decodeObjectForKey:kTREMonitoredVehicleJourneyBearing];
    self.vehicleRef = [aDecoder decodeObjectForKey:kTREMonitoredVehicleJourneyVehicleRef];
    self.delay = [aDecoder decodeObjectForKey:kTREMonitoredVehicleJourneyDelay];
    self.lineRef = [aDecoder decodeObjectForKey:kTREMonitoredVehicleJourneyLineRef];
    self.framedVehicleJourneyRef = [aDecoder decodeObjectForKey:kTREMonitoredVehicleJourneyFramedVehicleJourneyRef];
    self.vehicleLocation = [aDecoder decodeObjectForKey:kTREMonitoredVehicleJourneyVehicleLocation];
    self.originShortName = [aDecoder decodeObjectForKey:kTREMonitoredVehicleJourneyOriginShortName];
    self.journeyPatternRef = [aDecoder decodeObjectForKey:kTREMonitoredVehicleJourneyJourneyPatternRef];
    self.directionRef = [aDecoder decodeObjectForKey:kTREMonitoredVehicleJourneyDirectionRef];
    self.onwardCalls = [aDecoder decodeObjectForKey:kTREMonitoredVehicleJourneyOnwardCalls];
    self.operatorRef = [aDecoder decodeObjectForKey:kTREMonitoredVehicleJourneyOperatorRef];
    self.originAimedDepartureTime = [aDecoder decodeObjectForKey:kTREMonitoredVehicleJourneyOriginAimedDepartureTime];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{

    [aCoder encodeObject:_speed forKey:kTREMonitoredVehicleJourneySpeed];
    [aCoder encodeObject:_destinationShortName forKey:kTREMonitoredVehicleJourneyDestinationShortName];
    [aCoder encodeObject:_bearing forKey:kTREMonitoredVehicleJourneyBearing];
    [aCoder encodeObject:_vehicleRef forKey:kTREMonitoredVehicleJourneyVehicleRef];
    [aCoder encodeObject:_delay forKey:kTREMonitoredVehicleJourneyDelay];
    [aCoder encodeObject:_lineRef forKey:kTREMonitoredVehicleJourneyLineRef];
    [aCoder encodeObject:_framedVehicleJourneyRef forKey:kTREMonitoredVehicleJourneyFramedVehicleJourneyRef];
    [aCoder encodeObject:_vehicleLocation forKey:kTREMonitoredVehicleJourneyVehicleLocation];
    [aCoder encodeObject:_originShortName forKey:kTREMonitoredVehicleJourneyOriginShortName];
    [aCoder encodeObject:_journeyPatternRef forKey:kTREMonitoredVehicleJourneyJourneyPatternRef];
    [aCoder encodeObject:_directionRef forKey:kTREMonitoredVehicleJourneyDirectionRef];
    [aCoder encodeObject:_onwardCalls forKey:kTREMonitoredVehicleJourneyOnwardCalls];
    [aCoder encodeObject:_operatorRef forKey:kTREMonitoredVehicleJourneyOperatorRef];
    [aCoder encodeObject:_originAimedDepartureTime forKey:kTREMonitoredVehicleJourneyOriginAimedDepartureTime];
}

- (id)copyWithZone:(NSZone *)zone
{
    TREMonitoredVehicleJourney *copy = [[TREMonitoredVehicleJourney alloc] init];
    
    if (copy) {

        copy.speed = [self.speed copyWithZone:zone];
        copy.destinationShortName = [self.destinationShortName copyWithZone:zone];
        copy.bearing = [self.bearing copyWithZone:zone];
        copy.vehicleRef = [self.vehicleRef copyWithZone:zone];
        copy.delay = [self.delay copyWithZone:zone];
        copy.lineRef = [self.lineRef copyWithZone:zone];
        copy.framedVehicleJourneyRef = [self.framedVehicleJourneyRef copyWithZone:zone];
        copy.vehicleLocation = [self.vehicleLocation copyWithZone:zone];
        copy.originShortName = [self.originShortName copyWithZone:zone];
        copy.journeyPatternRef = [self.journeyPatternRef copyWithZone:zone];
        copy.directionRef = [self.directionRef copyWithZone:zone];
        copy.onwardCalls = [self.onwardCalls copyWithZone:zone];
        copy.operatorRef = [self.operatorRef copyWithZone:zone];
        copy.originAimedDepartureTime = [self.originAimedDepartureTime copyWithZone:zone];
    }
    
    return copy;
}


@end
