//
//  Departures.m
//
//  Created by Anteneh Sahledengel on 18/12/15
//  Copyright (c) 2015 shaby ltd. All rights reserved.
//

#import "StopDeparture.h"


NSString *const kDeparturesCode = @"code";
NSString *const kDeparturesDate = @"date";
NSString *const kDeparturesName = @"name";
NSString *const kDeparturesTime = @"time";
NSString *const kDeparturesDirection = @"direction";
NSString *const kDestination = @"destination";
NSString *const kParsedDate = @"parsedDate";


@interface StopDeparture ()

- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict;

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
            self.date = [[self objectOrNilForKey:kDeparturesDate fromDictionary:dict] stringValue];
            self.name = [self objectOrNilForKey:kDeparturesName fromDictionary:dict];
            self.time = [self objectOrNilForKey:kDeparturesTime fromDictionary:dict];
            self.direction = [self objectOrNilForKey:kDeparturesDirection fromDictionary:dict];

    }
    
    return self;
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

- (NSDictionary *)dictionaryRepresentation
{
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
    [mutableDict setValue:self.code forKey:kDeparturesCode];
    [mutableDict setValue:self.date forKey:kDeparturesDate];
    [mutableDict setValue:self.name forKey:kDeparturesName];
    [mutableDict setValue:self.time forKey:kDeparturesTime];
    [mutableDict setValue:self.direction forKey:kDeparturesDirection];
    [mutableDict setValue:self.destination forKey:kDestination];
    [mutableDict setValue:self.parsedDate forKey:kParsedDate];

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

    self.code = [aDecoder decodeObjectForKey:kDeparturesCode];
    self.date = [aDecoder decodeObjectForKey:kDeparturesDate];
    self.name = [aDecoder decodeObjectForKey:kDeparturesName];
    self.time = [aDecoder decodeObjectForKey:kDeparturesTime];
    self.direction = [aDecoder decodeObjectForKey:kDeparturesDirection];
    self.destination = [aDecoder decodeObjectForKey:kDestination];
    self.parsedDate = [aDecoder decodeObjectForKey:kParsedDate];
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
    [aCoder encodeObject:_parsedDate forKey:kParsedDate];
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
        copy.parsedDate = [self.parsedDate copyWithZone:zone];
    }
    
    return copy;
}


@end
