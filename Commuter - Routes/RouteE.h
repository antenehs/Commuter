//
//  Route.h
//  Reitti
//
//  Created by Anteneh Sahledengel on 12/8/14.
//  Copyright (c) 2014 Anteneh Sahledengel. All rights reserved.
//
//response from HSL

//1	length	Number	Length of the route in meters.
//2	duration	Number	Duration of the route in seconds.
//3	legs	Array
//Array of legs of the route.
//3.1	length	Number	Length of the leg in meters.
//3.2	duration	Number	Duration of the leg in seconds.
//3.3	type	String/Number
//Type of the leg:
//
//walk
//transport type id (see parameter mode_cost above for explanation of the ids)
//3.4
//
//code	String	Line code.
//3.5
//
//locs	Array	Array of locations on the leg (limited detail only lists start and end locations).
//3.6	shape	List	Shape (list of coordinates) of the leg (only in full detail).
//3.5.1	coord	Coordinate	Coordinate of the location.
//3.5.2	arrTime	Number	Arrival time to the location, format YYYYMMDDHHMM.
//3.5.3	depTime	Number	Departure time from the location, format YYYYMMDDHHMM.
//3.5.4	name	String	Name of the location.
//3.5.5	code	Number(7)	Long code of the stop.
//3.5.6	shortCode	String(4-6)	Short code of the stop.
//3.5.7	stopAddress	String	Address of the stop.

#import <Foundation/Foundation.h>
#import "RouteLegE.h"
#import "RouteLegLocationE.h"
#import <MapKit/MapKit.h>
#import "MatkaModels.h"

@interface RouteE : NSObject

+(id)routeFromMatkaRoute:(MatkaRoute *)matkaRoute;

-(double)getTotalWalkLength;
//-(int)getNumberOfNoneWalkLegs;
-(float)getLengthRatioInRoute:(RouteLegE *)leg;
-(bool)isOnlyWalkingRoute;
//-(NSDate *)getStartingTimeOfRoute;
//-(NSDate *)getEndingTimeOfRoute;
//-(NSDate *)getTimeAtTheFirstStop;
//-(CLLocationCoordinate2D)getStartCoords;
//-(NSString *)getDestinationCoords;

@property (nonatomic, retain) NSNumber * routeLength;
@property (nonatomic, retain) NSNumber * routeDurationInSeconds;
@property (nonatomic, retain) NSArray * unMappedRouteLength;
@property (nonatomic, retain) NSArray * unMappedRouteDurationInSeconds;
@property (nonatomic, retain) NSArray * routeLegs;
@property (nonatomic, retain) NSArray * unMappedRouteLegs;

//Computed properties
@property (nonatomic, readonly, strong)NSNumber *numberOfNoneWalkLegs;
@property (nonatomic, readonly, strong)NSDate *startingTimeOfRoute;
@property (nonatomic, readonly, strong)NSDate *endingTimeOfRoute;
@property (nonatomic, readonly, strong)NSDate *timeAtTheFirstStop;
@property (nonatomic, readonly)CLLocationCoordinate2D startCoords;
@property (nonatomic, readonly)CLLocationCoordinate2D destinationCoords;


@end
