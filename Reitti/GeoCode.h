//
//  GeoCode.h
//  Reitti
//
//  Created by Anteneh Sahledengel on 6/8/14.
//  Copyright (c) 2014 Anteneh Sahledengel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EnumManager.h"
#import <MapKit/MapKit.h>
#import "GeoCodeDetail.h"
#import "MatkaGeoCode.h"
#import "DigiGeoCode.h"
#import "DigiStop.h"
#import "BusStopShort.h"

@interface GeoCode : NSObject

-(id)initWithMapItem:(MKMapItem *)mapItem;
+(id)geocodeForMatkaGeocode:(MatkaGeoCode *)matkaGeocode;

+(id)geocodeForDigiGeocode:(DigiGeoCode *)digiGeocode;
+(id)geocodeForDigiStop:(DigiStop *)digiStop;

-(NSString *)getHouseNumber;
-(NSString *)getAddress;
-(NSString *)getStopShortCode;
-(NSString *)getStopCode;

-(NSString *)fullAddressString;
-(NSString *)getStreetAddressString;

@property (nonatomic, retain) NSNumber * locTypeId;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * matchedName;
@property (nonatomic, retain) NSString * city;
@property (nonatomic, retain) NSString * lang;
@property (nonatomic, retain) NSString * coords;
@property (nonatomic, retain) GeoCodeDetail *details;
@property (nonatomic) LocationType locationType;
@property (nonatomic) StopType stopType;

@property (nonatomic, readonly) CLLocationCoordinate2D coordinates;

@property (nonatomic, retain) NSString * iconPictureName;
@property (nonatomic, retain) NSString * monochromeIconName;
#ifndef APPLE_WATCH
@property (nonatomic, strong) UIImage *annotationImage;
#endif
-(BusStopShort *)busStop;

@end
