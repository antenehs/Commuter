//
//  Route.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 12/8/14.
//  Copyright (c) 2014 Anteneh Sahledengel. All rights reserved.

#import "Route.h"

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
-(int)getNumberOfNoneWalkLegs{
    int noneWalkLegs = 0;
    for (RouteLeg *leg in self.routeLegs) {
        if (leg.legType != LegTypeWalk) {
            noneWalkLegs ++;
        }
    }
    return noneWalkLegs;
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

-(NSDate *)getStartingTimeOfRoute{
    RouteLeg *firstLeg = [self.routeLegs firstObject];
    RouteLegLocation *firstLocation = [firstLeg.legLocations firstObject];
    return firstLocation.arrTime;
}
-(NSDate *)getEndingTimeOfRoute{
    RouteLeg *lastLeg = [self.routeLegs lastObject];
    RouteLegLocation *lastLocation = [lastLeg.legLocations lastObject];
    return lastLocation.depTime;
}

@end
