//
//  DigiFeatureProperties.m
//
//  Created by Anteneh Sahledengel on 12/19/16
//  Copyright (c) 2016 shaby ltd. All rights reserved.
//

#import "DigiFeatureProperties.h"
#import "ASA_Helpers.h"


NSString *const kDigiFeaturePropertiesSource = @"source";
NSString *const kDigiFeaturePropertiesCountry = @"country";
NSString *const kDigiFeaturePropertiesRegion = @"region";
NSString *const kDigiFeaturePropertiesStreet = @"street";
NSString *const kDigiFeaturePropertiesRegionGid = @"region_gid";
NSString *const kDigiFeaturePropertiesLocaladmin = @"localadmin";
NSString *const kDigiFeaturePropertiesLayer = @"layer";
NSString *const kDigiFeaturePropertiesName = @"name";
NSString *const kDigiFeaturePropertiesSourceId = @"source_id";
NSString *const kDigiFeaturePropertiesLocalityGid = @"locality_gid";
NSString *const kDigiFeaturePropertiesId = @"id";
NSString *const kDigiFeaturePropertiesConfidence = @"confidence";
NSString *const kDigiFeaturePropertiesAccuracy = @"accuracy";
NSString *const kDigiFeaturePropertiesLabel = @"label";
NSString *const kDigiFeaturePropertiesCountryGid = @"country_gid";
NSString *const kDigiFeaturePropertiesPostalcode = @"postalcode";
NSString *const kDigiFeaturePropertiesGid = @"gid";
NSString *const kDigiFeaturePropertiesLocaladminGid = @"localadmin_gid";
NSString *const kDigiFeaturePropertiesCountryA = @"country_a";
NSString *const kDigiFeaturePropertiesLocality = @"locality";
NSString *const kDigiFeaturePropertiesHousenumber = @"housenumber";
NSString *const kDigiFeaturePropertiesNeighbourhood = @"neighbourhood";

@interface DigiFeatureProperties ()

- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict;

@end

@implementation DigiFeatureProperties

@synthesize source = _source;
@synthesize country = _country;
@synthesize region = _region;
@synthesize street = _street;
@synthesize regionGid = _regionGid;
@synthesize localadmin = _localadmin;
@synthesize layer = _layer;
@synthesize name = _name;
@synthesize sourceId = _sourceId;
@synthesize localityGid = _localityGid;
@synthesize internalBaseClassIdentifier = _internalBaseClassIdentifier;
@synthesize confidence = _confidence;
@synthesize accuracy = _accuracy;
@synthesize label = _label;
@synthesize countryGid = _countryGid;
@synthesize postalcode = _postalcode;
@synthesize gid = _gid;
@synthesize localadminGid = _localadminGid;
@synthesize countryA = _countryA;
@synthesize locality = _locality;
@synthesize housenumber = _housenumber;
@synthesize neighbourhood = _neighbourhood;


-(NSNumber *)houseNumber {
    NSNumber *number = [self.housenumber asa_numberValue];
    return number ? number : @1;
}


