//
//  MatkaRoutePoint.h
//  Reitti
//
//  Created by Anteneh Sahledengel on 11/4/16.
//  Copyright © 2016 Anteneh Sahledengel. All rights reserved.
//

#import <Foundation/Foundation.h>
/*
 <POINT uid="start" x="3597369.0" y="6784330.0">
    <ARRIVAL date="20160412" time="0040"/>
    <DEPARTURE date="20160412" time="0041"/>
 </POINT>
 */

@interface MatkaRouteLocation : NSObject

@property(nonatomic, strong)NSString *uid;
@property(nonatomic, strong)NSNumber *xCoord;
@property(nonatomic, strong)NSNumber *yCoord;
@property(nonatomic, strong)NSString *type;
@property(nonatomic, strong)NSNumber *arrivalDate;
@property(nonatomic, strong)NSNumber *arrivalTime;
@property(nonatomic, strong)NSNumber *departureDate;
@property(nonatomic, strong)NSNumber *departureTime;

@end
