//
// Created by Anteneh Sahledengel on 14/5/15.
// Copyright (c) 2015 Anteneh Sahledengel. All rights reserved.
//

#import "Vehicle.h"
#import "ReittiStringFormatter.h"
#import "HSLCommunication.h"
#import "MonitoredVehicleJourney.h"
#import "VehicleLocation.h"
#import "LineRef.h"
#import "DirectionRef.h"
#import "HSLAndTRECommon.h"
#import "VehicleRef.h"
#import "TREVehiceDataModels.h"

@implementation Vehicle

//expected format
//Id, route, lat, lng, bearing, direction, previous stop, current stop, departure
- (instancetype)initWithCSV:(NSString *)csvString
{
    self = [super init];
    
    // This check serves to make sure that a non-NSDictionary object
    // passed into the model class doesn't break the parsing.
    if(self && csvString != nil) {
        NSArray *elements = [csvString componentsSeparatedByString:@";"];
        if (elements.count != 9)
            return nil;
        
        self.type = @"Feature";
        Geometry *geometry = [[Geometry alloc] init];
        geometry.type = @"Point";
        geometry.coordinates = @[elements[2],elements[3]];
        self.geometry = geometry;
        
        Properties *properties = [[Properties alloc] init];
        NSArray *codes = [elements[1] componentsSeparatedByString:@" "];
        properties.lineid = [NSString stringWithFormat:@"%@  %@", codes[0], elements[5]];
        properties.propertiesIdentifier = elements[0];
        NSString *bearingString = elements[4];
        properties.bearing = [bearingString doubleValue];
        properties.distanceFromStart = 0;
        properties.departure = elements[8];
        properties.lastUpdate = nil;
        NSString *typeName;
        NSString *lineName;
        if ([elements[0] hasPrefix:@"RHKL"]) {
            typeName = @"tram";
            lineName = [HSLCommunication parseBusNumFromLineCode:elements[1]];
        }else if ([elements[0] hasPrefix:@"metro"] || [elements[0] hasPrefix:@"METRO"]) {
            typeName = @"metro";
            lineName = [NSString stringWithFormat:@"M%@",elements[5]] ;
        }else if ([elements[0] hasPrefix:@"K"] || [elements[0] hasPrefix:@"k"]) {
            typeName = @"bus";
            lineName = elements[1];
        }else if ([elements[0] hasPrefix:@"H"] || [elements[0] hasPrefix:@"h"]) {
            typeName = @"train";
            lineName = [HSLCommunication parseBusNumFromLineCode:elements[1]];
        }else{
            typeName = @"other";
            lineName = elements[1];
        }
        
        properties.type = typeName;
        properties.name = lineName;
        properties.diff = 0;
        self.properties = properties;
    }
    
    return self;
}

