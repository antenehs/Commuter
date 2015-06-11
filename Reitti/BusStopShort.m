//
//  BusStopShort.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 4/3/14.
//  Copyright (c) 2014 Anteneh Sahledengel. All rights reserved.
//

#import "BusStopShort.h"
#import "ReittiStringFormatter.h"

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

-(void)setStopTypeForGDTypeString:(NSString *)type{
    //    typedef enum
    //    {
    //        StopTypeBus = 0,
    //        StopTypeTram = 1,
    //        StopTypeTrain = 2,
    //        StopTypeMetro = 3,
    //        StopTypeFerry = 4,
    //        StopTypeOther = 5
    //    } StopType;
    
    //0 - Tram, Streetcar, Light rail. Any light rail or street level system within a metropolitan area.
    //1 - Subway, Metro. Any underground rail system within a metropolitan area.
    //2 - Rail. Used for intercity or long-distance travel.
    //3 - Bus. Used for short- and long-distance bus routes.
    //4 - Ferry. Used for short- and long-distance boat service.
    //5 - Cable car. Used for street-level cable cars where the cable runs beneath the car.
    //6 - Gondola, Suspended cable car. Typically used for aerial cable cars where the car is suspended from the cable.
    //7 - Funicular. Any rail system designed for steep inclines.
    
    if ([type isEqualToString:@"0"]) {
        self.stopType = StopTypeTram;
    }else if ([type isEqualToString:@"1"]) {
        self.stopType = StopTypeMetro;
    }else if ([type isEqualToString:@"2"] || [type isEqualToString:@"109"]) {
        self.stopType = StopTypeTrain;
    }else if ([type isEqualToString:@"3"]) {
        self.stopType = StopTypeBus;
    }else if ([type isEqualToString:@"4"]) {
        self.stopType = StopTypeFerry;
    }else if ([type isEqualToString:@"5"]) {
        self.stopType = StopTypeTram;
    }else{
        self.stopType = StopTypeBus;
    }
}

@end
