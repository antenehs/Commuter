//
//  DigiGeoCode.h
//  Reitti
//
//  Created by Anteneh Sahledengel on 12/19/16.
//  Copyright © 2016 Anteneh Sahledengel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Geometry.h"
#import "DigiFeatureProperties.h"
#import "ReittiObject.h"
#import "EnumManager.h"

@interface DigiGeoCode : NSObject <NSCoding, NSCopying, Mappable>

@property (nonatomic, strong) NSString *type;
@property (nonatomic, strong) Geometry *geometry;
@property (nonatomic, strong) DigiFeatureProperties *properties;

//Computed properties
@property (nonatomic) LocationType locationType;
@property (nonatomic, strong) NSString *city;

+ (instancetype)modelObjectWithDictionary:(NSDictionary *)dict;
- (instancetype)initWithDictionary:(NSDictionary *)dict;
- (NSDictionary *)dictionaryRepresentation;

@end
