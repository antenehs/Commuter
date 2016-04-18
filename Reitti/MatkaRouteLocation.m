//
//  MatkaRoutePoint.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 11/4/16.
//  Copyright © 2016 Anteneh Sahledengel. All rights reserved.
//

#import "MatkaRouteLocation.h"
#import "ReittiDateFormatter.h"
#import "ReittiStringFormatter.h"
#import "MatkaName.h"

@implementation MatkaRouteLocation

-(NSDate *)parsedArrivalTime {
    if (!_parsedArrivalTime) {
        if (_arrivalTime) {
            _parsedArrivalTime = [[ReittiDateFormatter sharedFormatter] dateFromMatkaDateString:_arrivalDate andHourString:_arrivalTime];
        }
    }
    
    return _parsedArrivalTime;
}

-(NSDate *)parsedDepartureTime {
    if (!_parsedDepartureTime) {
        if (_departureTime) {
            _parsedDepartureTime = [[ReittiDateFormatter sharedFormatter] dateFromMatkaDateString:_departureDate andHourString:_departureTime];
        }
    }
    
    return _parsedDepartureTime;
}

-(NSString *)coordString {
    if (!_coordString) {
        _coordString = [ReittiStringFormatter coordStringFromKkj3CoorsWithX:_xCoord andY:_yCoord];
    }
    return _coordString;
}

-(CLLocationCoordinate2D)coords{
    return [ReittiStringFormatter convertStringTo2DCoord:self.coordString];
}

-(NSString *)nameFi {
    if (self.locNames && self.locNames.count > 0) {
        for (MatkaName *name in self.locNames) {
            if ([[name.language lowercaseString] isEqualToString:@"1"]) {
                return name.name;
            }
        }
    }
    
    return nil;
}

-(NSString *)nameSe {
    if (self.locNames && self.locNames.count > 0) {
        for (MatkaName *name in self.locNames) {
            if ([[name.language lowercaseString] isEqualToString:@"2"]) {
                return name.name;
            }
        }
    }
    
    return nil;
}

-(NSString *)name {
    return self.nameFi ? self.nameFi : self.nameSe;
}

@end
