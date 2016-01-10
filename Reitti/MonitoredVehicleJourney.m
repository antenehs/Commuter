//
//  MonitoredVehicleJourney.m
//
//  Created by Anteneh Sahledengel on 10/1/16
//  Copyright (c) 2016 shaby ltd. All rights reserved.
//

#import "MonitoredVehicleJourney.h"
#import "FramedVehicleJourneyRef.h"
#import "VehicleRef.h"
#import "DirectionRef.h"
#import "VehicleLocation.h"
#import "MonitoredCall.h"
#import "LineRef.h"
#import "OperatorRef.h"


NSString *const kMonitoredVehicleJourneyFramedVehicleJourneyRef = @"FramedVehicleJourneyRef";
NSString *const kMonitoredVehicleJourneyMonitored = @"Monitored";
NSString *const kMonitoredVehicleJourneyVehicleRef = @"VehicleRef";
NSString *const kMonitoredVehicleJourneyDirectionRef = @"DirectionRef";
NSString *const kMonitoredVehicleJourneyVehicleLocation = @"VehicleLocation";
NSString *const kMonitoredVehicleJourneyMonitoredCall = @"MonitoredCall";
NSString *const kMonitoredVehicleJourneyLineRef = @"LineRef";
NSString *const kMonitoredVehicleJourneyOperatorRef = @"OperatorRef";
NSString *const kMonitoredVehicleJourneyDelay = @"Delay";
NSString *const kMonitoredVehicleJourneyBearing = @"Bearing";


@interface MonitoredVehicleJourney ()

- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict;

@end

@implementation MonitoredVehicleJourney

@synthesize framedVehicleJourneyRef = _framedVehicleJourneyRef;
@synthesize monitored = _monitored;
@synthesize vehicleRef = _vehicleRef;
@synthesize directionRef = _directionRef;
@synthesize vehicleLocation = _vehicleLocation;
@synthesize monitoredCall = _monitoredCall;
@synthesize lineRef = _lineRef;
@synthesize operatorRef = _operatorRef;
@synthesize delay = _delay;


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
        self.framedVehicleJourneyRef = [FramedVehicleJourneyRef modelObjectWithDictionary:[dict objectForKey:kMonitoredVehicleJourneyFramedVehicleJourneyRef]];
        self.monitored = [[self objectOrNilForKey:kMonitoredVehicleJourneyMonitored fromDictionary:dict] boolValue];
        self.vehicleRef = [VehicleRef modelObjectWithDictionary:[dict objectForKey:kMonitoredVehicleJourneyVehicleRef]];
        self.directionRef = [DirectionRef modelObjectWithDictionary:[dict objectForKey:kMonitoredVehicleJourneyDirectionRef]];
        self.vehicleLocation = [VehicleLocation modelObjectWithDictionary:[dict objectForKey:kMonitoredVehicleJourneyVehicleLocation]];
        self.monitoredCall = [MonitoredCall modelObjectWithDictionary:[dict objectForKey:kMonitoredVehicleJourneyMonitoredCall]];
        self.lineRef = [LineRef modelObjectWithDictionary:[dict objectForKey:kMonitoredVehicleJourneyLineRef]];
        self.operatorRef = [OperatorRef modelObjectWithDictionary:[dict objectForKey:kMonitoredVehicleJourneyOperatorRef]];
        self.delay = [[self objectOrNilForKey:kMonitoredVehicleJourneyDelay fromDictionary:dict] doubleValue];
        self.bearing = [self objectOrNilForKey:kMonitoredVehicleJourneyBearing fromDictionary:dict];

    }
    
    return self;
    
}

