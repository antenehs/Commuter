//
//  Stops.m
//
//  Created by Anteneh Sahledengel on 19/5/16
//  Copyright (c) 2016 shaby ltd. All rights reserved.
//

#import "DigiStop.h"
#import "DigiStoptime.h"

NSString *const kStopsStoptimes = @"stoptimes";

@interface DigiStop ()

- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict;

@end

@implementation DigiStop

@synthesize stoptimes = _stoptimes;


+ (instancetype)modelObjectWithDictionary:(NSDictionary *)dict
{
    return [[self alloc] initWithDictionary:dict];
}

- (instancetype)initWithDictionary:(NSDictionary *)dict
{
    self = [super initWithDictionary:dict];
    
    // This check serves to make sure that a non-NSDictionary object
    // passed into the model class doesn't break the parsing.
    if(self && [dict isKindOfClass:[NSDictionary class]]) {
        
        NSObject *receivedStoptimes = nil;
        receivedStoptimes = [dict objectForKey:@"stoptimesWithoutPatterns"];
        if (!receivedStoptimes)
            receivedStoptimes = [dict objectForKey:kStopsStoptimes];
        NSMutableArray *parsedStoptimes = [NSMutableArray array];
        if ([receivedStoptimes isKindOfClass:[NSArray class]]) {
            for (NSDictionary *item in (NSArray *)receivedStoptimes) {
                if ([item isKindOfClass:[NSDictionary class]]) {
                    [parsedStoptimes addObject:[DigiStoptime modelObjectWithDictionary:item]];
                }
            }
        } else if ([receivedStoptimes isKindOfClass:[NSDictionary class]]) {
            [parsedStoptimes addObject:[DigiStoptime modelObjectWithDictionary:(NSDictionary *)receivedStoptimes]];
        }
        
        self.stoptimes = [NSArray arrayWithArray:parsedStoptimes];
        
    }
    
    return self;
    
}

- (NSDictionary *)dictionaryRepresentation
{
    NSMutableDictionary *mutableDict = [[super dictionaryRepresentation] mutableCopy];
    
    NSMutableArray *tempArrayForStoptimes = [NSMutableArray array];
    for (NSObject *subArrayObject in self.stoptimes) {
        if([subArrayObject respondsToSelector:@selector(dictionaryRepresentation)]) {
            // This class is a model object
            [tempArrayForStoptimes addObject:[subArrayObject performSelector:@selector(dictionaryRepresentation)]];
        } else {
            // Generic object
            [tempArrayForStoptimes addObject:subArrayObject];
        }
    }
    [mutableDict setValue:[NSArray arrayWithArray:tempArrayForStoptimes] forKey:kStopsStoptimes];
    
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
    self = [super initWithCoder:aDecoder];
    
    self.stoptimes = [aDecoder decodeObjectForKey:kStopsStoptimes];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [super encodeWithCoder:aCoder];

    [aCoder encodeObject:_stoptimes forKey:kStopsStoptimes];
}

- (id)copyWithZone:(NSZone *)zone
{
    DigiStop *copy = [super copyWithZone:zone];
    
    if (copy) {
        copy.routes = [self.routes copyWithZone:zone];
        copy.stoptimes = [self.stoptimes copyWithZone:zone];
    }
    
    return copy;
}

#pragma mark - Conversion to reitti object
-(BusStop *)reittiBusStop {
    BusStop *busStop = [BusStop new];
    
    [super fillBusStopShortPropertiesTo:busStop];
    
    NSMutableArray *departures = [@[] mutableCopy];
    for (DigiStoptime *digiTime in self.stoptimes) {
        [departures addObject:digiTime.reittiStopDeparture];
    }
    busStop.departures = departures;
    
    return busStop;
}

#pragma mark - Object mapping

+(MappingDescriptor *)mappingDescriptorForPath:(NSString *)path {
    MappingRelationShip *stopTimeRelationShip = [MappingRelationShip relationShipFromKeyPath:@"stoptimesWithoutPatterns"
                                                                               toKeyPath:@"stoptimes"
                                                                        withMappingClass:[DigiStoptime class]];
    
    NSArray *superRelationsShips = [super relationShips];
    NSMutableArray *allRelations = [superRelationsShips mutableCopy];
    [allRelations addObject:stopTimeRelationShip];
    
    return [MappingDescriptor descriptorFromPath:path
                                        forClass:[self class]
                           withMappingDictionary:[super mappingDictionary]
                                andRelationShips:allRelations];
}

@end
