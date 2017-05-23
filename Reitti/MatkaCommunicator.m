//
//  MatkaCommunicator.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 9/4/16.
//  Copyright © 2016 Anteneh Sahledengel. All rights reserved.
//

#import "MatkaCommunicator.h"
#import "MatkaStop.h"
#import "ReittiStringFormatter.h"
#import "ReittiAnalyticsManager.h"
#import "ReittiModels.h"
#import "MatkaObjectMapping.h"
#import "ReittiDateHelper.h"
#import "AnnotationFilterOption.h"
#import "DigiTransitCommunicator.h"

@interface MatkaCommunicator()

@end

@implementation MatkaCommunicator

+(instancetype)sharedManager {
    static MatkaCommunicator *sharedInstance = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedInstance = [MatkaCommunicator new];
    });
    
    return sharedInstance;
}

-(id)init{
    self = [super init];
    
    timeTableClient = [[APIClient alloc] init];
    timeTableClient.apiBaseUrl = @"http://api.matka.fi/timetables";
    
    genericClient = [[APIClient alloc] init];
    genericClient.apiBaseUrl = @"http://api.matka.fi";
    
    apiUserNames = @[@"asacommuter"];
    
    return self;
}

- (void)searchRouteForFromCoords:(CLLocationCoordinate2D)fromCoords andToCoords:(CLLocationCoordinate2D)toCoords withOptions:(RouteSearchOptions *)options andCompletionBlock:(ActionBlock)completionBlock {
    
    NSDictionary *optionsDict = [self apiRequestParametersDictionaryForRouteOptions:options];
    
    [optionsDict setValue:[self getApiUsername] forKey:@"user"];
    [optionsDict setValue:@"rebekah" forKey:@"pass"];
    
    AGSPoint *fromPoint = [ReittiStringFormatter convertCoordsToKkj3Point:fromCoords];
    AGSPoint *toPoint = [ReittiStringFormatter convertCoordsToKkj3Point:toCoords];
    if (!fromPoint || !toPoint) return;
    
    [optionsDict setValue:[NSString stringWithFormat:@"%d,%d", (int)fromPoint.x, (int)fromPoint.y] forKey:@"a"];
    [optionsDict setValue:[NSString stringWithFormat:@"%d,%d", (int)toPoint.x, (int)toPoint.y] forKey:@"b"];
    [optionsDict setValue:@"5" forKey:@"show"];
    
    [genericClient doXmlApiFetchWithParams:optionsDict responseDescriptor:[MatkaObjectMapping routeResponseDescriptor] andCompletionBlock:^(NSArray *matkaRoutes, NSError *error) {
        if (!error) {
            NSMutableArray *responseArray = [@[] mutableCopy];
            for (MatkaRoute *route in matkaRoutes) {
                Route *reittiRoute = [Route routeFromMatkaRoute:route];
                if (reittiRoute) [responseArray addObject:reittiRoute];
            }
            
            completionBlock(responseArray, nil);
        } else {
            completionBlock(nil, @"Route search failed."); //TODO: Proper error message
        }
    }];
    
    [[ReittiAnalyticsManager sharedManager] trackApiUseEventForAction:kActionSearchedRouteFromApi label:@"MATKA" value:nil];
}

