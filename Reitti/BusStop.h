//
//  BusStop.h
//  Reitti
//
//  Created by Anteneh Sahledengel on 7/2/14.
//  Copyright (c) 2014 Anteneh Sahledengel. All rights reserved.
//

//Bus stop information recieved
//1 code        Number(7)	Unique, long code of the stop, e.g. 1040602.
//2	code_short	String(4-6)	Short code, e.g. 0013 or ki0468.
//3	name_fi     String	Name of the stop in Finnish.
//4	name_sv     String	Name of the stop in Swedish.
//5	city_fi     String	Name of the city in Finnish.
//6	city_sv     String	Name of the city in Swedish.
//7 lines       Array	Array of lines that pass the stop with their destination, line code and it's                        destination are separated by ":", e.g. 2103  1:Pohjois-Tapiola
//8	coords      Coordinate	Coordinates of the stop (<x,y>, e.g. 2551217,6681725). The location specified in this field is slightly modified for mapping reasons.
//9	wgs_coords	Coordinate	Longitude and latitude of the stop (WGS84 coordinates, <lon,lat>). The location specified in this field is the measured point of the stop sign.
//10 accessibility	Array	Accessibility information of the stop, described in more detail below.
//11 departures	Array	Next departures leaving from the stop, array of line code, departure time and date.
//12 timetable_link	String	Link to the timetable page of the stop.
//13 omatlahdot_link	String	Link to the Omat lähdöt service.
//14 address_fi	String	Stop's address in Finnish.
//15 address_sv	String

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import <MapKit/MapKit.h>
#import "EnumManager.h"


@interface BusStop : NSObject

- (NSString *)destinationForLineFullCode:(NSString *)fullCode;

@property (nonatomic, retain) NSNumber * code;
@property (nonatomic, retain) NSString * code_short;
@property (nonatomic, retain) NSString * name_fi;
@property (nonatomic, retain) NSString * name_sv;
@property (nonatomic, retain) NSString * city_fi;
@property (nonatomic, retain) NSString * city_sv;
@property (nonatomic, retain) NSArray * lines;
@property (nonatomic, retain) NSString * coords;
@property (nonatomic, retain) NSString * wgs_coords;
@property (nonatomic, retain) NSArray * accessibility;
@property (nonatomic, retain) NSArray * departures;
@property (nonatomic, retain) NSString * timetable_link;
@property (nonatomic, retain) NSString * omatlahdot_link;
@property (nonatomic, retain) NSString * address_fi;
@property (nonatomic, retain) NSString * address_sv;
@property (nonatomic, retain) NSArray * lineCodes;
@property (nonatomic, retain) NSString * linesString;

@property (nonatomic) StopType stopType;

@end