- (NSDictionary *)dictionaryRepresentation
{
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
    [mutableDict setValue:[self.framedVehicleJourneyRef dictionaryRepresentation] forKey:kMonitoredVehicleJourneyFramedVehicleJourneyRef];
    [mutableDict setValue:[NSNumber numberWithBool:self.monitored] forKey:kMonitoredVehicleJourneyMonitored];
    [mutableDict setValue:[self.vehicleRef dictionaryRepresentation] forKey:kMonitoredVehicleJourneyVehicleRef];
    [mutableDict setValue:[self.directionRef dictionaryRepresentation] forKey:kMonitoredVehicleJourneyDirectionRef];
    [mutableDict setValue:[self.vehicleLocation dictionaryRepresentation] forKey:kMonitoredVehicleJourneyVehicleLocation];
    [mutableDict setValue:[self.monitoredCall dictionaryRepresentation] forKey:kMonitoredVehicleJourneyMonitoredCall];
    [mutableDict setValue:[self.lineRef dictionaryRepresentation] forKey:kMonitoredVehicleJourneyLineRef];
    [mutableDict setValue:[self.operatorRef dictionaryRepresentation] forKey:kMonitoredVehicleJourneyOperatorRef];
    [mutableDict setValue:[NSNumber numberWithDouble:self.delay] forKey:kMonitoredVehicleJourneyDelay];
    [mutableDict setValue:self.bearing forKey:kMonitoredVehicleJourneyBearing];

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

    self.framedVehicleJourneyRef = [aDecoder decodeObjectForKey:kMonitoredVehicleJourneyFramedVehicleJourneyRef];
    self.monitored = [aDecoder decodeBoolForKey:kMonitoredVehicleJourneyMonitored];
    self.vehicleRef = [aDecoder decodeObjectForKey:kMonitoredVehicleJourneyVehicleRef];
    self.directionRef = [aDecoder decodeObjectForKey:kMonitoredVehicleJourneyDirectionRef];
    self.vehicleLocation = [aDecoder decodeObjectForKey:kMonitoredVehicleJourneyVehicleLocation];
    self.monitoredCall = [aDecoder decodeObjectForKey:kMonitoredVehicleJourneyMonitoredCall];
    self.lineRef = [aDecoder decodeObjectForKey:kMonitoredVehicleJourneyLineRef];
    self.operatorRef = [aDecoder decodeObjectForKey:kMonitoredVehicleJourneyOperatorRef];
    self.delay = [aDecoder decodeDoubleForKey:kMonitoredVehicleJourneyDelay];
    self.bearing = [aDecoder decodeObjectForKey:kMonitoredVehicleJourneyBearing];
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{

    [aCoder encodeObject:_framedVehicleJourneyRef forKey:kMonitoredVehicleJourneyFramedVehicleJourneyRef];
    [aCoder encodeBool:_monitored forKey:kMonitoredVehicleJourneyMonitored];
    [aCoder encodeObject:_vehicleRef forKey:kMonitoredVehicleJourneyVehicleRef];
    [aCoder encodeObject:_directionRef forKey:kMonitoredVehicleJourneyDirectionRef];
    [aCoder encodeObject:_vehicleLocation forKey:kMonitoredVehicleJourneyVehicleLocation];
    [aCoder encodeObject:_monitoredCall forKey:kMonitoredVehicleJourneyMonitoredCall];
    [aCoder encodeObject:_lineRef forKey:kMonitoredVehicleJourneyLineRef];
    [aCoder encodeObject:_operatorRef forKey:kMonitoredVehicleJourneyOperatorRef];
    [aCoder encodeDouble:_delay forKey:kMonitoredVehicleJourneyDelay];
    [aCoder encodeObject:_bearing forKey:kMonitoredVehicleJourneyBearing];
}

- (id)copyWithZone:(NSZone *)zone
{
    MonitoredVehicleJourney *copy = [[MonitoredVehicleJourney alloc] init];
    
    if (copy) {

        copy.framedVehicleJourneyRef = [self.framedVehicleJourneyRef copyWithZone:zone];
        copy.monitored = self.monitored;
        copy.vehicleRef = [self.vehicleRef copyWithZone:zone];
        copy.directionRef = [self.directionRef copyWithZone:zone];
        copy.vehicleLocation = [self.vehicleLocation copyWithZone:zone];
        copy.monitoredCall = [self.monitoredCall copyWithZone:zone];
        copy.lineRef = [self.lineRef copyWithZone:zone];
        copy.operatorRef = [self.operatorRef copyWithZone:zone];
        copy.delay = self.delay;
    }
    
    return copy;
}


@end
