//
//  MatkaGeoCode.h
//  Reitti
//
//  Created by Anteneh Sahledengel on 10/4/16.
//  Copyright © 2016 Anteneh Sahledengel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
/*
 <LOC name1="Teeripalontie" number="3" city="Ranua" code="" address="" type="900" category="street" x="3460901" y="7315588"/>
*/

@interface MatkaGeoCode : NSObject

@property (nonatomic, strong)NSString *name;
@property (nonatomic, strong)NSNumber *number;
@property (nonatomic, strong)NSString *city;
@property (nonatomic, strong)NSString *code;
@property (nonatomic, strong)NSString *address;
@property (nonatomic, strong)NSNumber *type;
@property (nonatomic, strong)NSString *category;
@property (nonatomic, strong)NSNumber *xCoord;
@property (nonatomic, strong)NSNumber *yCoord;

@property (nonatomic, strong)NSString *coordString;
@property (nonatomic)CLLocationCoordinate2D coord;

@end
