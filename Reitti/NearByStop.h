//
//  NearByStop.h
//  Reitti
//
//  Created by Anteneh Sahledengel on 23/5/15.
//  Copyright (c) 2015 Anteneh Sahledengel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Features.h"
#import <MapKit/MapKit.h>
#import "EnumManager.h"

@interface NearByStop : Features

-(NSString *)linesAsCommaSepString;

@property (nonatomic, strong) NSString *stopCode;
@property (nonatomic, strong) NSString *stopShortCode;
@property (nonatomic, strong) NSString *stopName;
@property (nonatomic) CLLocationCoordinate2D coords;
@property (nonatomic) double distance;
@property (nonatomic) StopType stopType;
@property (nonatomic, strong) NSArray *lines;
@property (nonatomic, strong) NSString *stopAddress;

@end
