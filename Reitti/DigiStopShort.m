//
//  DigiStopShort.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 12/26/16.
//  Copyright © 2016 Anteneh Sahledengel. All rights reserved.
//

#import "DigiStopShort.h"

NSString *const kStopsGtfsId = @"gtfsId";
NSString *const kStopsCode = @"code";
NSString *const kStopsLon = @"lon";
NSString *const kStopsLat = @"lat";
NSString *const kStopsName = @"name";
NSString *const kStopsUrl = @"url";

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

#pragma mark - Object mapping
+(RKResponseDescriptor *)responseDiscriptorForPath:(NSString *)path {
    return [RKResponseDescriptor responseDescriptorWithMapping:[DigiStopShort objectMapping]
                                                        method:RKRequestMethodAny
                                                   pathPattern:nil
                                                       keyPath:path
                                                   statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
}

+(RKObjectMapping *)objectMapping {
    RKObjectMapping* stopMapping = [RKObjectMapping mappingForClass:[DigiStopShort class] ];
    [stopMapping addAttributeMappingsFromDictionary:[DigiStopShort mappingDictionary]];
    
    return stopMapping;
}

+(NSDictionary *)mappingDictionary {
    return @{
             @"gtfsId" : @"gtfsId",
             @"code" : @"code",
             @"lon" : @"lon",
             @"lat" : @"lat",
             @"name" : @"name",
             @"url" : @"url",
             @"desc" : @"desc",
             @"vehicleType" : @"vehicleType",
             @"zoneId" : @"zoneId"
             };
}

@end
