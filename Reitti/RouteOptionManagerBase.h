//
//  RouteOptionManagerBase.h
//  Reitti
//
//  Created by Anteneh Sahledengel on 27/8/16.
//  Copyright © 2016 Anteneh Sahledengel. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    RouteTimeNow = 0,
    RouteTimeDeparture = 1,
    RouteTimeArrival = 2
} RouteTimeType;

typedef enum {
    RouteSearchOptionFastest = 0,
    RouteSearchOptionLeastTransfer = 1,
    RouteSearchOptionLeastWalking = 2
} RouteSearchOptimization;

extern NSString * kSelectedRouteSearchOptimizationKey;
extern NSString * kRouteSearchDateKey;
extern NSString * kSelectedRouteTimeTypeKey;
extern NSString * kSelectedRouteTrasportTypesKey;
extern NSString * kSelectedTicketZoneKey;
extern NSString * kSelectedChangeMargineKey;
extern NSString * kSelectedWalkingSpeedKey;
extern NSString * kNumberOfRouteResultsKey;

extern NSString * displayTextOptionKey;
extern NSString * detailOptionKey;
extern NSString * valueOptionKey;
extern NSString * pictureOptionKey;
extern NSString * defaultOptionKey;

extern NSInteger kDefaultNumberOfResults;

@interface RouteOptionManagerBase : NSObject

+(NSString *)commaSepStringFromArray:(NSArray *)array withSeparator:(NSString *)separator;

@property (nonatomic, strong) NSDateFormatter *hourFormatter;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@property (nonatomic, strong) NSDateFormatter *fullDateFormatter;

@end
