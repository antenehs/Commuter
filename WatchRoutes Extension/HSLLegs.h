//
//  HSLLegs.h
//
//  Created by Anteneh Sahledengel on 28/6/16
//  Copyright (c) 2016 shaby ltd. All rights reserved.
//

#import <Foundation/Foundation.h>



@interface HSLLegs : NSObject <NSCoding, NSCopying>

@property (nonatomic, strong) NSArray *locs;
@property (nonatomic, strong) NSString *code;
@property (nonatomic, assign) double length;
@property (nonatomic, strong) NSString *type;
@property (nonatomic, assign) double duration;

+ (instancetype)modelObjectWithDictionary:(NSDictionary *)dict;
- (instancetype)initWithDictionary:(NSDictionary *)dict;
- (NSDictionary *)dictionaryRepresentation;

@end
