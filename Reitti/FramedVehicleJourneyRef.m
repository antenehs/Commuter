//
//  FramedVehicleJourneyRef.m
//
//  Created by Anteneh Sahledengel on 10/1/16
//  Copyright (c) 2016 shaby ltd. All rights reserved.
//

#import "FramedVehicleJourneyRef.h"
#import "DataFrameRef.h"


NSString *const kFramedVehicleJourneyRefDatedVehicleJourneyRef = @"DatedVehicleJourneyRef";
NSString *const kFramedVehicleJourneyRefDataFrameRef = @"DataFrameRef";


@interface FramedVehicleJourneyRef ()

- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict;

@end

@implementation FramedVehicleJourneyRef

@synthesize datedVehicleJourneyRef = _datedVehicleJourneyRef;
@synthesize dataFrameRef = _dataFrameRef;


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
            self.datedVehicleJourneyRef = [self objectOrNilForKey:kFramedVehicleJourneyRefDatedVehicleJourneyRef fromDictionary:dict];
            self.dataFrameRef = [DataFrameRef modelObjectWithDictionary:[dict objectForKey:kFramedVehicleJourneyRefDataFrameRef]];

    }
    
    return self;
    
}

- (NSDictionary *)dictionaryRepresentation
{
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
    [mutableDict setValue:self.datedVehicleJourneyRef forKey:kFramedVehicleJourneyRefDatedVehicleJourneyRef];
    [mutableDict setValue:[self.dataFrameRef dictionaryRepresentation] forKey:kFramedVehicleJourneyRefDataFrameRef];

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

    self.datedVehicleJourneyRef = [aDecoder decodeObjectForKey:kFramedVehicleJourneyRefDatedVehicleJourneyRef];
    self.dataFrameRef = [aDecoder decodeObjectForKey:kFramedVehicleJourneyRefDataFrameRef];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{

    [aCoder encodeObject:_datedVehicleJourneyRef forKey:kFramedVehicleJourneyRefDatedVehicleJourneyRef];
    [aCoder encodeObject:_dataFrameRef forKey:kFramedVehicleJourneyRefDataFrameRef];
}

- (id)copyWithZone:(NSZone *)zone
{
    FramedVehicleJourneyRef *copy = [[FramedVehicleJourneyRef alloc] init];
    
    if (copy) {

        copy.datedVehicleJourneyRef = [self.datedVehicleJourneyRef copyWithZone:zone];
        copy.dataFrameRef = [self.dataFrameRef copyWithZone:zone];
    }
    
    return copy;
}


@end
