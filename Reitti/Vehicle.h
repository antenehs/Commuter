//
// Created by Anteneh Sahledengel on 14/5/15.
// Copyright (c) 2015 Anteneh Sahledengel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Features.h"
#import <MapKit/MapKit.h>
#import "EnumManager.h"
#import "DevHslVehicle.h"
#import "TREVehicle.h"

@interface Vehicle : Features

- (instancetype)initWithCSV:(NSString *)csvString;
- (instancetype)initWithHslDevVehicle:(DevHslVehicle *)hslDevVehicle;
- (instancetype)initWithTreVehicle:(TREVehicle *)treVehicle;

@property (nonatomic, strong) NSString *vehicleId;
@property (nonatomic, strong) NSString *vehicleName;
@property (nonatomic, strong) NSString *vehicleLineId;

@property (nonatomic) CLLocationCoordinate2D coords;
@property (nonatomic) double bearing;
@property (nonatomic) VehicleType vehicleType;

@property (nonatomic, strong) NSString *vehicleLineGtfsId;

@end
