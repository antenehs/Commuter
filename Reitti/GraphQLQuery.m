//
//  GraphQLQuery.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 15/5/16.
//  Copyright © 2016 Anteneh Sahledengel. All rights reserved.
//

#import "GraphQLQuery.h"
#import "ReittiStringFormatter.h"

@implementation GraphQLQuery
@synthesize query;

+(RKObjectMapping*)requestMapping   {
    
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[GraphQLQuery class]];
    
    [mapping addAttributeMappingsFromDictionary:@{
                                                  @"query":   @"query",
                                                  }];
    return mapping;
    
}

+(NSString *)stopQueryStringWithArguments:(NSDictionary *)arguments {
    NSString *queryWithArgumentes = [GraphQLQuery queryStringForType:GraphQLQueryTypeStops andArguments:arguments];
    NSString *stopFragment = [GraphQLQuery fullStopFragment];
    
    return [queryWithArgumentes stringByReplacingOccurrencesOfString:@"[*STOP_FRAGMENT*]" withString:stopFragment];
}

+(NSString *)stopInAreaQueryStringWithArguments:(NSDictionary *)arguments {
    NSString *queryWithArgumentes = [GraphQLQuery queryStringForType:GraphQLQueryTypeStopsInArea andArguments:arguments];
    NSString *stopFragment = [GraphQLQuery fullStopFragment];
    
    return [queryWithArgumentes stringByReplacingOccurrencesOfString:@"[*STOP_FRAGMENT*]" withString:stopFragment];
}

+(NSString *)shortStopFragment {
    NSString *stopFragment = [GraphQLQuery contentsOfGraphQlFileNamed:[GraphQLQuery queryFragmentTemplateFileNameForType:GraphQLQueryTypeStops]];
    
    return stopFragment;
}

+(NSString *)fullStopFragment {
    NSString *stopFragment = [GraphQLQuery contentsOfGraphQlFileNamed:[GraphQLQuery queryFragmentTemplateFileNameForType:GraphQLQueryTypeStops]];
    
    NSString *shortRouteFragment = [GraphQLQuery contentsOfGraphQlFileNamed:[GraphQLQuery queryFragmentTemplateFileNameForType:GraphQLQueryTypeRouteShort]];
    
    stopFragment = [stopFragment stringByReplacingOccurrencesOfString:@"[*SHORT_ROUTE_FRAGMENT*]" withString:shortRouteFragment];
    
    return stopFragment;
}


+(NSString *)planQueryStringWithArguments:(NSDictionary *)arguments {
    NSString *queryWithArgumentes = [GraphQLQuery queryStringForType:GraphQLQueryTypePlan andArguments:arguments];
    NSString *planFragment = [GraphQLQuery contentsOfGraphQlFileNamed:[GraphQLQuery queryFragmentTemplateFileNameForType:GraphQLQueryTypePlan]];
    
    return [queryWithArgumentes stringByReplacingOccurrencesOfString:@"[*PLAN_FRAGMENT*]" withString:planFragment];
}


+(NSString *)routeQueryStringWithArguments:(NSDictionary *)arguments {
    NSString *queryWithArgumentes = [GraphQLQuery queryStringForType:GraphQLQueryTypeRoute andArguments:arguments];
    NSString *routeFragment = [GraphQLQuery contentsOfGraphQlFileNamed:[GraphQLQuery queryFragmentTemplateFileNameForType:GraphQLQueryTypeRoute]];
    
    return [queryWithArgumentes stringByReplacingOccurrencesOfString:@"[*ROUTE_FRAGMENT*]" withString:routeFragment];
}

+(NSString *)shortRouteQueryStringWithArguments:(NSDictionary *)arguments {
    NSString *queryWithArgumentes = [GraphQLQuery queryStringForType:GraphQLQueryTypeRoute andArguments:arguments];
    NSString *routeFragment = [GraphQLQuery contentsOfGraphQlFileNamed:[GraphQLQuery queryFragmentTemplateFileNameForType:GraphQLQueryTypeRouteShort]];
    
    return [queryWithArgumentes stringByReplacingOccurrencesOfString:@"[*ROUTE_FRAGMENT*]" withString:routeFragment];
}

#pragma mark - Bikes graphql
+(NSString *)bikeStationsQueryString {
    NSString *queryString = [GraphQLQuery queryStringForType:GraphQLQueryTypeBikeStation andArguments:nil];
    NSString *stopFragment = [GraphQLQuery bikeStationFragment];
    
    return [queryString stringByReplacingOccurrencesOfString:@"[*BIKES_FRAGMENT*]" withString:stopFragment];
}

+(NSString *)bikeStationFragment {
    NSString *stopFragment = [GraphQLQuery contentsOfGraphQlFileNamed:[GraphQLQuery queryFragmentTemplateFileNameForType:GraphQLQueryTypeBikeStation]];
    
    return stopFragment;
}

