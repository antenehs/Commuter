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
#import "MatkaLine.h"
#import "StopLine.h"

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
//        line.direction = @"1";
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
                           @"codeShort":self.codeShort!= nil? self.codeShort: @"",
                           @"nameFi":self.nameFi!= nil? self.nameFi : @"",
                           @"nameSv":self.nameSv!= nil? self.nameSv : @"",
                           @"cityFi":self.cityFi!= nil? self.cityFi : @"",
                           @"citySv":self.citySv!= nil? self.citySv : @"",
                           @"lines":linesArray,
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
