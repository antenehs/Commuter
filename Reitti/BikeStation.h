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
#import <RestKit/RestKit.h>

@class RouteLegLocation;

typedef enum
{
    NotAvailable = 0,
    LowAvailability = 1,
    HighAvailability = 2
} Availability;

@interface BikeStation : NSObject

+(id)bikeStationFromLegLocation:(RouteLegLocation *)location;

+(RKResponseDescriptor *)responseDiscriptorForPath:(NSString *)path;
-(BOOL)isValid;

@property (nonatomic, strong)NSString *stationId;
@property (nonatomic, strong)NSString *name;
@property (nonatomic, strong)NSString *xCoord;
@property (nonatomic, strong)NSString *yCoord;
@property (nonatomic, strong)NSNumber *bikesAvailable;
@property (nonatomic, strong)NSNumber *spacesAvailable;
@property (nonatomic) BOOL allowDropoff;
@property (nonatomic) BOOL realTimeData;

@property (nonatomic)CLLocationCoordinate2D coordinates;
@property (nonatomic, strong)NSString *bikesAvailableString;
@property (nonatomic, strong)NSString *spacesAvailableString;
@property (nonatomic)CLLocationDistance distance;
@property (nonatomic)Availability bikeAvailability;
@property (nonatomic)Availability spaceAvailability;

@end
