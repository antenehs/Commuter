//
//  Route.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 12/8/14.
//  Copyright (c) 2014 Anteneh Sahledengel. All rights reserved.

#import "RouteE.h"
#import "ReittiStringFormatterE.h"

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
-(int)getNumberOfNoneWalkLegs{
    int noneWalkLegs = 0;
    for (RouteLegE *leg in self.routeLegs) {
        if (leg.legType != LegTypeWalk) {
            noneWalkLegs ++;
        }
    }
    return noneWalkLegs;
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

-(NSDate *)getStartingTimeOfRoute{
    RouteLegE *firstLeg = [self.routeLegs firstObject];
    RouteLegLocationE *firstLocation = [firstLeg.legLocations firstObject];
    return firstLocation.arrTime;
}
-(NSDate *)getEndingTimeOfRoute{
    RouteLegE *lastLeg = [self.routeLegs lastObject];
    RouteLegLocationE *lastLocation = [lastLeg.legLocations lastObject];
    return lastLocation.depTime;
}

-(NSDate *)getTimeAtTheFirstStop{
    for (RouteLegE *leg in self.routeLegs) {
        if (leg.legType != LegTypeWalk) {
            RouteLegLocationE *firstLocation = [leg.legLocations firstObject];
            return firstLocation.depTime;
        }
    }
    
    return nil;
}

-(CLLocationCoordinate2D)getStartCoords{
    RouteLegE *firstLeg = [self.routeLegs firstObject];
    RouteLegLocationE *firstLocation = [firstLeg.legLocations firstObject];
    
    return [ReittiStringFormatterE convertStringTo2DCoord:firstLocation.coordsString];
}

-(NSString *)getDestinationCoords{
    RouteLegE *lastLeg = [self.routeLegs lastObject];
    RouteLegLocationE *lastLocation = [lastLeg.legLocations lastObject];
    
    return lastLocation.coordsString;
}

@end
