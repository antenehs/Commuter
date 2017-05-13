//
//  BusStopShort.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 4/3/14.
//  Copyright (c) 2014 Anteneh Sahledengel. All rights reserved.
//

#import "BusStopShort.h"
#import "ReittiStringFormatter.h"
#import "CacheManager.h"

@interface BusStopShort ()

@property (strong, nonatomic)StaticStop *staticStop;

@end

@implementation BusStopShort

@synthesize code;
@synthesize codeShort;
@synthesize name;
@synthesize city;
@synthesize coords;
@synthesize address;
@synthesize distance;
@synthesize lines;

-(BusStopShort *)initWithNearByStop:(NearByStop *)nearByStop{
    
    self = [super init];
    
    self.code = [NSNumber numberWithInteger:[nearByStop.stopCode integerValue]];
    self.codeShort = nearByStop.stopShortCode;
    self.name = nearByStop.stopName;
    self.city = @"";
    self.coords = [NSString stringWithFormat:@"%f,%f", nearByStop.coords.longitude, nearByStop.coords.latitude];
    self.address = nearByStop.stopAddress;
    self.distance = [NSNumber numberWithDouble:nearByStop.distance];
    self.lines = nearByStop.lines;
    self.linesString = [nearByStop linesAsCommaSepString];
    self.stopType = nearByStop.stopType;
    
    return self;
}

-(StopType)stopType{
    @try {
        if (_stopType == StopTypeUnknown) {
            NSLog(@"DIGITRANSITERROR: ========= THIS shouldn't have happened with digi transit");
            assert(false);
            
            if (!_staticStop) {
                _staticStop = [[CacheManager sharedManager] getStopForCode:[NSString stringWithFormat:@"%@", self.code]];
            }
            
            if (_staticStop != nil) {
                _stopType = _staticStop.reittiStopType;
            }else{
                 _stopType = StopTypeBus;
            }
        }
        
        return _stopType;
    }
    @catch (NSException *exception) {
        
    }
}

#pragma mark - Init from other stops

+(id)stopFromBusStop:(BusStop *)busStop {
    BusStopShort *stop = [[BusStopShort alloc] init];
    
    stop.gtfsId = busStop.gtfsId;
    stop.code = busStop.code;
    stop.codeShort = busStop.code_short;
    stop.name = busStop.name_fi;
    stop.city = busStop.city_fi;
    stop.coords = busStop.coords;
    stop.address = busStop.address_fi;
    stop.distance = busStop.distance;
    stop.lines = busStop.lines;
    stop.linesString = busStop.linesString;
    stop.stopType = busStop.stopType;
    
    return stop;
}

+(id)stopFromMatkaStop:(MatkaStop *)matkaStop {
    BusStopShort *stop = [[BusStopShort alloc] init];
    
    stop.code = [NSNumber numberWithInteger:[matkaStop.stopId integerValue]];
    stop.codeShort = matkaStop.stopShortCode;
    stop.name = matkaStop.nameFi;
    stop.city = [NSString stringWithFormat:@"%d", [matkaStop.cityId intValue]];;
    stop.coords = matkaStop.coordString;
    stop.address = @"";
    stop.distance = matkaStop.distance;
    stop.lines = @[];
    stop.linesString = nil;
    stop.stopType = StopTypeBus;
    
    return stop;
}


@end
