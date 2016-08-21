//
//  GeoCode.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 6/8/14.
//  Copyright (c) 2014 Anteneh Sahledengel. All rights reserved.
//

#import "GeoCode.h"
#import "CacheManager.h"
#import "ReittiStringFormatter.h"

@implementation GeoCode

@synthesize locType;
@synthesize locTypeId;
@synthesize name;
@synthesize matchedName;
@synthesize city;
@synthesize details;
@synthesize lang;
@synthesize coords;

-(id)initWithMapItem:(MKMapItem *)mapItem{
    self = [super init];
    
    if (self) {
        self.name = [NSString stringWithFormat:@"%@", mapItem.name];
        self.locTypeId = @1018;
        self.coords = [ReittiStringFormatter convert2DCoordToString:mapItem.placemark.coordinate];
        
        self.city = mapItem.placemark.addressDictionary[@"City"] ? mapItem.placemark.addressDictionary[@"City"] : mapItem.name;
//        NSLog(@"%@", mapItem.placemark.addressDictionary);
        
        GeoCodeDetail *detail = [GeoCodeDetail new];
        detail.address = mapItem.placemark.addressDictionary[@"Street"] ? mapItem.placemark.addressDictionary[@"Street"] : mapItem.name;
        
        self.details = detail;
    }
    
    return self;
}

+(id)geocodeForMatkaGeocode:(MatkaGeoCode *)matkaGeocode {
    GeoCode *geoCode = [[GeoCode alloc] init];
    
    geoCode.name = matkaGeocode.name;
    geoCode.locType = matkaGeocode.category;
    geoCode.locTypeId = matkaGeocode.type;
    geoCode.coords = matkaGeocode.coordString;
    geoCode.city = matkaGeocode.city;
    
    GeoCodeDetail *detail = [GeoCodeDetail new];
    detail.address = matkaGeocode.address;
    detail.shortCode = matkaGeocode.code;
    detail.houseNumber = matkaGeocode.number;
    
    geoCode.details = detail;
    
    return geoCode;
}

-(NSString *)getHouseNumber{
    @try {
        if (!self.details)
            return @"";

        NSNumber *houseNum = self.details.houseNumber;
        if (houseNum != nil){
            if ([houseNum isKindOfClass:[NSString class]]) {
                if (![(NSString *)houseNum isEqualToString:@"1"] && ![(NSString *)houseNum isEqualToString:@"0"])
                    return (NSString *)houseNum;
                else
                    return @"";
            }else{
                if (![[houseNum stringValue] isEqualToString:@"1"] && ![[houseNum stringValue] isEqualToString:@"0"])
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
        NSString *address = self.details.address;
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
        NSString *shortCode = self.details.shortCode;
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
        if (!self.details.code) return nil;
            
        NSString *code = self.details.code;
        
        return [NSNumber numberWithInteger:[code integerValue]];
    }
    @catch (NSException *exception) {
        return nil;
    }
}

-(LocationType)getLocationType{
    int typeId_int = [self.locTypeId intValue];
    if((0 < typeId_int && typeId_int < 10) || typeId_int == 108 || typeId_int == 1008 || typeId_int == 1018) //1018 = from apple, 108 from matka
        return LocationTypePOI;
    else if (typeId_int == 10)
        return LocationTypeStop;
    else if (typeId_int == 900)
        return LocationTypeAddress;
    else if (typeId_int == 999)
        return LocationTypeDroppedPin;
    else if (typeId_int == 550)
        return LocationTypeContact;
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
    if ([self.locTypeId integerValue] == 1018) {//Apples geocode has different format
        return [NSString stringWithFormat:@"%@, %@", [self getStreetAddressString], self.city];
    }else{
        //In case of reverse geocoding, street number and city is included in the name. So check if city name exists already
        if ([[self getStreetAddressString] containsString:self.city]) {
            return [self getStreetAddressString];
        }else{
            return [NSString stringWithFormat:@"%@, %@", [self getStreetAddressString], self.city];
        }
    }
}

-(NSString *)getStreetAddressString{
    if ([self.locTypeId integerValue] == 1018 || [self.locTypeId integerValue] == 550) {//Apples geocode has different format
        return self.details.address;
    }else{ //Searches from HSL and TRE has the address as name
        //In case of reverse geocoding, street number and city is included in the name.
        if ([self.name containsString:self.city]) {
            return self.name;
        }else{
            return [[NSString stringWithFormat:@"%@ %@", self.name, self.getHouseNumber] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        }
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
