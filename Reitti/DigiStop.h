//
//  DigiStops.h
//
//  Created by Anteneh Sahledengel on 19/5/16
//  Copyright (c) 2016 shaby ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DigiStopShort.h"
#import "Mapping.h"

#import "BusStop.h"

@interface DigiStop : DigiStopShort <NSCoding, NSCopying, Mappable, DictionaryMappable>

-(BusStop *)reittiBusStop;

@property (nonatomic, strong) NSArray *stoptimes;

+ (instancetype)modelObjectWithDictionary:(NSDictionary *)dict;
//- (instancetype)initWithDictionary:(NSDictionary *)dict;
//- (NSDictionary *)dictionaryRepresentation;

@end
