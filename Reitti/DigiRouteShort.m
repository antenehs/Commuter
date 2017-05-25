//
//  DigiRouteShort.m
//
//  Created by Anteneh Sahledengel on 19/5/16
//  Copyright (c) 2016 shaby ltd. All rights reserved.
//

#import "DigiRouteShort.h"

NSString *const kDigiRouteId = @"id";
NSString *const kDigiRouteLongName = @"longName";
NSString *const kDigiRouteShortName = @"shortName";
NSString *const kDigiRouteBikesAllowed = @"bikesAllowed";
NSString *const kDigiRouteGtfsId = @"gtfsId";
NSString *const kDigiRouteUrl = @"url";
NSString *const kDigiRouteType = @"type";
NSString *const kDigiRouteDesc = @"desc";
NSString *const kDigiRouteMode = @"mode";


@interface DigiRouteShort ()

- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict;

@end

@implementation DigiRouteShort

@synthesize routeIdentifier = _routeIdentifier;
@synthesize longName = _longName;
@synthesize shortName = _shortName;
@synthesize bikesAllowed = _bikesAllowed;
@synthesize gtfsId = _gtfsId;
@synthesize url = _url;
@synthesize type = _type;
@synthesize desc = _desc;
@synthesize mode = _mode;

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
        self.routeIdentifier = [self objectOrNilForKey:kDigiRouteId fromDictionary:dict];
        self.longName = [self objectOrNilForKey:kDigiRouteLongName fromDictionary:dict];
        self.shortName = [self objectOrNilForKey:kDigiRouteShortName fromDictionary:dict];
        self.bikesAllowed = [self objectOrNilForKey:kDigiRouteBikesAllowed fromDictionary:dict];
        self.gtfsId = [self objectOrNilForKey:kDigiRouteGtfsId fromDictionary:dict];
        self.url = [self objectOrNilForKey:kDigiRouteUrl fromDictionary:dict];
        self.type = [self objectOrNilForKey:kDigiRouteType fromDictionary:dict];
        self.desc = [self objectOrNilForKey:kDigiRouteDesc fromDictionary:dict];
        self.mode = [self objectOrNilForKey:kDigiRouteMode fromDictionary:dict];
    }
    
    return self;
    
}

- (NSDictionary *)dictionaryRepresentation
{
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
    [mutableDict setValue:self.routeIdentifier forKey:kDigiRouteId];
    [mutableDict setValue:self.longName forKey:kDigiRouteLongName];
    [mutableDict setValue:self.shortName forKey:kDigiRouteShortName];
    [mutableDict setValue:self.bikesAllowed forKey:kDigiRouteBikesAllowed];
    [mutableDict setValue:self.gtfsId forKey:kDigiRouteGtfsId];
    [mutableDict setValue:self.url forKey:kDigiRouteUrl];
    [mutableDict setValue:self.type forKey:kDigiRouteType];
    [mutableDict setValue:self.desc forKey:kDigiRouteDesc];
    [mutableDict setValue:self.mode forKey:kDigiRouteMode];
    
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
    
    self.routeIdentifier = [aDecoder decodeObjectForKey:kDigiRouteId];
    self.longName = [aDecoder decodeObjectForKey:kDigiRouteLongName];
    self.shortName = [aDecoder decodeObjectForKey:kDigiRouteShortName];
    self.bikesAllowed = [aDecoder decodeObjectForKey:kDigiRouteBikesAllowed];
    self.gtfsId = [aDecoder decodeObjectForKey:kDigiRouteGtfsId];
    self.url = [aDecoder decodeObjectForKey:kDigiRouteUrl];
    self.type = [aDecoder decodeObjectForKey:kDigiRouteType];
    self.desc = [aDecoder decodeObjectForKey:kDigiRouteDesc];
    self.mode = [aDecoder decodeObjectForKey:kDigiRouteMode];

    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    
    [aCoder encodeObject:_routeIdentifier forKey:kDigiRouteId];
    [aCoder encodeObject:_longName forKey:kDigiRouteLongName];
    [aCoder encodeObject:_shortName forKey:kDigiRouteShortName];
    [aCoder encodeObject:_bikesAllowed forKey:kDigiRouteBikesAllowed];
    [aCoder encodeObject:_gtfsId forKey:kDigiRouteGtfsId];
    [aCoder encodeObject:_url forKey:kDigiRouteUrl];
    [aCoder encodeObject:_type forKey:kDigiRouteType];
    [aCoder encodeObject:_desc forKey:kDigiRouteDesc];
    [aCoder encodeObject:_mode forKey:kDigiRouteMode];
}

