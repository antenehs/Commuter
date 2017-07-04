//
//  BusStop.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 7/2/14.
//  Copyright (c) 2014 Anteneh Sahledengel. All rights reserved.
//

#import "BusStop.h"
#import "EnumManager.h"
#import "ReittiStringFormatter.h"
#import "StopLine.h"
#import "GroupedDepartures.h"
#import "AppManager.h"

#ifndef APPLE_WATCH
#import "MatkaLine.h"
#endif

@implementation BusStop

@synthesize departures;

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

#ifndef APPLE_WATCH
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

#endif

#pragma mark - conversion to and from dictionary
-(id)initWithDictionary:(NSDictionary *)dict parseLines:(BOOL)parseLines {
    NSMutableArray *linesArray = [@[] mutableCopy];
    
    NSArray *linesDictionary = [self objectOrNilForKey:@"lines" fromDictionary:dict];
    
    if(parseLines) {
        for (NSDictionary *lineDic in linesDictionary) {
            StopLine *line = [StopLine initFromDictionary:lineDic];
            if (dict) [linesArray addObject:line];
        }
    }
    
    self.gtfsId = [self objectOrNilForKey:@"gtfsId" fromDictionary:dict];
    self.code = [NSNumber numberWithInt:[[self objectOrNilForKey:@"code" fromDictionary:dict] intValue]];
    self.codeShort = [self objectOrNilForKey:@"codeShort" fromDictionary:dict];
    self.nameFi = [self objectOrNilForKey:@"nameFi" fromDictionary:dict];
    self.nameSv = [self objectOrNilForKey:@"nameSv" fromDictionary:dict];
    self.cityFi = [self objectOrNilForKey:@"cityFi" fromDictionary:dict];
    self.citySv = [self objectOrNilForKey:@"citySv" fromDictionary:dict];
    self.lines = parseLines ? linesArray : linesDictionary;
    self.coords = [self objectOrNilForKey:@"coords" fromDictionary:dict];
    self.wgsCoords = [self objectOrNilForKey:@"wgsCoords" fromDictionary:dict];
    self.addressFi = [self objectOrNilForKey:@"addressFi" fromDictionary:dict];
    self.addressSv = [self objectOrNilForKey:@"addressSv" fromDictionary:dict];
    self.distance = [self objectOrNilForKey:@"distance" fromDictionary:dict];
    self.stopType = (StopType)[[self objectOrNilForKey:@"stopType" fromDictionary:dict] intValue];
    self.distance = [self objectOrNilForKey:@"distance" fromDictionary:dict];
    
    self.departures = [self dictionaryToDeparturesArray:[self objectOrNilForKey:@"departures" fromDictionary:dict]];
    self.timetableLink = [self objectOrNilForKey:@"timetableLink" fromDictionary:dict];
    
    return  self;
}

-(NSDictionary *)toDictionary{
    NSMutableArray *linesArray = [@[] mutableCopy];
    for (StopLine *line in self.lines) {
        if (![line isKindOfClass:[StopLine class]])
            break;
        NSDictionary *dict = [line dictionaryRepresentation];
        if (dict) [linesArray addObject:dict];
    }
    
    NSDictionary *dict = @{@"gtfsId":self.gtfsId ? self.gtfsId: @"",
                           @"code":[NSString stringWithFormat:@"%d", self.code != nil ? [self.code intValue] : 1] ,
                           @"codeShort":self.codeShort!= nil ? self.codeShort: @"",
                           @"nameFi":self.nameFi!= nil? self.nameFi : @"",
                           @"nameSv":self.nameSv!= nil? self.nameSv : @"",
                           @"cityFi":self.cityFi!= nil? self.cityFi : @"",
                           @"citySv":self.citySv!= nil? self.citySv : @"",
                           @"lines":linesArray ? linesArray : @[],
                           @"coords":self.coords!= nil? self.coords : @"",
                           @"wgsCoords":self.wgsCoords ? self.wgsCoords: @"",
                           @"departures":self.departures!= nil? [self departureToDictionary:self.departures] : @[],
                           @"timetableLink":self.timetableLink!= nil? self.timetableLink : @"",
                           @"distance":self.distance ? self.distance: @"",
                           @"stopType":[NSNumber numberWithInt:self.stopType],
                           @"addressFi":self.addressFi!= nil? self.addressFi : @"",
                           @"addressSv":self.addressSv!= nil? self.addressSv : @"",};
    
    return dict;
}

