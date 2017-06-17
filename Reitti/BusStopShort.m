//
//  BusStopShort.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 4/3/14.
//  Copyright (c) 2014 Anteneh Sahledengel. All rights reserved.
//

#import "BusStopShort.h"
#import "ReittiStringFormatter.h"
#import "StopLine.h"
#import "AppManager.h"

#if MAIN_APP
#import "CacheManager.h"
#endif

@interface BusStopShort ()

#if MAIN_APP
@property (strong, nonatomic)StaticStop *staticStop;
#endif

@end

@implementation BusStopShort

@synthesize code;
@synthesize codeShort;
@synthesize coords;
@synthesize distance;
@synthesize lines;

-(StopType)stopType{
    @try {
        if (_stopType == StopTypeUnknown) {
            NSLog(@"DIGITRANSITERROR: ========= THIS shouldn't have happened with digi transit");
//            NSAssert(false, @"DIGITRANSITERROR: ========= THIS shouldn't have happened with digi transit");
#if MAIN_APP
            if (!_staticStop) {
                _staticStop = [[CacheManager sharedManager] getStopForCode:[NSString stringWithFormat:@"%@", self.code]];
            }
            
            if (_staticStop != nil) {
                _stopType = _staticStop.reittiStopType;
            }else{
                 _stopType = StopTypeBus;
            }
#endif
        }
        
        return _stopType;
    }
    @catch (NSException *exception) {
        
    }
}

-(NSString *)name {
    if (!_name) {
        _name = self.nameFi ? self.nameFi : self.nameSv;
    }
    
    return _name;
}

-(NSString *)city {
    if (!_city) {
        _city = self.cityFi ? self.cityFi : self.citySv;
    }
    
    return _city;
}

-(NSString *)address {
    if (!_address) {
        _address = self.addressFi ? self.addressFi : self.addressSv;
    }
    
    return _address;
}

#pragma mark - Init from other stops

#ifndef APPLE_WATCH
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
#endif

#pragma mark - Computed properties

-(NSString *)stopIconName {
    return [AppManager stopIconNameForStopType:self.stopType];
}

-(NSArray *)lineCodes{
    if (!_lineCodes) {
        if (self.lines && self.lines.count > 0) {
            if ([self.lines[0] isKindOfClass:[StopLine class]]) {
                NSMutableArray *lineCodeArray = [@[] mutableCopy];
                for (StopLine *line in lines) {
                    if (line.code) {
                        [lineCodeArray addObject:line.code];
                    }
                }
                
                _lineCodes = lineCodeArray;
            }
        }
    }
    
    return _lineCodes;
}

-(NSArray *)lineFullCodes{
    if (!_lineFullCodes) {
        if (self.lines && self.lines.count > 0) {
            if ([lines[0] isKindOfClass:[StopLine class]]) {
                NSMutableArray *lineCodeArray = [@[] mutableCopy];
                for (StopLine *line in lines) {
                    if (line.fullCode) {
                        [lineCodeArray addObject:line.fullCode];
                    }
                }
                
                _lineFullCodes = lineCodeArray;
            }
        }
    }
    
    return _lineFullCodes;
}

- (NSString *)destinationForLineFullCode:(NSString *)fullCode{
    if (self.lines && self.lines.count > 0) {
        if ([lines[0] isKindOfClass:[StopLine class]]) {
            for (StopLine *line in lines) {
                if ([line.fullCode isEqualToString:fullCode]) {
                    return line.destination;
                }
            }
        }
    }
    
    return @"Unknown";
}

-(NSString *)linesString{
    if (!self.lineCodes) {
        return @"";
    }
    return [ReittiStringFormatter commaSepStringFromArray:self.lineCodes withSeparator:@", "];
}

-(CLLocationCoordinate2D)coordinate {
    return [ReittiStringFormatter convertStringTo2DCoord:self.coords];
}


@end
