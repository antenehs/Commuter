//
//  MatkaRoutePoint.h
//  Reitti
//
//  Created by Anteneh Sahledengel on 11/4/16.
//  Copyright © 2016 Anteneh Sahledengel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
/*
 <POINT uid="start" x="3597369.0" y="6784330.0">
    <ARRIVAL date="20160412" time="0040"/>
    <DEPARTURE date="20160412" time="0041"/>
 </POINT>
 */

@interface MatkaRouteLocation : NSObject

//-(RouteLocation *)routeLocation;

@property(nonatomic, strong)NSString *uid;
@property(nonatomic, strong)NSNumber *xCoord;
@property(nonatomic, strong)NSNumber *yCoord;
@property(nonatomic, strong)NSString *type;
@property(nonatomic, strong)NSArray *locNames;
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
