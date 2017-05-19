//
//  DigiRoute.m
//
//  Created by Anteneh Sahledengel on 12/26/16
//  Copyright (c) 2016 shaby ltd. All rights reserved.
//

#import "DigiRoute.h"
//#import "Line.h"

NSString *const kDigiRouteAlerts = @"alerts";
NSString *const kDigiRoutePatterns = @"patterns";


@interface DigiRoute ()

- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict;

@end

@implementation DigiRoute

@synthesize alerts = _alerts;
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
    self.patterns = [aDecoder decodeObjectForKey:kDigiRoutePatterns];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [super encodeWithCoder:aCoder];
    
    [aCoder encodeObject:_alerts forKey:kDigiRouteAlerts];
    [aCoder encodeObject:_patterns forKey:kDigiRoutePatterns];
}

- (id)copyWithZone:(NSZone *)zone
{
    DigiRoute *copy = [super copyWithZone:zone];
    
    if (copy) {
        copy.alerts = [self.alerts copyWithZone:zone];
        copy.patterns = [self.patterns copyWithZone:zone];
    }
    
    return copy;
}

#pragma mark - Overriden properties
-(NSString *)lineEnd {
    NSString *newLineEnd = nil;
    
    if (self.patterns.firstObject) {
        DigiPattern *firstPattern = self.patterns.firstObject;
        newLineEnd = [firstPattern lineEnd];
    }
    
    return newLineEnd ? newLineEnd : [super lineEnd];
}

-(NSString *)lineStart {
    NSString *newLineStart = nil;
    
    if (self.patterns.firstObject) {
        DigiPattern *firstPattern = self.patterns.firstObject;
        newLineStart = [firstPattern lineStart];
    }
    
    return newLineStart ? newLineStart : [super lineStart];
}

#pragma mark - Conversion
-(Line *)reittiLine {
    return [self reittiLineForPattern:self.patterns.firstObject];
}

-(Line *)reittiLineForPattern:(DigiPattern *)pattern {
    Line *line = [Line new];
    
    line.code = self.gtfsId;
    line.codeShort = self.shortName;
    line.lineType = self.lineType;
    
    line.lineStart = pattern ? pattern.lineStart : self.lineStart;
    line.lineEnd = pattern ? pattern.lineEnd : self.lineEnd;
    
    line.timetableUrl = self.url;
    line.dateFrom = nil;
    line.dateTo = nil;
    
    line.name = pattern ? pattern.name : self.longName;
    
    if (pattern) {
        line.patternCode = pattern.code;
        line.patternDirectionId = pattern.directionId;
        
        if (pattern.stops) {
            NSMutableArray *stops = [@[] mutableCopy];
            for (DigiStopShort *digiStop in pattern.stops) {
                [stops addObject:digiStop.reittiLineStop];
            }
            
            line.lineStops = stops;
        }
        
        line.shapeCoordinates = pattern.shapeCoordinates ? pattern.shapeCoordinates : @[];
    }
    
    return line;
}

#pragma mark - Object mapping

+(MappingDescriptor *)mappingDescriptorForPath:(NSString *)path {
    MappingRelationShip *paternRelationShip = [MappingRelationShip relationShipFromKeyPath:@"patterns"
                                                                               toKeyPath:@"patterns"
                                                                        withMappingClass:[DigiPattern class]];
    
    return [MappingDescriptor descriptorFromPath:path
                                        forClass:[self class]
                           withMappingDictionary:[super mappingDictionary]
                                andRelationShips:@[paternRelationShip]];
}

@end
