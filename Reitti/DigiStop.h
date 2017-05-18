//
//  DigiStops.h
//
//  Created by Anteneh Sahledengel on 19/5/16
//  Copyright (c) 2016 shaby ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DigiStopShort.h"
#import "EnumManager.h"
#import "Mapping.h"

@interface DigiStop : DigiStopShort <NSCoding, NSCopying, Mappable>

@property (nonatomic, strong) NSArray *routes;
@property (nonatomic, strong) NSArray *stoptimes;

@property (nonatomic) StopType stopType;

+ (instancetype)modelObjectWithDictionary:(NSDictionary *)dict;
- (instancetype)initWithDictionary:(NSDictionary *)dict;
- (NSDictionary *)dictionaryRepresentation;

@end