#pragma mark - Derived properties
-(NSArray *)groupedDepartures {
    NSMutableArray *groupedDepartures = [@[] mutableCopy];
    
    //We see lines as unique if they have same gtfs id and destination. But sometimes
    //Even with same id and destination there could be different patters.
    NSMutableArray *departuresCopy = [self.validDepartures mutableCopy];
    for (StopDeparture *departure in self.departures) {
        NSArray *sameDepartures = [self collectDeparturesFromList:departuresCopy forLineGtfsId:departure.lineGtfsId andDestination:departure.destination];
        if (!sameDepartures)
            continue;
        
        StopLine *line = [self lineForDeparture:departure];
        if (!line)
            continue;
        
        [groupedDepartures addObject:[GroupedDepartures groupedDeparutesForLine:line
                                                                        busStop:self
                                                                     departures:sameDepartures]];
        [departuresCopy removeObjectsInArray:sameDepartures];
    }

    _groupedDepartures = groupedDepartures;
    
    return _groupedDepartures;
}


//Departures matching line within the next 2 hours
-(NSArray *)collectDeparturesFromList:(NSMutableArray *)departuresList forLineGtfsId:(NSString *)lineGtfsId andDestination:(NSString *)destination {
    
    NSArray *filtered = [departuresList filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(StopDeparture *  _Nullable evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
        return [evaluatedObject.lineGtfsId isEqualToString:lineGtfsId] &&
               [evaluatedObject.destination isEqualToString:destination] &&
               [evaluatedObject.departureTime timeIntervalSinceNow] < 7000;
    }]];
    
    return filtered.count > 0 ? filtered : nil;
}

-(NSArray *)departuresMatchingDeparture:(StopDeparture *)departure {
    
    if (!self.departures) { return nil; }
    
    NSArray *filtered = [self.departures filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(StopDeparture *  _Nullable evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
        return [evaluatedObject.lineGtfsId isEqualToString:departure.lineGtfsId] &&
        [evaluatedObject.destination isEqualToString:departure.destination] &&
        [evaluatedObject.departureTime timeIntervalSinceDate:departure.departureTime] > 0;
    }]];
    
    return filtered.count > 0 ? filtered : nil;
}

/*
 //DOESNT WORK FOR SOME REASON
 
-(void)sortDepartureGroupsInPlace:(inout NSArray<GroupedDepartures *> *)departureGroups {
    [departureGroups sortedArrayUsingComparator:^NSComparisonResult(GroupedDepartures *  _Nonnull obj1, GroupedDepartures *  _Nonnull obj2) {
        if (obj1.departures.count < 1 || obj2.departures.count < 1) {
            return NSOrderedSame;
        }
        
        NSTimeInterval firstDeparture = [[(StopDeparture *)obj1.departures[0] departureTime] timeIntervalSinceNow];
        
        NSTimeInterval secondDeparture = [[(StopDeparture *)obj2.departures[0] departureTime] timeIntervalSinceNow];
 
        return firstDeparture <= secondDeparture ? NSOrderedAscending : NSOrderedDescending;
    }];
}
*/

-(NSArray *)validDepartures {
    NSMutableArray *validDepartures = [@[] mutableCopy];
    
    for (StopDeparture *departure in self.departures) {
        NSDate *departureTime = departure.departureTime;
        
        if (departureTime && [departureTime timeIntervalSinceNow] > 0) {
            [validDepartures addObject:departure];
        }
    }
    
    return validDepartures;
}

-(StopLine *)lineForDeparture:(StopDeparture *)departure {
    if (!self.lines)
        return nil;
    
    NSArray *filteredLines = [self.lines filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"fullCode == %@", departure.lineGtfsId]];
    
    return filteredLines.count > 0 ? filteredLines[0] : nil;
}

#pragma mark - Helper Method

-(NSArray *)departureToDictionary:(NSArray *)dipartures{
    
    if (dipartures == nil || [dipartures isEqual:[NSNull null]])
        return @[];
    
    if (dipartures.count < 1)
        return @[];
    
    NSMutableArray *array = [@[] mutableCopy];
    
    for (StopDeparture *departure in dipartures) {
        [array addObject:[departure dictionaryRepresentation]];
    }
    
    return array;
}

-(NSArray *)dictionaryToDeparturesArray:(NSArray *)dicts{
    if (dicts == nil)
        return @[];
    
    NSMutableArray *array = [@[] mutableCopy];
    
    for (NSDictionary *depDict in dicts) {
        [array addObject:[StopDeparture modelObjectWithDictionary:depDict]];
    }
    
    return array;
}

- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict
{
    id object = [dict objectForKey:aKey];
    return [object isEqual:[NSNull null]] ? nil : object;
}


@end