- (id)copyWithZone:(NSZone *)zone
{
    DigiRouteShort *copy = [[DigiRouteShort alloc] init];
    
    if (copy) {
        
        copy.routeIdentifier = [self.routeIdentifier copyWithZone:zone];
        copy.longName = [self.longName copyWithZone:zone];
        copy.shortName = [self.shortName copyWithZone:zone];
        copy.bikesAllowed = [self.bikesAllowed copyWithZone:zone];
        copy.gtfsId = [self.gtfsId copyWithZone:zone];
        copy.url = [self.url copyWithZone:zone];
        copy.type = [self.type copyWithZone:zone];
        copy.desc = [self.desc copyWithZone:zone];
        copy.mode = [self.mode copyWithZone:zone];
    }
    
    return copy;
}

#pragma mark - Derived properties
-(LineType)lineType {
    return [EnumManager lineTypeForDigiLineType:self.mode];
}

-(NSString *)lineStart {
    if (!_lineStart) {
        if (self.longName) {
            _lineStart = [DigiRouteShort routeStartFromLongName:self.longName];
        }
    }
    
    return _lineStart;
}

+(NSString *)routeStartFromLongName:(NSString *)routeLongName {
    NSArray *comps = [routeLongName componentsSeparatedByString:@"-"];
    if (comps.count > 1) {
        return [comps firstObject];
    }
    
    return nil;
}

-(NSString *)lineEnd {
    if (!_lineEnd) {
        if (self.longName) {
            _lineEnd = [DigiRouteShort routeDestinationFromLongName:self.longName];
        } else {
            _lineEnd = nil;
        }
    }
    
    return _lineEnd;
}

+(NSString *)routeDestinationFromLongName:(NSString *)routeLongName {
    NSArray *comps = [routeLongName componentsSeparatedByString:@"-"];
    if (comps.count > 1) {
        NSString *lineEnd = [comps lastObject];
        //There could be optional destinations at the end
        if ([lineEnd containsString:@"("] && [lineEnd containsString:@")"]) {
            if (comps.count > 2) {
                lineEnd = [NSString stringWithFormat:@"%@ - %@", comps[comps.count - 2], lineEnd];
            }
        }
        return lineEnd;
    } else {
        return routeLongName;
    }
    
    return nil;
}

#pragma mark - conversion
-(StopLine *)reittiStopLine {
    return [self reittiStopLineWithPattern:self.patterns.firstObject];
}

-(StopLine *)reittiStopLineWithPattern:(DigiPatternShort *)patternShort {
    StopLine *line = [[StopLine alloc] init];
    
    line.fullCode = self.gtfsId;
    line.code = [self.shortName uppercaseString];
    line.name = self.longName;
    line.lineType = self.lineType;
    line.pattern = patternShort.reittiLinePattern;
    
    //FIXME: Parse these
    line.destination = patternShort.headsign;
    line.lineStart = self.lineStart;
    line.lineEnd = patternShort.headsign;
    
    return line;
}

#pragma mark - Object mapping

+(NSDictionary *)mappingDictionary {
    return @{
             @"routeIdentifier" : @"routeIdentifier",
             @"shortName"       : @"shortName",
             @"longName"        : @"longName",
             @"gtfsId"          : @"gtfsId",
             @"bikesAllowed"    : @"bikesAllowed",
             @"url"             : @"url",
             @"type"            : @"type",
             @"desc"            : @"desc",
             @"mode"            : @"mode"
             };
}

+(MappingDescriptor *)mappingDescriptorForPath:(NSString *)path {
    MappingRelationShip *paternRelationShip = [MappingRelationShip relationShipFromKeyPath:@"patterns"
                                                                                 toKeyPath:@"patterns"
                                                                          withMappingClass:[DigiPatternShort class]];
    
    return [MappingDescriptor descriptorFromPath:path
                                        forClass:[self class]
                           withMappingDictionary:[self mappingDictionary]
                                andRelationShips:@[paternRelationShip]];
}

@end
