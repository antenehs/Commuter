//
//  HSLAndTRECommon.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 7/12/15.
//  Copyright © 2015 Anteneh Sahledengel. All rights reserved.
//

#import "HSLAndTRECommon.h"
#import "ReittiStringFormatter.h"

@interface HSLAndTRECommon ()

@end

@implementation HSLAndTRECommon

-(void)searchRouteForFromCoords:(CLLocationCoordinate2D)fromCoords andToCoords:(CLLocationCoordinate2D)toCoords withOptionsDictionary:(NSDictionary *)optionsDict andCompletionBlock:(ActionBlock)completionBlock{
    
    [optionsDict setValue:@"route" forKey:@"request"];
    [optionsDict setValue:@"4326" forKey:@"epsg_in"];
    [optionsDict setValue:@"4326" forKey:@"epsg_out"];
    [optionsDict setValue:@"json" forKey:@"format"];
    
    [optionsDict setValue:[ReittiStringFormatter convert2DCoordToString:fromCoords] forKey:@"from"];
    [optionsDict setValue:[ReittiStringFormatter convert2DCoordToString:toCoords] forKey:@"to"];
    
    NSDictionary *mappingDict = @{
                                  @"length" : @"unMappedRouteLength",
                                  @"duration" : @"unMappedRouteDurationInSeconds",
                                  @"legs" : @"unMappedRouteLegs"
                                  };
    
    [super doApiFetchWithParams:optionsDict mappingDictionary:mappingDict mapToClass:[Route class] andCompletionBlock:^(NSArray *responseArray, NSError *error){
        if (!error) {
            for (Route *route in responseArray) {
                route.routeLegs = [self mapRouteLegsFromArray:route.unMappedRouteLegs];
                NSLog(@"route length is %@", route.routeLength);
                route.routeLength = [route.unMappedRouteLength objectAtIndex:0];
                route.routeDurationInSeconds = [route.unMappedRouteDurationInSeconds objectAtIndex:0];
            }
            
            completionBlock(responseArray, nil);
        }else{
            completionBlock(nil, [self formattedRouteSearchErrorMessageForError:error]);
        }
    }];
}

-(NSString *)formattedRouteSearchErrorMessageForError:(NSError *)error{
    if (error.code == -1009) {
        return @"Internet connection appears to be offline.";
    }else if (error.code == -1016) {
        return @"No route information available for the selected addresses.";
    }else{
        return @"Unknown Error Occured.";
    }
}

-(NSArray *)mapRouteLegsFromArray:(NSArray *)arrayResponse{
    NSMutableArray *legsArray = [[NSMutableArray alloc] init];
    int legOrder = 0;
    for (NSDictionary *legDict in [arrayResponse objectAtIndex:0]) {
        //NSLog(@"a dictionary %@",legDict);
        RouteLeg *leg = [[RouteLeg alloc] initFromDictionary:legDict];
        leg.legOrder = legOrder;
        [legsArray addObject:leg];
        legOrder++;
    }
    
    return legsArray;
}

#pragma mark - stop in area fetch method

- (void)fetchStopsInAreaForRegionCenterCoords:(CLLocationCoordinate2D)regionCenter andDiameter:(NSInteger)diameter withOptionsDictionary:(NSDictionary *)optionsDict withCompletionBlock:(ActionBlock)completionBlock{
    
    if (!optionsDict) 
        optionsDict = @{};
    
    [optionsDict setValue:@"stops_area" forKey:@"request"];
    [optionsDict setValue:@"4326" forKey:@"epsg_in"];
    [optionsDict setValue:@"4326" forKey:@"epsg_out"];
    [optionsDict setValue:@"json" forKey:@"format"];
    [optionsDict setValue:@"60" forKey:@"limit"];
    
    [optionsDict setValue:[ReittiStringFormatter convert2DCoordToString:regionCenter] forKey:@"center_coordinate"];
    [optionsDict setValue:[NSString stringWithFormat:@"%ld", diameter] forKey:@"diameter"];
    
    NSDictionary *mappingDict = @{
                                  @"code" : @"code",
                                  @"codeShort" : @"codeShort",
                                  @"name" : @"name",
                                  @"city" : @"city",
                                  @"coords" : @"coords",
                                  @"address" : @"address",
                                  @"dist" : @"distance"
                                  };
    
    [super doApiFetchWithParams:optionsDict mappingDictionary:mappingDict mapToClass:[BusStopShort class] andCompletionBlock:^(NSArray *responseArray, NSError *error){
        if (!error) {
            completionBlock(responseArray, nil);
        }else{
            completionBlock(nil, [self formattedNearbyStopSearchErrorMessageForError:error]);
        }
    }];
}

-(NSString *)formattedNearbyStopSearchErrorMessageForError:(NSError *)error{
    NSString *errorString = @"";
    switch (error.code) {
        case -1009:
            errorString = @"Internet connection appears to be offline.";
            break;
        case -1011:
            errorString = @"Nearby stops service not available in this area.";
            break;
        case -1001:
            errorString = @"Request timed out.";
            break;
        case -1016:
            errorString = @"No stops information available for the selected region.";
            break;
        default:
            errorString = @"Unknown Error Occured.";
            break;
    }
    
    return errorString;
}


