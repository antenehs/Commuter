//
//  HSLLocs.h
//
//  Created by Anteneh Sahledengel on 28/6/16
//  Copyright (c) 2016 shaby ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@class HSLCoord;

@interface HSLLocs : NSObject <NSCoding, NSCopying>

@property (nonatomic, assign) id name;
@property (nonatomic, strong) NSString *arrTime;
@property (nonatomic, strong) HSLCoord *coord;
@property (nonatomic, strong) NSString *code;
@property (nonatomic, strong) NSString *depTime;
@property (nonatomic, strong) NSString *stopAddress;
@property (nonatomic, strong) NSString *shortCode;

+ (instancetype)modelObjectWithDictionary:(NSDictionary *)dict;
- (instancetype)initWithDictionary:(NSDictionary *)dict;
- (NSDictionary *)dictionaryRepresentation;

@end
