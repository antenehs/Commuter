//
//  BusStopShort.h
//  Reitti
//
//  Created by Anteneh Sahledengel on 4/3/14.
//  Copyright (c) 2014 Anteneh Sahledengel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NearByStop.h"
//#import "ReittiModels.h"
#import "MatkaStop.h"
#import "ReittiObject.h"
#import "BusStop.h"

@interface BusStopShort : ReittiObject

-(BusStopShort *)initWithNearByStop:(NearByStop *)nearByStop;

+(id)stopFromBusStop:(BusStop *)stop;
+(id)stopFromMatkaStop:(MatkaStop *)matkaStop;
//-(void)setStopTypeForGDTypeString:(NSString *)type;

@property (nonatomic, retain) NSNumber * code;
@property (nonatomic, strong) NSString * gtfsId;
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
