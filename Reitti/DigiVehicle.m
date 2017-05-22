//
//  DigiVehicle.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 5/21/17.
//  Copyright © 2017 Anteneh Sahledengel. All rights reserved.
//

#import "DigiVehicle.h"

#if MAIN_APP
#import "CacheManager.h"
#endif

@implementation DigiVehicle

#pragma mark - Commputed properties
-(NSString *)vehicleName {
    if (!_vehicleName) {
        if (self.vehicleType == VehicleTypeMetro) {
            _vehicleName = [NSString stringWithFormat:@"M%@", self.direction];
        } else {
            _vehicleName = [DigiVehicle parseBusNumFromLineCode:self.lineId];
        }
    }
    
    return _vehicleName;
}

-(NSString *)gtfsId {
    if (!_gtfsId) {
        if (self.operatorId) {
            _gtfsId = [NSString stringWithFormat:@"%@:%@", self.operatorId, self.lineId];
        } else {
            _gtfsId = self.lineId;
        }
    }
    
    return _gtfsId;
}

-(CLLocationCoordinate2D)coords {
    return CLLocationCoordinate2DMake(self.latitude, self.longitude);
}

-(VehicleType)vehicleType {
    if (_vehicleType == VehicleTypeUnknown) {
        if ([self.vehicleId hasPrefix:@"RHKL"]) {
            _vehicleType = VehicleTypeTram;
        }else if ([self.vehicleId hasPrefix:@"metro"] || [self.vehicleId hasPrefix:@"METRO"]) {
            _vehicleType = VehicleTypeMetro;
        }else if ([self.vehicleId hasPrefix:@"K"] || [self.vehicleId hasPrefix:@"k"]) {
            _vehicleType = VehicleTypeBus;
        }else if ([self.vehicleId hasPrefix:@"H"] || [self.vehicleId hasPrefix:@"h"]) {
            _vehicleType = VehicleTypeTrain;
        }else{
            _vehicleType = VehicleTypeBus;
        }
    }
    
    return _vehicleType;
}

#pragma mark - Helper

+(NSString *)parseBusNumFromLineCode:(NSString *)lineCode{
    //TODO: Test with 1230 for weird numbers of the same 24 bus.
    //    NSArray *codes = [lineCode componentsSeparatedByString:@" "];
    //    NSString *code = [codes objectAtIndex:0];
    
    //Test for GTFS code
    if ([lineCode hasPrefix:@"HSL:"])
        return [lineCode stringByReplacingOccurrencesOfString:@"HSL:" withString:@""];
    
    //Line codes from HSL live could be only 4 characters
    if (lineCode.length < 4)
        return lineCode;
    
#if MAIN_APP
    //Try getting from line cache
    CacheManager *cacheManager = [CacheManager sharedManager];
    
    NSString * lineName = [cacheManager getRouteNameForCode:lineCode];
    
    if (lineName != nil && ![lineName isEqualToString:@""]) {
        return lineName;
    }
#endif
    
    //Can be assumed a metro
    if ([lineCode hasPrefix:@"1300"])
        return @"Metro";
    
    //Can be assumed a ferry
    if ([lineCode hasPrefix:@"1019"])
        return @"Ferry";
    
    //Can be assumed a train line
    if (([lineCode hasPrefix:@"3001"] || [lineCode hasPrefix:@"3002"]) && lineCode.length > 4) {
        NSString * trainLineCode = [lineCode substringWithRange:NSMakeRange(4, 1)];
        if (trainLineCode != nil && trainLineCode.length > 0)
            return trainLineCode;
    }
    
    //2-4. character = line code (e.g. 102)
    NSString *codePart = [lineCode substringWithRange:NSMakeRange(1, 3)];
    while ([codePart hasPrefix:@"0"]) {
        codePart = [codePart substringWithRange:NSMakeRange(1, codePart.length - 1)];
    }
    
    if (lineCode.length <= 4)
        return codePart;
    
    //5 character = letter variant (e.g. T)
    NSString *firstLetterVariant = [lineCode substringWithRange:NSMakeRange(4, 1)];
    if ([firstLetterVariant isEqualToString:@" "])
        return codePart;
    
    if (lineCode.length <= 5)
        return [NSString stringWithFormat:@"%@%@", codePart, firstLetterVariant];
    
    //6 character = letter variant or numeric variant (ignore number variant)
    NSString *secondLetterVariant = [lineCode substringWithRange:NSMakeRange(5, 1)];
    if ([secondLetterVariant isEqualToString:@" "] || [secondLetterVariant intValue])
        return [NSString stringWithFormat:@"%@%@", codePart, firstLetterVariant];
    
    return [NSString stringWithFormat:@"%@%@%@", codePart, firstLetterVariant, secondLetterVariant];
}

#pragma mark - conversion

-(Vehicle *)reittiVehicle {
    Vehicle *vehicle = [Vehicle new];
    Properties *properties = [Properties new];
    
    vehicle.properties = properties;
    
    vehicle.vehicleName = self.vehicleName;
    vehicle.vehicleId = self.vehicleId;
    vehicle.vehicleLineId = self.lineId;
    vehicle.vehicleLineGtfsId = self.gtfsId;
    vehicle.coords = self.coords;
    vehicle.bearing = self.bearing ? [self.bearing doubleValue] : -1;
    vehicle.vehicleType = self.vehicleType;
    
    return vehicle;
}

#pragma mark - mapping
+(NSDictionary *)mappingDictionary {
    return @{
                @"ValidUntilTime"                                   :@"validUntilTime",
                @"RecordedAtTime"                                   :@"recordedAtTime",
                @"MonitoredVehicleJourney.VehicleRef.value"         :@"vehicleId",
                @"MonitoredVehicleJourney.LineRef.value"            :@"lineId",
                @"MonitoredVehicleJourney.OperatorRef.value"        :@"operatorId",
                @"MonitoredVehicleJourney.DirectionRef.value"       :@"direction",
                @"MonitoredVehicleJourney.VehicleLocation.Longitude":@"longitude",
                @"MonitoredVehicleJourney.VehicleLocation.Latitude" :@"latitude",
                @"MonitoredVehicleJourney.Bearing"                  :@"bearing",
                @"MonitoredVehicleJourney.Delay"                    :@"delay",
                @"MonitoredVehicleJourney.Monitored"                :@"monitored",
                @"MonitoredVehicleJourney.MonitoredCall.StopPointRef":@"monitoredAtStopCode"
             };
}

+(MappingDescriptor *)mappingDescriptorForPath:(NSString *)path {
    return [MappingDescriptor descriptorFromPath:path
                                        forClass:[self class]
                           withMappingDictionary:[self mappingDictionary]];
}

@end
