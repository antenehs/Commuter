//
//  RouteEntity.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 16/9/14.
//  Copyright (c) 2014 Anteneh Sahledengel. All rights reserved.
//

#import "RouteEntity.h"


@implementation RouteEntity

@dynamic routeUniqueName;
@dynamic fromLocationName;
@dynamic fromLocationCoordsString;
@dynamic toLocationName;
@dynamic toLocationCoordsString;
@dynamic isHistory;

-(BOOL)isHistoryRoute {
    return self.isHistory ? [self.isHistory boolValue] : YES;
}

+(NSString *)uniqueRouteNameFor:(NSString *)fromLoc andToLoc:(NSString *)toLoc {
    return [NSString stringWithFormat:@"%@ - %@",fromLoc, toLoc];
}

@end
