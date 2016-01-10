//
//  MonitoredVehicleJourney.h
//
//  Created by Anteneh Sahledengel on 10/1/16
//  Copyright (c) 2016 shaby ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FramedVehicleJourneyRef, VehicleRef, DirectionRef, VehicleLocation, MonitoredCall, LineRef, OperatorRef;

@interface MonitoredVehicleJourney : NSObject <NSCoding, NSCopying>

@property (nonatomic, strong) FramedVehicleJourneyRef *framedVehicleJourneyRef;
@property (nonatomic, assign) BOOL monitored;
@property (nonatomic, strong) VehicleRef *vehicleRef;
@property (nonatomic, strong) DirectionRef *directionRef;
@property (nonatomic, strong) VehicleLocation *vehicleLocation;
@property (nonatomic, strong) MonitoredCall *monitoredCall;
@property (nonatomic, strong) LineRef *lineRef;
@property (nonatomic, strong) OperatorRef *operatorRef;
@property (nonatomic, assign) double delay;
@property (nonatomic, assign) NSString *bearing;

+ (instancetype)modelObjectWithDictionary:(NSDictionary *)dict;
- (instancetype)initWithDictionary:(NSDictionary *)dict;
- (NSDictionary *)dictionaryRepresentation;

@end
