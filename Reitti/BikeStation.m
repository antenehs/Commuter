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

@interface BikeStation()

@property (nonatomic, strong)CLLocation *location;
@property (nonatomic, retain) NSNumber * totalSpaces;

@end

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

-(CLLocationCoordinate2D)coordinates {
    if (self.lon && self.lat) {
        return [ReittiStringFormatter convertStringTo2DCoord:[NSString stringWithFormat:@"%@,%@", self.lon, self.lat]];
    }
    
    return CLLocationCoordinate2DMake(0, 0);
}

-(CLLocation *)location {
    if (!_location) {
        _location = [[CLLocation alloc] initWithLatitude:self.coordinates.latitude longitude:self.coordinates.longitude];
    }
    
    return  _location;
}

-(BOOL)isValid {
    return self.lon && self.lat;
}

-(NSString *)bikesAvailableString {
    if (self.bikesAvailable.intValue == 0) {
        return NSLocalizedString(@"No Bikes", nil);
    } else {
        return [NSString stringWithFormat:@"%d %@",self.bikesAvailable.intValue, [self bikesUnitString]];
    }
}

-(NSString *)bikesUnitString {
    if(self.bikesAvailable.intValue == 1) {
        return NSLocalizedString(@"Bike", nil);
    } else {
        return NSLocalizedString(@"Bikes", nil);
    }
}

-(NSString *)spacesAvailableString {
    if (self.spacesAvailable.intValue == 0) {
        return NSLocalizedString(@"No Return Space", nil);
    } else {
        return [NSString stringWithFormat:@"%d %@",self.spacesAvailable.intValue, [self spacesUnitString]];
    }
}

-(NSString *)spacesUnitString {
    if(self.spacesAvailable.intValue == 1) {
        return NSLocalizedString(@"Free Space", nil);
    } else {
        return NSLocalizedString(@"Free Spaces", nil);
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

-(NSNumber *)totalSpaces {
    return [NSNumber numberWithInt:self.bikesAvailable.intValue + self.spacesAvailable.intValue];
}

@end
