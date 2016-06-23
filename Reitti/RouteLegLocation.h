//
//  RouteLegLocation.h
//  Reitti
//
//  Created by Anteneh Sahledengel on 12/8/14.
//  Copyright (c) 2014 Anteneh Sahledengel. All rights reserved.
//
//3.5.1	coord	Coordinate	Coordinate of the location.
//3.5.2	arrTime	Number	Arrival time to the location, format YYYYMMDDHHMM.
//3.5.3	depTime	Number	Departure time from the location, format YYYYMMDDHHMM.
//3.5.4	name	String	Name of the location.
//3.5.5	code	Number(7)	Long code of the stop.
//3.5.6	shortCode	String(4-6)	Short code of the stop.
//3.5.7	stopAddress	String	Address of the stop.

#import <Foundation/Foundation.h>
#import "EnumManager.h"
#import "MatkaRouteLocation.h"
#import "MatkaRouteStop.h"
#import "DigiIntermediateStops.h"
#import "DigiPlace.h"
//#import "RouteLegs.m"

@interface RouteLegLocation : NSObject

-(id)initFromDictionary:(NSDictionary *)legDict;
-(id)copy;

+(RouteLegLocation *)routeLocationFromMatkaRouteLocation:(MatkaRouteLocation *)matkaLocation;
+(RouteLegLocation *)routeLocationFromMatkaRouteStop:(MatkaRouteStop *)matkaStop;

+(RouteLegLocation *)routeLocationFromDigiPlace:(DigiPlace *)digiPlace;
+(RouteLegLocation *)routeLocationFromDigiIntermidiateStop:(DigiIntermediateStops *)digiStop;

@property(nonatomic) bool isHeaderLocation;
@property (nonatomic) LegTransportType locationLegType;
@property (nonatomic) int locationLegOrder;

@property (nonatomic, retain) NSDictionary * coordsDictionary;
@property (nonatomic, retain) NSDate * arrTime;
@property (nonatomic, retain) NSDate * depTime;
@property (nonatomic, retain) NSString * name;

@property (nonatomic, retain) NSString * stopCode;
@property (nonatomic, retain) NSString * shortCode;
@property (nonatomic, retain) NSString * stopAddress;

@property (nonatomic, retain) NSString * bikeStationId;
@property (nonatomic, retain) NSNumber * bikesAvailable;
@property (nonatomic, retain) NSNumber * spacesAvailable;


@property (nonatomic, retain) NSString * coordsString;
@property (nonatomic) CLLocationCoordinate2D coords;

@end
