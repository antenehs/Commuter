//
//  Route.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 12/8/14.
//  Copyright (c) 2014 Anteneh Sahledengel. All rights reserved.

#import "Route.h"
#import "ASA_Helpers.h"
#import "AppManager.h"

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
        _numberOfNoneWalkLegs = [NSNumber numberWithInteger:self.noneWalkingLegs.count];
    }
    
    return _numberOfNoneWalkLegs;
}

-(NSArray *)noneWalkingLegs {
    if (!_noneWalkingLegs) {
        NSMutableArray *legs = [@[] mutableCopy];
        for (RouteLeg *leg in self.routeLegs) {
            if (leg.legType != LegTypeWalk)
                [legs addObject:leg];
        }
        
        _noneWalkingLegs = legs;
    }
    
    return _noneWalkingLegs;
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
        
        _startCoords = [firstLocation.coordsString convertTo2DCoord];
    }
    
    return _startCoords;
}

-(CLLocationCoordinate2D)destinationCoords{
    if (![ReittiMapkitHelper isValidCoordinate:_destinationCoords]) {
        RouteLeg *lastLeg = [self.routeLegs lastObject];
        RouteLegLocation *lastLocation = [lastLeg.legLocations lastObject];
        
        _destinationCoords = [lastLocation.coordsString convertTo2DCoord];
    }
    
    return _destinationCoords;
}

#pragma mark - To and from dictionary
+(instancetype)initFromDictionary: (NSDictionary *)dictionary {
    if (!dictionary) return nil;
    
    Route *route = [Route new];
    route.routeLength = [route objectOrNilForKey:@"routeLength" fromDictionary:dictionary];
    route.routeDurationInSeconds = [route objectOrNilForKey:@"routeDurationInSeconds" fromDictionary:dictionary];
    route.fromLocationName = [route objectOrNilForKey:@"fromLocationName" fromDictionary:dictionary];
    route.toLocationName = [route objectOrNilForKey:@"toLocationName" fromDictionary:dictionary];
    
    NSMutableArray *legs = [@[] mutableCopy];
    NSArray *legDictionaries = [route objectOrNilForKey:@"routeLegs" fromDictionary:dictionary];
    for (NSDictionary *legDict in legDictionaries) {
        RouteLeg *leg = [RouteLeg initFromDictionary:legDict];
        if (leg) [legs addObject:leg];
    }
    
    route.routeLegs = legs;
    
    route.numberOfNoneWalkLegs = [route objectOrNilForKey:@"numberOfNoneWalkLegs" fromDictionary:dictionary];
    route.startingTimeOfRoute = [route objectOrNilForKey:@"startingTimeOfRoute" fromDictionary:dictionary];
    route.endingTimeOfRoute = [route objectOrNilForKey:@"endingTimeOfRoute" fromDictionary:dictionary];
    route.timeAtTheFirstStop = [route objectOrNilForKey:@"timeAtTheFirstStop" fromDictionary:dictionary];
    
    NSString *startCoordsString = [route objectOrNilForKey:@"startCoords" fromDictionary:dictionary];
    route.startCoords = [startCoordsString convertTo2DCoord];
    
    NSString *destCoordsString = [route objectOrNilForKey:@"destinationCoords" fromDictionary:dictionary];
    route.destinationCoords = [destCoordsString convertTo2DCoord];
    
    return route;
}

-(NSDictionary *)dictionaryRepresentation{
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
    [mutableDict setValue:self.routeLength forKey:@"routeLength"];
    [mutableDict setValue:self.routeDurationInSeconds forKey:@"routeDurationInSeconds"];
    [mutableDict setValue:self.fromLocationName forKey:@"fromLocationName"];
    [mutableDict setValue:self.toLocationName forKey:@"toLocationName"];
    
    NSMutableArray *legDictArray = [@[] mutableCopy];
    for (RouteLeg *leg in self.routeLegs) {
        NSDictionary *legDict = [leg dictionaryRepresentation];
        if (legDict) [legDictArray addObject:legDict];
    }
    
    [mutableDict setValue:legDictArray forKey:@"routeLegs"];
    
    [mutableDict setValue:self.numberOfNoneWalkLegs forKey:@"numberOfNoneWalkLegs"];
    [mutableDict setValue:self.startingTimeOfRoute forKey:@"startingTimeOfRoute"];
    [mutableDict setValue:self.endingTimeOfRoute forKey:@"endingTimeOfRoute"];
    [mutableDict setValue:self.timeAtTheFirstStop forKey:@"timeAtTheFirstStop"];
    
    [mutableDict setValue:[NSString stringRepresentationOf2DCoord:self.startCoords] forKey:@"startCoords"];
    [mutableDict setValue:[NSString stringRepresentationOf2DCoord:self.destinationCoords] forKey:@"destinationCoords"];
    
    return [NSDictionary dictionaryWithDictionary:mutableDict];
}

-(NSString *)routeUniqueName {
    return [NSString stringWithFormat:@"%@ - %@",self.fromLocationName, self.toLocationName];
}


#ifndef APPLE_WATCH

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

-(UIImage *)routeIcon {
    if (!_routeIcon) {
        if (!self.routeLegs || self.routeLegs.count == 0)
            _routeIcon = [UIImage imageNamed:@"up-right-arrow-32"];
        else {
            if ([self isOnlyWalkingRoute]) {
                _routeIcon = [AppManager vehicleImageForLegTrasnportType:LegTypeWalk];
            } else if ([self numberOfNoneWalkLegs] > 0) {
                LegTransportType type = [[[self noneWalkingLegs] firstObject] legType];
                if (type == LegTypeMetro)
                    _routeIcon = [UIImage imageNamed:@"metro-no-background"];
                else
                    _routeIcon = [AppManager vehicleImageForLegTrasnportType:type];
            } else {
                _routeIcon = [UIImage imageNamed:@"up-right-arrow-32"];
            }
        }
    }
    
    return _routeIcon;
}
#endif

#pragma mark - Helper Method
- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict
{
    id object = [dict objectForKey:aKey];
    return [object isEqual:[NSNull null]] ? nil : object;
}



@end