- (void)fetchStopsInAreaForRegionCenterCoords:(CLLocationCoordinate2D)regionCenter andDiameter:(NSInteger)diameter withCompletionBlock:(ActionBlock)completionBlock {
    NSMutableDictionary *options = [@{} mutableCopy];
    [options setValue:@"stop" forKey:@"m"];
    [options setValue:@"50" forKey:@"count"];
    
    [options setValue:[self getApiUsername] forKey:@"user"];
    [options setValue:@"rebekah" forKey:@"pass"];
    
    AGSPoint *point = [ReittiStringFormatter convertCoordsToKkj3Point:regionCenter];
    if (!point) return;
    
    [options setValue:[NSString stringWithFormat:@"%d", (int)point.x] forKey:@"x"];
    [options setValue:[NSString stringWithFormat:@"%d", (int)point.y] forKey:@"y"];
    
    [options setValue:[NSString stringWithFormat:@"%ld", diameter] forKey:@"radius"];
    
    [timeTableClient doXmlApiFetchWithParams:options responseDescriptor:[MatkaObjectMapping stopResponseDescriptorForPath:@"MATKAXML.XY2STOPS.STOP"] andCompletionBlock:^(NSArray *matkaStops, NSError *error) {
        if (!error) {
            NSMutableArray *responseArray = [@[] mutableCopy];
            for (MatkaStop *stop in matkaStops) {
                BusStopShort *reittiStop = [BusStopShort stopFromMatkaStop:stop];
                if (reittiStop) [responseArray addObject:reittiStop];
            }
            
            completionBlock(responseArray, nil);
        } else {
            completionBlock(nil, @"Error occured"); //TODO: Proper error message
        }
    }];
    
    [[ReittiAnalyticsManager sharedManager] trackApiUseEventForAction:kActionSearchedNearbyStopsFromApi label:@"MATKA" value:nil];
}

- (void)fetchStopDetailForCode:(NSString *)stopCode withCompletionBlock:(ActionBlock)completionBlock {
    NSMutableDictionary *options = [@{} mutableCopy];
    [options setValue:@"stopid" forKey:@"m"];
    [options setValue:@"50" forKey:@"count"];
    
    [options setValue:[self getApiUsername] forKey:@"user"];
    [options setValue:@"rebekah" forKey:@"pass"];
    
    [options setValue:stopCode forKey:@"stopid"];
    
    [timeTableClient doXmlApiFetchWithParams:options responseDescriptor:[MatkaObjectMapping stopResponseDescriptorForPath:@"MATKAXML.STOP2TIMES.STOP"] andCompletionBlock:^(NSArray *matkaStops, NSError *error) {
        if (!error && matkaStops.count > 0) {
            BusStop *stop = [BusStop stopFromMatkaStop:matkaStops[0]];

            completionBlock(stop, nil);
        } else {
            //API seems to fail if there is no departure. Differentiate that with other failures
            completionBlock(nil, nil); //TODO: Proper error message
        }
    }];
    
    [[ReittiAnalyticsManager sharedManager] trackApiUseEventForAction:kActionSearchedStopFromApi label:@"MATKA" value:nil];
}

-(void)fetchRealtimeDeparturesForStopName:(NSString *)name andShortCode:(NSString *)code withCompletionHandler:(ActionBlock)completionBlock {
    //Use name as name in case of HSL region
    [[DigiTransitCommunicator finlandDigiTransitCommunicator] fetchDeparturesForStopName:name withCompletionHandler:completionBlock];
}

- (void)searchGeocodeForSearchTerm:(NSString *)searchTerm withCompletionBlock:(ActionBlock)completionBlock {
    NSMutableDictionary *options = [@{} mutableCopy];
    [options setValue:@"100" forKey:@"count"];
    
    [options setValue:[self getApiUsername] forKey:@"user"];
    [options setValue:@"rebekah" forKey:@"pass"];
    
    [options setValue:searchTerm forKey:@"key"];
    
    [genericClient doXmlApiFetchWithParams:options responseDescriptor:[MatkaObjectMapping geocodeResponseDescriptorForPath:@"MTRXML.GEOCODE.LOC"] andCompletionBlock:^(NSArray *matkaGeocodes, NSError *error) {
        if (!error) {
            NSMutableArray *geocodes = [@[] mutableCopy];
            for (MatkaGeoCode *matkaGeocode in matkaGeocodes)
                [geocodes addObject:[GeoCode geocodeForMatkaGeocode:matkaGeocode]];
            
            completionBlock(geocodes, nil);
        } else {
            completionBlock(nil, @"Error occured"); //TODO: Proper error message
        }
    }];
    
    [[ReittiAnalyticsManager sharedManager] trackApiUseEventForAction:kActionSearchedAddressFromApi label:@"MATKA" value:nil];
}

