//
//  DigiTrip.h
//
//  Created by Anteneh Sahledengel on 19/5/16
//  Copyright (c) 2016 shaby ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DigiRoute.h"
#import "DigiPattern.h"
#import "Mapping.h"

@interface DigiTrip : NSObject <NSCoding, NSCopying, Mappable>

@property (nonatomic, strong) DigiRoute *route;
@property (nonatomic, strong) DigiPattern *pattern;
@property (nonatomic, strong) NSString *tripHeadsign;

+ (instancetype)modelObjectWithDictionary:(NSDictionary *)dict;
- (instancetype)initWithDictionary:(NSDictionary *)dict;
- (NSDictionary *)dictionaryRepresentation;

@end
