//
//  DigiPattern.h
//
//  Created by Anteneh Sahledengel on 28/5/16
//  Copyright (c) 2016 shaby ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DigiGeometry.h"
#import "DigiStopShort.h"
#import "DigiPatternShort.h"
#import "Mapping.h"

@interface DigiPattern : DigiPatternShort <NSCoding, NSCopying, Mappable>

@property (nonatomic, strong) NSArray *stops;
@property (nonatomic, strong) NSArray *geometry;

//Computed
@property (nonatomic, strong) NSArray *shapeCoordinates;
@property (nonatomic, strong) NSArray *shapeStringCoordinates;
@property (nonatomic, strong) NSString *lineStart;
@property (nonatomic, strong) NSString *lineEnd;

+ (instancetype)modelObjectWithDictionary:(NSDictionary *)dict;
- (instancetype)initWithDictionary:(NSDictionary *)dict;
- (NSDictionary *)dictionaryRepresentation;

@end
