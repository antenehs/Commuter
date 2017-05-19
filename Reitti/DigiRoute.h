//
//  DigiRoute.h
//
//  Created by Anteneh Sahledengel on 12/26/16
//  Copyright (c) 2016 shaby ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DigiRouteShort.h"
#import "Mapping.h"
#import "DigiPattern.h"
#import "Line.h"

@interface DigiRoute : DigiRouteShort <NSCoding, NSCopying, Mappable>

-(Line *)reittiLine;
-(Line *)reittiLineForPattern:(DigiPattern *)pattern;

@property (nonatomic, strong) NSArray *patterns;
@property (nonatomic, strong) NSArray *alerts;

+ (instancetype)modelObjectWithDictionary:(NSDictionary *)dict;
- (instancetype)initWithDictionary:(NSDictionary *)dict;
- (NSDictionary *)dictionaryRepresentation;

@end
