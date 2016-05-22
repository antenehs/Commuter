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
                if (line.code) {
                    [lineCodeArray addObject:line.code];
                }
            }
            
            return lineCodeArray;
        }
    }
    
    return nil;
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
                
                return lineCodeArray;
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

- (void)updateDeparturesFromRealtimeDepartures:(NSArray *)realtimeDepartures {
    if (realtimeDepartures && realtimeDepartures.count > 0 && self.departures) {
        for (StopDeparture *scheduledDeparture in self.departures) {
            StopDeparture *realtimeDep = [self filterDepartures:realtimeDepartures forDeparture:scheduledDeparture];
            if (realtimeDep && realtimeDep.isRealTime) {
                scheduledDeparture.isRealTime = YES;
                scheduledDeparture.parsedRealtimeDate = realtimeDep.parsedRealtimeDate;
                scheduledDeparture.destination = realtimeDep.destination;
            }
        }
    }
}

- (StopDeparture *)filterDepartures:(NSArray *)allDepartures forDeparture:(StopDeparture *)searchDeparture {
    NSArray *result = [allDepartures filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id object, NSDictionary *bindings) {
        StopDeparture *dep = (StopDeparture *)object;
        if (!dep) return NO;
        
        return dep.code == searchDeparture.code && [dep.parsedScheduledDate isEqualToDate:searchDeparture.parsedScheduledDate];
    }]];
    
    return result && result.count == 1 ? result[0] : nil;
}

#pragma mark - Init from other class

+ (id)stopFromMatkaStop:(MatkaStop *)matkaStop {
    BusStop *stop = [[BusStop alloc] init];
    
    stop.code = [NSNumber numberWithInteger:[matkaStop.stopId integerValue]];;
    stop.code_short = matkaStop.stopShortCode;
    stop.name_fi = matkaStop.nameFi;
    stop.name_sv = matkaStop.nameSe;
    stop.city_fi = @"";
    stop.city_sv = @"";
    stop.lines = [BusStop linesFromMatkaLines:matkaStop.stopLines];
    stop.coords = matkaStop.coordString;
    stop.wgs_coords = matkaStop.coordString;
    stop.departures = [BusStop departuresFromMatkaLines:matkaStop.stopLines];
    stop.timetable_link = nil;
    stop.address_fi = @"";
    stop.address_sv = @"";
    
    stop.fetchedFromApi = ReittiMatkaApi;
    
    return stop;
}

+ (NSArray *)linesFromMatkaLines:(NSArray *)matkaLines {
    NSMutableArray *lines = [@[] mutableCopy];
    for (MatkaLine *matkaLine in matkaLines) {
        StopLine *line = [[StopLine alloc] init];
        line.fullCode = matkaLine.lineId;
        line.code = [matkaLine.codeShort uppercaseString];
        line.name = matkaLine.name;
        line.direction = @"1";
        line.destination = matkaLine.name;
        line.lineType = matkaLine.lineType;
        line.lineStart = matkaLine.lineStart;
        line.lineEnd = matkaLine.lineEnd;
        
        [lines addObject:line];
    }
    
    return lines;
}

+ (NSArray *)departuresFromMatkaLines:(NSArray *)matkaLines {
    NSMutableArray *departures = [@[] mutableCopy];
    
    for (MatkaLine *matkaLine in matkaLines) {
        if (!matkaLine.departureTime || !matkaLine.codeShort) continue;
        
        StopDeparture *departure = [[StopDeparture alloc] init];
        departure.code = matkaLine.codeShort;
        departure.name = matkaLine.name;
        departure.date = nil;
        departure.time = matkaLine.departureTime;
        departure.direction = @"1";
        departure.destination = matkaLine.lineEnd;
        departure.parsedScheduledDate = matkaLine.parsedDepartureTime;
        
        [departures addObject:departure];
    }
    
    return departures;
}

@end
