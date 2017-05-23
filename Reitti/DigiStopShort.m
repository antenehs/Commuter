//
//  DigiStopShort.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 12/26/16.
//  Copyright © 2016 Anteneh Sahledengel. All rights reserved.
//

#import "DigiStopShort.h"
#import "DigiRouteShort.h"

NSString *const kStopsGtfsId = @"gtfsId";
NSString *const kStopsCode = @"code";
NSString *const kStopsLon = @"lon";
NSString *const kStopsLat = @"lat";
NSString *const kStopsName = @"name";
NSString *const kStopsUrl = @"url";
NSString *const kStopsRoutes = @"routes";

@interface DigiStopShort ()

- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict;

@end

@implementation DigiStopShort

@synthesize gtfsId = _gtfsId;
@synthesize code = _code;
@synthesize lon = _lon;
@synthesize lat = _lat;
@synthesize name = _name;
@synthesize url = _url;
@synthesize routes = _routes;

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
        self.gtfsId = [self objectOrNilForKey:kStopsGtfsId fromDictionary:dict];
        self.code = [self objectOrNilForKey:kStopsCode fromDictionary:dict];
        self.lon = [self objectOrNilForKey:kStopsLon fromDictionary:dict];
        self.lat = [self objectOrNilForKey:kStopsLat fromDictionary:dict];
        self.name = [self objectOrNilForKey:kStopsName fromDictionary:dict];
        self.url = [self objectOrNilForKey:kStopsUrl fromDictionary:dict];
        
        NSObject *receivedRoutes = [dict objectForKey:kStopsRoutes];
        NSMutableArray *parsedRoutes = [NSMutableArray array];
        if ([receivedRoutes isKindOfClass:[NSArray class]]) {
            for (NSDictionary *item in (NSArray *)receivedRoutes) {
                if ([item isKindOfClass:[NSDictionary class]]) {
                    [parsedRoutes addObject:[DigiRouteShort modelObjectWithDictionary:item]];
                }
            }
        } else if ([receivedRoutes isKindOfClass:[NSDictionary class]]) {
            [parsedRoutes addObject:[DigiRouteShort modelObjectWithDictionary:(NSDictionary *)receivedRoutes]];
        }
        
        self.routes = [NSArray arrayWithArray:parsedRoutes];
    }
    
    return self;
    
}

- (NSDictionary *)dictionaryRepresentation
{
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
    [mutableDict setValue:self.gtfsId forKey:kStopsGtfsId];
    [mutableDict setValue:self.code forKey:kStopsCode];
    [mutableDict setValue:self.lon forKey:kStopsLon];
    [mutableDict setValue:self.lat forKey:kStopsLat];
    [mutableDict setValue:self.name forKey:kStopsName];
    [mutableDict setValue:self.url forKey:kStopsUrl];
    
    NSMutableArray *tempArrayForRoutes = [NSMutableArray array];
    for (NSObject *subArrayObject in self.routes) {
        if([subArrayObject respondsToSelector:@selector(dictionaryRepresentation)]) {
            // This class is a model object
            [tempArrayForRoutes addObject:[subArrayObject performSelector:@selector(dictionaryRepresentation)]];
        } else {
            // Generic object
            [tempArrayForRoutes addObject:subArrayObject];
        }
    }
    [mutableDict setValue:[NSArray arrayWithArray:tempArrayForRoutes] forKey:kStopsRoutes];
    
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
    
    self.gtfsId = [aDecoder decodeObjectForKey:kStopsGtfsId];
    self.code = [aDecoder decodeObjectForKey:kStopsCode];
    self.lon = [aDecoder decodeObjectForKey:kStopsLon];
    self.lat = [aDecoder decodeObjectForKey:kStopsLat];
    self.name = [aDecoder decodeObjectForKey:kStopsName];
    self.url = [aDecoder decodeObjectForKey:kStopsUrl];
    self.routes = [aDecoder decodeObjectForKey:kStopsRoutes];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    
    [aCoder encodeObject:_gtfsId forKey:kStopsGtfsId];
    [aCoder encodeObject:_code forKey:kStopsCode];
    [aCoder encodeObject:_lon forKey:kStopsLon];
    [aCoder encodeObject:_lat forKey:kStopsLat];
    [aCoder encodeObject:_name forKey:kStopsName];
    [aCoder encodeObject:_url forKey:kStopsUrl];
    [aCoder encodeObject:_routes forKey:kStopsRoutes];
}

- (id)copyWithZone:(NSZone *)zone
{
    DigiStopShort *copy = [[DigiStopShort alloc] init];
    
    if (copy) {
        
        copy.gtfsId = [self.gtfsId copyWithZone:zone];
        copy.code = [self.code copyWithZone:zone];
        copy.lon = self.lon;
        copy.lat = self.lat;
        copy.name = [self.name copyWithZone:zone];
        copy.url = [self.url copyWithZone:zone];
    }
    
    return copy;
}

