//
//  BikeStation.m
//  HelsinkiBikes
//
//  Created by Anteneh Sahledengel on 4/5/16.
//  Copyright © 2016 Anteneh Sahledengel. All rights reserved.
//

#import "BikeStation.h"
#import "ReittiStringFormatter.h"

@implementation BikeStation

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
    
    if (bikes == 0) {
        return NotAvailable;
    } else if (bikes < 5 && total > 2 * bikes) {
        return LowAvailability;
    } else {
        return HighAvailability;
    }
}

-(Availability)spaceAvailability {
    int spaces = self.spacesAvailable.intValue;
    int total = self.bikesAvailable.intValue + self.spacesAvailable.intValue;
    
    if (spaces == 0) {
        return NotAvailable;
    } else if (spaces < 5 && total > 2 * spaces) {
        return LowAvailability;
    } else {
        return HighAvailability;
    }
}

@end
