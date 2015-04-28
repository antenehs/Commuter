//
//  GeoCode.h
//  Reitti
//
//  Created by Anteneh Sahledengel on 6/8/14.
//  Copyright (c) 2014 Anteneh Sahledengel. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum
{
    LocationTypePOI = 1,
    LocationTypeAddress = 2,
    LocationTypeStop = 3,
    LocationTypeDroppedPin = 10
} LocationType;

@interface GeoCode : NSObject

-(NSString *)getHouseNumber;
-(NSString *)getAddress;
-(NSString *)getStopShortCode;
-(NSNumber *)getStopCode;
-(LocationType)getLocationType;
-(void)setLocationType:(LocationType)type;
-(NSString *)FullAddressString;
-(NSString *)getStreetAddressString;

@property (nonatomic, retain) NSString * locType;
@property (nonatomic, retain) NSNumber * locTypeId;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * matchedName;
@property (nonatomic, retain) NSString * city;
@property (nonatomic, retain) NSString * lang;
@property (nonatomic, retain) NSString * coords;
@property (nonatomic, retain) NSDictionary * details;

@end
