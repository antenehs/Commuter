//
//  TREVehicleLocation.h
//
//  Created by Anteneh Sahledengel on 3/4/16
//  Copyright (c) 2016 shaby ltd. All rights reserved.
//

#import <Foundation/Foundation.h>



@interface TREVehicleLocation : NSObject <NSCoding, NSCopying>

@property (nonatomic, strong) NSString *longitude;
@property (nonatomic, strong) NSString *latitude;

+ (instancetype)modelObjectWithDictionary:(NSDictionary *)dict;
- (instancetype)initWithDictionary:(NSDictionary *)dict;
- (NSDictionary *)dictionaryRepresentation;

@end
