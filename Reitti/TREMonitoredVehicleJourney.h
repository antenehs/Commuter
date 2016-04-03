//
//  TREMonitoredVehicleJourney.h
//
//  Created by Anteneh Sahledengel on 3/4/16
//  Copyright (c) 2016 shaby ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TREFramedVehicleJourneyRef, TREVehicleLocation;

@interface TREMonitoredVehicleJourney : NSObject <NSCoding, NSCopying>

@property (nonatomic, strong) NSString *speed;
@property (nonatomic, strong) NSString *destinationShortName;
@property (nonatomic, strong) NSString *bearing;
@property (nonatomic, strong) NSString *vehicleRef;
@property (nonatomic, strong) NSString *delay;
@property (nonatomic, strong) NSString *lineRef;
@property (nonatomic, strong) TREFramedVehicleJourneyRef *framedVehicleJourneyRef;
@property (nonatomic, strong) TREVehicleLocation *vehicleLocation;
@property (nonatomic, strong) NSString *originShortName;
@property (nonatomic, strong) NSString *journeyPatternRef;
@property (nonatomic, strong) NSString *directionRef;
@property (nonatomic, strong) NSArray *onwardCalls;
@property (nonatomic, strong) NSString *operatorRef;
@property (nonatomic, strong) NSString *originAimedDepartureTime;

+ (instancetype)modelObjectWithDictionary:(NSDictionary *)dict;
- (instancetype)initWithDictionary:(NSDictionary *)dict;
- (NSDictionary *)dictionaryRepresentation;

@end
