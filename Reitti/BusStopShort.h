//
//  BusStopShort.h
//  Reitti
//
//  Created by Anteneh Sahledengel on 4/3/14.
//  Copyright (c) 2014 Anteneh Sahledengel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ReittiObject.h"
#import "ReittiObjectProtocols.h"
#import "EnumManager.h"

#ifndef APPLE_WATCH
#import "NearByStop.h"
#import "MatkaStop.h"
#endif

@interface BusStopShort : ReittiObject <ReittiPlaceAtDistance>

#ifndef APPLE_WATCH
+(id)stopFromMatkaStop:(MatkaStop *)matkaStop;
-(id)initWithNearByStop:(NearByStop *)nearByStop;
#endif

-(NSString *)destinationForLineFullCode:(NSString *)fullCode;

@property (nonatomic, retain) NSNumber * code /*__IOS_PROHIBITED*/;
@property (nonatomic, strong) NSString * gtfsId;
@property (nonatomic, retain) NSString * codeShort;

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * nameFi;
@property (nonatomic, retain) NSString * nameSv;

@property (nonatomic, retain) NSString * city;
@property (nonatomic, retain) NSString * cityFi;
@property (nonatomic, retain) NSString * citySv;

@property (nonatomic, retain) NSString * coords;
@property (nonatomic, retain) NSString * wgsCoords;

@property (nonatomic, retain) NSString * address;
@property (nonatomic, retain) NSString * addressFi;
@property (nonatomic, retain) NSString * addressSv;

@property (nonatomic, retain) NSNumber * distance;

@property (nonatomic, retain) NSString * timetableLink;

@property (nonatomic, retain) NSArray * lines;
@property (nonatomic, retain) NSString * linesString;
@property (nonatomic, retain) NSArray * lineCodes;
@property (nonatomic, retain) NSArray * lineFullCodes;

@property (nonatomic) StopType stopType;
@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;

@property (nonatomic, retain)NSString *stopIconName;

@end
