//
//  BusStop.h
//  Reitti
//
//  Created by Anteneh Sahledengel on 7/2/14.
//  Copyright (c) 2014 Anteneh Sahledengel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MatkaStop.h"
#import "DigiStop.h"
#import "BusStopShort.h"

@interface BusStop : BusStopShort

- (void)updateDeparturesFromRealtimeDepartures:(NSArray *)realtimeDepartures;

+(id)stopFromMatkaStop:(MatkaStop *)matkaStop;
-(id)initFromDigiStop:(DigiStop *)digiStop;

@property (nonatomic, retain) NSArray * departures;

@end
