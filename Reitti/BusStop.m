//
//  BusStop.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 7/2/14.
//  Copyright (c) 2014 Anteneh Sahledengel. All rights reserved.
//

#import "BusStop.h"
#import "EnumManager.h"
#import "CacheManager.h"


@implementation BusStop

@synthesize code;
@synthesize code_short;
@synthesize name_fi;
@synthesize name_sv;
@synthesize city_fi;
@synthesize city_sv;
@synthesize lines;
@synthesize coords;
@synthesize wgs_coords;
@synthesize accessibility;
@synthesize departures;
@synthesize timetable_link;
@synthesize omatlahdot_link;
@synthesize address_fi;
@synthesize address_sv;

-(StopType)stopType{
    @try {
        StaticStop *staticStop = [[CacheManager sharedManager] getStopForCode:[NSString stringWithFormat:@"%@", self.code]];
        if (staticStop != nil) {
            return staticStop.reittiStopType;
        }else{
            return StopTypeBus;
        }
    }
    @catch (NSException *exception) {
        
    }
}

@end
