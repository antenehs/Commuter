//
//  MatkaRouteWalk.h
//  Reitti
//
//  Created by Anteneh Sahledengel on 11/4/16.
//  Copyright © 2016 Anteneh Sahledengel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MatkaRouteLocation.h"
#import "MatkaRouteStop.h"
#import "EnumManager.h"

@interface MatkaRouteLeg : NSObject

//These are alternating. There cant be bot startPoint and startStop
-(MatkaRouteLocation *)legStartPoint;
-(MatkaRouteLocation *)legEndPoint;
-(MatkaRouteStop *)legStartStop;
-(MatkaRouteStop *)legEndStop;

@property(nonatomic, strong)NSNumber *time;
@property(nonatomic, strong)NSNumber *distance;

//Line type leg
@property(nonatomic, strong)NSString *lineId;
@property(nonatomic, strong)NSString *codeShort;
@property(nonatomic, strong)NSNumber *transportType;

//Start and dest locations - For walking legs only
@property(nonatomic, strong)NSArray *startDestPoints;

//Either location or stops for walking and line legs respectively
@property(nonatomic, strong)NSArray *locations;
@property(nonatomic, strong)NSArray *stops;

//Computed properties
@property(nonatomic, strong)NSNumber *timeInSeconds;
@property(nonatomic, strong)NSDate *startingTime;
@property(nonatomic, strong)NSDate *endingTime;
@property(nonatomic)LegTransportType legType;
@property(nonatomic)int legOrder;

@end