#pragma mark - computed properties

-(NSString *)coordString {
    return [NSString stringWithFormat:@"%@,%@", self.lon , self.lat];
}

-(NSNumber *)numberId {
    
    NSArray *comps = [self.gtfsId componentsSeparatedByString:@":"];
    
    NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
    f.numberStyle = NSNumberFormatterDecimalStyle;
    NSNumber *myNumber = [f numberFromString:comps.lastObject];
    
    if (myNumber) {
        return myNumber;
    }
    
    return @0;
}

-(StopType)stopType {
    if (_stopType == StopTypeUnknown) {
        if (self.routes && self.routes.count > 0) {
            DigiRouteShort *firstRoute = self.routes.firstObject;
            _stopType = [EnumManager stopTypeFromLineType:firstRoute.lineType];
        } else {
            _stopType = StopTypeBus;
        }
    }
    
    return _stopType;
}

#pragma mark - conversion
-(LineStop *)reittiLineStop {
    LineStop *stop = [LineStop new];
    
    stop.coords = self.coordString;
    stop.address = self.name;
    stop.time = nil;
    stop.gtfsId = self.gtfsId;
    stop.code = [self.numberId stringValue];
    stop.codeShort = self.code;
    stop.platformNumber = self;
    stop.cityName = nil;
    stop.name = self.name;
    
    return stop;
}

//#if MAIN_APP
-(BusStopShort *)reittiBusStopShort {
    BusStopShort *stopShort = [BusStopShort new];
    
    [self fillBusStopShortPropertiesTo:stopShort];
    
    return stopShort;
}

-(void)fillBusStopShortPropertiesTo:(BusStopShort *)stopShort {
    stopShort.code = self.numberId;
    stopShort.gtfsId = self.gtfsId;
    stopShort.codeShort = self.code ? self.code : self.gtfsId;
    
    stopShort.name = self.name;
    stopShort.nameFi = self.name;
    stopShort.nameSv = self.name;
    
    stopShort.city = @"";
    stopShort.cityFi = @"";
    stopShort.citySv = @"";
    
    stopShort.address = self.desc;
    stopShort.addressFi = self.desc;
    stopShort.addressSv = self.desc;
    
    stopShort.stopType = self.stopType;
    stopShort.fetchedFromApi = ReittiDigiTransitApi;
    
    stopShort.coords = self.coordString;
    stopShort.wgsCoords = self.coordString;
    
    stopShort.timetableLink = self.url;
    
    stopShort.lines = [self reittiStopLines];
}

-(NSArray *)reittiStopLines {
    NSMutableArray *lines = [@[] mutableCopy];
    
    for (DigiPatternShort *pattern in self.patterns) {
        //Find the route with this pattern
        DigiRouteShort *routeShort = [self routeWithStopPattern:pattern];
        if (routeShort) {
//            routeShort.patterns = @[pattern];
            [lines addObject:[routeShort reittiStopLineWithPattern:pattern]];
        } else {}
    }
    
    return lines;
}

-(DigiRouteShort *)routeWithStopPattern:(DigiPatternShort *)stopPattern {
    for (DigiRouteShort *digiRouteShort in self.routes) {
        for (DigiPatternShort *pattern in digiRouteShort.patterns) {
            if ([pattern.code isEqualToString:stopPattern.code]) {
                return digiRouteShort;
            }
        }
    }
    
    NSLog(@"STOP PATTERN AND ROUTE PATTERN MISMATCH");
    return nil;
}

#pragma mark - Object mapping

+(NSDictionary *)mappingDictionary {
    return @{
             @"gtfsId"      : @"gtfsId",
             @"code"        : @"code",
             @"lon"         : @"lon",
             @"lat"         : @"lat",
             @"name"        : @"name",
             @"url"         : @"url",
             @"desc"        : @"desc",
             @"vehicleType" : @"vehicleType",
             @"zoneId"      : @"zoneId"
             };
}

+(NSArray *)relationShips {
    MappingRelationShip *routeRelationShip = [MappingRelationShip relationShipFromKeyPath:@"routes"
                                                                                toKeyPath:@"routes"
                                                                         withMappingClass:[DigiRouteShort class]];
    
    MappingRelationShip *patternRelationShip = [MappingRelationShip relationShipFromKeyPath:@"patterns"
                                                                                toKeyPath:@"patterns"
                                                                         withMappingClass:[DigiPatternShort class]];
    return @[routeRelationShip, patternRelationShip];
}

+(MappingDescriptor *)mappingDescriptorForPath:(NSString *)path {
    return [MappingDescriptor descriptorFromPath:path
                                        forClass:[self class]
                           withMappingDictionary:[self mappingDictionary]
                                andRelationShips:[self relationShips]];
}

@end
