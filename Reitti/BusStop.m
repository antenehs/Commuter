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
#import "ReittiStringFormatter.h"
#import "StopLine.h"

@interface BusStop ()

@property (strong, nonatomic)StaticStop *staticStop;

@end


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
        if (!_staticStop) {
            _staticStop = [[CacheManager sharedManager] getStopForCode:[NSString stringWithFormat:@"%@", self.code]];
        }
        
        if (_staticStop) {
            return _staticStop.reittiStopType;
        }else{
            return StopTypeBus;
        }
    }
    @catch (NSException *exception) {}
}

-(NSArray *)lineCodes{
    if (self.lines && self.lines.count > 0) {
        if ([lines[0] isKindOfClass:[StopLine class]]) {
            NSMutableArray *lineCodeArray = [@[] mutableCopy];
            for (StopLine *line in lines) {
                [lineCodeArray addObject:line.code];
            }
            
            return lineCodeArray;
        }
    }
    
    return nil;
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
