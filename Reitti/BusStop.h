//
//  BusStop.h
//  Reitti
//
//  Created by Anteneh Sahledengel on 7/2/14.
//  Copyright (c) 2014 Anteneh Sahledengel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BusStopShort.h"
#import "StopDeparture.h"

#ifndef APPLE_WATCH
#import "MatkaStop.h"
#endif

@interface BusStop : BusStopShort

- (void)updateDeparturesFromRealtimeDepartures:(NSArray *)realtimeDepartures;

#ifndef APPLE_WATCH
+(id)stopFromMatkaStop:(MatkaStop *)matkaStop;
#endif

-(id)initWithDictionary:(NSDictionary *)dict parseLines:(BOOL)noLines;
-(NSDictionary *)toDictionary;

@property (nonatomic, retain) NSArray *departures;

//drived Properites
@property (nonatomic, strong) NSArray *groupedDepartures;

@end
