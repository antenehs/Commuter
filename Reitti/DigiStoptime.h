//
//  DigiStoptimes.h
//
//  Created by Anteneh Sahledengel on 19/5/16
//  Copyright (c) 2016 shaby ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RestKit/RestKit.h>
#import "DigiTrip.h"

@interface DigiStoptime : NSObject <NSCoding, NSCopying>

@property (nonatomic, strong) NSNumber *serviceDay;
@property (nonatomic, strong) NSNumber *scheduledDeparture;
@property (nonatomic, strong) DigiTrip *trip;
@property (nonatomic, strong) NSNumber *realtime;
@property (nonatomic, strong) NSNumber *realtimeDeparture;
@property (nonatomic, strong) NSString *realtimeState;

//Computed properties
@property (nonatomic, strong) NSDate *parsedScheduledDepartureDate;
@property (nonatomic, strong) NSDate *parsedRealtimeDepartureDate;

+(RKResponseDescriptor *)responseDiscriptorForPath:(NSString *)path;
+(RKObjectMapping *)objectMapping;

+ (instancetype)modelObjectWithDictionary:(NSDictionary *)dict;
- (instancetype)initWithDictionary:(NSDictionary *)dict;
- (NSDictionary *)dictionaryRepresentation;

@end