#pragma mark - initialization
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
            self.source = [self objectOrNilForKey:kDigiFeaturePropertiesSource fromDictionary:dict];
            self.country = [self objectOrNilForKey:kDigiFeaturePropertiesCountry fromDictionary:dict];
            self.region = [self objectOrNilForKey:kDigiFeaturePropertiesRegion fromDictionary:dict];
            self.street = [self objectOrNilForKey:kDigiFeaturePropertiesStreet fromDictionary:dict];
            self.regionGid = [self objectOrNilForKey:kDigiFeaturePropertiesRegionGid fromDictionary:dict];
            self.localadmin = [self objectOrNilForKey:kDigiFeaturePropertiesLocaladmin fromDictionary:dict];
            self.layer = [self objectOrNilForKey:kDigiFeaturePropertiesLayer fromDictionary:dict];
            self.name = [self objectOrNilForKey:kDigiFeaturePropertiesName fromDictionary:dict];
            self.sourceId = [self objectOrNilForKey:kDigiFeaturePropertiesSourceId fromDictionary:dict];
            self.localityGid = [self objectOrNilForKey:kDigiFeaturePropertiesLocalityGid fromDictionary:dict];
            self.internalBaseClassIdentifier = [self objectOrNilForKey:kDigiFeaturePropertiesId fromDictionary:dict];
            self.confidence = [[self objectOrNilForKey:kDigiFeaturePropertiesConfidence fromDictionary:dict] doubleValue];
            self.accuracy = [self objectOrNilForKey:kDigiFeaturePropertiesAccuracy fromDictionary:dict];
            self.label = [self objectOrNilForKey:kDigiFeaturePropertiesLabel fromDictionary:dict];
            self.countryGid = [self objectOrNilForKey:kDigiFeaturePropertiesCountryGid fromDictionary:dict];
            self.postalcode = [self objectOrNilForKey:kDigiFeaturePropertiesPostalcode fromDictionary:dict];
            self.gid = [self objectOrNilForKey:kDigiFeaturePropertiesGid fromDictionary:dict];
            self.localadminGid = [self objectOrNilForKey:kDigiFeaturePropertiesLocaladminGid fromDictionary:dict];
            self.countryA = [self objectOrNilForKey:kDigiFeaturePropertiesCountryA fromDictionary:dict];
            self.locality = [self objectOrNilForKey:kDigiFeaturePropertiesLocality fromDictionary:dict];
            self.housenumber = [self objectOrNilForKey:kDigiFeaturePropertiesHousenumber fromDictionary:dict];
            self.neighbourhood = [self objectOrNilForKey:kDigiFeaturePropertiesNeighbourhood fromDictionary:dict];

    }
    
    return self;
    
}

