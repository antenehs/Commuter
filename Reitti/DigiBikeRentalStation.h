//
//  DigiBikeRentalStation.h
//
//  Created by Anteneh Sahledengel on 28/5/16
//  Copyright (c) 2016 shaby ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Mapping.h"
#import "BikeStation.h"

@interface DigiBikeRentalStation : NSObject <NSCoding, NSCopying, Mappable>

-(BikeStation *)bikeStation;

@property (nonatomic, strong) NSString *stationId;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *lon;
@property (nonatomic, strong) NSString *lat;
@property (nonatomic, strong) NSNumber *bikesAvailable;
@property (nonatomic, strong) NSNumber *spacesAvailable;
@property (nonatomic) BOOL realtime;
@property (nonatomic) BOOL allowDropoff;

+ (instancetype)modelObjectWithDictionary:(NSDictionary *)dict;
- (instancetype)initWithDictionary:(NSDictionary *)dict;
- (NSDictionary *)dictionaryRepresentation;

@end
