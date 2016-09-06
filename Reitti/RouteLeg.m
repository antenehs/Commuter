//
//  RouteLeg.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 12/8/14.
//  Copyright (c) 2014 Anteneh Sahledengel. All rights reserved.
//
//1 = Helsinki internal bus lines
//2 = trams
//3 = Espoo internal bus lines
//4 = Vantaa internal bus lines
//5 = regional bus lines
//6 = metro
//7 = ferry
//8 = U-lines
//12 = commuter trains
//21 = Helsinki service lines
//22 = Helsinki night buses
//23 = Espoo service lines
//24 = Vantaa service lines
//25 = region night buses
//36 = Kirkkonummi internal bus lines
//39 = Kerava internal bus lines


#import "RouteLeg.h"
#import "EnumManager.h"

#ifndef APPLE_WATCH
#import "DigiDataModels.h"
#endif

@implementation RouteLeg

@synthesize legLength;
@synthesize legDurationInSeconds;
@synthesize waitingTimeInSeconds;
@synthesize lineCode;
@synthesize legLocations;
@synthesize legShapeDictionaries;
@synthesize showDetailed;
@synthesize legOrder;

-(id)initFromHSLandTREDictionary:(NSDictionary *)legDict{
    if (self = [super init]) {
        self.legLength = [self objectOrNilForKey:@"length" fromDictionary:legDict];
        self.legDurationInSeconds = [self objectOrNilForKey:@"duration" fromDictionary:legDict];
        self.legSpecificType = [self objectOrNilForKey:@"type" fromDictionary:legDict];
        self.legType = [self getLegTransportType];
        self.lineCode = [self objectOrNilForKey:@"code" fromDictionary:legDict];
        
        NSMutableArray *locsArray = [[NSMutableArray alloc] init];
        
        for (NSDictionary *locDict in legDict[@"locs"]) {
            RouteLegLocation *loc = [[RouteLegLocation alloc] initFromHSLandTREDictionary:locDict];
            loc.locationLegOrder = self.legOrder;
            loc.locationLegType = self.legType;
            [locsArray addObject:loc];
        }
        
        if (locsArray.count > 0) {
            RouteLegLocation *lastLoc = [locsArray lastObject];
            if (lastLoc != nil) {
                waitingTimeInSeconds = [lastLoc.depTime timeIntervalSinceDate:lastLoc.arrTime];
            }
        }else{
            waitingTimeInSeconds = 0;
        }
        
        self.legShapeDictionaries = [self objectOrNilForKey:@"shape" fromDictionary:legDict];
        
        NSMutableArray *shapeArray = [[NSMutableArray alloc] init];
        for (NSDictionary * shapeDict in legDict[@"shape"]) {
            [shapeArray addObject:[NSString stringWithFormat:@"%@,%@",[self objectOrNilForKey:@"x" fromDictionary:shapeDict] , [self objectOrNilForKey:@"y" fromDictionary:shapeDict]]];
        }
        
        self.legLocations = locsArray;
        
        if (self.legType == LegTypeWalk || self.legType == LegTypeOther) {
            self.showDetailed = NO;
        }else{
            self.showDetailed = NO;
        }
    }
    return self;
}

-(LegTransportType)getLegTransportType{
    if ([self.legSpecificType isEqual:@"walk"]) {
        return LegTypeWalk;
    }
    else if ([self.legSpecificType isEqual:@"1"] ||
            [self.legSpecificType isEqual:@"3"] ||
                [self.legSpecificType isEqual:@"4"] ||
                    [self.legSpecificType isEqual:@"5"] ||
                        [self.legSpecificType isEqual:@"22"] ||
                            [self.legSpecificType isEqual:@"25"] ||
                                [self.legSpecificType isEqual:@"36"] ||
                                    [self.legSpecificType isEqual:@"39"] ||
                                        [self.legSpecificType isEqual:@"8"]) {
        return LegTypeBus;
    }
    else if ([self.legSpecificType isEqual:@"7"]) {
        return LegTypeFerry;
    }
    else if ([self.legSpecificType isEqual:@"6"]) {
        return LegTypeMetro;
    }
    else if ([self.legSpecificType isEqual:@"2"]) {
        return LegTypeTram;
    }
    else if ([self.legSpecificType isEqual:@"12"]) {
        return LegTypeTrain;
    }
    else if ([self.legSpecificType isEqual:@"21"] ||
                [self.legSpecificType isEqual:@"23"] ||
                    [self.legSpecificType isEqual:@"24"]){
        return LegTypeService;
    }
    else{
        return LegTypeOther;
    }
}