- (instancetype)initWithHslDevVehicle:(DevHslVehicle *)hslDevVehicle{
    if (!hslDevVehicle)
        return nil;
    
    self = [super init];
    
    self.type = @"Feature";
    
    //==========Coordinates===============
    Geometry *geometry = [[Geometry alloc] init];
    geometry.type = @"Point";
    NSString *latitude = [NSString stringWithFormat:@"%f", hslDevVehicle.monitoredVehicleJourney.vehicleLocation.latitude];
    NSString *longitude = [NSString stringWithFormat:@"%f", hslDevVehicle.monitoredVehicleJourney.vehicleLocation.longitude];
    geometry.coordinates = @[ longitude , latitude];
    self.geometry = geometry;
    
    //==========Line codes================
    Properties *properties = [[Properties alloc] init];
    NSString *lineCode = hslDevVehicle.monitoredVehicleJourney.lineRef.value;
    NSString *lineDirection = hslDevVehicle.monitoredVehicleJourney.directionRef.value;
    NSString *lineFullString = [HSLAndTRECommon lineJoreCodeForCode:lineCode andDirection:lineDirection];
    properties.lineid = lineFullString;
    NSString *lineName = [HSLCommunication parseBusNumFromLineCode:lineCode];
    
    properties.propertiesIdentifier = hslDevVehicle.monitoredVehicleJourney.vehicleRef.value;
    NSString *bearingString = hslDevVehicle.monitoredVehicleJourney.bearing;
    properties.bearing = bearingString ? [bearingString doubleValue] : -1;
    properties.distanceFromStart = 0;
    properties.departure = @"";
    properties.lastUpdate = nil;
    NSString *typeName;
    
    NSString *vehicleId = hslDevVehicle.monitoredVehicleJourney.vehicleRef.value;
    if ([vehicleId hasPrefix:@"RHKL"]) {
        typeName = @"tram";
    }else if ([vehicleId hasPrefix:@"metro"] || [vehicleId hasPrefix:@"METRO"]) {
        typeName = @"metro";
        lineName = [NSString stringWithFormat:@"M%@", lineDirection] ;
    }else if ([vehicleId hasPrefix:@"K"] || [vehicleId hasPrefix:@"k"]) {
        typeName = @"bus";
    }else if ([vehicleId hasPrefix:@"H"] || [vehicleId hasPrefix:@"h"]) {
        typeName = @"train";
    }else{
        typeName = @"bus";
    }
    
    properties.type = typeName;
    properties.name = lineName;
    properties.diff = 0;
    self.properties = properties;
    
    return self;
}

- (instancetype)initWithTreVehicle:(TREVehicle *)treVehicle {
    if (!treVehicle)
        return nil;
    
    self = [super init];
    
    self.type = @"Feature";
    
    //==========Coordinates===============
    Geometry *geometry = [[Geometry alloc] init];
    geometry.type = @"Point";
    NSString *latitude = treVehicle.monitoredVehicleJourney.vehicleLocation.latitude;
    NSString *longitude = treVehicle.monitoredVehicleJourney.vehicleLocation.longitude;
    geometry.coordinates = @[ longitude , latitude];
    self.geometry = geometry;
    
    //==========Line codes================
    Properties *properties = [[Properties alloc] init];
    NSString *lineCode = treVehicle.monitoredVehicleJourney.lineRef;
    NSString *lineDirection = treVehicle.monitoredVehicleJourney.directionRef;
    NSString *lineFullString = [HSLAndTRECommon lineJoreCodeForCode:lineCode andDirection:lineDirection];
    properties.lineid = lineFullString;
    
    properties.propertiesIdentifier = treVehicle.monitoredVehicleJourney.vehicleRef;
    NSString *bearingString = treVehicle.monitoredVehicleJourney.bearing;
    properties.bearing = bearingString ? [bearingString doubleValue] : -1;
    properties.distanceFromStart = 0;
    properties.departure = @"";
    properties.lastUpdate = nil;
    
    properties.type = @"bus";
    properties.name = lineCode;
    properties.diff = 0;
    self.properties = properties;
    
    //TODO: Parse next stops too.
    return self;
}

- (NSString *)vehicleId{
    return self.properties.propertiesIdentifier;
}

- (NSString *)vehicleName{
    return self.properties.name;
}

- (NSString *)vehicleLineId{
    return self.properties.lineid;
}

- (CLLocationCoordinate2D)coords{
    NSNumber *longitude = [self.geometry.coordinates objectAtIndex:0];
    NSNumber *latitude = [self.geometry.coordinates objectAtIndex:1];
    CLLocationCoordinate2D coordinate = {.latitude = [latitude doubleValue] , .longitude =  [longitude doubleValue]};
    
    return coordinate;
}

-(double)bearing{
    return self.properties.bearing;
}

-(void)setBearing:(double)bearing{
    self.properties.bearing = bearing;
}

-(VehicleType)vehicleType{
    return [EnumManager vehicleTypeForTypeName:self.properties.type];
}

@end