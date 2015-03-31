//
//  RouteSearchOptions.h
//  Reitti
//
//  Created by Anteneh Sahledengel on 29/3/15.
//  Copyright (c) 2015 Anteneh Sahledengel. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum
{
    SelectedTimeNow = 0,
    SelectedTimeDeparture = 1,
    SelectedTimeArrival = 2
} SelectedTimeType;

typedef enum
{
    RouteSearchOptionFastest = 0,
    RouteSearchOptionLeastTransfer = 1,
    RouteSearchOptionLeastWalking = 2
} RouteSearchOption;

@interface RouteSearchOptions : NSObject

@property(nonatomic,strong) NSDate *date;
@property(nonatomic)SelectedTimeType selectedTimeType;
@property(nonatomic)RouteSearchOption routeSearchOption;

@end
