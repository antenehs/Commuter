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
#import "AppManager.h"
#import "StopDeparture.h"
#import "MatkaLine.h"
#import "StopLine.h"

@interface BusStop ()

@property (strong, nonatomic)StaticStop *staticStop;

@end


@implementation BusStop

//@synthesize code;
//@synthesize nameFi;
//@synthesize nameSv;
//@synthesize cityFi;
//@synthesize citySv;
//@synthesize coords;
//@synthesize wgsCoords;
@synthesize departures;
//@synthesize timetableLink;
//@synthesize omatlahdotLink;
//@synthesize addressFi;
//@synthesize addressSv;

//-(StopType)stopType{
//    @try {
//        if (_stopType == StopTypeUnknown) {
//            NSLog(@"DIGITRANSITERROR: ========= THIS shouldn't have happened with digi transit");
//            if (!_staticStop) {
//                _staticStop = [[CacheManager sharedManager] getStopForCode:[NSString stringWithFormat:@"%@", self.code]];
//            }
//            
//            if (_staticStop) {
//                return _staticStop.reittiStopType;
//            }else{
//                return StopTypeBus;
//            }
//        } else {
//            return _stopType;
//        }
//    }
//    @catch (NSException *exception) {}
//}


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
-(id)initFromDigiStop:(DigiStop *)digiStop {
    self = [super initFromDigiStop:digiStop];
    
    NSMutableArray *newDepartures = [@[] mutableCopy];
    for (DigiStoptime *digiTime in digiStop.stoptimes) {
        [newDepartures addObject:[StopDeparture departureForDigiStopTime:digiTime]];
    }
    self.departures = newDepartures;
    
    return self;
}

+ (id)stopFromMatkaStop:(MatkaStop *)matkaStop {
    BusStop *stop = [[BusStop alloc] init];
    
    stop.code = [NSNumber numberWithInteger:[matkaStop.stopId integerValue]];;
    stop.codeShort = matkaStop.stopShortCode;
    stop.nameFi = matkaStop.nameFi;
    stop.nameSv = matkaStop.nameSe;
    stop.cityFi = @"";
    stop.citySv = @"";
    stop.lines = [BusStop linesFromMatkaLines:matkaStop.stopLines];
    stop.coords = matkaStop.coordString;
    stop.wgsCoords = matkaStop.coordString;
    stop.departures = [BusStop departuresFromMatkaLines:matkaStop.stopLines];
    stop.timetableLink = nil;
    stop.addressFi = @"";
    stop.addressSv = @"";
    
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
