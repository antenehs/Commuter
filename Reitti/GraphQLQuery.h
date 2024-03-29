//
//  GraphQLQuery.h
//  Reitti
//
//  Created by Anteneh Sahledengel on 15/5/16.
//  Copyright © 2016 Anteneh Sahledengel. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifndef APPLE_WATCH
#import "RKObjectMapping.h"
#endif

typedef enum {
    GraphQLQueryTypeStop = 0,
    GraphQLQueryTypeStops = 1,
    GraphQLQueryTypeStopsShort = 2,
    GraphQLQueryTypeStopsInArea = 3,
    GraphQLQueryTypePlan = 4,
    GraphQLQueryTypeRoute = 5,
    GraphQLQueryTypeRouteShort = 6,
    GraphQLQueryTypeBikeStation = 7,
    GraphQLQueryTypeAlert = 8,
    GraphQLQueryTypePattern = 9,
    GraphQLQueryTypePatternShort = 10,
    GraphQLQueryTypeStopTime = 11,
} GraphQLQueryType;

@interface GraphQLQuery : NSObject

@property (nonatomic, strong) NSString* query;

#ifndef APPLE_WATCH
+(RKObjectMapping*)requestMapping;
#endif

+(NSDictionary *)requestMappingDictionary;

+(NSString *)stopQueryStringWithArguments:(NSDictionary *)arguments;
+(NSString *)stopInAreaQueryStringWithArguments:(NSDictionary *)arguments;
+(NSString *)planQueryStringWithArguments:(NSDictionary *)arguments;
+(NSString *)routeQueryStringWithArguments:(NSDictionary *)arguments;
+(NSString *)shortRouteQueryStringWithArguments:(NSDictionary *)arguments;
+(NSString *)bikeStationsQueryString;
+(NSString *)alertsQueryString;

//+(NSString *)queryStringForType:(GraphQLQueryType)type andArguments:(NSDictionary *)arguments;

@end
