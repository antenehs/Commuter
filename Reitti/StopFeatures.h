//
//  StopFeatures.h
//
//  Created by Anteneh Sahledengel on 23/5/15
//  Copyright (c) 2015 shaby ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Geometry, StopProperties;

@interface StopFeatures : NSObject <NSCoding, NSCopying>

@property (nonatomic, strong) NSString *type;
@property (nonatomic, strong) Geometry *geometry;
@property (nonatomic, strong) Properties *properties;

+ (instancetype)modelObjectWithDictionary:(NSDictionary *)dict;
- (instancetype)initWithDictionary:(NSDictionary *)dict;
- (NSDictionary *)dictionaryRepresentation;

@end
