//
//  DevHslVehicle.h
//
//  Created by Anteneh Sahledengel on 10/1/16
//  Copyright (c) 2016 shaby ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MonitoredVehicleJourney;

@interface DevHslVehicle : NSObject <NSCoding, NSCopying>

@property (nonatomic, assign) double validUntilTime;
@property (nonatomic, strong) MonitoredVehicleJourney *monitoredVehicleJourney;
@property (nonatomic, assign) double recordedAtTime;

+ (instancetype)modelObjectWithDictionary:(NSDictionary *)dict;
- (instancetype)initWithDictionary:(NSDictionary *)dict;
- (NSDictionary *)dictionaryRepresentation;

@end
