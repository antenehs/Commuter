//
//  GeoCode.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 6/8/14.
//  Copyright (c) 2014 Anteneh Sahledengel. All rights reserved.
//

#import "GeoCode.h"

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
            if (![[houseNum stringValue] isEqualToString:@"1"])
                return [houseNum stringValue];
            else
                return @"";
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
    else
        return LocationTypeAddress;
}

@end
