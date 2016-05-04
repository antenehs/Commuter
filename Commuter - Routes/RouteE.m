//
//  Route.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 12/8/14.
//  Copyright (c) 2014 Anteneh Sahledengel. All rights reserved.

#import "RouteE.h"
//#import "ReittiStringFormatterE.h"
#import "ReittiStringFormatter.h"
#import "ReittiMapkitHelper.h"

@interface RouteE ()

@property (nonatomic, strong)NSNumber *numberOfNoneWalkLegs;
@property (nonatomic, strong)NSDate *startingTimeOfRoute;
@property (nonatomic, strong)NSDate *endingTimeOfRoute;
@property (nonatomic, strong)NSDate *timeAtTheFirstStop;
@property (nonatomic)CLLocationCoordinate2D startCoords;
@property (nonatomic)CLLocationCoordinate2D destinationCoords;

@end

@implementation RouteE

@synthesize routeLength;
@synthesize routeDurationInSeconds;
@synthesize routeLegs;
@synthesize unMappedRouteLegs;

-(double)getTotalWalkLength{
    double totalLength = 0;
    for (RouteLegE *leg in self.routeLegs) {
        if (leg.legType == LegTypeWalk) {
            totalLength += [leg.legLength doubleValue];
        }
    }
    
    return totalLength;
}

-(float)getLengthRatioInRoute:(RouteLegE *)leg{
    float legDuration = [leg.legDurationInSeconds floatValue];
    
    return legDuration/[self.routeDurationInSeconds floatValue];
}

-(bool)isOnlyWalkingRoute{
    int walkLegs = 0;
    for (RouteLegE *leg in self.routeLegs) {
        if (leg.legType == LegTypeWalk) {
            walkLegs ++;
        }
    }
    
    if (walkLegs == self.routeLegs.count) {
        return YES;
    }else{
        return NO;
    }
}

//-(int)getNumberOfNoneWalkLegs{
//    int noneWalkLegs = 0;
//    for (RouteLegE *leg in self.routeLegs) {
//        if (leg.legType != LegTypeWalk) {
//            noneWalkLegs ++;
//        }
//    }
//    return noneWalkLegs;
//}

-(NSNumber *)numberOfNoneWalkLegs{
    
    if (!_numberOfNoneWalkLegs) {
        int noneWalkLegs = 0;
        for (RouteLegE *leg in self.routeLegs) {
            if (leg.legType != LegTypeWalk) {
                noneWalkLegs ++;
            }
        }
        
        _numberOfNoneWalkLegs = [NSNumber numberWithInt:noneWalkLegs];
    }
    
    return _numberOfNoneWalkLegs;
}

//-(NSDate *)getStartingTimeOfRoute{
//    RouteLegE *firstLeg = [self.routeLegs firstObject];
//    RouteLegLocationE *firstLocation = [firstLeg.legLocations firstObject];
//    return firstLocation.arrTime;
//}
//-(NSDate *)getEndingTimeOfRoute{
//    RouteLegE *lastLeg = [self.routeLegs lastObject];
//    RouteLegLocationE *lastLocation = [lastLeg.legLocations lastObject];
//    return lastLocation.depTime;
//}
//
//-(NSDate *)getTimeAtTheFirstStop{
//    for (RouteLegE *leg in self.routeLegs) {
//        if (leg.legType != LegTypeWalk) {
//            RouteLegLocationE *firstLocation = [leg.legLocations firstObject];
//            return firstLocation.depTime;
//        }
//    }
//    
//    return nil;
//}

-(NSDate *)startingTimeOfRoute{
    if (!_startingTimeOfRoute) {
        RouteLegE *firstLeg = [self.routeLegs firstObject];
        RouteLegLocationE *firstLocation = [firstLeg.legLocations firstObject];
        _startingTimeOfRoute = firstLocation.arrTime;
    }
    
    return _startingTimeOfRoute;
}

-(NSDate *)endingTimeOfRoute{
    if (!_endingTimeOfRoute) {
        RouteLegE *lastLeg = [self.routeLegs lastObject];
        RouteLegLocationE *lastLocation = [lastLeg.legLocations lastObject];
        _endingTimeOfRoute = lastLocation.depTime;
    }
    
    return _endingTimeOfRoute;
}

-(NSDate *)timeAtTheFirstStop{
    if (!_timeAtTheFirstStop) {
        for (RouteLegE *leg in self.routeLegs) {
            if (leg.legType != LegTypeWalk) {
                RouteLegLocationE *firstLocation = [leg.legLocations firstObject];
                _timeAtTheFirstStop = firstLocation.depTime;
                break;
            }
        }
    }
    
    return _timeAtTheFirstStop;
}


//-(CLLocationCoordinate2D)getStartCoords{
//    RouteLegE *firstLeg = [self.routeLegs firstObject];
//    RouteLegLocationE *firstLocation = [firstLeg.legLocations firstObject];
//    
//    return [ReittiStringFormatterE convertStringTo2DCoord:firstLocation.coordsString];
//}
//
//-(NSString *)getDestinationCoords{
//    RouteLegE *lastLeg = [self.routeLegs lastObject];
//    RouteLegLocationE *lastLocation = [lastLeg.legLocations lastObject];
//    
//    return lastLocation.coordsString;
//}

-(CLLocationCoordinate2D)startCoords{
    if (![ReittiMapkitHelper isValidCoordinate:_startCoords]) {
        RouteLegE *firstLeg = [self.routeLegs firstObject];
        RouteLegLocationE *firstLocation = [firstLeg.legLocations firstObject];
        
        _startCoords = [ReittiStringFormatter convertStringTo2DCoord:firstLocation.coordsString];
    }
    
    return _startCoords;
}

-(CLLocationCoordinate2D)destinationCoords{
    if (![ReittiMapkitHelper isValidCoordinate:_destinationCoords]) {
        RouteLegE *lastLeg = [self.routeLegs lastObject];
        RouteLegLocationE *lastLocation = [lastLeg.legLocations lastObject];
        
        _destinationCoords = [ReittiStringFormatter convertStringTo2DCoord:lastLocation.coordsString];
    }
    
    return _destinationCoords;
}

#pragma mark - Conversion from matka object
+(id)routeFromMatkaRoute:(MatkaRoute *)matkaRoute {
    RouteE *route = [[RouteE alloc] init];
    
    route.routeLength = matkaRoute.distance;
    route.routeDurationInSeconds = matkaRoute.timeInSeconds;
    route.numberOfNoneWalkLegs = [NSNumber numberWithInteger: matkaRoute.routeLineLegs ? matkaRoute.routeLineLegs.count : 0];
    route.startingTimeOfRoute = matkaRoute.startingTime;
    route.endingTimeOfRoute = matkaRoute.endingTime;
    route.timeAtTheFirstStop = matkaRoute.timeAtFirstStop;
    route.startCoords = matkaRoute.startCoords;
    route.destinationCoords = matkaRoute.destinationCoords;
    
    NSMutableArray *allLegs = [@[] mutableCopy];
    for (MatkaRouteLeg *matkaLeg in matkaRoute.allLegs) {
        RouteLegE *leg = [RouteLegE routeLegFromMatkaRouteLeg:matkaLeg];
        if (leg)
            [allLegs addObject:leg];
    }
    
    route.routeLegs = allLegs;
    
    return route;
}

@end
