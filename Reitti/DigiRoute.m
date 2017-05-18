//
//  DigiRoute.m
//
//  Created by Anteneh Sahledengel on 12/26/16
//  Copyright (c) 2016 shaby ltd. All rights reserved.
//

#import "DigiRoute.h"
#import "DigiStopShort.h"
#import "DigiPattern.h"
#import "DigiStopShort.h"


NSString *const kDigiRouteAlerts = @"alerts";
NSString *const kDigiRouteStops = @"stops";
NSString *const kDigiRoutePatterns = @"patterns";


@interface DigiRoute ()

- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict;

@end

@implementation DigiRoute

@synthesize alerts = _alerts;
@synthesize stops = _stops;
@synthesize patterns = _patterns;


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
        
        self.alerts = [self objectOrNilForKey:kDigiRouteAlerts fromDictionary:dict];
        
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
        NSObject *receivedDigiPatterns = [dict objectForKey:kDigiRoutePatterns];
        NSMutableArray *parsedDigiPatterns = [NSMutableArray array];
        if ([receivedDigiPatterns isKindOfClass:[NSArray class]]) {
            for (NSDictionary *item in (NSArray *)receivedDigiPatterns) {
                if ([item isKindOfClass:[NSDictionary class]]) {
                    [parsedDigiPatterns addObject:[DigiPattern modelObjectWithDictionary:item]];
                }
           }
        } else if ([receivedDigiPatterns isKindOfClass:[NSDictionary class]]) {
           [parsedDigiPatterns addObject:[DigiPattern modelObjectWithDictionary:(NSDictionary *)receivedDigiPatterns]];
        }

        self.patterns = [NSArray arrayWithArray:parsedDigiPatterns];

    }
    
    return self;
    
}

- (NSDictionary *)dictionaryRepresentation
{
    NSMutableDictionary *mutableDict = [[super dictionaryRepresentation] mutableCopy];
    NSMutableArray *tempArrayForAlerts = [NSMutableArray array];
    for (NSObject *subArrayObject in self.alerts) {
        if([subArrayObject respondsToSelector:@selector(dictionaryRepresentation)]) {
            // This class is a model object
            [tempArrayForAlerts addObject:[subArrayObject performSelector:@selector(dictionaryRepresentation)]];
        } else {
            // Generic object
            [tempArrayForAlerts addObject:subArrayObject];
        }
    }
    [mutableDict setValue:[NSArray arrayWithArray:tempArrayForAlerts] forKey:kDigiRouteAlerts];
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

    NSMutableArray *tempArrayForPatterns = [NSMutableArray array];
    for (NSObject *subArrayObject in self.patterns) {
        if([subArrayObject respondsToSelector:@selector(dictionaryRepresentation)]) {
            // This class is a model object
            [tempArrayForPatterns addObject:[subArrayObject performSelector:@selector(dictionaryRepresentation)]];
        } else {
            // Generic object
            [tempArrayForPatterns addObject:subArrayObject];
        }
    }
    [mutableDict setValue:[NSArray arrayWithArray:tempArrayForPatterns] forKey:kDigiRoutePatterns];

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

    self.alerts = [aDecoder decodeObjectForKey:kDigiRouteAlerts];
    self.stops = [aDecoder decodeObjectForKey:kDigiRouteStops];
    self.patterns = [aDecoder decodeObjectForKey:kDigiRoutePatterns];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [super encodeWithCoder:aCoder];
    
    [aCoder encodeObject:_alerts forKey:kDigiRouteAlerts];
    [aCoder encodeObject:_stops forKey:kDigiRouteStops];
    [aCoder encodeObject:_patterns forKey:kDigiRoutePatterns];
}

- (id)copyWithZone:(NSZone *)zone
{
    DigiRoute *copy = [super copyWithZone:zone];
    
    if (copy) {
        copy.alerts = [self.alerts copyWithZone:zone];
        copy.stops = [self.stops copyWithZone:zone];
        copy.patterns = [self.patterns copyWithZone:zone];
    }
    
    return copy;
}

#pragma mark - Overriden properties
-(NSString *)lineEnd {
    NSString *lineEnd = [super lineEnd];
    
    if (!lineEnd && self.stops.count > 0) {
        DigiStopShort *stop = [self.stops lastObject];
        self.lineEnd = stop.name;
    }
    
    return [super lineEnd];
}

#pragma mark - Computed properties
-(NSArray *)shapeCoordinates {
    if (!_shapeCoordinates) {
        if (self.patterns && self.patterns.count > 0) {
            NSMutableArray *tempArray = [@[] mutableCopy];
            
            for (DigiPattern *pattern in self.patterns) {
                [tempArray addObjectsFromArray:pattern.shapeCoordinates];
            }
            _shapeCoordinates = tempArray;
        }
    }
    
    return _shapeCoordinates;
}

#pragma mark - Object mapping

+(MappingDescriptor *)mappingDescriptorForPath:(NSString *)path {
    MappingRelationShip *stopRelationShip = [MappingRelationShip relationShipFromKeyPath:@"stops"
                                                                               toKeyPath:@"stops"
                                                                        withMappingClass:[DigiStopShort class]];
    
    MappingRelationShip *paternRelationShip = [MappingRelationShip relationShipFromKeyPath:@"patterns"
                                                                               toKeyPath:@"patterns"
                                                                        withMappingClass:[DigiPattern class]];
    
    return [MappingDescriptor descriptorFromPath:path
                                        forClass:[self class]
                           withMappingDictionary:[self mappingDictionary]
                                andRelationShips:@[stopRelationShip, paternRelationShip]];
}

@end
