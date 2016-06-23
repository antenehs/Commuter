//
//  Route.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 12/8/14.
//  Copyright (c) 2014 Anteneh Sahledengel. All rights reserved.

#import "Route.h"
#import "ReittiStringFormatter.h"
#import "ASA_Helpers.h"

@interface Route ()

@property (nonatomic, strong)NSNumber *numberOfNoneWalkLegs;
@property (nonatomic, strong)NSDate *startingTimeOfRoute;
@property (nonatomic, strong)NSDate *endingTimeOfRoute;
@property (nonatomic, strong)NSDate *timeAtTheFirstStop;
@property (nonatomic)CLLocationCoordinate2D startCoords;
@property (nonatomic)CLLocationCoordinate2D destinationCoords;

@end

@implementation Route

@synthesize routeLength;
@synthesize routeDurationInSeconds;
@synthesize routeLegs;
@synthesize unMappedRouteLegs;

-(double)getTotalWalkLength{
    double totalLength = 0;
    for (RouteLeg *leg in self.routeLegs) {
        if (leg.legType == LegTypeWalk) {
            totalLength += [leg.legLength doubleValue];
        }
    }
    
    return totalLength;
}

-(float)getLengthRatioInRoute:(RouteLeg *)leg{
    float legDuration = [leg.legDurationInSeconds floatValue];
    
    return legDuration/[self.routeDurationInSeconds floatValue];
}

-(bool)isOnlyWalkingRoute{
    int walkLegs = 0;
    for (RouteLeg *leg in self.routeLegs) {
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

-(NSNumber *)numberOfNoneWalkLegs{
    
    if (!_numberOfNoneWalkLegs) {
        int noneWalkLegs = 0;
        for (RouteLeg *leg in self.routeLegs) {
            if (leg.legType != LegTypeWalk) {
                noneWalkLegs ++;
            }
        }
        
        _numberOfNoneWalkLegs = [NSNumber numberWithInt:noneWalkLegs];
    }
    
    return _numberOfNoneWalkLegs;
}

-(NSDate *)startingTimeOfRoute{
    if (!_startingTimeOfRoute) {
        RouteLeg *firstLeg = [self.routeLegs firstObject];
        RouteLegLocation *firstLocation = [firstLeg.legLocations firstObject];
        _startingTimeOfRoute = firstLocation.arrTime;
    }
    
    return _startingTimeOfRoute;
}

-(NSDate *)endingTimeOfRoute{
    if (!_endingTimeOfRoute) {
        RouteLeg *lastLeg = [self.routeLegs lastObject];
        RouteLegLocation *lastLocation = [lastLeg.legLocations lastObject];
        _endingTimeOfRoute = lastLocation.depTime;
    }
    
    return _endingTimeOfRoute;
}

-(NSDate *)timeAtTheFirstStop{
    if (!_timeAtTheFirstStop) {
        for (RouteLeg *leg in self.routeLegs) {
            if (leg.legType != LegTypeWalk) {
                RouteLegLocation *firstLocation = [leg.legLocations firstObject];
                _timeAtTheFirstStop = firstLocation.depTime;
                break;
            }
        }
    }
    
    return _timeAtTheFirstStop;
}

-(CLLocationCoordinate2D)startCoords{
    if (![ReittiMapkitHelper isValidCoordinate:_startCoords]) {
        RouteLeg *firstLeg = [self.routeLegs firstObject];
        RouteLegLocation *firstLocation = [firstLeg.legLocations firstObject];
        
        _startCoords = [ReittiStringFormatter convertStringTo2DCoord:firstLocation.coordsString];
    }
    
    return _startCoords;
}

-(CLLocationCoordinate2D)destinationCoords{
    if (![ReittiMapkitHelper isValidCoordinate:_destinationCoords]) {
        RouteLeg *lastLeg = [self.routeLegs lastObject];
        RouteLegLocation *lastLocation = [lastLeg.legLocations lastObject];
        
        _destinationCoords = [ReittiStringFormatter convertStringTo2DCoord:lastLocation.coordsString];
    }
    
    return _destinationCoords;
}

#pragma mark - Conversion from matka object
+(id)routeFromMatkaRoute:(MatkaRoute *)matkaRoute {
    Route *route = [[Route alloc] init];
    
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
        RouteLeg *leg = [RouteLeg routeLegFromMatkaRouteLeg:matkaLeg];
        if (leg)
            [allLegs addObject:leg];
    }
    
    route.routeLegs = allLegs;
    
    return route;
}

+(id)routeFromDigiPlan:(DigiPlan *)digiPlan {
    Route *route = [[Route alloc] init];
    
    route.routeLength = digiPlan.distance;
    route.routeDurationInSeconds = digiPlan.duration;
    route.numberOfNoneWalkLegs = digiPlan.numberOfNoneWalkLegs;
    route.startingTimeOfRoute = digiPlan.parsedStartTime;
    route.endingTimeOfRoute = digiPlan.parsedEndTime;
    route.timeAtTheFirstStop = digiPlan.timeAtFirstStop;
    route.startCoords = digiPlan.startCoords;
    route.destinationCoords = digiPlan.destinationCoords;
    
    NSMutableArray *allLegs = [@[] mutableCopy];
    for (DigiLegs *digiLeg in digiPlan.legs) {
        RouteLeg *leg = [RouteLeg routeLegFromDigiRouteLeg:digiLeg];
        if (leg)
            [allLegs addObject:leg];
    }
    
    route.routeLegs = allLegs;
    
    return route;
}

@end
