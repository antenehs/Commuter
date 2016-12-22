//
//  GraphQLQuery.h
//  Reitti
//
//  Created by Anteneh Sahledengel on 15/5/16.
//  Copyright © 2016 Anteneh Sahledengel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RKObjectMapping.h"

typedef enum {
    GraphQLQueryTypeStop = 0,
    GraphQLQueryTypeStops = 1,
    GraphQLQueryTypeStopsInArea = 2,
    GraphQLQueryTypePlan = 3
} GraphQLQueryType;

@interface GraphQLQuery : NSObject

@property (nonatomic, strong) NSString* query;

+(RKObjectMapping*)requestMapping;

+(NSString *)stopQueryStringWithArguments:(NSDictionary *)arguments;
+(NSString *)stopInAreaQueryStringWithArguments:(NSDictionary *)arguments;
+(NSString *)planQueryStringWithArguments:(NSDictionary *)arguments;

//+(NSString *)queryStringForType:(GraphQLQueryType)type andArguments:(NSDictionary *)arguments;

@end
