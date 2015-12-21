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
@synthesize stopType;

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

-(NSString *)linesString{
    if (self.lines == nil) {
        return @"";
    }
    return [ReittiStringFormatter commaSepStringFromArray:self.lines withSeparator:@","];
}

-(StopType)stopType{
    @try {
        if (!_staticStop) {
            _staticStop = [[CacheManager sharedManager] getStopForCode:[NSString stringWithFormat:@"%@", self.code]];
        }
        
        if (_staticStop != nil) {
            return _staticStop.reittiStopType;
        }else{
            return StopTypeBus;
        }
    }
    @catch (NSException *exception) {
        
    }
}

-(NSArray *)lines{
    @try {
        StaticStop *staticStop = [[CacheManager sharedManager] getStopForCode:[NSString stringWithFormat:@"%@", self.code]];
        if (staticStop != nil) {
            return staticStop.lineNames;
        }else{
            return @[];
        }
    }
    @catch (NSException *exception) {
        
    }
}

@end
