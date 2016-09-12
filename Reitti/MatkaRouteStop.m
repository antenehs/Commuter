//
//  MatkaRouteStop.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 11/4/16.
//  Copyright © 2016 Anteneh Sahledengel. All rights reserved.
//

#import "MatkaRouteStop.h"
#import "ReittiDateFormatter.h"
#import "MatkaName.h"
#import "ReittiStringFormatter.h"

@implementation MatkaRouteStop

-(NSDate *)parsedArrivalTime {
    if (!_parsedArrivalTime) {
        if (_arrivalTime) {
            _parsedArrivalTime = [[ReittiDateFormatter sharedFormatter] dateFromApiDateString:_arrivalDate andHourString:_arrivalTime];
        }
    }
    
    return _parsedArrivalTime;
}

-(NSDate *)parsedDepartureTime {
    if (!_parsedDepartureTime) {
        if (_departureTime) {
            _parsedDepartureTime = [[ReittiDateFormatter sharedFormatter] dateFromApiDateString:_departureDate andHourString:_departureTime];
        }
    }
    
    return _parsedDepartureTime;
}

-(NSString *)coordString {
    if (!_coordString) {
#if !(DEPARTURES_WIDGET)
        _coordString = [ReittiStringFormatter coordStringFromKkj3CoorsWithX:_xCoord andY:_yCoord];
#else
        _coordString = [NSString stringWithFormat:@"%@,%@", _xCoord, _yCoord];
#endif
    }
    return _coordString;
}

-(CLLocationCoordinate2D)coords{
    return [ReittiStringFormatter convertStringTo2DCoord:self.coordString];
}

-(NSString *)nameFi {
    if (_stopNames && _stopNames.count > 0) {
        for (MatkaName *name in _stopNames) {
            if ([[name.language lowercaseString] isEqualToString:@"1"]) {
                return name.name;
            }
        }
    }
    
    return nil;
}

-(NSString *)nameSe {
    if (_stopNames && _stopNames.count > 0) {
        for (MatkaName *name in _stopNames) {
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
