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
    
    [super doJsonApiFetchWithParams:optionsDict mappingDictionary:mappingDict mapToClass:[Route class] mapKeyPath:@"" andCompletionBlock:^(NSArray *responseArray, NSError *error){
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
    }else if (error.code == -1001) {
        return @"Connection to the data provider could not be established. Please try again later.";
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
    
    [super doJsonApiFetchWithParams:optionsDict mappingDictionary:mappingDict mapToClass:[BusStopShort class] mapKeyPath:@"" andCompletionBlock:^(NSArray *responseArray, NSError *error){
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
    
    [super doJsonApiFetchWithParams:optionsDict mappingDictionary:mappingDict mapToClass:[BusStop class] mapKeyPath:@"" andCompletionBlock:^(NSArray *responseArray, NSError *error){
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
            errorString = @"Connection to the data provider could not be established. Please try again later.";
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

#pragma mark - line fetch methods
- (void)fetchLineDetailForSearchterm:(NSString *)searchTerm andOptionsDictionary:(NSDictionary *)optionsDict withcompletionBlock:(ActionBlock)completionBlock{
    if (!optionsDict)
        optionsDict = @{};
    
    [optionsDict setValue:@"lines" forKey:@"request"];
    [optionsDict setValue:@"4326" forKey:@"epsg_in"];
    [optionsDict setValue:@"4326" forKey:@"epsg_out"];
    [optionsDict setValue:@"json" forKey:@"format"];
    [optionsDict setValue:@"1" forKey:@"filter_variants"];
    
    [optionsDict setValue:searchTerm forKey:@"query"];
    
    [super doApiFetchWithOutMappingWithParams:optionsDict andCompletionBlock:^(NSData *responseData, NSError *error){
        if (!error) {
            NSError *localError = nil;
            NSArray *lines = [self lineFromJSON:responseData error:&localError];
            
            if (lines != nil) {
                completionBlock(lines, nil);
            }else{
                completionBlock(nil, @"Fetching lines failed");
            }
        }else{
            completionBlock(nil, [self formattedLineDetailFetchErrorMessageForError:error]);
        }
    }];
}

-(NSString *)formattedLineDetailFetchErrorMessageForError:(NSError *)error{
    NSString *errorString = @"";
    switch (error.code) {
        case -1009:
            errorString = @"Internet connection appears to be offline.";
            break;
        case -1001:
            errorString = @"Connection to the data provider could not be established. Please try again later.";
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

-(NSArray *)lineFromJSON:(NSData *)objectNotation error:(NSError **)error{
    NSError *localError = nil;
    NSArray *parsedObject = [NSJSONSerialization JSONObjectWithData:objectNotation options:0 error:&localError];
    
    if (localError != nil) {
        *error = localError;
        return nil;
    }
    
    NSMutableArray *lines = [[NSMutableArray alloc] init];
    
    for (NSDictionary *lineDict in parsedObject) {
        HSLLine *hslLine = [[HSLLine alloc] initWithDictionary:lineDict];
        
        Line *line = [[Line alloc] initFromHSLLine:hslLine];
        if (line != nil) {
            //Parse dates
            line.parsedDateFrom = line.dateFrom ? [self.dateFormatter dateFromString:line.dateFrom] : nil;
            line.parsedDateTo = line.dateTo ? [self.dateFormatter dateFromString:line.dateTo] : nil;
            [lines addObject:line];
        }
    }
    
    return lines;
}

#pragma mark - geocode fetch methods
- (void)fetchGeocodeWithOptionsDictionary:(NSDictionary *)optionsDict withcompletionBlock:(ActionBlock)completionBlock{
    if (!optionsDict)
        optionsDict = @{};
    
    [optionsDict setValue:@"geocode" forKey:@"request"];
    [optionsDict setValue:@"4326" forKey:@"epsg_in"];
    [optionsDict setValue:@"4326" forKey:@"epsg_out"];
    [optionsDict setValue:@"json" forKey:@"format"];
    
    [super doJsonApiFetchWithParams:optionsDict responseDescriptor:[self responseDescriptorForGeoCode] andCompletionBlock:^(NSArray *responseArray, NSError *error){
        if (!error) {
            if (responseArray && responseArray.count > 0) {
                completionBlock(responseArray, nil);
            }else{
                completionBlock(nil, @"No address was found for the search term");
            }
            
        }else{
            completionBlock(nil, [self formattedGeocodeFetchErrorMessageForError:error]);
        }
    }];
}

-(NSString *)formattedGeocodeFetchErrorMessageForError:(NSError *)error{
    NSString *errorString = @"";
    switch (error.code) {
        case -1009:
            errorString = @"Internet connection appears to be offline.";
            break;
        default:
            errorString = nil;
            break;
    }
    
    return errorString;
}

#pragma mark - Reverse geocode fetch methods
- (void)fetchRevereseGeocodeWithOptionsDictionary:(NSDictionary *)optionsDict withcompletionBlock:(ActionBlock)completionBlock{
    if (!optionsDict)
        optionsDict = @{};
    
    [optionsDict setValue:@"reverse_geocode" forKey:@"request"];
    [optionsDict setValue:@"4326" forKey:@"epsg_in"];
    [optionsDict setValue:@"4326" forKey:@"epsg_out"];
    [optionsDict setValue:@"json" forKey:@"format"];
    
    [super doJsonApiFetchWithParams:optionsDict responseDescriptor:[self responseDescriptorForGeoCode] andCompletionBlock:^(NSArray *responseArray, NSError *error){
        if (!error) {
            if (responseArray && responseArray.count > 0) {
                //Parse details before returning
                completionBlock(responseArray[0], nil);
            }else{
                completionBlock(nil, @"No address was found for the coordinates");
            }
            
        }else{
            completionBlock(nil, [self formattedReverseGeocodeFetchErrorMessageForError:error]);
        }
    }];
}

-(RKResponseDescriptor *)responseDescriptorForGeoCode{
    RKObjectMapping* detailMapping = [RKObjectMapping mappingForClass:[GeoCodeDetail class] ];
    [detailMapping addAttributeMappingsFromDictionary: @{@"address" : @"address",
                                                         @"code" : @"code",
                                                         @"shortCode" : @"shortCode",
                                                         @"lines" : @"lines",
                                                         @"transportTypeId" : @"transport_type_id",
                                                         @"terminalCode" : @"terminal_code",
                                                         @"terminalName" : @"terminal_name",
                                                         @"houseNumber" : @"houseNumber",
                                                         @"poiType" : @"poiType",
                                                         @"shortName" : @"short_name",
                                                         @"platformNumber" : @"platform_number"
                                                         }];
    
    RKObjectMapping* geoCodeMapping = [RKObjectMapping mappingForClass:[GeoCode class] ];
    [geoCodeMapping addAttributeMappingsFromArray:@[ @"locType", @"locTypeId", @"name", @"city", @"matchedName", @"lang", @"coords" ]];
    
    [geoCodeMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"details"
                                                                                   toKeyPath:@"details"
                                                                                 withMapping:detailMapping]];
    
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:geoCodeMapping
                                                                                            method:RKRequestMethodAny
                                                                                       pathPattern:nil
                                                                                           keyPath:@""
                                                                                       statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    return responseDescriptor;
}

-(NSString *)formattedReverseGeocodeFetchErrorMessageForError:(NSError *)error{
    NSString *errorString = @"";
    switch (error.code) {
        case -1009:
            errorString = @"Internet connection appears to be offline.";
            break;
        default:
            errorString = @"No address was found for the coordinates";
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
        [_dateFormatter setDateFormat:@"yyyyMMdd"];
    }
    
    return _dateFormatter;
}

- (NSDateFormatter *)fullDateFormatter{
    if (!_fullDateFormatter) {
        
        _fullDateFormatter = [[NSDateFormatter alloc] init];
        [_fullDateFormatter setDateFormat:@"yyyyMMdd HHmm"];
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

+ (NSString *)lineJoreCodeForCode:(NSString *)code andDirection:(NSString *)direction{
    
    if (!code)
        return nil;
    
    if (!direction || direction.length == 0)
        return code;
    
    return [NSString stringWithFormat:@"%@%@%@%@",
            code,
            code.length < 5 ? @" " : @"",
            code.length < 6 ? @" " : @"",
            direction];
    
}

@end
