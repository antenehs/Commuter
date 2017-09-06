//
//  DigiPattern.m
//
//  Created by Anteneh Sahledengel on 28/5/16
//  Copyright (c) 2016 shaby ltd. All rights reserved.
//

#import "DigiPattern.h"

NSString *const kDigiPatternGeometry = @"geometry";
NSString *const kDigiRouteStops = @"stops";


@interface DigiPattern ()

- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict;

@end

@implementation DigiPattern

@synthesize stops = _stops;
@synthesize geometry = _geometry;


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
        NSObject *receivedDigiStops = [dict objectForKey:kDigiRouteStops];
        NSMutableArray *parsedDigiStops = [NSMutableArray array];
        if ([receivedDigiStops isKindOfClass:[NSArray class]]) {
            for (NSDictionary *item in (NSArray *)receivedDigiStops) {
                if ([item isKindOfClass:[NSDictionary class]]) {
                    [parsedDigiStops addObject:[DigiStopShort modelObjectWithDictionary:item]];
                }
            }
        } else if ([receivedDigiStops isKindOfClass:[NSDictionary class]]) {
            [parsedDigiStops addObject:[DigiStopShort modelObjectWithDictionary:(NSDictionary *)receivedDigiStops]];
        }
        
        self.stops = [NSArray arrayWithArray:parsedDigiStops];
        
        NSObject *receivedDigiGeometry = [dict objectForKey:kDigiPatternGeometry];
        NSMutableArray *parsedDigiGeometry = [NSMutableArray array];
        if ([receivedDigiGeometry isKindOfClass:[NSArray class]]) {
            for (NSDictionary *item in (NSArray *)receivedDigiGeometry) {
                if ([item isKindOfClass:[NSDictionary class]]) {
                    [parsedDigiGeometry addObject:[DigiGeometry modelObjectWithDictionary:item]];
                }
           }
        } else if ([receivedDigiGeometry isKindOfClass:[NSDictionary class]]) {
           [parsedDigiGeometry addObject:[DigiGeometry modelObjectWithDictionary:(NSDictionary *)receivedDigiGeometry]];
        }

        self.geometry = [NSArray arrayWithArray:parsedDigiGeometry];

    }
    
    return self;
    
}

- (NSDictionary *)dictionaryRepresentation
{
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
    
    NSMutableArray *tempArrayForStops = [NSMutableArray array];
    for (NSObject *subArrayObject in self.stops) {
        if([subArrayObject respondsToSelector:@selector(dictionaryRepresentation)]) {
            // This class is a model object
            [tempArrayForStops addObject:[subArrayObject performSelector:@selector(dictionaryRepresentation)]];
        } else {
            // Generic object
            [tempArrayForStops addObject:subArrayObject];
        }
    }
    [mutableDict setValue:[NSArray arrayWithArray:tempArrayForStops] forKey:kDigiRouteStops];
    
    NSMutableArray *tempArrayForGeometry = [NSMutableArray array];
    for (NSObject *subArrayObject in self.geometry) {
        if([subArrayObject respondsToSelector:@selector(dictionaryRepresentation)]) {
            // This class is a model object
            [tempArrayForGeometry addObject:[subArrayObject performSelector:@selector(dictionaryRepresentation)]];
        } else {
            // Generic object
            [tempArrayForGeometry addObject:subArrayObject];
        }
    }
    [mutableDict setValue:[NSArray arrayWithArray:tempArrayForGeometry] forKey:kDigiPatternGeometry];

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

    self.stops = [aDecoder decodeObjectForKey:kDigiRouteStops];
    self.geometry = [aDecoder decodeObjectForKey:kDigiPatternGeometry];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:_stops forKey:kDigiRouteStops];
    [aCoder encodeObject:_geometry forKey:kDigiPatternGeometry];
}

- (id)copyWithZone:(NSZone *)zone
{
    DigiPattern *copy = [[DigiPattern alloc] init];
    
    if (copy) {
        copy.stops = [self.stops copyWithZone:zone];
        copy.geometry = [self.geometry copyWithZone:zone];
    }
    
    return copy;
}

#pragma mark - Derived properties
-(NSString *)name {
    if (self.lineStart && self.lineEnd) {
        return [NSString stringWithFormat:@"%@ - %@", self.lineStart, self.lineEnd];
    }
    
    return super.name;
}

-(NSArray *)shapeCoordinates {
    if (!_shapeCoordinates) {
        if (self.geometry && self.geometry.count > 0) {
            NSMutableArray *tempArray = [@[] mutableCopy];
            for (DigiGeometry *geometry in self.geometry) {
                if (geometry.location) [tempArray addObject:geometry.location];
            }
            
            _shapeCoordinates = tempArray;
        } else {
            _shapeCoordinates = @[];
        }
    }
    
    return _shapeCoordinates;
}

-(NSArray *)shapeStringCoordinates {
    if (!_shapeStringCoordinates) {
        if (self.geometry && self.geometry.count > 0) {
            NSMutableArray *tempArray = [@[] mutableCopy];
            for (DigiGeometry *geometry in self.geometry) {
                if (geometry.stringCoordinate) [tempArray addObject:geometry.stringCoordinate];
            }
            
            _shapeStringCoordinates = tempArray;
        } else {
            _shapeStringCoordinates = @[];
        }
    }
    
    return _shapeStringCoordinates;
}

-(NSString *)lineEnd {
    return self.headsign;
}

-(NSString *)lineStart {
    if (!_lineStart && self.stops.count > 0) {
        DigiStopShort *stop = [self.stops firstObject];
        _lineStart = stop.name;
    }
    
    return _lineStart;
}

#pragma mark - 
#pragma mark Conversion
-(LinePattern *)reittiLinePattern {
    LinePattern *linePattern = [super reittiLinePattern];
    
    NSMutableArray *stops = [@[] mutableCopy];
    for (DigiStopShort *digiStop in self.stops) {
        [stops addObject:digiStop.reittiLineStop];
    }
    
    linePattern.lineStops = stops;
    linePattern.shapeCoordinates = self.shapeCoordinates ? self.shapeCoordinates : @[];
    
    linePattern.lineStart = self.lineStart;
    linePattern.lineEnd = self.lineEnd;
    
    return linePattern;
}

#pragma mark - Mapping

+(MappingDescriptor *)mappingDescriptorForPath:(NSString *)path {
    MappingRelationShip *stopRelationShip = [MappingRelationShip relationShipFromKeyPath:@"stops"
                                                                               toKeyPath:@"stops"
                                                                        withMappingClass:[DigiStopShort class]];
    
    MappingRelationShip *geometryRelationShip = [MappingRelationShip relationShipFromKeyPath:@"geometry"
                                                                               toKeyPath:@"geometry"
                                                                        withMappingClass:[DigiGeometry class]];
    
    return [MappingDescriptor descriptorFromPath:path
                                        forClass:[self class]
                           withMappingDictionary:[super mappingDictionary]
                                andRelationShips:@[stopRelationShip, geometryRelationShip]];
}


@end
