//
//  DigiPattern.h
//
//  Created by Anteneh Sahledengel on 28/5/16
//  Copyright (c) 2016 shaby ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DigiGeometry.h"
#import "Mapping.h"

@interface DigiPattern : NSObject <NSCoding, NSCopying, Mappable>

@property (nonatomic, strong) NSArray *geometry;
@property (nonatomic, strong) NSArray *shapeCoordinates;

+ (instancetype)modelObjectWithDictionary:(NSDictionary *)dict;
- (instancetype)initWithDictionary:(NSDictionary *)dict;
- (NSDictionary *)dictionaryRepresentation;

@end
