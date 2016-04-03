//
//  TREFramedVehicleJourneyRef.m
//
//  Created by Anteneh Sahledengel on 3/4/16
//  Copyright (c) 2016 shaby ltd. All rights reserved.
//

#import "TREFramedVehicleJourneyRef.h"


NSString *const kTREFramedVehicleJourneyRefDateFrameRef = @"dateFrameRef";
NSString *const kTREFramedVehicleJourneyRefDatedVehicleJourneyRef = @"datedVehicleJourneyRef";


@interface TREFramedVehicleJourneyRef ()

- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict;

@end

@implementation TREFramedVehicleJourneyRef

@synthesize dateFrameRef = _dateFrameRef;
@synthesize datedVehicleJourneyRef = _datedVehicleJourneyRef;


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
            self.dateFrameRef = [self objectOrNilForKey:kTREFramedVehicleJourneyRefDateFrameRef fromDictionary:dict];
            self.datedVehicleJourneyRef = [self objectOrNilForKey:kTREFramedVehicleJourneyRefDatedVehicleJourneyRef fromDictionary:dict];

    }
    
    return self;
    
}

- (NSDictionary *)dictionaryRepresentation
{
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
    [mutableDict setValue:self.dateFrameRef forKey:kTREFramedVehicleJourneyRefDateFrameRef];
    [mutableDict setValue:self.datedVehicleJourneyRef forKey:kTREFramedVehicleJourneyRefDatedVehicleJourneyRef];

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

    self.dateFrameRef = [aDecoder decodeObjectForKey:kTREFramedVehicleJourneyRefDateFrameRef];
    self.datedVehicleJourneyRef = [aDecoder decodeObjectForKey:kTREFramedVehicleJourneyRefDatedVehicleJourneyRef];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{

    [aCoder encodeObject:_dateFrameRef forKey:kTREFramedVehicleJourneyRefDateFrameRef];
    [aCoder encodeObject:_datedVehicleJourneyRef forKey:kTREFramedVehicleJourneyRefDatedVehicleJourneyRef];
}

- (id)copyWithZone:(NSZone *)zone
{
    TREFramedVehicleJourneyRef *copy = [[TREFramedVehicleJourneyRef alloc] init];
    
    if (copy) {

        copy.dateFrameRef = [self.dateFrameRef copyWithZone:zone];
        copy.datedVehicleJourneyRef = [self.datedVehicleJourneyRef copyWithZone:zone];
    }
    
    return copy;
}


@end
