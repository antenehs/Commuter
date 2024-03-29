//
//  Departures.h
//
//  Created by Anteneh Sahledengel on 18/12/15
//  Copyright (c) 2015 shaby ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface StopDeparture : NSObject <NSCoding, NSCopying>

@property (nonatomic, strong) NSString *lineGtfsId;
@property (nonatomic, strong) NSString *code;
@property (nonatomic, strong) NSString *date;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *time;
@property (nonatomic, strong) NSDate *parsedScheduledDate;
@property (nonatomic, strong) NSDate *parsedRealtimeDate;

@property (nonatomic, strong, readonly) NSDate *departureTime;

@property (nonatomic) BOOL isRealTime;
@property (nonatomic, strong) NSString *direction;

@property (nonatomic, strong) NSString *destination;

+ (instancetype)modelObjectWithDictionary:(NSDictionary *)dict;
- (instancetype)initWithDictionary:(NSDictionary *)dict;
- (NSDictionary *)dictionaryRepresentation;

@end