#pragma mark - Helpers

+(NSString *)queryStringForType:(GraphQLQueryType)type andArguments:(NSDictionary *)arguments {
    NSString *templateQuery = [GraphQLQuery contentsOfGraphQlFileNamed:[GraphQLQuery queryTemplateFileNameForType:type]];
    
    if (arguments) {
        NSString *argumentsString = [GraphQLQuery formatArgumentsFromDictionary:arguments];
        
        return [templateQuery stringByReplacingOccurrencesOfString:@"[*ARGUMENTS*]" withString:argumentsString];
    } else {
        return templateQuery;
    }
    
}

+(NSString *)queryTemplateFileNameForType:(GraphQLQueryType)type {
    switch (type) {
        case GraphQLQueryTypeStop:
            return @"StopQuery";
        case GraphQLQueryTypeStops:
            return @"StopsQuery";
        case GraphQLQueryTypeStopsShort:
            return @"StopsQuery";
        case GraphQLQueryTypeStopsInArea:
            return @"StopsInAreaQuery";
        case GraphQLQueryTypePlan:
            return @"PlanQuery";
        case GraphQLQueryTypeRoute:
            return @"RouteQuery";
        case GraphQLQueryTypeRouteShort:
            return @"RouteQuery";
        case GraphQLQueryTypeBikeStation:
            return @"BikesQuery";
        default:
            return nil;
    }
}

+(NSString *)queryFragmentTemplateFileNameForType:(GraphQLQueryType)type {
    switch (type) {
        case GraphQLQueryTypeStop:
            return @"StopQueryFragment";
        case GraphQLQueryTypeStops:
            return @"StopsQueryFragment";
        case GraphQLQueryTypeStopsShort:
            return @"StopsQueryShortFragment";
        case GraphQLQueryTypeStopsInArea:
            return @"StopsInAreaQueryFragment";
        case GraphQLQueryTypePlan:
            return @"PlanQueryFragment";
        case GraphQLQueryTypeRoute:
            return @"RouteQueryFullFragment";
        case GraphQLQueryTypeRouteShort:
            return @"RouteQueryShortFragment";
        case GraphQLQueryTypeBikeStation:
            return @"BikesQueryFragment";
        default:
            return nil;
    }
}

#pragma mark - Helpers
+(NSString *)formatArgumentsFromDictionary:(NSDictionary *)dictionary {
    NSString *arguments = @"";
    
    NSArray *allKeys = dictionary.allKeys;
    for (int i=0; i<allKeys.count; i++) {
        NSString *key = allKeys[i];
        id value = dictionary[key];
        NSString *stringValue = @"";
        
          stringValue = [self argumentStringValue:value];
        
        arguments = [NSString stringWithFormat:@"%@ %@ : %@%@", arguments, key, stringValue, i == allKeys.count-1 ? @"" : @","];
    }
    
    return arguments;
}

+ (NSString *)argumentStringValue:(id)value {
    NSString *stringValue=@"";
    
    if ([value isKindOfClass:[NSDictionary class]]) {
        stringValue = [NSString stringWithFormat:@"{ %@ }", [GraphQLQuery formatArgumentsFromDictionary:value]];
    } else if ([value isKindOfClass:[NSArray class]]) {
        NSMutableArray *stringValues = [@[] mutableCopy];
        for (id val in value) {
            [stringValues addObject:[GraphQLQuery argumentStringValue:val]];
        }
        stringValue = [NSString stringWithFormat:@"[ %@ ]", [ReittiStringFormatter commaSepStringFromArray:stringValues withSeparator:nil]];
    } else if ([value isKindOfClass:[NSString class]]) {
        stringValue = [NSString stringWithFormat:@"\"%@\"", value];
    } else if ([value isKindOfClass:[NSNumber class]]) {
        if (strcmp([(NSNumber *)value objCType], [@(YES) objCType]) == 0 || strcmp([(NSNumber *)value objCType], [@(NO) objCType]) == 0) {
            stringValue = [value boolValue] ? @"true" : @"false";
        } else if (strcmp([value objCType], @encode(int)) == 0) {
            stringValue = [NSString stringWithFormat:@"%d", [value intValue]];
        } else if (strcmp([value objCType], @encode(double)) == 0) {
            stringValue = [NSString stringWithFormat:@"%f", [value doubleValue]];
        } else {
            stringValue = [(NSNumber *)value stringValue];
        }
    }
    
    return stringValue;
}

+(NSString *)contentsOfGraphQlFileNamed:(NSString *)fileName {
    NSString *path = [[NSBundle mainBundle] pathForResource:fileName ofType:@"graphql"];
    return [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
}

@end