-(NSArray *)legShapeCoorStrings {
    if (!_legShapeCoorStrings) {
        NSMutableArray *strings = [@[] mutableCopy];
        for (NSDictionary *coordDict in self.legShapeDictionaries) {
            [strings addObject:[NSString stringWithFormat:@"%@,%@", [coordDict objectForKey:@"x"], [coordDict objectForKey:@"y"]]];
        }
        
        _legShapeCoorStrings = strings;
    }
    
    return _legShapeCoorStrings;
}

-(int)getNumberOfStopsInLeg {
    int count = 0;
    if (self.legType != LegTypeWalk) {
        count = (int)self.legLocations.count;
    }
    
    return count;
}

-(NSString *)startLocName {
    if (!_startLocName) {
        RouteLegLocation *loc = self.legLocations.count > 0 ? self.legLocations[0] : nil;
        if (loc) _startLocName = loc.name;
        else _startLocName = @"";
    }
    
    return _startLocName;
}

-(NSString *)endLocName {
    if (!_endLocName) {
        RouteLegLocation *loc = self.legLocations.count > 0 ? [self.legLocations lastObject] : nil;
        if (loc) _endLocName = loc.name;
        else _endLocName = @"";
    }
    
    return _endLocName;
}

-(NSDate *)departureTime {
    if (!_departureTime) {
        RouteLegLocation *firstLocation = [self.legLocations firstObject];
        _departureTime = firstLocation.depTime;
    }
    
    return _departureTime;
}

-(NSString *)lineDisplayName{
    return [EnumManager lineDisplayName:self.legType forLineCode:self.lineName];
}

#pragma mark - to and from dictionary

+(instancetype)initFromDictionary: (NSDictionary *)dictionary {
    if (!dictionary) return nil;
    
    RouteLeg *leg = [RouteLeg new];
    leg.legLength = [leg objectOrNilForKey:@"legLength" fromDictionary:dictionary];
    leg.legDurationInSeconds = [leg objectOrNilForKey:@"legDurationInSeconds" fromDictionary:dictionary];
    leg.legSpecificType = [leg objectOrNilForKey:@"legSpecificType" fromDictionary:dictionary];
    leg.lineCode = [leg objectOrNilForKey:@"lineCode" fromDictionary:dictionary];
    leg.lineName = [leg objectOrNilForKey:@"lineName" fromDictionary:dictionary];
    leg.legShapeDictionaries = [leg objectOrNilForKey:@"legShapeDictionaries" fromDictionary:dictionary];
    
    NSMutableArray *locations = [@[] mutableCopy];
    NSArray *locDictionaries = [leg objectOrNilForKey:@"legLocations" fromDictionary:dictionary];
    for (NSDictionary *locDict in locDictionaries) {
        RouteLegLocation *location = [RouteLegLocation initFromDictionary:locDict];
        if (location) [locations addObject:location];
    }
    
    leg.legLocations = locations;
    
    leg.startLocName = [leg objectOrNilForKey:@"startLocName" fromDictionary:dictionary];
    leg.endLocName = [leg objectOrNilForKey:@"endLocName" fromDictionary:dictionary];
    leg.legType = [[leg objectOrNilForKey:@"legType" fromDictionary:dictionary] intValue];
    leg.waitingTimeInSeconds = [[leg objectOrNilForKey:@"waitingTimeInSeconds" fromDictionary:dictionary] integerValue];
    leg.showDetailed = [[leg objectOrNilForKey:@"showDetailed" fromDictionary:dictionary] boolValue];
    leg.legOrder = [[leg objectOrNilForKey:@"legOrder" fromDictionary:dictionary] intValue];
    
    return leg;
}

