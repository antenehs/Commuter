//
//  DigiFeatureProperties.h
//
//  Created by Anteneh Sahledengel on 12/19/16
//  Copyright (c) 2016 shaby ltd. All rights reserved.
//

/*
venue           points of interest, businesses, things with walls
address         places with a street address
street          streets,roads,highways
neighbourhood	social communities, neighbourhoods
borough         a local administrative boundary, currently only used for New York City
localadmin      local administrative boundaries
locality        towns, hamlets, cities
county          official governmental area; usually bigger than a locality, almost always smaller than a region
macrocounty     a related group of counties. Mostly in Europe.
region          states and provinces
macroregion     a related group of regions. Mostly in Europe
country         places that issue passports, nations, nation-states
coarse          alias for simultaneously using all administrative layers (everything except venue and address)
*/

#import <Foundation/Foundation.h>
#import "Mapping.h"

@interface DigiFeatureProperties : NSObject <NSCoding, NSCopying, Mappable>

@property (nonatomic, strong) NSString *source;
@property (nonatomic, strong) NSString *country;
@property (nonatomic, strong) NSString *region;
@property (nonatomic, strong) NSString *street;
@property (nonatomic, strong) NSString *regionGid;
@property (nonatomic, strong) NSString *localadmin;
@property (nonatomic, strong) NSString *layer;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *sourceId;
@property (nonatomic, strong) NSString *localityGid;
@property (nonatomic, strong) NSString *internalBaseClassIdentifier;
@property (nonatomic, assign) double confidence;
@property (nonatomic, strong) NSString *accuracy;
@property (nonatomic, strong) NSString *label;
@property (nonatomic, strong) NSString *countryGid;
@property (nonatomic, strong) NSString *postalcode;
@property (nonatomic, strong) NSString *gid;
@property (nonatomic, strong) NSString *localadminGid;
@property (nonatomic, strong) NSString *countryA;
@property (nonatomic, strong) NSString *locality;
@property (nonatomic, strong) NSString *housenumber;
@property (nonatomic, strong) NSString *neighbourhood;

@property (nonatomic, strong) NSNumber *houseNumber;

+ (instancetype)modelObjectWithDictionary:(NSDictionary *)dict;
- (instancetype)initWithDictionary:(NSDictionary *)dict;
- (NSDictionary *)dictionaryRepresentation;

@end
