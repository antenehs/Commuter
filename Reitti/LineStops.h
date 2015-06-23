//
//  LineStops.h
//
//  Created by Anteneh Sahledengel on 18/6/15
//  Copyright (c) 2015 shaby ltd. All rights reserved.
//

#import <Foundation/Foundation.h>



@interface LineStops : NSObject <NSCoding, NSCopying>

@property (nonatomic, strong) NSString *coords;
@property (nonatomic, strong) NSString *address;
@property (nonatomic, assign) double time;
@property (nonatomic, strong) NSString *code;
@property (nonatomic, strong) NSString *codeShort;
@property (nonatomic, strong) NSString *platformNumber;
@property (nonatomic, strong) NSString *cityName;
@property (nonatomic, strong) NSString *name;

+ (instancetype)modelObjectWithDictionary:(NSDictionary *)dict;
- (instancetype)initWithDictionary:(NSDictionary *)dict;
- (NSDictionary *)dictionaryRepresentation;

@end
