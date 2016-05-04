//
//  MatkaRouteWalk.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 11/4/16.
//  Copyright © 2016 Anteneh Sahledengel. All rights reserved.
//

#import "MatkaRouteLeg.h"

@implementation MatkaRouteLeg

-(NSNumber *)timeInSeconds {
    if (!_timeInSeconds) {
        if (self.time) {
            double seconds = [self.time doubleValue] * 60.0;
            _timeInSeconds = [NSNumber numberWithDouble:seconds];
        }else
            _timeInSeconds = @0;
    }
    
    return _timeInSeconds;
}

-(NSDate *)startingTime {
    //Walking legs might have both point and stop. Check for both
    if (!_startingTime) {
        MatkaRouteLocation *loc = [self legStartPoint];
        if (loc) {
            _startingTime = loc.parsedDepartureTime;
        } else if (self.stops) {
            MatkaRouteStop *firstStop = [self.stops firstObject];
            if (firstStop) {
                _startingTime = firstStop.parsedDepartureTime;
            }
        }
    }
    
    return _startingTime;
}

-(NSDate *)endingTime {
    if (!_endingTime) {
        MatkaRouteLocation *loc = [self legEndPoint];
        if (loc) {
            _endingTime = loc.parsedArrivalTime;
        } else if (self.stops) {
            MatkaRouteStop *lastStop = [self.stops lastObject];
            if (lastStop) {
                _endingTime = lastStop.parsedArrivalTime;
            }
        }
    }
    
    return _endingTime;
}

-(LegTransportType)legType {
    if (self.transportType || self.lineId || self.codeShort) {
        return [EnumManager legTypeForMatkaTrasportType:self.transportType];
    }else{
        return LegTypeWalk;
    }
}

-(MatkaRouteLocation *)legStartPoint {
    if (_startDestPoints) {
        for (MatkaRouteLocation *loc in _startDestPoints) {
            if ([[loc.uid lowercaseString] isEqualToString:@"start"]) {
                return loc;
            }
        }
    }
    
    return nil;
}

-(MatkaRouteLocation *)legEndPoint {
    if (_startDestPoints) {
        for (MatkaRouteLocation *loc in _startDestPoints) {
            if ([[loc.uid lowercaseString] isEqualToString:@"dest"]) {
                return loc;
            }
        }
    }
    
    return nil;
}

-(MatkaRouteStop *)legStartStop {
    if (![self legStartPoint] && self.stops) {
        return [self.stops firstObject];
    }
    
    return nil;
}

-(MatkaRouteStop *)legEndStop {
    if (![self legEndPoint] && self.stops) {
        return [self.stops lastObject];
    }
    
    return nil;
}

@end
