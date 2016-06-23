//
//  DigiFrom.m
//
//  Created by Anteneh Sahledengel on 28/5/16
//  Copyright (c) 2016 shaby ltd. All rights reserved.
//

#import "DigiPlace.h"
#import "ReittiMapkitHelper.h"
#import "ReittiStringFormatter.h"

NSString *const kDigiFromBikeRentalStation = @"bikeRentalStation";
NSString *const kDigiFromLat = @"lat";
NSString *const kDigiFromLon = @"lon";
NSString *const kDigiFromName = @"name";
NSString *const kDigiFromIntermediateStops = @"intermediateStops";


@interface DigiPlace ()

- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict;

@end

@implementation DigiPlace

@synthesize bikeRentalStation = _bikeRentalStation;
@synthesize lat = _lat;
@synthesize lon = _lon;
@synthesize name = _name;
@synthesize intermediateStop = _intermediateStop;


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
            self.bikeRentalStation = [DigiBikeRentalStation modelObjectWithDictionary:[dict objectForKey:kDigiFromBikeRentalStation]];
            self.lat = [self objectOrNilForKey:kDigiFromLat fromDictionary:dict];
            self.lon = [self objectOrNilForKey:kDigiFromLon fromDictionary:dict];
            self.name = [self objectOrNilForKey:kDigiFromName fromDictionary:dict];
            self.intermediateStop = [DigiIntermediateStops modelObjectWithDictionary:[dict objectForKey:kDigiFromIntermediateStops]];
    }
    
    return self;
}

- (NSDictionary *)dictionaryRepresentation
{
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
    [mutableDict setValue:[self.bikeRentalStation dictionaryRepresentation] forKey:kDigiFromBikeRentalStation];
    [mutableDict setValue:self.lat forKey:kDigiFromLat];
    [mutableDict setValue:self.lon forKey:kDigiFromLon];
    [mutableDict setValue:self.name forKey:kDigiFromName];
    [mutableDict setValue:[self.intermediateStop dictionaryRepresentation] forKey:kDigiFromIntermediateStops];

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

    self.bikeRentalStation = [aDecoder decodeObjectForKey:kDigiFromBikeRentalStation];
    self.lat = [aDecoder decodeObjectForKey:kDigiFromLat];
    self.lon = [aDecoder decodeObjectForKey:kDigiFromLon];
    self.name = [aDecoder decodeObjectForKey:kDigiFromName];
    self.intermediateStop = [aDecoder decodeObjectForKey:kDigiFromIntermediateStops];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{

    [aCoder encodeObject:_bikeRentalStation forKey:kDigiFromBikeRentalStation];
    [aCoder encodeObject:_lat forKey:kDigiFromLat];
    [aCoder encodeObject:_lon forKey:kDigiFromLon];
    [aCoder encodeObject:_name forKey:kDigiFromName];
    [aCoder encodeObject:_intermediateStop forKey:kDigiFromIntermediateStops];
}

- (id)copyWithZone:(NSZone *)zone
{
    DigiPlace *copy = [[DigiPlace alloc] init];
    
    if (copy) {

        copy.bikeRentalStation = [self.bikeRentalStation copyWithZone:zone];
        copy.lat = self.lat;
        copy.lon = self.lon;
        copy.name = self.name;
        copy.intermediateStop = [self.intermediateStop copyWithZone:zone];
    }
    
    return copy;
}

-(CLLocationCoordinate2D )coords {
    if (![ReittiMapkitHelper isValidCoordinate:_coords]) {
        _coords = CLLocationCoordinate2DMake([self.lat floatValue],[self.lon floatValue]);
    }
    return _coords;
}

+(RKResponseDescriptor *)responseDiscriptorForPath:(NSString *)path {
    return [RKResponseDescriptor responseDescriptorWithMapping:[DigiPlace objectMapping]
                                                        method:RKRequestMethodAny
                                                   pathPattern:nil
                                                       keyPath:path
                                                   statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
}

+(RKObjectMapping *)objectMapping {
    RKObjectMapping* placeMapping = [RKObjectMapping mappingForClass:[DigiPlace class] ];
    [placeMapping addAttributeMappingsFromDictionary:@{
                                                          @"lat" : @"lat",
                                                          @"lon" : @"lon",
                                                          @"name" : @"name"
                                                          }];
    
    [placeMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"bikeRentalStation"
                                                                                toKeyPath:@"bikeRentalStation"
                                                                              withMapping:[DigiBikeRentalStation objectMapping]]];
    
    [placeMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"stop"
                                                                                toKeyPath:@"intermediateStop"
                                                                              withMapping:[DigiIntermediateStops objectMapping]]];
    return placeMapping;
}


@end
