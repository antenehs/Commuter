//
//  MatkaRoute.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 11/4/16.
//  Copyright © 2016 Anteneh Sahledengel. All rights reserved.
//

#import "MatkaRoute.h"
#import "ReittiDateHelper.h"
#import "ReittiStringFormatter.h"
#import "ASA_Helpers.h"

@implementation MatkaRoute

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
    if (!_startingTime) {
        MatkaRouteLocation *loc = [self routeStartPoint];
        if (loc) {
            _startingTime = loc.parsedDepartureTime;
        }
    }
    
    return _startingTime;
}

-(NSDate *)endingTime {
    if (!_endingTime) {
        MatkaRouteLocation *loc = [self routeEndPoint];
        if (loc) {
            _endingTime = loc.parsedArrivalTime;
        }
    }
    
    return _endingTime;
}

-(NSDate *)timeAtFirstStop {
    if (!_timeAtFirstStop) {
        if (_routeLineLegs && _routeLineLegs.count > 0) {
            MatkaRouteLeg *firstLineLeg = _routeLineLegs[0];
            if (firstLineLeg.stops && firstLineLeg.stops.count > 0 ) {
                MatkaRouteStop *firstStop = firstLineLeg.stops[0];
                _timeAtFirstStop = firstStop.parsedDepartureTime;
            }   
        }
    }
    
    return _timeAtFirstStop;
}

-(CLLocationCoordinate2D)startCoords {
    if (![ReittiMapkitHelper isValidCoordinate:_startCoords]) {
        MatkaRouteLocation *loc = [self routeStartPoint];
        if (loc) {
            _startCoords = loc.coords;
        }
    }
    
    return _startCoords;
}

-(CLLocationCoordinate2D)destinationCoords {
    if (![ReittiMapkitHelper isValidCoordinate:_destinationCoords]) {
        MatkaRouteLocation *loc = [self routeEndPoint];
        if (loc) {
            _destinationCoords = loc.coords;
        }
    }
    
    return _destinationCoords;
}

-(MatkaRouteLocation *)routeStartPoint {
    if (_points) {
        for (MatkaRouteLocation *loc in _points) {
            if ([[loc.uid lowercaseString] isEqualToString:@"start"]) {
                return loc;
            }
        }
    }
    
    return nil;
}

-(MatkaRouteLocation *)routeEndPoint {
    if (_points) {
        for (MatkaRouteLocation *loc in _points) {
            if ([[loc.uid lowercaseString] isEqualToString:@"dest"]) {
                return loc;
            }
        }
    }
    
    return nil;
}

-(NSArray *)allLegs {
    if (!_allLegs) {
        NSMutableArray *allLegArray = [@[] mutableCopy];
        
        if (self.routeWalkingLegs)
            [allLegArray addObjectsFromArray:self.routeWalkingLegs];
        
        if (self.routeLineLegs)
            [allLegArray addObjectsFromArray:self.routeLineLegs];
        
        NSSortDescriptor *dateSort = [[NSSortDescriptor alloc] initWithKey:@"startingTime" ascending:YES];
        
        [allLegArray sortUsingDescriptors:@[dateSort]];
        
        for (int i = 0; i < allLegArray.count; i++) {
            [allLegArray[i] setLegOrder:i];
        }
        
        _allLegs = allLegArray;
    }
    
    return _allLegs;
}

@end
