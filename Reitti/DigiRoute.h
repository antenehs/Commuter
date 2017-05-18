//
//  DigiRoute.h
//
//  Created by Anteneh Sahledengel on 12/26/16
//  Copyright (c) 2016 shaby ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DigiRouteShort.h"
#import "Mapping.h"


@interface DigiRoute : DigiRouteShort <NSCoding, NSCopying, Mappable>

@property (nonatomic, strong) NSArray *stops;
@property (nonatomic, strong) NSArray *patterns;
@property (nonatomic, strong) NSArray *alerts;

@property (nonatomic, strong) NSArray *shapeCoordinates;

+ (instancetype)modelObjectWithDictionary:(NSDictionary *)dict;
- (instancetype)initWithDictionary:(NSDictionary *)dict;
- (NSDictionary *)dictionaryRepresentation;

@end
