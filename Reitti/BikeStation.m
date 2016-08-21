//
//  BikeStation.m
//  HelsinkiBikes
//
//  Created by Anteneh Sahledengel on 4/5/16.
//  Copyright © 2016 Anteneh Sahledengel. All rights reserved.
//

#import "BikeStation.h"
#import "ReittiStringFormatter.h"
#import "RouteLegLocation.h"

@implementation BikeStation

+(id)bikeStationFromLegLocation:(RouteLegLocation *)location {
    BikeStation *station = [BikeStation new];
    station.name = location.name;
    station.stationId = location.bikeStationId;
    station.bikesAvailable = location.bikesAvailable != nil ? location.bikesAvailable : @0;
    station.spacesAvailable = location.spacesAvailable != nil ? location.spacesAvailable : @0;
    station.coordinates = location.coords;
    
    return station;
}

+(RKResponseDescriptor *)responseDiscriptorForPath:(NSString *)path {
    RKObjectMapping* stationMapping = [RKObjectMapping mappingForClass:[BikeStation class] ];
    [stationMapping addAttributeMappingsFromDictionary:@{
                                                      @"id" : @"stationId",
                                                      @"name" : @"name",
                                                      @"x"     : @"xCoord",
                                                      @"y" : @"yCoord",
                                                      @"bikesAvailable" : @"bikesAvailable",
                                                      @"spacesAvailable" : @"spacesAvailable",
                                                      @"allowDropoff" : @"allowDropoff",
                                                      @"realTimeData" : @"realTimeData",
                                                      }];
    
    return [RKResponseDescriptor responseDescriptorWithMapping:stationMapping
                                                        method:RKRequestMethodAny
                                                   pathPattern:nil
                                                       keyPath:path
                                                   statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
}

-(CLLocationCoordinate2D)coordinates {
    if (self.xCoord && self.yCoord) {
        return [ReittiStringFormatter convertStringTo2DCoord:[NSString stringWithFormat:@"%@,%@", self.xCoord, self.yCoord]];
    }
    
    return CLLocationCoordinate2DMake(0, 0);
}

-(BOOL)isValid {
    return self.xCoord && self.yCoord;
}

-(NSString *)bikesAvailableString {
    if (self.bikesAvailable.intValue == 0) {
        return NSLocalizedString(@"No Bikes", nil);
    } else if(self.bikesAvailable.intValue == 1) {
        return [NSString stringWithFormat:@"1 %@", NSLocalizedString(@"Bike", nil)];
    } else {
        return [NSString stringWithFormat:@"%d %@",self.bikesAvailable.intValue, NSLocalizedString(@"Bikes", nil)];
    }
}

-(NSString *)spacesAvailableString {
    if (self.spacesAvailable.intValue == 0) {
        return NSLocalizedString(@"No Return Space", nil);
    } else if(self.spacesAvailable.intValue == 1) {
        return [NSString stringWithFormat:@"1 %@", NSLocalizedString(@"Free Space", nil)];
    } else {
        return [NSString stringWithFormat:@"%d %@",self.spacesAvailable.intValue, NSLocalizedString(@"Free Spaces", nil)];
    }
}

-(Availability)bikeAvailability {
    int bikes = self.bikesAvailable.intValue;
    int total = self.bikesAvailable.intValue + self.spacesAvailable.intValue;
    
    CGFloat percentage = ((CGFloat)bikes/total) * 100;
    
    if (percentage == 0) {
        return NotAvailable;
    } else if (percentage < 35) {
        return LowAvailability;
    } else if (percentage >= 35 && percentage < 65) {
        return HalfAvailability;
    } else if (percentage >= 65 && percentage < 100) {
        return HighAvailability;
    } else {
        return FullAvailability;
    }
}

-(Availability)spaceAvailability {
    int spaces = self.spacesAvailable.intValue;
    int total = self.bikesAvailable.intValue + self.spacesAvailable.intValue;
    
    CGFloat percentage = ((CGFloat)spaces/total) * 100;
    
    if (percentage == 0) {
        return NotAvailable;
    } else if (percentage < 35) {
        return LowAvailability;
    } else if (percentage >= 35 && percentage < 65) {
        return HalfAvailability;
    } else if (percentage >= 65 && percentage < 100) {
        return HighAvailability;
    } else {
        return FullAvailability;
    }
}

@end
