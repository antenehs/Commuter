//
//  Value.h
//
//  Created by Anteneh Sahledengel on 2/7/15
//  Copyright (c) 2015 shaby ltd. All rights reserved.
//

#import <Foundation/Foundation.h>



@interface Value : NSObject <NSCoding, NSCopying>

@property (nonatomic, assign) double maxValue;
@property (nonatomic, assign) double lastPurchase;
@property (nonatomic, assign) double available;
@property (nonatomic, strong) NSArray *defaultPriceRange;
@property (nonatomic, assign) double minValue;
@property (nonatomic, assign) double alertLimit;

+ (instancetype)modelObjectWithDictionary:(NSDictionary *)dict;
- (instancetype)initWithDictionary:(NSDictionary *)dict;
- (NSDictionary *)dictionaryRepresentation;

@end
