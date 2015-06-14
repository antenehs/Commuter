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
    
//    1 = Helsinki internal bus lines
//    2 = trams
//    3 = Espoo internal bus lines
//    4 = Vantaa internal bus lines
//    5 = regional bus lines
//    6 = metro
//    7 = ferry
//    8 = U-lines
//    12 = commuter trains
//    21 = Helsinki service lines
//    22 = Helsinki night buses
//    23 = Espoo service lines
//    24 = Vantaa service lines
//    25 = region night buses
//    36 = Kirkkonummi internal bus lines
//    39 = Kerava internal bus lines
    
    if ([type isEqualToString:@"2"]) {
        self.stopType = StopTypeTram;
    }else if ([type isEqualToString:@"6"]) {
        self.stopType = StopTypeMetro;
    }else if ([type isEqualToString:@"12"]) {
        self.stopType = StopTypeTrain;
    }else if ([type isEqualToString:@"3"]) {
        self.stopType = StopTypeBus;
    }else if ([type isEqualToString:@"7"]) {
        self.stopType = StopTypeFerry;
    }else{
        self.stopType = StopTypeBus;
    }
}

@end
