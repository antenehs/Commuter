//
//  TRETreVehicle.m
//
//  Created by Anteneh Sahledengel on 3/4/16
//  Copyright (c) 2016 shaby ltd. All rights reserved.
//

#import "TREVehicle.h"
#import "TREMonitoredVehicleJourney.h"


NSString *const kTRETreVehicleMonitoredVehicleJourney = @"monitoredVehicleJourney";
NSString *const kTRETreVehicleRecordedAtTime = @"recordedAtTime";
NSString *const kTRETreVehicleValidUntilTime = @"validUntilTime";


@interface TREVehicle ()

- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict;

@end

@implementation TREVehicle

@synthesize monitoredVehicleJourney = _monitoredVehicleJourney;
@synthesize recordedAtTime = _recordedAtTime;
@synthesize validUntilTime = _validUntilTime;


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
            self.monitoredVehicleJourney = [TREMonitoredVehicleJourney modelObjectWithDictionary:[dict objectForKey:kTRETreVehicleMonitoredVehicleJourney]];
            self.recordedAtTime = [self objectOrNilForKey:kTRETreVehicleRecordedAtTime fromDictionary:dict];
            self.validUntilTime = [self objectOrNilForKey:kTRETreVehicleValidUntilTime fromDictionary:dict];

    }
    
    return self;
    
}

- (NSDictionary *)dictionaryRepresentation
{
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
    [mutableDict setValue:[self.monitoredVehicleJourney dictionaryRepresentation] forKey:kTRETreVehicleMonitoredVehicleJourney];
    [mutableDict setValue:self.recordedAtTime forKey:kTRETreVehicleRecordedAtTime];
    [mutableDict setValue:self.validUntilTime forKey:kTRETreVehicleValidUntilTime];

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

    self.monitoredVehicleJourney = [aDecoder decodeObjectForKey:kTRETreVehicleMonitoredVehicleJourney];
    self.recordedAtTime = [aDecoder decodeObjectForKey:kTRETreVehicleRecordedAtTime];
    self.validUntilTime = [aDecoder decodeObjectForKey:kTRETreVehicleValidUntilTime];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{

    [aCoder encodeObject:_monitoredVehicleJourney forKey:kTRETreVehicleMonitoredVehicleJourney];
    [aCoder encodeObject:_recordedAtTime forKey:kTRETreVehicleRecordedAtTime];
    [aCoder encodeObject:_validUntilTime forKey:kTRETreVehicleValidUntilTime];
}

- (id)copyWithZone:(NSZone *)zone
{
    TREVehicle *copy = [[TREVehicle alloc] init];
    
    if (copy) {

        copy.monitoredVehicleJourney = [self.monitoredVehicleJourney copyWithZone:zone];
        copy.recordedAtTime = [self.recordedAtTime copyWithZone:zone];
        copy.validUntilTime = [self.validUntilTime copyWithZone:zone];
    }
    
    return copy;
}


@end
