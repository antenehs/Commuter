//
//  MatkaNearbyStop.h
//  Reitti
//
//  Created by Anteneh Sahledengel on 9/4/16.
//  Copyright © 2016 Anteneh Sahledengel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MatkaName.h"
#import <MapKit/MapKit.h>

/*
 <STOP xCoord = ‘%Real’ yCoord = ‘%Real’
 id = ‘%String’
 code = ‘%String’
 distance = ‘%Integer’
 cityId = ‘%Integer’
 companyCode = ‘%String’
 order = ‘%Integer’
 tranportType = ‘%Integer’> <name></name>
 <LINE></LINE> </STOP>
*/

@interface MatkaStop : NSObject

@property (nonatomic, strong)NSString *stopId;
@property (nonatomic, strong)NSString *stopShortCode;
@property (nonatomic, retain)NSArray *stopNames;
@property (nonatomic, retain)NSArray *stopLines;
@property (nonatomic, strong)NSNumber *xCoord;
@property (nonatomic, strong)NSNumber *yCoord;
@property (nonatomic, strong)NSNumber *distance;
@property (nonatomic, strong)NSNumber *cityId;
@property (nonatomic, strong)NSString *companyCode;
@property (nonatomic, strong)NSNumber *order;
@property (nonatomic, strong)NSNumber *transportType;

@property (nonatomic, strong)NSString *coordString;
@property (nonatomic)CLLocationCoordinate2D coords;
@property (nonatomic, strong)NSString *nameFi;
@property (nonatomic, strong)NSString *nameSe;

@end
