//
//  BusStop.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 7/2/14.
//  Copyright (c) 2014 Anteneh Sahledengel. All rights reserved.
//

/*
#import "BusStopE.h"
#import "StopLine.h"

@implementation BusStopE

@synthesize code;
@synthesize code_short;
@synthesize name_fi;
@synthesize name_sv;
@synthesize city_fi;
@synthesize city_sv;
@synthesize lines;
@synthesize coords;
@synthesize departures;
@synthesize timetable_link;
@synthesize address_fi;
@synthesize address_sv;

-(id)initWithDictionary:(NSDictionary *)dict parseLines:(BOOL)parseLines {
    NSMutableArray *linesArray = [@[] mutableCopy];
    
    NSArray *linesDictionary = [self objectOrNilForKey:@"lines" fromDictionary:dict];
    
    if(parseLines) {
        for (NSDictionary *lineDic in linesDictionary) {
            StopLine *line = [StopLine initFromDictionary:lineDic];
            if (dict) [linesArray addObject:line];
        }
    }
    
    self.code = [NSNumber numberWithInt:[[self objectOrNilForKey:@"code" fromDictionary:dict] intValue]];
    self.code_short = [self objectOrNilForKey:@"code_short" fromDictionary:dict];
    self.name_fi = [self objectOrNilForKey:@"name_fi" fromDictionary:dict];
    self.name_sv = [self objectOrNilForKey:@"name_sv" fromDictionary:dict];
    self.city_fi = [self objectOrNilForKey:@"city_fi" fromDictionary:dict];
    self.city_sv = [self objectOrNilForKey:@"city_sv" fromDictionary:dict];
    self.lines = parseLines ? linesArray : linesDictionary;
    self.coords = [self objectOrNilForKey:@"coords" fromDictionary:dict];
    self.departures = [self plistToDeparturesArray:[self objectOrNilForKey:@"departures" fromDictionary:dict]];
    self.timetable_link = [self objectOrNilForKey:@"timetable_link" fromDictionary:dict];
    self.address_fi = [self objectOrNilForKey:@"address_fi" fromDictionary:dict];
    self.address_sv = [self objectOrNilForKey:@"address_sv" fromDictionary:dict];
    
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
    
    NSDictionary *dict = @{@"code":[NSString stringWithFormat:@"%d", self.code != nil ? [self.code intValue] : 1] ,
                           @"code_short":self.code_short!= nil? self.code_short : @"",
                           @"name_fi":self.name_fi!= nil? self.name_fi : @"",
                           @"name_sv":self.name_sv!= nil? self.name_sv : @"",
                           @"city_fi":self.city_fi!= nil? self.city_fi : @"",
                           @"city_sv":self.city_sv!= nil? self.city_sv : @"",
                           @"lines":linesArray,
                           @"coords":self.coords!= nil? self.coords : @"",
                           @"departures":self.departures!= nil? [self departuretoPlist:self.departures] : @[],
                           @"timetable_link":self.timetable_link!= nil? self.timetable_link : @"",
                           @"address_fi":self.address_fi!= nil? self.address_fi : @"",
                           @"address_sv":self.address_sv!= nil? self.address_sv : @"",};
    
    return dict;
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

-(NSArray *)departuretoPlist:(NSArray *)dipartures{
    
    @try {
        if (dipartures == nil || [dipartures isEqual:[NSNull null]])
            return @[];
        
        if (dipartures.count < 1)
            return @[];
        
        NSMutableArray *array = [@[] mutableCopy];
        
        for (NSDictionary *dict in dipartures) {
            NSDictionary *departure = @{@"code":[self objectOrNilForKey:@"code" fromDictionary:dict],
                                        @"date":[NSString stringWithFormat:@"%d", [[self objectOrNilForKey:@"date" fromDictionary:dict] intValue]],
                                        @"time":[NSString stringWithFormat:@"%d", [[self objectOrNilForKey:@"time" fromDictionary:dict] intValue]],};
            [array addObject:departure];
        }
        
        return array;
    }
    @catch (NSException *exception) {
        return @[];
    }
}

-(NSArray *)plistToDeparturesArray:(NSArray *)plist{
    if (plist == nil)
        return @[];
    
    NSMutableArray *array = [@[] mutableCopy];
    
    for (NSDictionary *dict in plist) {
        NSDictionary *departure = @{@"code":dict[@"code"],
                                    @"date":[NSNumber numberWithInt:[dict[@"date"] intValue]],
                                    @"time":[NSNumber numberWithInt:[dict[@"time"] intValue]],};
        [array addObject:departure];
    }
    
    return array;
}

+ (id)stopFromMatkaStop:(MatkaStop *)matkaStop {
    BusStopE *stop = [[BusStopE alloc] init];
    
    stop.code = [NSNumber numberWithInteger:[matkaStop.stopId integerValue]];;
    stop.code_short = matkaStop.stopShortCode;
    stop.name_fi = matkaStop.nameFi;
    stop.name_sv = matkaStop.nameSe;
    stop.city_fi = @"";
    stop.city_sv = @"";
//    stop.lines = [BusStopE linesFromMatkaLines:matkaStop.stopLines];
    stop.coords = matkaStop.coordString;
//    stop.wgs_coords = matkaStop.coordString;
    stop.departures = [BusStopE departuresFromMatkaLines:matkaStop.stopLines];
    stop.timetable_link = nil;
    stop.address_fi = @"";
    stop.address_sv = @"";
    
    return stop;
}

//+ (NSArray *)linesFromMatkaLines:(NSArray *)matkaLines {
//    NSMutableArray *lines = [@[] mutableCopy];
//    for (MatkaLine *matkaLine in matkaLines) {
//        StopLine *line = [[StopLine alloc] init];
//        line.fullCode = matkaLine.lineId;
//        line.code = [matkaLine.codeShort uppercaseString];
//        line.name = matkaLine.name;
//        line.direction = @"1";
//        line.destination = matkaLine.name;
//        line.lineType = matkaLine.lineType;
//        line.lineStart = matkaLine.lineStart;
//        line.lineEnd = matkaLine.lineEnd;
//        
//        [lines addObject:line];
//    }
//    
//    return lines;
//}

+ (NSArray *)departuresFromMatkaLines:(NSArray *)matkaLines {
    NSMutableArray *departures = [@[] mutableCopy];
    
    for (MatkaLine *matkaLine in matkaLines) {
        if (!matkaLine.departureTime) continue;
        
        NSMutableDictionary *departure = [[NSMutableDictionary alloc] init];
        
        departure[@"code"] = matkaLine.codeShort;
        departure[@"time"] = matkaLine.departureTime;
        
        [departures addObject:departure];
    }
    
    return departures;
}

#pragma mark - Helper Method
- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict
{
    id object = [dict objectForKey:aKey];
    return [object isEqual:[NSNull null]] ? nil : object;
}


@end
*/
