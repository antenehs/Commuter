//
//  DigiLegs.m
//
//  Created by Anteneh Sahledengel on 28/5/16
//  Copyright (c) 2016 shaby ltd. All rights reserved.
//

#import "DigiLegs.h"
#import "DigiPlace.h"
#import "DigiTrip.h"
#import "DigiPolylineGeometry.h"


NSString *const kDigiLegsTransitLeg = @"transitLeg";
NSString *const kDigiLegsTrip = @"trip";
NSString *const kDigiLegsRealTime = @"realTime";
NSString *const kDigiLegsFrom = @"from";
NSString *const kDigiLegsIntermediateStops = @"intermediateStops";
NSString *const kDigiLegsMode = @"mode";
NSString *const kDigiLegsRentedBike = @"rentedBike";
NSString *const kDigiLegsEndTime = @"endTime";
NSString *const kDigiLegsDuration = @"duration";
NSString *const kDigiLegsDistance = @"distance";
NSString *const kDigiLegsStartTime = @"startTime";
NSString *const kDigiLegsTo = @"to";
NSString *const kDigiLegGeometry = @"legGeometry";


@interface DigiLegs ()

- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict;
@property(nonatomic, strong) NSString *lineName;

@end

@implementation DigiLegs

@synthesize transitLeg = _transitLeg;
@synthesize trip = _trip;
@synthesize realTime = _realTime;
@synthesize from = _from;
@synthesize intermediateStops = _intermediateStops;
@synthesize mode = _mode;
@synthesize rentedBike = _rentedBike;
@synthesize endTime = _endTime;
@synthesize duration = _duration;
@synthesize distance = _distance;
@synthesize startTime = _startTime;
@synthesize to = _to;
@synthesize legGeometry = _legGeometry;


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
        self.transitLeg = [self objectOrNilForKey:kDigiLegsTransitLeg fromDictionary:dict];
        self.trip = [DigiTrip modelObjectWithDictionary:[dict objectForKey:kDigiLegsTrip]];
        self.realTime = [self objectOrNilForKey:kDigiLegsRealTime fromDictionary:dict];
        self.from = [DigiPlace modelObjectWithDictionary:[dict objectForKey:kDigiLegsFrom]];
        NSArray *stopsDictArray = [self objectOrNilForKey:kDigiLegsIntermediateStops fromDictionary:dict];
        self.intermediateStops = [MappingHelper mapDictionaryArray:stopsDictArray toArrayOfClassType:[DigiIntermediateStops class]];
        self.mode = [self objectOrNilForKey:kDigiLegsMode fromDictionary:dict];
        self.rentedBike = [self objectOrNilForKey:kDigiLegsRentedBike fromDictionary:dict];
        self.endTime = [self objectOrNilForKey:kDigiLegsEndTime fromDictionary:dict];
        self.duration = [self objectOrNilForKey:kDigiLegsDuration fromDictionary:dict];
        self.distance = [self objectOrNilForKey:kDigiLegsDistance fromDictionary:dict];
        self.startTime = [self objectOrNilForKey:kDigiLegsStartTime fromDictionary:dict];
        self.to = [DigiPlace modelObjectWithDictionary:[dict objectForKey:kDigiLegsTo]];
        self.legGeometry = [DigiPolylineGeometry modelObjectWithDictionary:[dict objectForKey:kDigiLegGeometry]];

    }
    
    return self;
    
}

