//
//  BusStop.h
//  Reitti
//
//  Created by Anteneh Sahledengel on 7/2/14.
//  Copyright (c) 2014 Anteneh Sahledengel. All rights reserved.

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import <MapKit/MapKit.h>
#import "MatkaModels.h"

@interface BusStopE : NSObject

@property (nonatomic, retain) NSNumber * code;
@property (nonatomic, retain) NSString * code_short;
@property (nonatomic, retain) NSString * name_fi;
@property (nonatomic, retain) NSString * name_sv;
@property (nonatomic, retain) NSString * city_fi;
@property (nonatomic, retain) NSString * city_sv;
@property (nonatomic, retain) NSArray * lines;
@property (nonatomic, retain) NSString * coords;
@property (nonatomic, retain) NSArray * departures;
@property (nonatomic, retain) NSString * timetable_link;
@property (nonatomic, retain) NSString * address_fi;
@property (nonatomic, retain) NSString * address_sv;

-(id)initWithDictionary:(NSDictionary *)dict parseLines:(BOOL)noLines;
-(NSDictionary *)toDictionary;

-(NSString *)destinationForLineFullCode:(NSString *)fullCode;

+ (id)stopFromMatkaStop:(MatkaStop *)matkaStop;

@end
