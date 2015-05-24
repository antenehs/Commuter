//
//  BusStopShort.h
//  Reitti
//
//  Created by Anteneh Sahledengel on 4/3/14.
//  Copyright (c) 2014 Anteneh Sahledengel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NearByStop.h"

@interface BusStopShort : NSObject

-(BusStopShort *)initWithNearByStop:(NearByStop *)nearByStop;

@property (nonatomic, retain) NSNumber * code;
@property (nonatomic, retain) NSString * codeShort;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * city;
@property (nonatomic, retain) NSString * coords;
@property (nonatomic, retain) NSString * address;
@property (nonatomic, retain) NSNumber * distance;
@property (nonatomic, retain) NSArray  * lines;
@property (nonatomic, retain) NSString  * linesString;
@property (nonatomic) StopType stopType;

@end
