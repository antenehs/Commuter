//
//  DigiIntermediateStops.m
//
//  Created by Anteneh Sahledengel on 28/5/16
//  Copyright (c) 2016 shaby ltd. All rights reserved.
//

#import "DigiIntermediateStops.h"
#import "ReittiMapkitHelper.h"

NSString *const kDigiIntermediateStopsGtfsId = @"gtfsId";
NSString *const kDigiIntermediateStopsCode = @"code";
NSString *const kDigiIntermediateStopsLat = @"lat";
NSString *const kDigiIntermediateStopsName = @"name";
NSString *const kDigiIntermediateStopsLon = @"lon";


@interface DigiIntermediateStops ()

- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict;

@end

@implementation DigiIntermediateStops

@synthesize gtfsId = _gtfsId;
@synthesize code = _code;
@synthesize lat = _lat;
@synthesize name = _name;
@synthesize lon = _lon;


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
            self.gtfsId = [self objectOrNilForKey:kDigiIntermediateStopsGtfsId fromDictionary:dict];
            self.code = [self objectOrNilForKey:kDigiIntermediateStopsCode fromDictionary:dict];
            self.lat = [self objectOrNilForKey:kDigiIntermediateStopsLat fromDictionary:dict];
            self.name = [self objectOrNilForKey:kDigiIntermediateStopsName fromDictionary:dict];
            self.lon = [self objectOrNilForKey:kDigiIntermediateStopsLon fromDictionary:dict];
    }
    
    return self;
    
}

- (NSDictionary *)dictionaryRepresentation
{
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
    [mutableDict setValue:self.gtfsId forKey:kDigiIntermediateStopsGtfsId];
    [mutableDict setValue:self.code forKey:kDigiIntermediateStopsCode];
    [mutableDict setValue:self.lat forKey:kDigiIntermediateStopsLat];
    [mutableDict setValue:self.name forKey:kDigiIntermediateStopsName];
    [mutableDict setValue:self.lon forKey:kDigiIntermediateStopsLon];

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

    self.gtfsId = [aDecoder decodeObjectForKey:kDigiIntermediateStopsGtfsId];
    self.code = [aDecoder decodeObjectForKey:kDigiIntermediateStopsCode];
    self.lat = [aDecoder decodeObjectForKey:kDigiIntermediateStopsLat];
    self.name = [aDecoder decodeObjectForKey:kDigiIntermediateStopsName];
    self.lon = [aDecoder decodeObjectForKey:kDigiIntermediateStopsLon];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{

    [aCoder encodeObject:_gtfsId forKey:kDigiIntermediateStopsGtfsId];
    [aCoder encodeObject:_code forKey:kDigiIntermediateStopsCode];
    [aCoder encodeObject:_lat forKey:kDigiIntermediateStopsLat];
    [aCoder encodeObject:_name forKey:kDigiIntermediateStopsName];
    [aCoder encodeObject:_lon forKey:kDigiIntermediateStopsLon];
}

- (id)copyWithZone:(NSZone *)zone
{
    DigiIntermediateStops *copy = [[DigiIntermediateStops alloc] init];
    
    if (copy) {

        copy.gtfsId = [self.gtfsId copyWithZone:zone];
        copy.code = [self.code copyWithZone:zone];
        copy.lat = self.lat;
        copy.name = [self.name copyWithZone:zone];
        copy.lon = self.lon;
    }
    
    return copy;
}

-(CLLocationCoordinate2D )coords {
    if (![ReittiMapkitHelper isValidCoordinate:_coords]) {
        _coords = CLLocationCoordinate2DMake([self.lat floatValue],[self.lon floatValue]);
    }
    return _coords;
}

+(MappingDescriptor *)mappingDescriptorForPath:(NSString *)path {
    
    return [MappingDescriptor descriptorFromPath:path
                                        forClass:[self class]
                           withMappingDictionary:@{
                                                   @"gtfsId": @"gtfsId",
                                                   @"code"  : @"code",
                                                   @"lon"   : @"lon",
                                                   @"lat"   : @"lat",
                                                   @"name"  : @"name"
                                                   }
                                andRelationShips:@[]];
}


@end
