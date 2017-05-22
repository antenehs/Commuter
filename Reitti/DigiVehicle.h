//
//  DigiVehicle.h
//  Reitti
//
//  Created by Anteneh Sahledengel on 5/21/17.
//  Copyright © 2017 Anteneh Sahledengel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Mapping.h"
#import "EnumManager.h"
#import <MapKit/MapKit.h>
#import "Vehicle.h"

@interface DigiVehicle : NSObject<Mappable>

-(Vehicle *)reittiVehicle;

@property (nonatomic, strong) NSString *vehicleId;
@property (nonatomic, strong) NSString *lineId;
@property (nonatomic, strong) NSString *operatorId;
@property (nonatomic, strong) NSString *direction;
@property (nonatomic) double longitude;
@property (nonatomic) double latitude;
@property (nonatomic, strong) NSNumber *bearing;
@property (nonatomic) double validUntilTime;
@property (nonatomic) double recordedAtTime;
@property (nonatomic) double delay;
@property (nonatomic) BOOL monitored;
@property (nonatomic, strong) NSNumber *monitoredAtStopCode;

//Computed
@property (nonatomic, strong) NSString *vehicleName;
@property (nonatomic, strong) NSString *gtfsId;
@property (nonatomic) CLLocationCoordinate2D coords;
@property (nonatomic) VehicleType vehicleType;

@end
