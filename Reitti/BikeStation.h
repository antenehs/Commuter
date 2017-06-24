//
//  BikeStation.h
//  HelsinkiBikes
//
//  Created by Anteneh Sahledengel on 4/5/16.
//  Copyright © 2016 Anteneh Sahledengel. All rights reserved.
//

/*
 <stations>
 <id>A42</id>
 <name>Baana</name>
 <x>24.922583</x>
 <y>60.164159</y>
 <bikesAvailable>6</bikesAvailable>
 <spacesAvailable>14</spacesAvailable>
 <allowDropoff>true</allowDropoff>
 <networks>
 <networks>default</networks>
 </networks>
 <realTimeData>true</realTimeData>
 </stations>
 */

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "ReittiObject.h"
#import "ReittiObjectProtocols.h"

@class RouteLegLocation;

typedef enum
{
    NotAvailable = 0,
    LowAvailability = 1,
    HalfAvailability = 2,
    HighAvailability = 3,
    FullAvailability = 4
} Availability;

@interface BikeStation : ReittiObject <ReittiPlaceAtDistance>

+(id)bikeStationFromLegLocation:(RouteLegLocation *)location;

-(BOOL)isValid;

@property (nonatomic, strong)NSString *stationId;
@property (nonatomic, strong)NSString *name;
@property (nonatomic, strong)NSString *lon;
@property (nonatomic, strong)NSString *lat;
@property (nonatomic, strong)NSNumber *bikesAvailable;
@property (nonatomic, strong)NSNumber *spacesAvailable;
@property (nonatomic) BOOL allowDropoff;
@property (nonatomic) BOOL realTimeData;

@property (nonatomic)CLLocationCoordinate2D coordinates;
@property (nonatomic, strong, readonly)CLLocation *location;
@property (nonatomic, strong, readonly)NSString *bikesAvailableString;
@property (nonatomic, strong, readonly)NSString *bikesUnitString;
@property (nonatomic, strong, readonly)NSString *spacesAvailableString;
@property (nonatomic, strong, readonly)NSString *spacesUnitString;
@property (nonatomic)NSNumber *distance;
@property (nonatomic)Availability bikeAvailability;
@property (nonatomic)Availability spaceAvailability;

@property (nonatomic, retain, readonly) NSNumber * totalSpaces;

@end
