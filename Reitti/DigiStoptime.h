//
//  DigiStoptimes.h
//
//  Created by Anteneh Sahledengel on 19/5/16
//  Copyright (c) 2016 shaby ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import "DigiTrip.h"
#import "Mapping.h"
#import "StopDeparture.h"

@interface DigiStoptime : NSObject <NSCoding, NSCopying, Mappable>

-(StopDeparture *)reittiStopDeparture;

@property (nonatomic, strong) NSNumber *serviceDay;
@property (nonatomic, strong) NSNumber *scheduledDeparture;
@property (nonatomic, strong) NSNumber *realtimeDeparture;
@property (nonatomic, strong) NSNumber *scheduledArrival;
@property (nonatomic, strong) NSNumber *realtimeArrival;
@property (nonatomic, strong) NSString *realtimeState;
@property (nonatomic, strong) NSNumber *realtime;
@property (nonatomic, strong) NSString *routeLongName;
@property (nonatomic, strong) NSString *routeShortName;
@property (nonatomic, strong) NSString *destination;
@property (nonatomic, strong) NSString *stopName;
@property (nonatomic, strong) NSString *stopGtfsId;

//Computed properties
@property (nonatomic, strong) NSDate *parsedScheduledDepartureDate;
@property (nonatomic, strong) NSDate *parsedRealtimeDepartureDate;
@property (nonatomic, strong) NSDate *parsedScheduledArrivalDate;
@property (nonatomic, strong) NSDate *parsedRealtimeArrivalDate;

+ (instancetype)modelObjectWithDictionary:(NSDictionary *)dict;
- (instancetype)initWithDictionary:(NSDictionary *)dict;
- (NSDictionary *)dictionaryRepresentation;

@end
