//
//  MatkaRouteStop.h
//  Reitti
//
//  Created by Anteneh Sahledengel on 11/4/16.
//  Copyright © 2016 Anteneh Sahledengel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

/*
 <STOP code="79656:167306" x="3388056.0" y="6691053.0" id="9542383" ord="50">
 <ARRIVAL date="20160412" time="0615"/>
 <DEPARTURE date="20160412" time="0615"/>
 <NAME lang="1" val="Helsinki-vantaa Lentoasema T1"/>
 <XTRA name="city_id" val="92"/>
 </STOP>
*/

@interface MatkaRouteStop : NSObject

@property(nonatomic, strong)NSString *stopCode;
@property(nonatomic, strong)NSArray *stopNames;
@property(nonatomic, strong)NSString *stopId;
@property(nonatomic, strong)NSString *stopOrder;
@property(nonatomic, strong)NSNumber *xCoord;
@property(nonatomic, strong)NSNumber *yCoord;
@property(nonatomic, strong)NSString *type;
@property(nonatomic, strong)NSString *arrivalDate;
@property(nonatomic, strong)NSString *arrivalTime;
@property(nonatomic, strong)NSString *departureDate;
@property(nonatomic, strong)NSString *departureTime;

//Computed properties
@property(nonatomic, strong)NSDate *parsedArrivalTime;
@property(nonatomic, strong)NSDate *parsedDepartureTime;
@property(nonatomic)CLLocationCoordinate2D coords;
@property(nonatomic, strong)NSString *coordString;
@property (nonatomic, strong)NSString *nameFi;
@property (nonatomic, strong)NSString *nameSe;
@property (nonatomic, strong)NSString *name;

@end
