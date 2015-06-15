//
//  EnumManager.m
//  
//
//  Created by Anteneh Sahledengel on 15/6/15.
//
//

#import "EnumManager.h"

@implementation EnumManager

+(StopType)stopTypeForGDTypeString:(NSString *)type{
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
        return StopTypeTram;
    }else if ([type isEqualToString:@"6"]) {
        return StopTypeMetro;
    }else if ([type isEqualToString:@"12"]) {
        return StopTypeTrain;
    }else if ([type isEqualToString:@"3"]) {
        return StopTypeBus;
    }else if ([type isEqualToString:@"7"]) {
        return StopTypeFerry;
    }else{
        return StopTypeBus;
    }
}


+(StopType)stopTypeForPubTransStopType:(NSString *)type{
    if ([type isEqualToString:@"tram"]) {
        return StopTypeTram;
    }else if ([type isEqualToString:@"train"]) {
        return StopTypeTrain;
    }else if ([type isEqualToString:@"metro"]) {
        return StopTypeMetro;
    }else if ([type isEqualToString:@"bus"]) {
        return StopTypeBus;
    }else if ([type isEqualToString:@"ferry"]) {
        return StopTypeFerry;
    }else {
        return StopTypeBus;
    }
}

@end