- (NSDictionary *)dictionaryRepresentation
{
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
    [mutableDict setValue:[NSNumber numberWithBool:self.transitLeg] forKey:kDigiLegsTransitLeg];
    [mutableDict setValue:self.trip forKey:kDigiLegsTrip];
    [mutableDict setValue:[NSNumber numberWithBool:self.realTime] forKey:kDigiLegsRealTime];
    [mutableDict setValue:[self.from dictionaryRepresentation] forKey:kDigiLegsFrom];
    [mutableDict setValue:[MappingHelper mapObjectArrayToDictionary:self.intermediateStops] forKey:kDigiLegsIntermediateStops];
    [mutableDict setValue:self.mode forKey:kDigiLegsMode];
    [mutableDict setValue:self.rentedBike forKey:kDigiLegsRentedBike];
    [mutableDict setValue:self.endTime forKey:kDigiLegsEndTime];
    [mutableDict setValue:self.duration forKey:kDigiLegsDuration];
    [mutableDict setValue:self.distance forKey:kDigiLegsDistance];
    [mutableDict setValue:self.startTime forKey:kDigiLegsStartTime];
    [mutableDict setValue:[self.to dictionaryRepresentation] forKey:kDigiLegsTo];
    [mutableDict setValue:[self.legGeometry dictionaryRepresentation] forKey:kDigiLegGeometry];

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

    self.transitLeg = [aDecoder decodeObjectForKey:kDigiLegsTransitLeg];
    self.trip = [aDecoder decodeObjectForKey:kDigiLegsTrip];
    self.realTime = [aDecoder decodeObjectForKey:kDigiLegsRealTime];
    self.from = [aDecoder decodeObjectForKey:kDigiLegsFrom];
    self.intermediateStops = [aDecoder decodeObjectForKey:kDigiLegsIntermediateStops];
    self.mode = [aDecoder decodeObjectForKey:kDigiLegsMode];
    self.rentedBike = [aDecoder decodeObjectForKey:kDigiLegsRentedBike];
    self.endTime = [aDecoder decodeObjectForKey:kDigiLegsEndTime];
    self.duration = [aDecoder decodeObjectForKey:kDigiLegsDuration];
    self.distance = [aDecoder decodeObjectForKey:kDigiLegsDistance];
    self.startTime = [aDecoder decodeObjectForKey:kDigiLegsStartTime];
    self.to = [aDecoder decodeObjectForKey:kDigiLegsTo];
    self.legGeometry = [aDecoder decodeObjectForKey:kDigiLegGeometry];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{

    [aCoder encodeObject:_transitLeg forKey:kDigiLegsTransitLeg];
    [aCoder encodeObject:_trip forKey:kDigiLegsTrip];
    [aCoder encodeObject:_realTime forKey:kDigiLegsRealTime];
    [aCoder encodeObject:_from forKey:kDigiLegsFrom];
    [aCoder encodeObject:_intermediateStops forKey:kDigiLegsIntermediateStops];
    [aCoder encodeObject:_mode forKey:kDigiLegsMode];
    [aCoder encodeObject:_rentedBike forKey:kDigiLegsRentedBike];
    [aCoder encodeObject:_endTime forKey:kDigiLegsEndTime];
    [aCoder encodeObject:_duration forKey:kDigiLegsDuration];
    [aCoder encodeObject:_distance forKey:kDigiLegsDistance];
    [aCoder encodeObject:_startTime forKey:kDigiLegsStartTime];
    [aCoder encodeObject:_to forKey:kDigiLegsTo];
    [aCoder encodeObject:_legGeometry forKey:kDigiLegGeometry];
}

- (id)copyWithZone:(NSZone *)zone
{
    DigiLegs *copy = [[DigiLegs alloc] init];
    
    if (copy) {

        copy.transitLeg = self.transitLeg;
        copy.trip = [self.trip copyWithZone:zone];
        copy.realTime = self.realTime;
        copy.from = [self.from copyWithZone:zone];
        copy.intermediateStops = [self.intermediateStops copyWithZone:zone];
        copy.mode = [self.mode copyWithZone:zone];
        copy.rentedBike = self.rentedBike;
        copy.endTime = self.endTime;
        copy.duration = self.duration;
        copy.distance = self.distance;
        copy.startTime = self.startTime;
        copy.to = [self.to copyWithZone:zone];
        copy.legGeometry = [self.legGeometry copyWithZone:zone];
    }
    
    return copy;
}

-(NSDate *)parsedStartTime {
    if (!_parsedStartTime) {
        double startTime = [self.startTime doubleValue]/1000;
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:startTime];
        if (date) _parsedStartTime = date;
    }
    
    return _parsedStartTime;
}

-(NSDate *)parsedEndTime {
    if (!_parsedEndTime) {
        double startTime = [self.endTime doubleValue]/1000;
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:startTime];
        if (date) _parsedEndTime = date;
    }
    
    return _parsedEndTime;
}

-(NSString *)lineName {
    if (!_lineName) {
        if (self.trip.route.shortName) {
            _lineName = self.trip.route.shortName;
        } else if (self.trip.destination){
            //First three letters of destination
            NSString *dest = self.trip.destination;
            if (dest.length > 2) {
                _lineName = [[dest substringToIndex:3] uppercaseString];
            } else {
                _lineName = [dest uppercaseString];
            }
            
        }
    }
    
    return _lineName;
}

-(NSString *)lineGtfsId {
    return self.trip.route.gtfsId;
}

-(NSString *)lineDestination {
    return self.trip.destination;
}

-(LegTransportType)legType {
    if (self.mode) {
        return [EnumManager legTypeForDigiTrasportType:self.mode];
    }else{
        return LegTypeWalk;
    }
}

-(CLLocationCoordinate2D)startCoords {
    return self.from.coords;
}

-(CLLocationCoordinate2D)destinationCoords {
    return self.to.coords;
}

-(NSArray *)fullTripShapeLocations {
    return self.trip.pattern.shapeCoordinates;
}

#pragma mark - mapping

+(NSDictionary *)mappingDictionary {
    return @{
             @"transitLeg" : @"transitLeg",
             @"realTime" : @"realTime",
             @"mode" : @"mode",
             @"rentedBike" : @"rentedBike",
             @"endTime" : @"endTime",
             @"duration" : @"duration",
             @"distance" : @"distance",
             @"startTime" : @"startTime",
             };
}

+(MappingDescriptor *)mappingDescriptorForPath:(NSString *)path {
    MappingRelationShip *fromPlaceRelationShip = [MappingRelationShip relationShipFromKeyPath:@"from"
                                                                               toKeyPath:@"from"
                                                                        withMappingClass:[DigiPlace class]];
    
    MappingRelationShip *toPlaceRelationShip = [MappingRelationShip relationShipFromKeyPath:@"to"
                                                                                toKeyPath:@"to"
                                                                         withMappingClass:[DigiPlace class]];
    
    MappingRelationShip *geometryRelationShip = [MappingRelationShip relationShipFromKeyPath:kDigiLegGeometry
                                                                                  toKeyPath:kDigiLegGeometry
                                                                           withMappingClass:[DigiPolylineGeometry class]];
    
    MappingRelationShip *stopRelationShip = [MappingRelationShip relationShipFromKeyPath:@"intermediateStops"
                                                                                toKeyPath:@"intermediateStops"
                                                                         withMappingClass:[DigiIntermediateStops class]];
    
    MappingRelationShip *tripRelationShip = [MappingRelationShip relationShipFromKeyPath:@"trip"
                                                                                toKeyPath:@"trip"
                                                                         withMappingClass:[DigiTrip class]];
    
    return [MappingDescriptor descriptorFromPath:path
                                        forClass:[self class]
                           withMappingDictionary:[self mappingDictionary]
                                andRelationShips:@[fromPlaceRelationShip, toPlaceRelationShip, geometryRelationShip, stopRelationShip, tripRelationShip]];
}

@end
