//
//  BusStop.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 7/2/14.
//  Copyright (c) 2014 Anteneh Sahledengel. All rights reserved.
//

#import "BusStopE.h"

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

-(id)initWithDictionary:(NSDictionary *)dict{
    self.code = [NSNumber numberWithInt:[dict[@"code"] intValue]];
    self.code_short = dict[@"code_short"];
    self.name_fi = dict[@"name_fi"];
    self.name_sv = dict[@"name_sv"];
    self.city_fi = dict[@"city_fi"];
    self.city_sv = dict[@"city_sv"];
    self.lines = dict[@"lines"];
    self.coords = dict[@"coords"];
    self.departures = [self plistToDeparturesArray:dict[@"departures"]];
    self.timetable_link = dict[@"timetable_link"];
    self.address_fi = dict[@"address_fi"];
    self.address_sv = dict[@"address_sv"];
    
    return  self;
}

-(NSDictionary *)toDictionary{
    NSDictionary *dict = @{@"code":[NSString stringWithFormat:@"%d", self.code != nil ? [self.code intValue] : 1] ,
                           @"code_short":self.code_short!= nil? self.code_short : @"",
                           @"name_fi":self.name_fi!= nil? self.name_fi : @"",
                           @"name_sv":self.name_sv!= nil? self.name_sv : @"",
                           @"city_fi":self.city_fi!= nil? self.city_fi : @"",
                           @"city_sv":self.city_sv!= nil? self.city_sv : @"",
                           @"lines":@[],
                           @"coords":self.coords!= nil? self.coords : @"",
                           @"departures":self.departures!= nil? [self departuretoPlist:self.departures] : @[],
                           @"timetable_link":self.timetable_link!= nil? self.timetable_link : @"",
                           @"address_fi":self.address_fi!= nil? self.address_fi : @"",
                           @"address_sv":self.address_sv!= nil? self.address_sv : @"",};
    
    return dict;
}

-(NSArray *)departuretoPlist:(NSArray *)dipartures{
    
    @try {
        if (dipartures == nil || [dipartures isEqual:[NSNull null]])
            return @[];
        
        if (dipartures.count < 1)
            return @[];
        
        NSMutableArray *array = [@[] mutableCopy];
        
        for (NSDictionary *dict in dipartures) {
            NSDictionary *departure = @{@"code":dict[@"code"],
                                        @"date":[NSString stringWithFormat:@"%d", [dict[@"date"] intValue]],
                                        @"time":[NSString stringWithFormat:@"%d", [dict[@"time"] intValue]],};
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


@end
