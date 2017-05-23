//
//  DigiGeometry.m
//
//  Created by Anteneh Sahledengel on 28/5/16
//  Copyright (c) 2016 shaby ltd. All rights reserved.
//

#import "DigiGeometry.h"

NSString *const kDigiGeometryLat = @"lat";
NSString *const kDigiGeometryLon = @"lon";


@interface DigiGeometry ()

- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict;

@end

@implementation DigiGeometry

@synthesize lat = _lat;
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
            self.lat = [self objectOrNilForKey:kDigiGeometryLat fromDictionary:dict];
            self.lon = [self objectOrNilForKey:kDigiGeometryLon fromDictionary:dict];
    }
    
    return self;
    
}

- (NSDictionary *)dictionaryRepresentation
{
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
    [mutableDict setValue:self.lat forKey:kDigiGeometryLat];
    [mutableDict setValue:self.lon forKey:kDigiGeometryLon];

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

    self.lat = [aDecoder decodeObjectForKey:kDigiGeometryLat];
    self.lon = [aDecoder decodeObjectForKey:kDigiGeometryLon];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{

    [aCoder encodeObject:_lat forKey:kDigiGeometryLat];
    [aCoder encodeObject:_lon forKey:kDigiGeometryLon];
}

- (id)copyWithZone:(NSZone *)zone
{
    DigiGeometry *copy = [[DigiGeometry alloc] init];
    
    if (copy) {

        copy.lat = self.lat;
        copy.lon = self.lon;
    }
    
    return copy;
}

#pragma mark - computed propeties

-(CLLocation *)location {
    if (!_location) {
        _location = [[CLLocation alloc] initWithLatitude:[_lat doubleValue] longitude:[_lon doubleValue]];
    }
    
    return _location;
}

-(CLLocationCoordinate2D)coordinate {
    return self.location.coordinate;
}

-(NSString *)stringCoordinate {
    return [NSString stringWithFormat:@"%f,%f",self.coordinate.longitude,self.coordinate.latitude];
}

#pragma mark - mapping

+(MappingDescriptor *)mappingDescriptorForPath:(NSString *)path {
    
    return [MappingDescriptor descriptorFromPath:path
                                        forClass:[self class]
                           withMappingDictionary:@{
                                                   @"lat" : @"lat",
                                                   @"lon" : @"lon"
                                                   }
                                andRelationShips:@[]];
}


@end
