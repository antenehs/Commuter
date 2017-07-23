//
//  Departures.m
//
//  Created by Anteneh Sahledengel on 18/12/15
//  Copyright (c) 2015 shaby ltd. All rights reserved.
//

#import "StopDeparture.h"
#import "AppManager.h"
#import "AppFeatureManager.h"

NSString *const kDeparturesCode = @"code";
NSString *const kDeparturesDate = @"date";
NSString *const kDeparturesName = @"name";
NSString *const kDeparturesTime = @"time";
NSString *const kDeparturesDirection = @"direction";
NSString *const kDestination = @"destination";
NSString *const kParsedScheduledDate = @"parsedScheduledDate";
NSString *const kParsedRealtimeDate = @"parsedRealTimeDate";
NSString *const kIsRealTime = @"isRealTime";


@interface StopDeparture ()

- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict;
@property (nonatomic, strong) NSDate *departureTime;

@end

@implementation StopDeparture

@synthesize code = _code;
@synthesize date = _date;
@synthesize name = _name;
@synthesize time = _time;
@synthesize direction = _direction;
@synthesize destination = _destination;

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
            self.code = [self objectOrNilForKey:kDeparturesCode fromDictionary:dict];
            self.date = [self objectOrNilForKey:kDeparturesDate fromDictionary:dict];
            self.name = [self objectOrNilForKey:kDeparturesName fromDictionary:dict];
            self.time = [self objectOrNilForKey:kDeparturesTime fromDictionary:dict];
            self.direction = [self objectOrNilForKey:kDeparturesDirection fromDictionary:dict];
            self.destination = [self objectOrNilForKey:kDestination fromDictionary:dict];
            self.parsedScheduledDate = [self objectOrNilForKey:kParsedScheduledDate fromDictionary:dict];
            self.parsedRealtimeDate = [self objectOrNilForKey:kParsedRealtimeDate fromDictionary:dict];
            self.isRealTime = [[self objectOrNilForKey:kIsRealTime fromDictionary:dict] boolValue];
    }
    
    [self setDefaultValues];
    
    return self;
}

- (NSDictionary *)dictionaryRepresentation
{
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
    [mutableDict setValue:self.code forKey:kDeparturesCode];
    [mutableDict setValue:self.date forKey:kDeparturesDate];
    [mutableDict setValue:self.name forKey:kDeparturesName];
    [mutableDict setValue:self.time forKey:kDeparturesTime];
    [mutableDict setValue:self.direction forKey:kDeparturesDirection];
    [mutableDict setValue:self.destination forKey:kDestination];
    [mutableDict setValue:self.parsedScheduledDate forKey:kParsedScheduledDate];
    [mutableDict setValue:self.parsedRealtimeDate forKey:kParsedRealtimeDate];
    [mutableDict setValue:[NSNumber numberWithBool:self.isRealTime] forKey:kIsRealTime];
    
    return [NSDictionary dictionaryWithDictionary:mutableDict];
}

-(instancetype)init {
    self = [super init];
    
    if (self) {
        [self setDefaultValues];
    }
    
    return self;
}

-(void)setDefaultValues {
    self.isRealTime = false;
}


//Api might sometimes return the incorrect type, do make sure the type match in a getter

-(NSString *)time{
    if ([_time isKindOfClass:[NSString class]]) {
        return _time;
    }else if ([_time isKindOfClass:[NSNumber class]]){
        return [NSString stringWithFormat:@"%d", [_time intValue]];
    }
    
    return _time;
}

-(NSString *)date{
    if ([_date isKindOfClass:[NSString class]]) {
        return _date;
    }else if ([_date isKindOfClass:[NSNumber class]]){
        return [NSString stringWithFormat:@"%d", [_date intValue]];
    }
    
    return _date;
}

- (NSString *)description 
{
    return [NSString stringWithFormat:@"%@", [self dictionaryRepresentation]];
}

-(NSDate *)departureTime {
    if (!_departureTime) {
        if ([AppFeatureManager proFeaturesAvailable] && self.isRealTime && self.parsedRealtimeDate) {
            _departureTime = self.parsedRealtimeDate;
        } else {
            _departureTime = self.parsedScheduledDate;
        }
    }
    
    return _departureTime;
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

    self.code = [aDecoder decodeObjectForKey:kDeparturesCode];
    self.date = [aDecoder decodeObjectForKey:kDeparturesDate];
    self.name = [aDecoder decodeObjectForKey:kDeparturesName];
    self.time = [aDecoder decodeObjectForKey:kDeparturesTime];
    self.direction = [aDecoder decodeObjectForKey:kDeparturesDirection];
    self.destination = [aDecoder decodeObjectForKey:kDestination];
    self.parsedScheduledDate = [aDecoder decodeObjectForKey:kParsedScheduledDate];
    self.parsedRealtimeDate = [aDecoder decodeObjectForKey:kParsedRealtimeDate];
    self.isRealTime = [aDecoder decodeBoolForKey:kIsRealTime];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{

    [aCoder encodeObject:_code forKey:kDeparturesCode];
    [aCoder encodeObject:_date forKey:kDeparturesDate];
    [aCoder encodeObject:_name forKey:kDeparturesName];
    [aCoder encodeObject:_time forKey:kDeparturesTime];
    [aCoder encodeObject:_direction forKey:kDeparturesDirection];
    [aCoder encodeObject:_destination forKey:kDestination];
    [aCoder encodeObject:_parsedScheduledDate forKey:kParsedScheduledDate];
    [aCoder encodeObject:_parsedRealtimeDate forKey:kParsedRealtimeDate];
    [aCoder encodeBool:_isRealTime forKey:kIsRealTime];
}

- (id)copyWithZone:(NSZone *)zone
{
    StopDeparture *copy = [[StopDeparture alloc] init];
    
    if (copy) {

        copy.code = [self.code copyWithZone:zone];
        copy.date = [self.date copyWithZone:zone];
        copy.name = [self.name copyWithZone:zone];
        copy.time = [self.time copyWithZone:zone];
        copy.direction = [self.direction copyWithZone:zone];
        copy.destination = [self.destination copyWithZone:zone];
        copy.parsedScheduledDate = [self.parsedScheduledDate copyWithZone:zone];
        copy.parsedRealtimeDate = [self.parsedRealtimeDate copyWithZone:zone];
        copy.isRealTime = self.isRealTime;
    }
    
    return copy;
}


@end