- (void)searchAddresseForCoordinate:(CLLocationCoordinate2D)coords withCompletionBlock:(ActionBlock)completionBlock {
    NSMutableDictionary *options = [@{} mutableCopy];
    
    [options setValue:[self getApiUsername] forKey:@"user"];
    [options setValue:@"rebekah" forKey:@"pass"];
    
    AGSPoint *point = [ReittiStringFormatter convertCoordsToKkj3Point:coords];
    if (!point) return;
    
    [options setValue:[NSString stringWithFormat:@"%d", (int)point.x] forKey:@"x"];
    [options setValue:[NSString stringWithFormat:@"%d", (int)point.y] forKey:@"y"];
    
    [genericClient doXmlApiFetchWithParams:options responseDescriptor:[MatkaObjectMapping geocodeResponseDescriptorForPath:@"MTRXML.REVERSE.LOC"] andCompletionBlock:^(NSArray *matkaGeocodes, NSError *error) {
        if (!error && matkaGeocodes.count > 0) {
            MatkaGeoCode *geocode = matkaGeocodes[0];
            geocode.xCoord = [NSNumber numberWithInteger:(int)point.x];
            geocode.yCoord = [NSNumber numberWithInteger:(int)point.y];
            completionBlock([GeoCode geocodeForMatkaGeocode:geocode], nil);
        } else {
            completionBlock(nil, @"Error occured"); //TODO: Proper error message
        }
    }];
    
    [[ReittiAnalyticsManager sharedManager] trackApiUseEventForAction:kActionSearchedReverseGeoCodeFromApi label:@"MATKA" value:nil];
}

- (void)fetchLinesForSearchterm:(NSString *)searchTerm withCompletionBlock:(ActionBlock)completionBlock {
    if (!searchTerm || [searchTerm isEqualToString:@""]) return;
    NSMutableDictionary *options = [@{} mutableCopy];
    
    [options setValue:[self getApiUsername] forKey:@"user"];
    [options setValue:@"rebekah" forKey:@"pass"];
    
    [options setValue:@"text" forKey:@"m"];
    [options setValue:searchTerm forKey:@"text"];
    
    [timeTableClient doXmlApiFetchWithParams:options responseDescriptor:[MatkaObjectMapping lineResponseDescriptorForKeyPath:@"MATKAXML.TXT2LINES.LINE" detailed:NO] andCompletionBlock:^(NSArray *matkaLines, NSError *error) {
        if (!error && matkaLines && matkaLines.count > 0) {
            NSMutableArray *lines = [@[] mutableCopy];
            for (MatkaLine *matkaLine in matkaLines) {
                Line *line = [Line lineFromMatkaLine:matkaLine];
                if (line) {
                    [lines addObject:line];
                }
            }
            
            completionBlock(lines, nil);
        } else {
            completionBlock(nil, nil); //TODO: Proper error message
        }
    }];
    
    [[ReittiAnalyticsManager sharedManager] trackApiUseEventForAction:kActionSearchedLineFromApi label:@"MATKA" value:nil];
}

