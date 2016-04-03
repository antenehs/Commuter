//
//  TREOnwardCalls.m
//
//  Created by Anteneh Sahledengel on 3/4/16
//  Copyright (c) 2016 shaby ltd. All rights reserved.
//

#import "TREOnwardCalls.h"


NSString *const kTREOnwardCallsExpectedDepartureTime = @"expectedDepartureTime";
NSString *const kTREOnwardCallsOrder = @"order";
NSString *const kTREOnwardCallsExpectedArrivalTime = @"expectedArrivalTime";
NSString *const kTREOnwardCallsStopPointRef = @"stopPointRef";


@interface TREOnwardCalls ()

- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict;

@end

@implementation TREOnwardCalls

@synthesize expectedDepartureTime = _expectedDepartureTime;
@synthesize order = _order;
@synthesize expectedArrivalTime = _expectedArrivalTime;
@synthesize stopPointRef = _stopPointRef;


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
            self.expectedDepartureTime = [self objectOrNilForKey:kTREOnwardCallsExpectedDepartureTime fromDictionary:dict];
            self.order = [self objectOrNilForKey:kTREOnwardCallsOrder fromDictionary:dict];
            self.expectedArrivalTime = [self objectOrNilForKey:kTREOnwardCallsExpectedArrivalTime fromDictionary:dict];
            self.stopPointRef = [self objectOrNilForKey:kTREOnwardCallsStopPointRef fromDictionary:dict];

    }
    
    return self;
    
}

- (NSDictionary *)dictionaryRepresentation
{
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
    [mutableDict setValue:self.expectedDepartureTime forKey:kTREOnwardCallsExpectedDepartureTime];
    [mutableDict setValue:self.order forKey:kTREOnwardCallsOrder];
    [mutableDict setValue:self.expectedArrivalTime forKey:kTREOnwardCallsExpectedArrivalTime];
    [mutableDict setValue:self.stopPointRef forKey:kTREOnwardCallsStopPointRef];

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

    self.expectedDepartureTime = [aDecoder decodeObjectForKey:kTREOnwardCallsExpectedDepartureTime];
    self.order = [aDecoder decodeObjectForKey:kTREOnwardCallsOrder];
    self.expectedArrivalTime = [aDecoder decodeObjectForKey:kTREOnwardCallsExpectedArrivalTime];
    self.stopPointRef = [aDecoder decodeObjectForKey:kTREOnwardCallsStopPointRef];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{

    [aCoder encodeObject:_expectedDepartureTime forKey:kTREOnwardCallsExpectedDepartureTime];
    [aCoder encodeObject:_order forKey:kTREOnwardCallsOrder];
    [aCoder encodeObject:_expectedArrivalTime forKey:kTREOnwardCallsExpectedArrivalTime];
    [aCoder encodeObject:_stopPointRef forKey:kTREOnwardCallsStopPointRef];
}

- (id)copyWithZone:(NSZone *)zone
{
    TREOnwardCalls *copy = [[TREOnwardCalls alloc] init];
    
    if (copy) {

        copy.expectedDepartureTime = [self.expectedDepartureTime copyWithZone:zone];
        copy.order = [self.order copyWithZone:zone];
        copy.expectedArrivalTime = [self.expectedArrivalTime copyWithZone:zone];
        copy.stopPointRef = [self.stopPointRef copyWithZone:zone];
    }
    
    return copy;
}


@end
