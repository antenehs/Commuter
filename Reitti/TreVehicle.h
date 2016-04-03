//
//  TRETreVehicle.h
//
//  Created by Anteneh Sahledengel on 3/4/16
//  Copyright (c) 2016 shaby ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TREMonitoredVehicleJourney;

@interface TREVehicle : NSObject <NSCoding, NSCopying>

@property (nonatomic, strong) TREMonitoredVehicleJourney *monitoredVehicleJourney;
@property (nonatomic, strong) NSString *recordedAtTime;
@property (nonatomic, strong) NSString *validUntilTime;

+ (instancetype)modelObjectWithDictionary:(NSDictionary *)dict;
- (instancetype)initWithDictionary:(NSDictionary *)dict;
- (NSDictionary *)dictionaryRepresentation;

@end
