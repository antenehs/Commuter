//
//  DigiBikeRentalStation.h
//
//  Created by Anteneh Sahledengel on 28/5/16
//  Copyright (c) 2016 shaby ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Mapping.h"

@interface DigiBikeRentalStation : NSObject <NSCoding, NSCopying, Mappable>

@property (nonatomic, strong) NSNumber *bikesAvailable;
@property (nonatomic, strong) NSString *stationId;
@property (nonatomic, strong) NSNumber *realtime;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSNumber *spacesAvailable;

+ (instancetype)modelObjectWithDictionary:(NSDictionary *)dict;
- (instancetype)initWithDictionary:(NSDictionary *)dict;
- (NSDictionary *)dictionaryRepresentation;

@end
