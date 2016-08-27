//
//  RouteOptionManagerBase.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 27/8/16.
//  Copyright © 2016 Anteneh Sahledengel. All rights reserved.
//

#import "RouteOptionManagerBase.h"

NSString * kSelectedRouteSearchOptimizationKey = @"selectedRouteSearchOptimization";
NSString * kRouteSearchDateKey = @"date";
NSString * kSelectedRouteTimeTypeKey = @"selectedTimeType";
NSString * kSelectedRouteTrasportTypesKey = @"selectedRouteTrasportTypes";
NSString * kSelectedTicketZoneKey = @"selectedTicketZone";
NSString * kSelectedChangeMargineKey = @"selectedChangeMargine";
NSString * kSelectedWalkingSpeedKey = @"selectedWalkingSpeed";
NSString * kNumberOfRouteResultsKey = @"numberOfResults";

NSString * displayTextOptionKey = @"displayText";
NSString * detailOptionKey = @"detail";
NSString * valueOptionKey = @"value";
NSString * pictureOptionKey = @"picture";
NSString * defaultOptionKey = @"default";

NSInteger kDefaultNumberOfResults = 5;

@implementation RouteOptionManagerBase

#pragma mark - Date formatters
- (NSDateFormatter *)hourFormatter{
    if (!_hourFormatter) {
        _hourFormatter = [[NSDateFormatter alloc] init];
        [_hourFormatter setDateFormat:@"HHmm"];
        [_hourFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"fi_FI"]];
    }
    
    return _hourFormatter;
}

- (NSDateFormatter *)dateFormatter{
    if (!_dateFormatter) {
        
        _dateFormatter = [[NSDateFormatter alloc] init];
        [_dateFormatter setDateFormat:@"yyyyMMdd"];
        [_dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"fi_FI"]];
    }
    
    return _dateFormatter;
}

- (NSDateFormatter *)fullDateFormatter{
    if (!_fullDateFormatter) {
        
        _fullDateFormatter = [[NSDateFormatter alloc] init];
        [_fullDateFormatter setDateFormat:@"yyyyMMdd HHmm"];
        [_fullDateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"fi_FI"]];
    }
    
    return _fullDateFormatter;
}

#pragma mark - Helpers
+(NSString *)commaSepStringFromArray:(NSArray *)array withSeparator:(NSString *)separator{
    NSMutableArray *tempArray = [[NSMutableArray alloc] init];
    if (array != nil && ![[array firstObject] isKindOfClass:[NSString class]]) {
        return nil;
    }
    
    for (NSString *line in array) {
        if (![tempArray containsObject:line]) {
            [tempArray addObject:line];
        }
    }
    
    separator = separator != nil ? separator : @",";
    
    if (tempArray.count > 0) {
        return [[tempArray valueForKey:@"description"] componentsJoinedByString:separator];
    }else{
        return @"";
    }
}

@end
