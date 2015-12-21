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
@synthesize legShapeDictionaries,legShapeStrings;
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
        
        NSLog(@"leg is %@",self);
        NSLog(@"a dictionary %@",legDict[@"locs"]);
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

-(int)getNumberOfStopsInLeg{
    int count = 0;
    if (self.legType != LegTypeWalk) {
        count = (int)self.legLocations.count;
    }
    
    return count;
}

@end
