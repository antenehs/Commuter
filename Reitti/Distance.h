//
//  Distance.h
//
//  Created by Anteneh Sahledengel on 2/7/15
//  Copyright (c) 2015 shaby ltd. All rights reserved.
//

#import <Foundation/Foundation.h>



@interface Distance : NSObject <NSCoding, NSCopying>

@property (nonatomic, strong) NSArray *defaultDistanceRange;
@property (nonatomic, assign) double defaultTripLength;

+ (instancetype)modelObjectWithDictionary:(NSDictionary *)dict;
- (instancetype)initWithDictionary:(NSDictionary *)dict;
- (NSDictionary *)dictionaryRepresentation;

@end
