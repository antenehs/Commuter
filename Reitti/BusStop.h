//
//  BusStop.h
//  Reitti
//
//  Created by Anteneh Sahledengel on 7/2/14.
//  Copyright (c) 2014 Anteneh Sahledengel. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import <CoreData/CoreData.h>
//#import <MapKit/MapKit.h>
#import "EnumManager.h"
#import "MatkaStop.h"
#import "DigiStop.h"
#import "BusStopShort.h"

@interface BusStop : BusStopShort

- (void)updateDeparturesFromRealtimeDepartures:(NSArray *)realtimeDepartures;
//- (NSString *)destinationForLineFullCode:(NSString *)fullCode;

+(id)stopFromMatkaStop:(MatkaStop *)matkaStop;
-(id)initFromDigiStop:(DigiStop *)digiStop;

//@property (nonatomic, retain) NSNumber * code;
//@property (nonatomic, strong) NSString *gtfsId;
//@property (nonatomic, retain) NSString * code_short;
//@property (nonatomic, retain) NSString * nameFi;
//@property (nonatomic, retain) NSString * nameSv;
//@property (nonatomic, retain) NSString * cityFi;
//@property (nonatomic, retain) NSString * citySv;
//@property (nonatomic, retain) NSString * coords;
//@property (nonatomic, retain) NSString * wgsCoords;
//@property (nonatomic, retain) NSArray * accessibility;
@property (nonatomic, retain) NSArray * departures;
//@property (nonatomic, retain) NSString * timetableLink;
//@property (nonatomic, retain) NSString * omatlahdotLink;
//@property (nonatomic, retain) NSString * addressFi;
//@property (nonatomic, retain) NSString * addressSv;
//@property (nonatomic, strong) NSNumber *distance;

//@property (nonatomic, retain) NSArray * lines;
//@property (nonatomic, retain) NSArray * lineCodes;
//@property (nonatomic, retain) NSArray * lineFullCodes;
//@property (nonatomic, retain) NSString * linesString;
//
////@property (nonatomic) StopType stopType;
//@property (nonatomic, retain)NSString *stopIconName;

@end
