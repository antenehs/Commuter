//
//  StaticStop.h
//
//  Created by Anteneh Sahledengel on 7/6/15
//  Copyright (c) 2015 shaby ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EnumManager.h"


@interface StaticStop : NSObject <NSCoding, NSCopying>

@property (nonatomic, strong) NSString *stopType;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *shortCode;
@property (nonatomic, strong) NSString *code;
@property (nonatomic, strong) NSArray *lineNames;
@property (nonatomic) StopType reittiStopType;

+ (instancetype)modelObjectWithDictionary:(NSDictionary *)dict;
- (instancetype)initWithDictionary:(NSDictionary *)dict;
- (NSDictionary *)dictionaryRepresentation;

@end
