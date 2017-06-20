//
//  RouteLeg.h
//  Reitti
//
//  Created by Anteneh Sahledengel on 12/8/14.
//  Copyright (c) 2014 Anteneh Sahledengel. All rights reserved.
//
// A Leg
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
#import "RouteLegLocation.h"
#import "DigiLegs.h"
#import "DigiTrip.h"

#ifndef APPLE_WATCH
#import "MatkaRouteLeg.h"
#import "MatkaRouteStop.h"
#import "MatkaRouteLocation.h"
#endif

@interface RouteLeg : NSObject

+(id)routeLegFromDigiRouteLeg:(DigiLegs *)digiLeg;

#ifndef APPLE_WATCH
+(id)routeLegFromMatkaRouteLeg:(MatkaRouteLeg *)matkaLeg;
#endif

-(id)initFromHSLandTREDictionary:(NSDictionary *)legDict;

+(instancetype)initFromDictionary: (NSDictionary *)dictionary;
-(NSDictionary *)dictionaryRepresentation;

-(int)getNumberOfStopsInLeg;

@property (nonatomic, retain) NSNumber * legLength;
@property (nonatomic, retain) NSNumber * legDurationInSeconds;
@property (nonatomic, retain) NSString * legSpecificType;
@property (nonatomic, retain) NSString * lineCode;
@property (nonatomic, retain) NSString * lineName;
@property (nonatomic, retain) NSArray * legLocations;
@property (nonatomic, retain) NSArray * legShapeDictionaries;

//Should be set during intialization of later.
@property (nonatomic) LegTransportType legType;
@property (nonatomic) NSInteger waitingTimeInSeconds;
@property (nonatomic) bool showDetailed;
@property (nonatomic) int legOrder;
@property (nonatomic, retain) NSString *startLocName;
@property (nonatomic, retain) NSString *endLocName;
@property (nonatomic, retain) NSString * lineDestination;
@property (nonatomic, strong) NSArray *fullLineShapeLocations;

//Derived properties
@property (nonatomic, strong)NSDate * departureTime;
@property (nonatomic, readonly) NSString * lineDisplayName;
@property (nonatomic, retain) NSArray * legShapeCoordLocations;
@property (nonatomic, strong, readonly) NSString *legUniqueName;

@end
