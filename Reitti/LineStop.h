//
//  LineStops.h
//
//  Created by Anteneh Sahledengel on 18/6/15
//  Copyright (c) 2015 shaby ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifndef APPLE_WATCH
#import "MatkaStop.h"
#endif

@interface LineStop : NSObject <NSCoding, NSCopying>

@property (nonatomic, strong) NSString *coords;
@property (nonatomic, strong) NSString *address;
@property (nonatomic, strong) NSNumber *time;
@property (nonatomic, strong) NSString *code;
@property (nonatomic, strong) NSString *gtfsId;
@property (nonatomic, strong) NSString *codeShort;
@property (nonatomic, strong) NSString *platformNumber;
@property (nonatomic, strong) NSString *cityName;
@property (nonatomic, strong) NSString *name;

+ (instancetype)modelObjectWithDictionary:(NSDictionary *)dict;
- (instancetype)initWithDictionary:(NSDictionary *)dict;
- (NSDictionary *)dictionaryRepresentation;

#ifndef APPLE_WATCH
+ (id)lineStopFromMatkaLineStop:(MatkaStop *)matkaStop;
#endif


@end
