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
#import "AppManager.h"
#import "SettingsManager.h"

@implementation GeoCode

//@synthesize locType;
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
//    geoCode.locType = matkaGeocode.category;
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

+(id)geocodeForDigiGeocode:(DigiGeoCode *)digiGeocode {
    GeoCode *geoCode = [[GeoCode alloc] init];
    
    geoCode.name = digiGeocode.properties.name;
    geoCode.locationType = digiGeocode.locationType;
    geoCode.coords = digiGeocode.geometry.coordString;
    geoCode.city = digiGeocode.city;

    GeoCodeDetail *detail = [GeoCodeDetail new];
    detail.address = digiGeocode.properties.street;
    detail.houseNumber = digiGeocode.properties.houseNumber;
    
    geoCode.details = detail;
    
    return geoCode;
}

+(id)geocodeForDigiStop:(DigiStop *)digiStop {
    GeoCode *geoCode = [[GeoCode alloc] init];
    
    geoCode.name = digiStop.name;
    geoCode.locationType = LocationTypeStop;
    geoCode.coords = digiStop.coordString;
    geoCode.stopType = digiStop.stopType;
    //TODO: No city.. do somelthing about it
//    geoCode.city = digiStop.city;
    
    GeoCodeDetail *detail = [GeoCodeDetail new];
    detail.address = digiStop.desc;
    detail.shortCode = digiStop.code;
    detail.code = digiStop.gtfsId;
    
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
-(NSString *)getStopCode{
    return self.details.code;
}

-(LocationType)getLocationType {
    if (_locationType == LocationTypeUnknown && self.locTypeId) {
        int typeId_int = [self.locTypeId intValue];
        if((0 < typeId_int && typeId_int < 10) || typeId_int == 108 || typeId_int == 1008 || typeId_int == 1018) //1018 = from apple, 108 from matka
            _locationType = LocationTypePOI;
        else if (typeId_int == 10)
            _locationType = LocationTypeStop;
        else if (typeId_int == 900)
            _locationType = LocationTypeAddress;
        else if (typeId_int == 999)
            _locationType = LocationTypeDroppedPin;
        else if (typeId_int == 550)
            _locationType = LocationTypeContact;
        else
            _locationType = LocationTypeAddress;
    }
    
    return _locationType;
}

-(void)setLocationType:(LocationType)type{
    _locationType = type;
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

-(NSString *)fullAddressString {
    if ([self.locTypeId integerValue] == 1018) {//Apples geocode has different format
        return [NSString stringWithFormat:@"%@%@ %@", [self getStreetAddressString], self.city ? @"," : @"", self.city ? self.city : @""];
    }else{
        //In case of reverse geocoding, street number and city is included in the name. So check if city name exists already
        if (self.city && [[self getStreetAddressString] containsString:self.city]) {
            return [self getStreetAddressString];
        }else{
            return [NSString stringWithFormat:@"%@%@ %@", [self getStreetAddressString], self.city ? @"," : @"", self.city ? self.city : @""];
        }
    }
}

-(NSString *)getStreetAddressString {
    if ([self.locTypeId integerValue] == 1018 || [self.locTypeId integerValue] == 550) {//Apples geocode has different format
        return self.details.address;
    }else{ //Searches from HSL and TRE has the address as name
        //In case of reverse geocoding, street number and city is included in the name.
        if (self.city && [self.name containsString:self.city]) {
            return self.name;
        } else if ([SettingsManager useDigiTransit]) {
            return self.name;
        } else {
            return [[NSString stringWithFormat:@"%@ %@", self.name, self.getHouseNumber] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        }
    }
}

-(StopType)stopType{
    if ([self getLocationType] == LocationTypeStop) {
        @try {
            if (_stopType == StopTypeUnknown) {
                StaticStop *staticStop = [[CacheManager sharedManager] getStopForCode:[self getStopCode]];
                if (staticStop != nil) {
                    _stopType = staticStop.reittiStopType;
                }else{
                    _stopType = StopTypeBus;
                }
            }
        }
        @catch (NSException *exception) {}
        
        return _stopType;
    }else{
        return StopTypeBus;
    }
}

-(NSString *)iconPictureName {
    if (self.getLocationType == LocationTypeContact) {
        return @"contactIcon";
    } else if (self.getLocationType == LocationTypePOI) {
        return @"location-75.png";
    } else if (self.getLocationType == LocationTypeAddress) {
        return @"search-75.png";
    } else if (self.getLocationType == LocationTypeDroppedPin) {
        return @"dropped-pin-100.png";
    } else {
        return [AppManager stopIconNameForStopType:StopTypeBus];
    }
}

-(CLLocationCoordinate2D)coordinates {
    return [ReittiStringFormatter convertStringTo2DCoord:self.coords];
}

#ifndef APPLE_WATCH
-(UIImage *)annotationImage {
    if (!_annotationImage) {
        CGRect outerFrame = CGRectMake(0, 0, 83, 124);
        CGRect topFrame = CGRectMake(3, 0, 77, 77);
        CGRect baseFrame = CGRectMake(10, 76, 63, 48);
        
        UIView *holder = [[UIView alloc] initWithFrame:outerFrame];
        
        UIImageView *topImageView = [[UIImageView alloc] initWithFrame:topFrame];
        [topImageView setImage:[UIImage imageNamed:self.iconPictureName]];
        [holder addSubview:topImageView];
        
        UIImageView *baseImageView = [[UIImageView alloc] initWithFrame:baseFrame];
        [baseImageView setImage:[UIImage imageNamed:@"AnnotationLeg"]];
        [holder addSubview:baseImageView];
        
        UIGraphicsBeginImageContext(holder.bounds.size);
        [holder.layer renderInContext:UIGraphicsGetCurrentContext()];
        _annotationImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    
    return _annotationImage;
}
#endif

-(BusStopShort *)busStop {
    if (self.locationType != LocationTypeStop)
        return nil;
    
    BusStopShort *castedBSS = [[BusStopShort alloc] init];
    castedBSS.gtfsId = self.getStopCode;
    castedBSS.codeShort = self.getStopShortCode;
    castedBSS.coords = self.coords;
    castedBSS.name = self.name;
    castedBSS.city = self.city;
    castedBSS.address = self.getAddress;
    castedBSS.distance = [NSNumber numberWithInt:0];
    castedBSS.stopType = self.stopType;
    
    return castedBSS;
}

@end