- (void)fetchLinesForCodes:(NSArray *)lineCodes withCompletionBlock:(ActionBlock)completionBlock {
    if (!lineCodes || lineCodes.count == 0) return;
    NSMutableDictionary *options = [@{} mutableCopy];
    
    [options setValue:[self getApiUsername] forKey:@"user"];
    [options setValue:@"rebekah" forKey:@"pass"];
    
    [options setValue:@"lineid" forKey:@"m"];
    
    __block NSInteger numberOfLines = lineCodes.count;
    __block NSMutableArray *allLines = [@[] mutableCopy];
    
    for (NSString *lineid in lineCodes) {
        [options setValue:lineid forKey:@"lineid"];
        [timeTableClient doXmlApiFetchWithParams:options responseDescriptor:[MatkaObjectMapping lineResponseDescriptorForKeyPath:@"MATKAXML.LINE2STOPS" detailed:YES] andCompletionBlock:^(NSArray *matkaLines, NSError *error) {
            numberOfLines--;
            if (!error && matkaLines && matkaLines.count > 0) {
                for (MatkaLine *matkaLine in matkaLines) {
                    Line *line = [Line lineFromMatkaLine:matkaLine];
                    if (line)
                        [allLines addObject:line];
                }
                if (numberOfLines == 0)
                    completionBlock(allLines, nil);
            } else {
                if (numberOfLines == 0)
                    completionBlock(allLines, nil);
            }
        }];
    }
    
    [[ReittiAnalyticsManager sharedManager] trackApiUseEventForAction:kActionSearchedLineFromApi label:@"MATKA" value:nil];
}

-(void)fetchTransportTypesWithCompletionBlock:(ActionBlock)completionBlock {
    NSMutableDictionary *options = [@{} mutableCopy];
    [options setValue:@"ttype" forKey:@"m"];
    
    [options setValue:[self getApiUsername] forKey:@"user"];
    [options setValue:@"rebekah" forKey:@"pass"];
    
    [timeTableClient doXmlApiFetchWithParams:options responseDescriptor:[MatkaObjectMapping matkaTransportTypeResponseDescriptorForPath:@"MATKAXML.TT2TINFO.TRANSPORT"] andCompletionBlock:^(NSArray *transportTypes, NSError *error) {
        if (!error && transportTypes.count > 0) {
            
            completionBlock(transportTypes, nil);
        } else {
            //API seems to fail if there is no departure. Differentiate that with other failures
            completionBlock(nil, error); //TODO: Proper error message
        }
    }];
}

#pragma mark - Route search option

-(NSDictionary *)apiRequestParametersDictionaryForRouteOptions:(RouteSearchOptions *)searchOptions{
    NSMutableDictionary *parametersDict = [@{} mutableCopy];
    
    /* Optimization string */
    NSString *optimizeString;
    if (searchOptions.selectedRouteSearchOptimization == RouteSearchOptionFastest) {
        optimizeString = @"2";
    }else if (searchOptions.selectedRouteSearchOptimization == RouteSearchOptionLeastTransfer) {
        optimizeString = @"3";
    }else if (searchOptions.selectedRouteSearchOptimization == RouteSearchOptionLeastWalking) {
        optimizeString = @"4";
    }else{
        optimizeString = @"1";
    }
    
    [parametersDict setObject:optimizeString forKey:@"optimize"];
    
    /* Search date and time */
    NSDate * searchDate = searchOptions.date;
    if (searchDate == nil)
        searchDate = [NSDate date];
    
    NSString *time = [[[ReittiDateHelper sharedFormatter] apiHourFormatter] stringFromDate:searchDate];
    NSString *date = [[[ReittiDateHelper sharedFormatter] apiDateFormatter] stringFromDate:searchDate];
    
    NSString *timeType;
    if (searchOptions.selectedTimeType == RouteTimeNow || searchOptions.selectedTimeType == RouteTimeDeparture)
        timeType = @"1";
    else
        timeType = @"2";
    
    [parametersDict setObject:time forKey:@"time"];
    [parametersDict setObject:date forKey:@"date"];
    [parametersDict setObject:timeType forKey:@"timemode"];
    
    /* Change Margine */
    if (searchOptions.selectedChangeMargine != nil && ![searchOptions.selectedChangeMargine isEqualToString:@"3 minutes (Default)"]) {
        [parametersDict setObject:[self.changeMargineOptions objectForKey:searchOptions.selectedChangeMargine] forKey:@"margin"];
    }
    
    /* Walking Speed */
    if (searchOptions.selectedWalkingSpeed != nil && ![searchOptions.selectedWalkingSpeed isEqualToString:@"Normal Walking (Default)"]) {
        [parametersDict setObject:[self.walkingSpeedOptions objectForKey:searchOptions.selectedWalkingSpeed] forKey:@"walkspeed"];
    }
    
    if (searchOptions.numberOfResults == kDefaultNumberOfResults) {
        [parametersDict setObject:@"5" forKey:@"show"];
    }else{
        [parametersDict setObject:[NSString stringWithFormat:@"%ld", (long)searchOptions.numberOfResults] forKey:@"show"];
    }
    
    return parametersDict;
}

