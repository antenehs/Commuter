//
//  DigiRoute.h
//
//  Created by Anteneh Sahledengel on 12/26/16
//  Copyright (c) 2016 shaby ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RestKit/RestKit.h>
#import "DigiRouteShort.h"


@interface DigiRoute : DigiRouteShort <NSCoding, NSCopying>

@property (nonatomic, strong) NSArray *stops;
@property (nonatomic, strong) NSArray *patterns;
@property (nonatomic, strong) NSArray *alerts;

@property (nonatomic, strong) NSArray *shapeCoordinates;

+(RKResponseDescriptor *)responseDiscriptorForPath:(NSString *)path;
+(RKObjectMapping *)objectMapping;

+ (instancetype)modelObjectWithDictionary:(NSDictionary *)dict;
- (instancetype)initWithDictionary:(NSDictionary *)dict;
- (NSDictionary *)dictionaryRepresentation;

@end