-(NSDictionary *)dictionaryRepresentation{
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
    [mutableDict setValue:self.legLength forKey:@"legLength"];
    [mutableDict setValue:self.legDurationInSeconds forKey:@"legDurationInSeconds"];
    [mutableDict setValue:self.legSpecificType forKey:@"legSpecificType"];
    [mutableDict setValue:self.lineCode forKey:@"lineCode"];
    [mutableDict setValue:self.lineName forKey:@"lineName"];
    [mutableDict setValue:self.legShapeDictionaries forKey:@"legShapeDictionaries"];
    
    NSMutableArray *locationDictArray = [@[] mutableCopy];
    for (RouteLegLocation *location in self.legLocations) {
        NSDictionary *locationDict = [location dictionaryRepresentation];
        if (locationDict) [locationDictArray addObject:locationDict];
    }
    
    [mutableDict setValue:locationDictArray forKey:@"legLocations"];
    
    [mutableDict setValue:self.startLocName forKey:@"startLocName"];
    [mutableDict setValue:self.endLocName forKey:@"endLocName"];
    [mutableDict setValue:[NSNumber numberWithInt:(int)self.legType] forKey:@"legType"];
    [mutableDict setValue:[NSNumber numberWithInteger:self.waitingTimeInSeconds] forKey:@"waitingTimeInSeconds"];
    [mutableDict setValue:[NSNumber numberWithBool:self.showDetailed] forKey:@"showDetailed"];
    [mutableDict setValue:[NSNumber numberWithInt:self.legOrder] forKey:@"legOrder"];
    
    return [NSDictionary dictionaryWithDictionary:mutableDict];
}

#ifndef APPLE_WATCH
#pragma mark - init from Matka leg
+(id)routeLegFromMatkaRouteLeg:(MatkaRouteLeg *)matkaLeg{
    RouteLeg *leg = [[RouteLeg alloc] init];
    
    leg.legLength = matkaLeg.distance;
    leg.legDurationInSeconds = matkaLeg.timeInSeconds;
    leg.waitingTimeInSeconds = 0; //TODO: think about this
    leg.legType = matkaLeg.legType;
    leg.lineCode = matkaLeg.lineId;
    leg.lineName = matkaLeg.codeShort;
    leg.legOrder = matkaLeg.legOrder;
    
    //If leg type is walk, create locations from matkaLeg.locations else from matkaLeg.stops
    if (matkaLeg.legType == LegTypeWalk) {
        NSMutableArray *locations = [@[] mutableCopy];
        NSMutableArray *shapeStrings = [@[] mutableCopy];
        MatkaRouteLocation *startLoc = [matkaLeg legStartPoint];
        if (startLoc) {
            RouteLegLocation *legLoc = [RouteLegLocation routeLocationFromMatkaRouteLocation:startLoc];
            legLoc.locationLegOrder = matkaLeg.legOrder;
            legLoc.locationLegType = leg.legType;
            [locations addObject:legLoc];
            [shapeStrings addObject:legLoc.coordsString];
        } else {
            MatkaRouteStop *startStop = [matkaLeg legStartStop];
            if(startStop) {
                RouteLegLocation *legLoc = [RouteLegLocation routeLocationFromMatkaRouteStop:startStop];
                legLoc.locationLegOrder = matkaLeg.legOrder;
                legLoc.locationLegType = leg.legType;
                [locations addObject:legLoc];
                [shapeStrings addObject:legLoc.coordsString];
            }
        }
        
        for (MatkaRouteLocation *loc in matkaLeg.locations) {
            RouteLegLocation *legLoc = [RouteLegLocation routeLocationFromMatkaRouteLocation:loc];
            legLoc.locationLegOrder = matkaLeg.legOrder;
            legLoc.locationLegType = leg.legType;
            [locations addObject:legLoc];
            [shapeStrings addObject:legLoc.coordsString];
        }
        
        MatkaRouteLocation *destLoc = [matkaLeg legEndPoint];
        if (destLoc) {
            RouteLegLocation *legLoc = [RouteLegLocation routeLocationFromMatkaRouteLocation:destLoc];
            legLoc.locationLegOrder = matkaLeg.legOrder;
            legLoc.locationLegType = leg.legType;
            [locations addObject:legLoc];
            [shapeStrings addObject:legLoc.coordsString];
        } else {
            MatkaRouteStop *endStop = [matkaLeg legEndStop];
            if(endStop) {
                RouteLegLocation *legLoc = [RouteLegLocation routeLocationFromMatkaRouteStop:endStop];
                legLoc.locationLegOrder = matkaLeg.legOrder;
                legLoc.locationLegType = leg.legType;
                [locations addObject:legLoc];
                [shapeStrings addObject:legLoc.coordsString];
            }
        }
        
        leg.legLocations = locations;
        leg.legShapeCoorStrings = shapeStrings;
    } else {
        NSMutableArray *locations = [@[] mutableCopy];
        NSMutableArray *shapeStrings = [@[] mutableCopy];
        for (MatkaRouteStop *loc in matkaLeg.stops) {
            RouteLegLocation *legLoc = [RouteLegLocation routeLocationFromMatkaRouteStop:loc];
            legLoc.locationLegOrder = matkaLeg.legOrder;
            legLoc.locationLegType = leg.legType;
            [locations addObject:legLoc];
            [shapeStrings addObject:legLoc.coordsString];
        }
        
        leg.legLocations = locations;
        leg.legShapeCoorStrings = shapeStrings;
    }
    
    return leg;
}

