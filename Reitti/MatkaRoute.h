//
//  MatkaRoute.h
//  Reitti
//
//  Created by Anteneh Sahledengel on 11/4/16.
//  Copyright © 2016 Anteneh Sahledengel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MatkaRouteLeg.h"
#import "MatkaRouteLocation.h"
#import <MapKit/MapKit.h>

@interface MatkaRoute : NSObject

@property(nonatomic, strong)NSNumber *time;
@property(nonatomic, strong)NSNumber *distance;

@property(nonatomic, strong)NSArray *points; /* Start and Dest points */
@property(nonatomic, strong)NSArray *routeWalkingLegs;
@property(nonatomic, strong)NSArray *routeLineLegs;

//Computed properties
@property(nonatomic, strong)NSNumber *timeInSeconds;
@property(nonatomic, strong)NSDate *startingTime;
@property(nonatomic, strong)NSDate *endingTime;
@property(nonatomic, strong)NSDate *timeAtFirstStop;
@property(nonatomic)CLLocationCoordinate2D startCoords;
@property(nonatomic)CLLocationCoordinate2D destinationCoords;

@property(nonatomic, strong)NSArray *allLegs;

@end