- (NSDictionary *)dictionaryRepresentation
{
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
    [mutableDict setValue:self.source forKey:kDigiFeaturePropertiesSource];
    [mutableDict setValue:self.country forKey:kDigiFeaturePropertiesCountry];
    [mutableDict setValue:self.region forKey:kDigiFeaturePropertiesRegion];
    [mutableDict setValue:self.street forKey:kDigiFeaturePropertiesStreet];
    [mutableDict setValue:self.regionGid forKey:kDigiFeaturePropertiesRegionGid];
    [mutableDict setValue:self.localadmin forKey:kDigiFeaturePropertiesLocaladmin];
    [mutableDict setValue:self.layer forKey:kDigiFeaturePropertiesLayer];
    [mutableDict setValue:self.name forKey:kDigiFeaturePropertiesName];
    [mutableDict setValue:self.sourceId forKey:kDigiFeaturePropertiesSourceId];
    [mutableDict setValue:self.localityGid forKey:kDigiFeaturePropertiesLocalityGid];
    [mutableDict setValue:self.internalBaseClassIdentifier forKey:kDigiFeaturePropertiesId];
    [mutableDict setValue:[NSNumber numberWithDouble:self.confidence] forKey:kDigiFeaturePropertiesConfidence];
    [mutableDict setValue:self.accuracy forKey:kDigiFeaturePropertiesAccuracy];
    [mutableDict setValue:self.label forKey:kDigiFeaturePropertiesLabel];
    [mutableDict setValue:self.countryGid forKey:kDigiFeaturePropertiesCountryGid];
    [mutableDict setValue:self.postalcode forKey:kDigiFeaturePropertiesPostalcode];
    [mutableDict setValue:self.gid forKey:kDigiFeaturePropertiesGid];
    [mutableDict setValue:self.localadminGid forKey:kDigiFeaturePropertiesLocaladminGid];
    [mutableDict setValue:self.countryA forKey:kDigiFeaturePropertiesCountryA];
    [mutableDict setValue:self.locality forKey:kDigiFeaturePropertiesLocality];
    [mutableDict setValue:self.housenumber forKey:kDigiFeaturePropertiesHousenumber];
    [mutableDict setValue:self.neighbourhood forKey:kDigiFeaturePropertiesNeighbourhood];

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

    self.source = [aDecoder decodeObjectForKey:kDigiFeaturePropertiesSource];
    self.country = [aDecoder decodeObjectForKey:kDigiFeaturePropertiesCountry];
    self.region = [aDecoder decodeObjectForKey:kDigiFeaturePropertiesRegion];
    self.street = [aDecoder decodeObjectForKey:kDigiFeaturePropertiesStreet];
    self.regionGid = [aDecoder decodeObjectForKey:kDigiFeaturePropertiesRegionGid];
    self.localadmin = [aDecoder decodeObjectForKey:kDigiFeaturePropertiesLocaladmin];
    self.layer = [aDecoder decodeObjectForKey:kDigiFeaturePropertiesLayer];
    self.name = [aDecoder decodeObjectForKey:kDigiFeaturePropertiesName];
    self.sourceId = [aDecoder decodeObjectForKey:kDigiFeaturePropertiesSourceId];
    self.localityGid = [aDecoder decodeObjectForKey:kDigiFeaturePropertiesLocalityGid];
    self.internalBaseClassIdentifier = [aDecoder decodeObjectForKey:kDigiFeaturePropertiesId];
    self.confidence = [aDecoder decodeDoubleForKey:kDigiFeaturePropertiesConfidence];
    self.accuracy = [aDecoder decodeObjectForKey:kDigiFeaturePropertiesAccuracy];
    self.label = [aDecoder decodeObjectForKey:kDigiFeaturePropertiesLabel];
    self.countryGid = [aDecoder decodeObjectForKey:kDigiFeaturePropertiesCountryGid];
    self.postalcode = [aDecoder decodeObjectForKey:kDigiFeaturePropertiesPostalcode];
    self.gid = [aDecoder decodeObjectForKey:kDigiFeaturePropertiesGid];
    self.localadminGid = [aDecoder decodeObjectForKey:kDigiFeaturePropertiesLocaladminGid];
    self.countryA = [aDecoder decodeObjectForKey:kDigiFeaturePropertiesCountryA];
    self.locality = [aDecoder decodeObjectForKey:kDigiFeaturePropertiesLocality];
    self.housenumber = [aDecoder decodeObjectForKey:kDigiFeaturePropertiesHousenumber];
    self.neighbourhood = [aDecoder decodeObjectForKey:kDigiFeaturePropertiesNeighbourhood];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{

    [aCoder encodeObject:_source forKey:kDigiFeaturePropertiesSource];
    [aCoder encodeObject:_country forKey:kDigiFeaturePropertiesCountry];
    [aCoder encodeObject:_region forKey:kDigiFeaturePropertiesRegion];
    [aCoder encodeObject:_street forKey:kDigiFeaturePropertiesStreet];
    [aCoder encodeObject:_regionGid forKey:kDigiFeaturePropertiesRegionGid];
    [aCoder encodeObject:_localadmin forKey:kDigiFeaturePropertiesLocaladmin];
    [aCoder encodeObject:_layer forKey:kDigiFeaturePropertiesLayer];
    [aCoder encodeObject:_name forKey:kDigiFeaturePropertiesName];
    [aCoder encodeObject:_sourceId forKey:kDigiFeaturePropertiesSourceId];
    [aCoder encodeObject:_localityGid forKey:kDigiFeaturePropertiesLocalityGid];
    [aCoder encodeObject:_internalBaseClassIdentifier forKey:kDigiFeaturePropertiesId];
    [aCoder encodeDouble:_confidence forKey:kDigiFeaturePropertiesConfidence];
    [aCoder encodeObject:_accuracy forKey:kDigiFeaturePropertiesAccuracy];
    [aCoder encodeObject:_label forKey:kDigiFeaturePropertiesLabel];
    [aCoder encodeObject:_countryGid forKey:kDigiFeaturePropertiesCountryGid];
    [aCoder encodeObject:_postalcode forKey:kDigiFeaturePropertiesPostalcode];
    [aCoder encodeObject:_gid forKey:kDigiFeaturePropertiesGid];
    [aCoder encodeObject:_localadminGid forKey:kDigiFeaturePropertiesLocaladminGid];
    [aCoder encodeObject:_countryA forKey:kDigiFeaturePropertiesCountryA];
    [aCoder encodeObject:_locality forKey:kDigiFeaturePropertiesLocality];
    [aCoder encodeObject:_housenumber forKey:kDigiFeaturePropertiesHousenumber];
    [aCoder encodeObject:_neighbourhood forKey:kDigiFeaturePropertiesNeighbourhood];
}

- (id)copyWithZone:(NSZone *)zone
{
    DigiFeatureProperties *copy = [[DigiFeatureProperties alloc] init];
    
    if (copy) {

        copy.source = [self.source copyWithZone:zone];
        copy.country = [self.country copyWithZone:zone];
        copy.region = [self.region copyWithZone:zone];
        copy.street = [self.street copyWithZone:zone];
        copy.regionGid = [self.regionGid copyWithZone:zone];
        copy.localadmin = [self.localadmin copyWithZone:zone];
        copy.layer = [self.layer copyWithZone:zone];
        copy.name = [self.name copyWithZone:zone];
        copy.sourceId = [self.sourceId copyWithZone:zone];
        copy.localityGid = [self.localityGid copyWithZone:zone];
        copy.internalBaseClassIdentifier = [self.internalBaseClassIdentifier copyWithZone:zone];
        copy.confidence = self.confidence;
        copy.accuracy = [self.accuracy copyWithZone:zone];
        copy.label = [self.label copyWithZone:zone];
        copy.countryGid = [self.countryGid copyWithZone:zone];
        copy.postalcode = [self.postalcode copyWithZone:zone];
        copy.gid = [self.gid copyWithZone:zone];
        copy.localadminGid = [self.localadminGid copyWithZone:zone];
        copy.countryA = [self.countryA copyWithZone:zone];
        copy.locality = [self.locality copyWithZone:zone];
        copy.housenumber = [self.housenumber copyWithZone:zone];
        copy.neighbourhood = [self.neighbourhood copyWithZone:zone];
    }
    
    return copy;
}

#pragma mark - Mappable protocol implemention
//#ifndef APPLE_WATCH
//+(RKResponseDescriptor *)responseDiscriptorForPath:(NSString *)path {
//    return [RKResponseDescriptor responseDescriptorWithMapping:[DigiFeatureProperties objectMapping]
//                                                        method:RKRequestMethodAny
//                                                   pathPattern:nil
//                                                       keyPath:path
//                                                   statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
//}
//
//+(RKObjectMapping *)objectMapping {
//    RKObjectMapping* geocodeMapping = [RKObjectMapping mappingForClass:[DigiFeatureProperties class]];
//    [geocodeMapping addAttributeMappingsFromDictionary:@{
//                                                         @"source" : @"source",
//                                                         @"country" : @"country",
//                                                         @"region" : @"region",
//                                                         @"street" : @"street",
//                                                         @"postalcode" : @"postalcode",
//                                                         @"region_gid" : @"regionGid",
//                                                         @"localadmin" : @"localadmin",
//                                                         @"layer" : @"layer",
//                                                         @"name" : @"name",
//                                                         @"source_id" : @"sourceId",
//                                                         @"locality_gid" : @"localityGid",
//                                                         @"id" : @"internalBaseClassIdentifier",
//                                                         @"confidence" : @"confidence",
//                                                         @"accuracy" : @"accuracy",
//                                                         @"label" : @"label",
//                                                         @"country_gid" : @"countryGid",
//                                                         @"gid" : @"gid",
//                                                         @"localadmin_gid" : @"localadminGid",
//                                                         @"country_a" : @"countryA",
//                                                         @"locality" : @"locality",
//                                                         @"housenumber" : @"housenumber",
//                                                         @"neighbourhood" : @"neighbourhood"
//                                                         }];
//    
//    return geocodeMapping;
//}
//#endif

+(NSDictionary *)mappingDictionary {
    return @{
             @"source"          : @"source",
             @"country"         : @"country",
             @"region"          : @"region",
             @"street"          : @"street",
             @"postalcode"      : @"postalcode",
             @"region_gid"      : @"regionGid",
             @"localadmin"      : @"localadmin",
             @"layer"           : @"layer",
             @"name"            : @"name",
             @"source_id"       : @"sourceId",
             @"locality_gid"    : @"localityGid",
             @"id"              : @"internalBaseClassIdentifier",
             @"confidence"      : @"confidence",
             @"accuracy"        : @"accuracy",
             @"label"           : @"label",
             @"country_gid"     : @"countryGid",
             @"gid"             : @"gid",
             @"localadmin_gid"  : @"localadminGid",
             @"country_a"       : @"countryA",
             @"locality"        : @"locality",
             @"housenumber"     : @"housenumber",
             @"neighbourhood"   : @"neighbourhood"
             };
}

+(MappingDescriptor *)mappingDescriptorForPath:(NSString *)path {
    return [MappingDescriptor descriptorFromPath:path
                                        forClass:[self class]
                           withMappingDictionary:[self mappingDictionary]];
}

@end
