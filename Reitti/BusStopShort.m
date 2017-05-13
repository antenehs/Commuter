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
#import "AppManager.h"
#import "StopLine.h"

@interface BusStopShort ()

@property (strong, nonatomic)StaticStop *staticStop;

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
//            assert(false);
            
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

-(id)initFromDigiStop:(DigiStop *)digiStop {
    self = [super init];
    
    self.code = digiStop.numberId;
    self.gtfsId = digiStop.gtfsId;
    self.codeShort = digiStop.code;
    
    self.name = digiStop.name;
    self.nameFi = digiStop.name;
    self.nameSv = digiStop.name;
    
    self.city = @"";
    self.cityFi = @"";
    self.citySv = @"";
    
    self.address = digiStop.desc;
    self.addressFi = digiStop.desc;
    self.addressSv = digiStop.desc;
    
    self.stopType = digiStop.stopType;
    self.fetchedFromApi = ReittiDigiTransitApi;
    
    self.coords = digiStop.coordString;
    self.wgsCoords = digiStop.coordString;
    
    self.timetableLink = digiStop.url;
    
    NSMutableArray *newLines = [@[] mutableCopy];
    for (DigiRoute *digiRoute in digiStop.routes) {
        [newLines addObject:[StopLine stopLineFromDigiRoute:digiRoute]];
    }
    self.lines = newLines;
    
    return self;
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



@end
