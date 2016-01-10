//
//  DevHslVehicle.m
//
//  Created by Anteneh Sahledengel on 10/1/16
//  Copyright (c) 2016 shaby ltd. All rights reserved.
//

#import "DevHslVehicle.h"
#import "MonitoredVehicleJourney.h"


NSString *const kDevHslVehicleValidUntilTime = @"ValidUntilTime";
NSString *const kDevHslVehicleMonitoredVehicleJourney = @"MonitoredVehicleJourney";
NSString *const kDevHslVehicleRecordedAtTime = @"RecordedAtTime";


@interface DevHslVehicle ()

- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict;

@end

@implementation DevHslVehicle

@synthesize validUntilTime = _validUntilTime;
@synthesize monitoredVehicleJourney = _monitoredVehicleJourney;
@synthesize recordedAtTime = _recordedAtTime;


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
            self.validUntilTime = [[self objectOrNilForKey:kDevHslVehicleValidUntilTime fromDictionary:dict] doubleValue];
            self.monitoredVehicleJourney = [MonitoredVehicleJourney modelObjectWithDictionary:[dict objectForKey:kDevHslVehicleMonitoredVehicleJourney]];
            self.recordedAtTime = [[self objectOrNilForKey:kDevHslVehicleRecordedAtTime fromDictionary:dict] doubleValue];

    }
    
    return self;
    
}

- (NSDictionary *)dictionaryRepresentation
{
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
    [mutableDict setValue:[NSNumber numberWithDouble:self.validUntilTime] forKey:kDevHslVehicleValidUntilTime];
    [mutableDict setValue:[self.monitoredVehicleJourney dictionaryRepresentation] forKey:kDevHslVehicleMonitoredVehicleJourney];
    [mutableDict setValue:[NSNumber numberWithDouble:self.recordedAtTime] forKey:kDevHslVehicleRecordedAtTime];

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

    self.validUntilTime = [aDecoder decodeDoubleForKey:kDevHslVehicleValidUntilTime];
    self.monitoredVehicleJourney = [aDecoder decodeObjectForKey:kDevHslVehicleMonitoredVehicleJourney];
    self.recordedAtTime = [aDecoder decodeDoubleForKey:kDevHslVehicleRecordedAtTime];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{

    [aCoder encodeDouble:_validUntilTime forKey:kDevHslVehicleValidUntilTime];
    [aCoder encodeObject:_monitoredVehicleJourney forKey:kDevHslVehicleMonitoredVehicleJourney];
    [aCoder encodeDouble:_recordedAtTime forKey:kDevHslVehicleRecordedAtTime];
}

- (id)copyWithZone:(NSZone *)zone
{
    DevHslVehicle *copy = [[DevHslVehicle alloc] init];
    
    if (copy) {

        copy.validUntilTime = self.validUntilTime;
        copy.monitoredVehicleJourney = [self.monitoredVehicleJourney copyWithZone:zone];
        copy.recordedAtTime = self.recordedAtTime;
    }
    
    return copy;
}


@end
