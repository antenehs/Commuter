//
//  HSLRoute.h
//
//  Created by Anteneh Sahledengel on 28/6/16
//  Copyright (c) 2016 shaby ltd. All rights reserved.
//

#import <Foundation/Foundation.h>



@interface HSLRoute : NSObject <NSCoding, NSCopying>

@property (nonatomic, strong) NSArray *legs;
@property (nonatomic, assign) double duration;
@property (nonatomic, assign) double length;

+ (instancetype)modelObjectWithDictionary:(NSDictionary *)dict;
- (instancetype)initWithDictionary:(NSDictionary *)dict;
- (NSDictionary *)dictionaryRepresentation;

@end