+(id)routeLegFromDigiRouteLeg:(DigiLegs *)digiLeg {
    RouteLeg *leg = [[RouteLeg alloc] init];
    
    leg.legLength = digiLeg.distance;
    leg.legDurationInSeconds = digiLeg.duration;
    leg.waitingTimeInSeconds = 0; //TODO: think about this
    leg.legType = digiLeg.legType;
    leg.lineCode = digiLeg.trip.route.gtfsId;
    leg.lineName = digiLeg.trip.route.shortName;
    leg.legOrder = digiLeg.legOrder;
    
    leg.legShapeCoorStrings = @[]; //TODO: Decode polyline
    
    NSMutableArray *locations = [@[] mutableCopy];
    NSMutableArray *shapeStrings = [@[] mutableCopy];
    if (digiLeg.legType == LegTypeWalk || digiLeg.legType == LegTypeBicycle) { //We only have start and end locations
        RouteLegLocation *fromLocation = [RouteLegLocation routeLocationFromDigiPlace:digiLeg.from];
        if (fromLocation) {
            fromLocation.locationLegOrder = digiLeg.legOrder;
            fromLocation.locationLegType = digiLeg.legType;
            [locations addObject:fromLocation];
            [shapeStrings addObject:fromLocation.coordsString];
        }
        
        RouteLegLocation *toLocation = [RouteLegLocation routeLocationFromDigiPlace:digiLeg.to];
        if (toLocation) {
            toLocation.locationLegOrder = digiLeg.legOrder;
            toLocation.locationLegType = digiLeg.legType;
            [locations addObject:toLocation];
            [shapeStrings addObject:toLocation.coordsString];
        }
    } else {
        
        RouteLegLocation *fromLocation = [RouteLegLocation routeLocationFromDigiPlace:digiLeg.from];
        if (fromLocation) {
            fromLocation.locationLegOrder = digiLeg.legOrder;
            fromLocation.locationLegType = digiLeg.legType;
            [locations addObject:fromLocation];
            [shapeStrings addObject:fromLocation.coordsString];
        }
        
        for (DigiIntermediateStops *stop in digiLeg.intermediateStops) {
            RouteLegLocation *stopLocation = [RouteLegLocation routeLocationFromDigiIntermidiateStop:stop];
            if (stopLocation) {
                stopLocation.locationLegOrder = digiLeg.legOrder;
                stopLocation.locationLegType = digiLeg.legType;
                [locations addObject:stopLocation];
                [shapeStrings addObject:stopLocation.coordsString];
            }
        }
        
        RouteLegLocation *toLocation = [RouteLegLocation routeLocationFromDigiPlace:digiLeg.to];
        if (toLocation) {
            toLocation.locationLegOrder = digiLeg.legOrder;
            toLocation.locationLegType = digiLeg.legType;
            [locations addObject:toLocation];
            [shapeStrings addObject:toLocation.coordsString];
        }
    }
    
    leg.legLocations = locations;
    leg.legShapeCoorStrings = shapeStrings;
    
    return leg;
}
#endif

#pragma mark - Helper Method
- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict
{
    id object = [dict objectForKey:aKey];
    return [self objectOrNil:object];
}

- (id)objectOrNil:(id)object {
    return [object isEqual:[NSNull null]] ? nil : object;
}

@end
