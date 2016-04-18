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
#import "ReittiStringFormatter.h"

@implementation RouteLeg

@synthesize legLength;
@synthesize legDurationInSeconds;
@synthesize waitingTimeInSeconds;
//@synthesize legType;
@synthesize lineCode;
@synthesize legLocations;
@synthesize legShapeDictionaries;
@synthesize showDetailed;
@synthesize legOrder;

-(id)initFromDictionary:(NSDictionary *)legDict{
    if (self = [super init]) {
        self.legLength = legDict[@"length"];
        self.legDurationInSeconds = legDict[@"duration"];
        self.legSpecificType = legDict[@"type"];
        self.legType = [self getLegTransportType];
        self.lineCode = legDict[@"code"];
        
        NSMutableArray *locsArray = [[NSMutableArray alloc] init];
        
        for (NSDictionary *locDict in legDict[@"locs"]) {
            RouteLegLocation *loc = [[RouteLegLocation alloc] initFromDictionary:locDict];
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
        
        self.legShapeDictionaries = legDict[@"shape"];
        
        NSMutableArray *shapeArray = [[NSMutableArray alloc] init];
        for (NSDictionary * shapeDict in legDict[@"shape"]) {
            [shapeArray addObject:[NSString stringWithFormat:@"%@,%@",shapeDict[@"x"],shapeDict[@"y"]]];
        }
        
        self.legLocations = locsArray;
        
        if (self.legType == LegTypeWalk || self.legType == LegTypeOther) {
            self.showDetailed = NO;
        }else{
            self.showDetailed = NO;
        }        
        
//        NSLog(@"leg is %@",self);
//        NSLog(@"a dictionary %@",legDict[@"locs"]);
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

-(int)getNumberOfStopsInLeg{
    int count = 0;
    if (self.legType != LegTypeWalk) {
        count = (int)self.legLocations.count;
    }
    
    return count;
}

-(NSString *)lineDisplayName{
    switch (self.legType) {
        case LegTypeBus:
            return [NSString stringWithFormat:@"Bus %@", self.lineName];
            break;
            
        case LegTypeTram:
            return [NSString stringWithFormat:@"Tram %@", self.lineName];
            break;
            
        case LegTypeTrain:
            return [NSString stringWithFormat:@"Train %@", self.lineName];
            break;
            
        case LegTypeFerry:
            return @"Ferry";
            break;
        
        case LegTypeMetro:
            return @"Metro";
            break;
            
        case LegTypeWalk:
            return @"Walk";
            break;
            
        default:
            return self.lineName;
            break;
    }
}

#pragma mark - init from Matka leg
+(id)routeLegFromMatkaRouteLeg:(MatkaRouteLeg *)matkaLeg{
    RouteLeg *leg = [[RouteLeg alloc] init];
    
    leg.legLength = matkaLeg.distance;
    leg.legDurationInSeconds = matkaLeg.timeInSeconds;
    leg.waitingTimeInSeconds = 0; //TODO: think about this
    leg.legType = matkaLeg.legType;
    leg.lineCode = [matkaLeg.lineId stringValue];
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
            [locations addObject:legLoc];
            [shapeStrings addObject:legLoc.coordsString];
        } else {
            MatkaRouteStop *startStop = [matkaLeg legStartStop];
            if(startStop) {
                RouteLegLocation *legLoc = [RouteLegLocation routeLocationFromMatkaRouteStop:startStop];
                legLoc.locationLegOrder = matkaLeg.legOrder;
                [locations addObject:legLoc];
                [shapeStrings addObject:legLoc.coordsString];
            }
        }
        
        for (MatkaRouteLocation *loc in matkaLeg.locations) {
            RouteLegLocation *legLoc = [RouteLegLocation routeLocationFromMatkaRouteLocation:loc];
            legLoc.locationLegOrder = matkaLeg.legOrder;
            [locations addObject:legLoc];
            [shapeStrings addObject:legLoc.coordsString];
        }
        
        MatkaRouteLocation *destLoc = [matkaLeg legEndPoint];
        if (destLoc) {
            RouteLegLocation *legLoc = [RouteLegLocation routeLocationFromMatkaRouteLocation:destLoc];
            legLoc.locationLegOrder = matkaLeg.legOrder;
            [locations addObject:legLoc];
            [shapeStrings addObject:legLoc.coordsString];
        } else {
            MatkaRouteStop *endStop = [matkaLeg legEndStop];
            if(endStop) {
                RouteLegLocation *legLoc = [RouteLegLocation routeLocationFromMatkaRouteStop:endStop];
                legLoc.locationLegOrder = matkaLeg.legOrder;
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
            [locations addObject:legLoc];
            [shapeStrings addObject:legLoc.coordsString];
        }
        
        leg.legLocations = locations;
        leg.legShapeCoorStrings = shapeStrings;
    }
    
    return leg;
}

@end
