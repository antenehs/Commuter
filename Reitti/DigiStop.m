//
//  Stops.m
//
//  Created by Anteneh Sahledengel on 19/5/16
//  Copyright (c) 2016 shaby ltd. All rights reserved.
//

#import "DigiStop.h"
#import "DigiRoute.h"
#import "DigiStoptime.h"


NSString *const kStopsGtfsId = @"gtfsId";
NSString *const kStopsRoutes = @"routes";
NSString *const kStopsCode = @"code";
NSString *const kStopsLon = @"lon";
NSString *const kStopsLat = @"lat";
NSString *const kStopsStoptimes = @"stoptimes";
NSString *const kStopsName = @"name";
NSString *const kStopsUrl = @"url";


@interface DigiStop ()

- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict;

@end

@implementation DigiStop

@synthesize gtfsId = _gtfsId;
@synthesize routes = _routes;
@synthesize code = _code;
@synthesize lon = _lon;
@synthesize lat = _lat;
@synthesize stoptimes = _stoptimes;
@synthesize name = _name;
@synthesize url = _url;


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
        NSObject *receivedRoutes = [dict objectForKey:kStopsRoutes];
        NSMutableArray *parsedRoutes = [NSMutableArray array];
        if ([receivedRoutes isKindOfClass:[NSArray class]]) {
            for (NSDictionary *item in (NSArray *)receivedRoutes) {
                if ([item isKindOfClass:[NSDictionary class]]) {
                    [parsedRoutes addObject:[DigiRoute modelObjectWithDictionary:item]];
                }
            }
        } else if ([receivedRoutes isKindOfClass:[NSDictionary class]]) {
            [parsedRoutes addObject:[DigiRoute modelObjectWithDictionary:(NSDictionary *)receivedRoutes]];
        }
        
        self.routes = [NSArray arrayWithArray:parsedRoutes];
        self.code = [self objectOrNilForKey:kStopsCode fromDictionary:dict];
        self.lon = [self objectOrNilForKey:kStopsLon fromDictionary:dict];
        self.lat = [self objectOrNilForKey:kStopsLat fromDictionary:dict];
        NSObject *receivedStoptimes = [dict objectForKey:kStopsStoptimes];
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
        self.name = [self objectOrNilForKey:kStopsName fromDictionary:dict];
        self.url = [self objectOrNilForKey:kStopsUrl fromDictionary:dict];
        
    }
    
    return self;
    
}

- (NSDictionary *)dictionaryRepresentation
{
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
    [mutableDict setValue:self.gtfsId forKey:kStopsGtfsId];
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
    [mutableDict setValue:self.code forKey:kStopsCode];
    [mutableDict setValue:self.lon forKey:kStopsLon];
    [mutableDict setValue:self.lat forKey:kStopsLat];
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
    [mutableDict setValue:self.name forKey:kStopsName];
    [mutableDict setValue:self.url forKey:kStopsUrl];
    
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
    self.routes = [aDecoder decodeObjectForKey:kStopsRoutes];
    self.code = [aDecoder decodeObjectForKey:kStopsCode];
    self.lon = [aDecoder decodeObjectForKey:kStopsLon];
    self.lat = [aDecoder decodeObjectForKey:kStopsLat];
    self.stoptimes = [aDecoder decodeObjectForKey:kStopsStoptimes];
    self.name = [aDecoder decodeObjectForKey:kStopsName];
    self.url = [aDecoder decodeObjectForKey:kStopsUrl];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    
    [aCoder encodeObject:_gtfsId forKey:kStopsGtfsId];
    [aCoder encodeObject:_routes forKey:kStopsRoutes];
    [aCoder encodeObject:_code forKey:kStopsCode];
    [aCoder encodeObject:_lon forKey:kStopsLon];
    [aCoder encodeObject:_lat forKey:kStopsLat];
    [aCoder encodeObject:_stoptimes forKey:kStopsStoptimes];
    [aCoder encodeObject:_name forKey:kStopsName];
    [aCoder encodeObject:_url forKey:kStopsUrl];
}

- (id)copyWithZone:(NSZone *)zone
{
    DigiStop *copy = [[DigiStop alloc] init];
    
    if (copy) {
        
        copy.gtfsId = [self.gtfsId copyWithZone:zone];
        copy.routes = [self.routes copyWithZone:zone];
        copy.code = [self.code copyWithZone:zone];
        copy.lon = self.lon;
        copy.lat = self.lat;
        copy.stoptimes = [self.stoptimes copyWithZone:zone];
        copy.name = [self.name copyWithZone:zone];
        copy.url = [self.url copyWithZone:zone];
    }
    
    return copy;
}

#pragma mark - computed properties
-(StopType)stopType {
    if (_stopType == StopTypeUnknown) {
        if (self.routes && self.routes.count > 0) {
            DigiRoute *firstRoute = self.routes.firstObject;
            _stopType = [EnumManager stopTypeFromLineType:[EnumManager lineTypeForDigiLineType:firstRoute.type]];
        } else {
            _stopType = StopTypeBus;
        }
    }
    
    return _stopType;
}

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

#pragma mark - Object mapping
+(RKResponseDescriptor *)responseDiscriptorForPath:(NSString *)path {
    return [RKResponseDescriptor responseDescriptorWithMapping:[DigiStop objectMapping]
                                                        method:RKRequestMethodAny
                                                   pathPattern:nil
                                                       keyPath:path
                                                   statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
}

+(RKObjectMapping *)objectMapping {
    RKObjectMapping* stopMapping = [RKObjectMapping mappingForClass:[DigiStop class] ];
    [stopMapping addAttributeMappingsFromDictionary:@{
                                                          @"gtfsId" : @"gtfsId",
                                                          @"code" : @"code",
                                                          @"lon" : @"lon",
                                                          @"lat" : @"lat",
                                                          @"name" : @"name",
                                                          @"url" : @"url",
                                                          @"desc" : @"desc",
                                                          @"vehicleType" : @"vehicleType",
                                                          @"zoneId" : @"zoneId"
                                                          }];
    
    [stopMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"stoptimesWithoutPatterns"
                                                                                    toKeyPath:@"stoptimes"
                                                                                  withMapping:[DigiStoptime objectMapping]]];
    
    [stopMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"routes"
                                                                                toKeyPath:@"routes"
                                                                              withMapping:[DigiRoute objectMapping]]];
    
    return stopMapping;
}

@end
