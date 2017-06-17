//
//  DigiTrip.m
//
//  Created by Anteneh Sahledengel on 19/5/16
//  Copyright (c) 2016 shaby ltd. All rights reserved.
//

#import "DigiTrip.h"
#import "DigiRoute.h"

NSString *const kDigiTripRoute = @"route";
NSString *const kDigiTripTripHeadsign = @"tripHeadsign";


@interface DigiTrip ()
@property(nonatomic, strong) NSString *destination;

- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict;

@end

@implementation DigiTrip

@synthesize route = _route;
@synthesize tripHeadsign = _tripHeadsign;


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
            self.route = [DigiRoute modelObjectWithDictionary:[dict objectForKey:kDigiTripRoute]];
            self.tripHeadsign = [self objectOrNilForKey:kDigiTripTripHeadsign fromDictionary:dict];

    }
    
    return self;
    
}

- (NSDictionary *)dictionaryRepresentation
{
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
    [mutableDict setValue:[self.route dictionaryRepresentation] forKey:kDigiTripRoute];
    [mutableDict setValue:self.tripHeadsign forKey:kDigiTripTripHeadsign];

    return [NSDictionary dictionaryWithDictionary:mutableDict];
}

- (NSString *)description 
{
    return [NSString stringWithFormat:@"%@", [self dictionaryRepresentation]];
}

#pragma mark - Computed values
-(NSDate *)arrivalTimeAtStop:(NSString *)stopCode {
    NSArray *stoptimes = [self.stopTimes filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.stopGtfsId == %@", stopCode]];
    
    if (stoptimes.count == 1) {
        return [(DigiStoptime *)stoptimes[0] parsedScheduledArrivalDate];
    }
    
    return nil;
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

    self.route = [aDecoder decodeObjectForKey:kDigiTripRoute];
    self.tripHeadsign = [aDecoder decodeObjectForKey:kDigiTripTripHeadsign];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{

    [aCoder encodeObject:_route forKey:kDigiTripRoute];
    [aCoder encodeObject:_tripHeadsign forKey:kDigiTripTripHeadsign];
}

- (id)copyWithZone:(NSZone *)zone
{
    DigiTrip *copy = [[DigiTrip alloc] init];
    
    if (copy) {

        copy.route = [self.route copyWithZone:zone];
        copy.tripHeadsign = [self.tripHeadsign copyWithZone:zone];
    }
    
    return copy;
}

#pragma mark - computed properties
-(NSString *)destination {
    if (!_destination) {
        if (self.tripHeadsign) { _destination = self.tripHeadsign; }
        if (!_destination && self.pattern.headsign) {
            _destination = self.pattern.headsign;
        }
        if (!_destination && self.route.lineEnd) {
            _destination = self.route.lineEnd;
        }
    }
    
    return _destination;
}

#pragma mark - mapping

+(MappingDescriptor *)mappingDescriptorForPath:(NSString *)path {
    MappingRelationShip *routeRelationShip = [MappingRelationShip relationShipFromKeyPath:@"route"
                                                                               toKeyPath:@"route"
                                                                        withMappingClass:[DigiRoute class]];
    
    MappingRelationShip *patternRelationShip = [MappingRelationShip relationShipFromKeyPath:@"pattern"
                                                                                toKeyPath:@"pattern"
                                                                         withMappingClass:[DigiPattern class]];
    
    MappingRelationShip *stopTimesRelationShip = [MappingRelationShip relationShipFromKeyPath:@"stoptimes"
                                                                                  toKeyPath:@"stopTimes"
                                                                           withMappingClass:[DigiStoptime class]];
    
    return [MappingDescriptor descriptorFromPath:path forClass:[self class]
                           withMappingDictionary:@{ @"tripHeadsign" : @"tripHeadsign" }
                                andRelationShips:@[routeRelationShip, patternRelationShip, stopTimesRelationShip]];
}

@end