#pragma mark - Stop fetch method

- (void)fetchStopDetailForCode:(NSString *)stopCode  andOptionsDictionary:(NSDictionary *)optionsDict withCompletionBlock:(ActionBlock)completionBlock{
    if (!optionsDict)
        optionsDict = @{};
    
    [optionsDict setValue:@"stop" forKey:@"request"];
    [optionsDict setValue:@"4326" forKey:@"epsg_in"];
    [optionsDict setValue:@"4326" forKey:@"epsg_out"];
    [optionsDict setValue:@"json" forKey:@"format"];
    [optionsDict setValue:@"20" forKey:@"dep_limit"];
    [optionsDict setValue:@"360" forKey:@"time_limit"];
    
    [optionsDict setValue:stopCode forKey:@"code"];
    
    NSDictionary *mappingDict = @{
                                  @"code" : @"code",
                                  @"code_short" : @"code_short",
                                  @"name_fi" : @"name_fi",
                                  @"name_sv" : @"name_sv",
                                  @"city_fi" : @"city_fi",
                                  @"city_sv" : @"city_sv",
                                  @"lines" : @"lines",
                                  @"coords" : @"coords",
                                  @"wgs_coords" : @"wgs_coords",
                                  @"accessibility" : @"accessibility",
                                  @"departures" : @"departures",
                                  @"timetable_link" : @"timetable_link",
                                  @"omatlahdot_link" : @"omatlahdot_link",
                                  @"address_fi" : @"address_fi",
                                  @"address_sv" : @"address_sv"
                                  };
    
    [super doApiFetchWithParams:optionsDict mappingDictionary:mappingDict mapToClass:[BusStop class] andCompletionBlock:^(NSArray *responseArray, NSError *error){
        if (!error) {
            completionBlock(responseArray, nil);
        }else{
            completionBlock(nil, [self formattedStopDetailFetchErrorMessageForError:error]);
        }
    }];
}

-(NSString *)formattedStopDetailFetchErrorMessageForError:(NSError *)error{
    NSString *errorString = @"";
    switch (error.code) {
        case -1009:
            errorString = @"Internet connection appears to be offline.";
            break;
        case -1001:
            errorString = @"Request timed out.";
            break;
        case -1016:
            errorString = @"The remote server returned nothing. Try again.";
            break;
        default:
            errorString = @"Unknown Error Occured. Please try again.";
            break;
    }
    
    return errorString;
}

#pragma mark - Date formatters
- (NSDateFormatter *)hourFormatter{
    if (!_hourFormatter) {
        _hourFormatter = [[NSDateFormatter alloc] init];
        [_hourFormatter setDateFormat:@"HHmm"];
    }
    
    return _hourFormatter;
}

- (NSDateFormatter *)dateFormatter{
    if (!_dateFormatter) {
        
        _dateFormatter = [[NSDateFormatter alloc] init];
        [_dateFormatter setDateFormat:@"YYYYMMdd"];
    }
    
    return _dateFormatter;
}

- (NSDateFormatter *)fullDateFormatter{
    if (!_fullDateFormatter) {
        
        _fullDateFormatter = [[NSDateFormatter alloc] init];
        [_fullDateFormatter setDateFormat:@"YYYYMMdd HHmm"];
    }
    
    return _fullDateFormatter;
}

#pragma mark - helpers
/**
 Expected format @"YYYYMMdd" and @"HHmm"
 */
- (NSDate *)dateFromDateString:(NSString *)dateString andHourString:(NSString *)hourString{
    @try {
        NSString *notFormattedTime = hourString;
        NSString *timeString = [ReittiStringFormatter formatHSLAPITimeWithColon:notFormattedTime];

        BOOL istommorrow = NO;
    
        NSArray *comp = [timeString componentsSeparatedByString:@":"];
        int hourVal = [[comp objectAtIndex:0] intValue];
        
        //The api time could be greater than 24( like 2643 )
        if (hourVal > 23) {
            timeString = [NSString stringWithFormat:@"0%d%@", hourVal - 24, [comp objectAtIndex:1] ];
            istommorrow = YES;
        }else{
            timeString = [NSString stringWithFormat:@"%d%@", hourVal, [comp objectAtIndex:1] ];
        }
        
        if (timeString.length == 3)
            timeString = [NSString stringWithFormat:@"0%@", timeString];
        
        NSString *fullDateString = [NSString stringWithFormat:@"%@ %@", dateString, timeString];
        NSDate *parsedDate = [self.fullDateFormatter dateFromString:fullDateString];
        
        NSTimeInterval seconds;
        if (istommorrow) {
            seconds = (24 * 60 * 60);
            parsedDate = [parsedDate dateByAddingTimeInterval:seconds];
        }
        
        return parsedDate;
    }
    @catch (NSException *exception) {
        return nil;
    }
}

/**
 Expected format @"HHmm"
 */
- (NSString *)readableHoursFromApiHours:(NSString *)apiHours{
    return nil;
}

@end
