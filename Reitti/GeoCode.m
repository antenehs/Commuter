//
//  GeoCode.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 6/8/14.
//  Copyright (c) 2014 Anteneh Sahledengel. All rights reserved.
//

#import "GeoCode.h"
#import "CacheManager.h"

@implementation GeoCode

@synthesize locType;
@synthesize locTypeId;
@synthesize name;
@synthesize matchedName;
@synthesize city;
@synthesize lang;
@synthesize coords;
@synthesize details;

-(NSString *)getHouseNumber{
    @try {
        NSNumber *houseNum = [details objectForKey:@"houseNumber"];
        if (houseNum != nil){
            if ([houseNum isKindOfClass:[NSString class]]) {
                if (![(NSString *)houseNum isEqualToString:@"1"])
                    return (NSString *)houseNum;
                else
                    return @"";
            }else{
                if (![[houseNum stringValue] isEqualToString:@"1"])
                    return [houseNum stringValue];
                else
                    return @"";
            }
            
        }else{
            return @"";
        }
    }
    @catch (NSException *exception) {
        return @"";
    }
}
-(NSString *)getAddress{
    @try {
        NSString *address = [details objectForKey:@"address"];
        if (address != nil)
            return address;
        else
            return @"";
    }
    @catch (NSException *exception) {
        return @"";
    }
}
-(NSString *)getStopShortCode{
    @try {
        NSString *shortCode = [details objectForKey:@"shortCode"];
        if (shortCode != nil)
            return shortCode;
        return @"";
    }
    @catch (NSException *exception) {
        return @"";
    }
    
}
-(NSNumber *)getStopCode{
    @try {
        NSNumber *code = [details objectForKey:@"code"];
            return code;
    }
    @catch (NSException *exception) {
        return nil;
    }
}

-(LocationType)getLocationType{
    int typeId_int = [self.locTypeId intValue];
    if((0 < typeId_int && typeId_int < 10) || typeId_int == 1008)
        return LocationTypePOI;
    else if (typeId_int == 10)
        return LocationTypeStop;
    else if (typeId_int == 900)
        return LocationTypeAddress;
    else if (typeId_int == 999)
        return LocationTypeDroppedPin;
    else
        return LocationTypeAddress;
}

-(void)setLocationType:(LocationType)type{
    switch (type) {
        case LocationTypePOI:
            self.locTypeId = [NSNumber numberWithInt:1];
            break;
            
        case LocationTypeStop:
            self.locTypeId = [NSNumber numberWithInt:10];
            break;
            
        case LocationTypeAddress:
            self.locTypeId = [NSNumber numberWithInt:900];
            break;
            
        case LocationTypeDroppedPin:
            self.locTypeId = [NSNumber numberWithInt:999]; //Custome type. Not coming from HSL
            break;
            
        default:
            self.locTypeId = [NSNumber numberWithInt:900];
            break;
    }
    
}

-(NSString *)fullAddressString{
    //In case of reverse geocoding, street number and city is included in the name. So check if city name exists already
    if ([[self getStreetAddressString] containsString:self.city]) {
        return [self getStreetAddressString];
    }else{
        return [NSString stringWithFormat:@"%@, %@", [self getStreetAddressString], self.city];
    }   
}

-(NSString *)getStreetAddressString{
    //In case of reverse geocoding, street number and city is included in the name.
    if ([self.name containsString:self.city]) {
        return self.name;
    }else{
        return [[NSString stringWithFormat:@"%@ %@", self.name, self.getHouseNumber] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    }
}

-(StopType)getStopType{
    if ([self getLocationType] == LocationTypeStop) {
        @try {
            StaticStop *staticStop = [[CacheManager sharedManager] getStopForCode:[NSString stringWithFormat:@"%@", [self getStopCode]]];
            if (staticStop != nil) {
                return staticStop.reittiStopType;
            }else{
                return StopTypeBus;
            }
        }
        @catch (NSException *exception) {
            
        }
    }else{
        return StopTypeBus;
    }
}

@end
