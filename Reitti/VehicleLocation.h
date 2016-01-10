//
//  VehicleLocation.h
//
//  Created by Anteneh Sahledengel on 10/1/16
//  Copyright (c) 2016 shaby ltd. All rights reserved.
//

#import <Foundation/Foundation.h>



@interface VehicleLocation : NSObject <NSCoding, NSCopying>

@property (nonatomic, assign) double latitude;
@property (nonatomic, assign) double longitude;

+ (instancetype)modelObjectWithDictionary:(NSDictionary *)dict;
- (instancetype)initWithDictionary:(NSDictionary *)dict;
- (NSDictionary *)dictionaryRepresentation;

@end
