//
//  GeoCodeDetail.h
//  Reitti
//
//  Created by Anteneh Sahledengel on 15/1/16.
//  Copyright © 2016 Anteneh Sahledengel. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GeoCodeDetail : NSObject

@property (nonatomic, retain) NSString * address;
@property (nonatomic, retain) NSString * code;
@property (nonatomic, retain) NSString * shortCode;
@property (nonatomic, retain) NSArray * lines;
@property (nonatomic, retain) NSString * transportTypeId;
@property (nonatomic, retain) NSString * terminalCode;
@property (nonatomic, retain) NSString * terminalName;
@property (nonatomic, retain) NSString * platformNumber;
@property (nonatomic, retain) NSNumber * houseNumber;
@property (nonatomic, retain) NSString * poiType;
@property (nonatomic, retain) NSString * shortName;

@end
