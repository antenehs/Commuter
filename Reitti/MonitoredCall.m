//
//  MonitoredCall.m
//
//  Created by Anteneh Sahledengel on 10/1/16
//  Copyright (c) 2016 shaby ltd. All rights reserved.
//

#import "MonitoredCall.h"


NSString *const kMonitoredCallStopPointRef = @"StopPointRef";


@interface MonitoredCall ()

- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict;

@end

@implementation MonitoredCall

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
            self.stopPointRef = [self objectOrNilForKey:kMonitoredCallStopPointRef fromDictionary:dict];

    }
    
    return self;
    
}

- (NSDictionary *)dictionaryRepresentation
{
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
    [mutableDict setValue:self.stopPointRef forKey:kMonitoredCallStopPointRef];

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

    self.stopPointRef = [aDecoder decodeObjectForKey:kMonitoredCallStopPointRef];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{

    [aCoder encodeObject:_stopPointRef forKey:kMonitoredCallStopPointRef];
}

- (id)copyWithZone:(NSZone *)zone
{
    MonitoredCall *copy = [[MonitoredCall alloc] init];
    
    if (copy) {

        copy.stopPointRef = [self.stopPointRef copyWithZone:zone];
    }
    
    return copy;
}


@end