-(NSArray *)allTrasportTypeNames {
    return @[@"Bus", @"Metro", @"Train", @"Tram", @"Ferry", @"Airplane", @"Uline"];
}

-(NSArray *)getDefaultTransportTypeNames {
    return @[@"Bus", @"Metro", @"Train", @"Tram", @"Ferry", @"Airplane", @"Uline"];
}

-(NSArray *)getTransportTypeOptions {
    return nil;
}

-(NSArray *)getTicketZoneOptions {
    return nil;
}

-(NSArray *)getChangeMargineOptions {
    return @[@{displayTextOptionKey : @"0 minute" , valueOptionKey: @"0"},
             @{displayTextOptionKey : @"1 minute" , valueOptionKey: @"1"},
             @{displayTextOptionKey : @"3 minutes (Default)", valueOptionKey : @"3", defaultOptionKey : @"yes"},
             @{displayTextOptionKey : @"5 minutes", valueOptionKey : @"5"},
             @{displayTextOptionKey : @"7 minutes", valueOptionKey : @"7"},
             @{displayTextOptionKey : @"9 minutes", valueOptionKey : @"9"},
             @{displayTextOptionKey : @"10 minutes", valueOptionKey : @"10"}];
}

-(NSInteger)getDefaultValueIndexForChangeMargineOptions {
    return 2;
}

-(NSArray *)getWalkingSpeedOptions {
    return @[@{displayTextOptionKey : @"Slow Walking", detailOptionKey : @"30 m/minute", valueOptionKey : @"30"},
             @{displayTextOptionKey : @"Normal Walking (Default)" , detailOptionKey : @"70 m/minute", valueOptionKey: @"70", defaultOptionKey : @"yes"},
             @{displayTextOptionKey : @"Fast Walking", detailOptionKey : @"100 m/minute", valueOptionKey : @"100"},
             @{displayTextOptionKey : @"Running", detailOptionKey : @"200 m/minute", valueOptionKey : @"200"},
             @{displayTextOptionKey : @"Bolting", detailOptionKey : @"300 m/minute", valueOptionKey : @"300"}];
}

-(NSInteger)getDefaultValueIndexForWalkingSpeedOptions {
    return 1;
}

-(NSInteger)getDefaultValueIndexForTicketZoneOptions {
    return 0;
}

-(NSDictionary *)changeMargineOptions{
    return @{@"0 minute" : @"0",
             @"1 minute" : @"1",
             @"3 minutes (Default)" : @"3",
             @"5 minutes" : @"5",
             @"7 minutes" : @"7",
             @"9 minutes" : @"9",
             @"10 minutes" : @"10"};
}

-(NSDictionary *)walkingSpeedOptions{
    return @{@"Slow Walking" : @"1",
             @"Normal Walking (Default)" : @"2",
             @"Fast Walking" : @"3",
             @"Running" : @"4",
             @"Bolting" : @"5"};
}

#pragma mark - Annot filter option
-(NSArray *)annotationFilterOptions {
    return @[[AnnotationFilterOption optionForBusStop]];
}

#pragma mark - Helper methods

- (NSString *)getApiUsername{
    return apiUserNames[0];
}

@end
