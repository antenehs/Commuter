//
//  TRECommunication.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 12/4/15.
//  Copyright (c) 2015 Anteneh Sahledengel. All rights reserved.
//

#import "TRECommunication.h"
#import "ReittiStringFormatter.h"
#import "AppManager.h"
#import "ReittiAnalyticsManager.h"
#import "ASA_Helpers.h"
#import "AnnotationFilterOption.h"
#import "DigiTransitCommunicator.h"
#import "ReittiModels.h"

@interface TRECommunication ()

@property (nonatomic, strong) NSDictionary *transportTypeOptions;
@property (nonatomic, strong) NSDictionary *ticketZoneOptions;
@property (nonatomic, strong) NSDictionary *changeMargineOptions;
@property (nonatomic, strong) NSDictionary *walkingSpeedOptions;

@end

@implementation TRECommunication

//@synthesize delegate;

-(id)init{
    self = [super init];
    super.apiBaseUrl = @"http://api.publictransport.tampere.fi/1_0_3/";
    
    treApiUserNames = @[@"asacommuterstops", @"asacommuterstops2", @"asacommuterstops3", @"asacommuterstops4",
                        @"asacommuterroutes", @"asacommuterroutes2", @"asacommuterroutes3", @"asacommuterroutes4",
                        @"asacommuternearby", @"asacommuternearby2", @"asacommuternearby3", @"asacommuternearby4",
                        @"commuterreversegeo", @"asareitti"];
    
    nextApiUsernameIndex = arc4random_uniform((int)treApiUserNames.count);
    
    return self;
}

-(void)searchRouteForFromCoords:(CLLocationCoordinate2D)fromCoords andToCoords:(CLLocationCoordinate2D)toCoords withOptions:(RouteSearchOptions *)options andCompletionBlock:(ActionBlock)completionBlock{
    
    NSDictionary *optionsDict = [self apiRequestParametersDictionaryForRouteOptions:options];
    
    NSString *username = [self getApiUsername];
    
    [optionsDict setValue:username forKey:@"user"];
    [optionsDict setValue:@"rebekah" forKey:@"pass"];
    
    [super searchRouteForFromCoords:fromCoords andToCoords:toCoords withOptionsDictionary:optionsDict andCompletionBlock:^(NSArray *routeArray, NSError *error){
        if (!error) {
            @try {
                for (Route *route in routeArray) {
                    for (RouteLeg *leg in route.routeLegs) {
                        @try {
                            leg.lineName = [TRECommunication parseBusNumFromLineCode:leg.lineCode];
                        }
                        @catch (NSException *exception) {
                            leg.lineName = leg.lineCode;
                        }
                    }
                }
            }
            @catch (NSException *exception) {}
        }
        
        completionBlock(routeArray, error);
    }];
    
    [[ReittiAnalyticsManager sharedManager] trackApiUseEventForAction:kActionSearchedRouteFromApi label:@"TRE" value:nil];
}

#pragma mark - Datasource value mapping

-(NSDictionary *)apiRequestParametersDictionaryForRouteOptions:(RouteSearchOptions *)searchOptions{
    NSMutableDictionary *parametersDict = [@{} mutableCopy];
    
    /* Optimization string */
    //TODO: Consider adding the default option as well
    NSString *optimizeString;
    if (searchOptions.selectedRouteSearchOptimization == RouteSearchOptionFastest) {
        optimizeString = @"fastest";
    }else if (searchOptions.selectedRouteSearchOptimization == RouteSearchOptionLeastTransfer) {
        optimizeString = @"least_transfers";
    }else if (searchOptions.selectedRouteSearchOptimization == RouteSearchOptionLeastWalking) {
        optimizeString = @"least_walking";
    }else{
        optimizeString = @"default";
    }
    
    [parametersDict setObject:optimizeString forKey:@"optimize"];
    
    /* Search date and time */
    NSDate * searchDate = searchOptions.date;
    if (searchDate == nil)
        searchDate = [NSDate date];
    
    NSString *time = [self.hourFormatter stringFromDate:searchDate];
    NSString *date = [self.dateFormatter stringFromDate:searchDate];
    
    NSString *timeType;
    if (searchOptions.selectedTimeType == RouteTimeNow || searchOptions.selectedTimeType == RouteTimeDeparture)
        timeType = @"departure";
    else
        timeType = @"arrival";
    
    [parametersDict setObject:time forKey:@"time"];
    [parametersDict setObject:date forKey:@"date"];
    [parametersDict setObject:timeType forKey:@"timetype"];
    
    /* Transport type */
    //TODO: Make sure this option is not shown since it is always bus
    /*
    if (searchOptions.selectedRouteTrasportTypes != nil) {
        NSString *transportTypes;
        if (searchOptions.selectedRouteTrasportTypes.count == self.transportTypeOptions.allKeys.count)
            transportTypes = @"all";
        else if (searchOptions.selectedRouteTrasportTypes.count == 0)
            transportTypes = @"walk";
        else {
            NSMutableArray *selected = [@[] mutableCopy];
            for (NSString *trans in searchOptions.selectedRouteTrasportTypes) {
                [selected addObject:[self.transportTypeOptions objectForKey:trans]];
            }
            transportTypes = [ReittiStringFormatter commaSepStringFromArray:selected withSeparator:@"|"];
        }
        
        [parametersDict setObject:transportTypes forKey:@"transport_types"];
    }
    */
    
    /* Ticket Zone */
    //TODO: Make sure this option is not shown since it is always tampere
    /*
    if (searchOptions.selectedTicketZone != nil && ![searchOptions.selectedTicketZone isEqualToString:@"All HSL Regions (Default)"]) {
        [parametersDict setObject:[self.ticketZoneOptions objectForKey:searchOptions.selectedTicketZone] forKey:@"zone"];
    }
    */
    
    /* Change Margine */
    if (searchOptions.selectedChangeMargine != nil && ![searchOptions.selectedChangeMargine isEqualToString:@"3 minutes (Default)"]) {
        [parametersDict setObject:[self.changeMargineOptions objectForKey:searchOptions.selectedChangeMargine] forKey:@"change_margin"];
    }
    
    /* Walking Speed */
    if (searchOptions.selectedWalkingSpeed != nil && ![searchOptions.selectedWalkingSpeed isEqualToString:@"Normal Walking (Default)"]) {
        [parametersDict setObject:[self.walkingSpeedOptions objectForKey:searchOptions.selectedWalkingSpeed] forKey:@"walk_speed"];
    }
    
    if (searchOptions.numberOfResults == kDefaultNumberOfResults) {
        [parametersDict setObject:@"5" forKey:@"show"];
    }else{
        [parametersDict setObject:[NSString stringWithFormat:@"%ld", (long)searchOptions.numberOfResults] forKey:@"show"];
    }
    
    /* Options for all search */
    [parametersDict setObject:@"full" forKey:@"detail"];
    
    return parametersDict;
}

//Could be hidden since there is only one option
-(NSDictionary *)transportTypeOptions{
    if (!_transportTypeOptions) {
        _transportTypeOptions = @{@"Bus" : @"bus"};
    }
    
    return _transportTypeOptions;
}

//Could be hidden since there is only one option
-(NSDictionary *)ticketZoneOptions{
    if (!_ticketZoneOptions) {
        _ticketZoneOptions = @{@"Tampere (Default)" : @"tampere"};
    }
    
    return _ticketZoneOptions;
}

-(NSDictionary *)changeMargineOptions{
    if (!_changeMargineOptions) {
        _changeMargineOptions = @{@"0 minute" : @"0",
                                  @"1 minute" : @"1",
                                  @"3 minutes (Default)" : @"3",
                                  @"5 minutes" : @"5",
                                  @"7 minutes" : @"7",
                                  @"9 minutes" : @"9",
                                  @"10 minutes" : @"10"};
    }
    
    return _changeMargineOptions;
}

-(NSDictionary *)walkingSpeedOptions{
    if (!_walkingSpeedOptions) {
        _walkingSpeedOptions = @{@"Slow Walking" : @"20",
                                 @"Normal Walking (Default)" : @"70",
                                 @"Fast Walking" : @"150",
                                 @"Running" : @"250",
                                 @"Fast Running" : @"350",
                                 @"Bolting" : @"499"};
    }
    
    return _walkingSpeedOptions;
}

#pragma mark - Route Search Options
-(NSArray *)allTrasportTypeNames{
    return @[@"Bus"];
}

-(NSArray *)getDefaultTransportTypeNames {
    return @[@"Bus"];
}

-(NSArray *)getTransportTypeOptions{
    return nil;
}

-(NSArray *)getTicketZoneOptions{
    return nil;
}

-(NSInteger)getDefaultValueIndexForTicketZoneOptions{
    return 0;
}

-(NSArray *)getChangeMargineOptions{
    return @[@{displayTextOptionKey : @"0 minute" , valueOptionKey: @"0"},
             @{displayTextOptionKey : @"1 minute" , valueOptionKey: @"1"},
             @{displayTextOptionKey : @"3 minutes (Default)", valueOptionKey : @"3", defaultOptionKey : @"yes"},
             @{displayTextOptionKey : @"5 minutes", valueOptionKey : @"5"},
             @{displayTextOptionKey : @"7 minutes", valueOptionKey : @"7"},
             @{displayTextOptionKey : @"9 minutes", valueOptionKey : @"9"},
             @{displayTextOptionKey : @"10 minutes", valueOptionKey : @"10"}];
}

-(NSInteger)getDefaultValueIndexForChangeMargineOptions{
    return 2;
}

-(NSArray *)getWalkingSpeedOptions{
    return @[@{displayTextOptionKey : @"Slow Walking", detailOptionKey : @"20 m/minute", valueOptionKey : @"20"},
             @{displayTextOptionKey : @"Normal Walking (Default)" , detailOptionKey : @"70 m/minute", valueOptionKey: @"70", defaultOptionKey : @"yes"},
             @{displayTextOptionKey : @"Fast Walking", detailOptionKey : @"150 m/minute", valueOptionKey : @"150"},
             @{displayTextOptionKey : @"Running", detailOptionKey : @"250 m/minute", valueOptionKey : @"250"},
             @{displayTextOptionKey : @"Fast Running", detailOptionKey : @"350 m/minute", valueOptionKey : @"350"},
             @{displayTextOptionKey : @"Bolting", detailOptionKey : @"500 m/minute", valueOptionKey : @"499"}];
}

-(NSInteger)getDefaultValueIndexForWalkingSpeedOptions{
    return 1;
}

#pragma mark - Stops in areas search protocol implementation
- (void)fetchStopsInAreaForRegionCenterCoords:(CLLocationCoordinate2D)regionCenter andDiameter:(NSInteger)diameter withCompletionBlock:(ActionBlock)completionBlock{
    NSMutableDictionary *optionsDict = [@{} mutableCopy];
    
    NSString *username = [self getApiUsername];
    
    [optionsDict setValue:username forKey:@"user"];
    [optionsDict setValue:@"rebekah" forKey:@"pass"];
    
    [super fetchStopsInAreaForRegionCenterCoords:regionCenter andDiameter:diameter withOptionsDictionary:optionsDict withCompletionBlock:completionBlock];
    
    [[ReittiAnalyticsManager sharedManager] trackApiUseEventForAction:kActionSearchedNearbyStopsFromApi label:@"TRE" value:nil];
}

#pragma mark - Stop fetch method

- (void)fetchStopDetailForCode:(NSString *)stopCode withCompletionBlock:(ActionBlock)completionBlock{
    NSMutableDictionary *optionsDict = [@{} mutableCopy];
    
    NSString *username = [self getApiUsername];
    
    [optionsDict setValue:username forKey:@"user"];
    [optionsDict setValue:@"rebekah" forKey:@"pass"];
    
    [super fetchStopDetailForCode:stopCode andOptionsDictionary:optionsDict withCompletionBlock:^(NSArray *fetchResult, NSString *error){
        if (!error) {
            if (fetchResult.count > 0) {
                //Assuming the stop code was unique and there is only one result
                BusStop *stop = fetchResult[0];
                //Handlind a TRE API bug that returns incorrect coordinate format even if epsg_out is specified as 4326
                stop.coords = stop.wgsCoords;
                
                //Parse lines and departures
                [self parseStopLines:stop];
                [self parseStopDepartures:stop];
                
                completionBlock(stop, nil);
            }
        }else{
            completionBlock(nil, error);
        }
    }];
    
    [[ReittiAnalyticsManager sharedManager] trackApiUseEventForAction:kActionSearchedStopFromApi label:@"TRE" value:nil];
}

-(void)fetchRealtimeDeparturesForStopName:(NSString *)name andShortCode:(NSString *)code withCompletionHandler:(ActionBlock)completionBlock {
    //Use name as name in case of HSL region
    [[DigiTransitCommunicator finlandDigiTransitCommunicator] fetchDeparturesForStopName:name withCompletionHandler:completionBlock];
}

#pragma mark - Line detail fetch protocol implementation
-(void)fetchLinesForSearchterm:(NSString *)searchTerm withCompletionBlock:(ActionBlock)completionBlock{
    NSMutableDictionary *optionsDict = [@{} mutableCopy];
    
    NSString *username = [self getApiUsername];
    
    [optionsDict setValue:username forKey:@"user"];
    [optionsDict setValue:@"rebekah" forKey:@"pass"];
    
    [super fetchLineDetailForSearchterm:searchTerm andOptionsDictionary:optionsDict withcompletionBlock:completionBlock];
    
    [[ReittiAnalyticsManager sharedManager] trackApiUseEventForAction:kActionSearchedLineFromApi label:@"TRE" value:nil];
}

- (void)fetchLinesForCodes:(NSArray *)lineCodes withCompletionBlock:(ActionBlock)completionBlock {
    if (!lineCodes || lineCodes.count < 1) return;
    NSString *codes = [ReittiStringFormatter commaSepStringFromArray:lineCodes withSeparator:@"|"];
    
    NSMutableDictionary *optionsDict = [@{} mutableCopy];
    
    NSString *username = [self getApiUsername];
    
    [optionsDict setValue:username forKey:@"user"];
    [optionsDict setValue:@"rebekah" forKey:@"pass"];
    
    [super fetchLineDetailForSearchterm:codes andOptionsDictionary:optionsDict withcompletionBlock:completionBlock];
    
    [[ReittiAnalyticsManager sharedManager] trackApiUseEventForAction:kActionSearchedLineFromApi label:@"HSL" value:nil];
}

#pragma mark - Geocode search protocol implementation
-(void)searchGeocodeForSearchTerm:(NSString *)searchTerm withCompletionBlock:(ActionBlock)completionBlock{
    NSMutableDictionary *optionsDict = [@{} mutableCopy];
    
    NSString *username = [self getApiUsername];
    
    [optionsDict setValue:username forKey:@"user"];
    [optionsDict setValue:@"rebekah" forKey:@"pass"];
    
    [optionsDict setValue:searchTerm forKey:@"key"];
    
    [super fetchGeocodeWithOptionsDictionary:optionsDict withcompletionBlock:completionBlock];
    
    [[ReittiAnalyticsManager sharedManager] trackApiUseEventForAction:kActionSearchedAddressFromApi label:@"TRE" value:nil];
}

#pragma mark - Reverse geocode fetch protocol implementation
-(void)searchAddresseForCoordinate:(CLLocationCoordinate2D)coords withCompletionBlock:(ActionBlock)completionBlock{
    NSMutableDictionary *optionsDict = [@{} mutableCopy];
    
    NSString *username = [self getApiUsername];
    
    [optionsDict setValue:username forKey:@"user"];
    [optionsDict setValue:@"rebekah" forKey:@"pass"];
    
    NSString *coordStrings = [NSString stringWithFormat:@"%f,%f", coords.longitude, coords.latitude];
    [optionsDict setValue:coordStrings forKey:@"coordinate"];
    
    [super fetchRevereseGeocodeWithOptionsDictionary:optionsDict withcompletionBlock:completionBlock];
    
    [[ReittiAnalyticsManager sharedManager] trackApiUseEventForAction:kActionSearchedReverseGeoCodeFromApi label:@"HSL" value:nil];
}

#pragma mark - Annot filter option
-(NSArray *)annotationFilterOptions {
    return @[[AnnotationFilterOption optionForBusStop]];
}

#pragma mark - helpers
- (NSString *)getRandomUsername{
    int r = arc4random_uniform((int)treApiUserNames.count);
    
    return treApiUserNames[r];
}

- (NSString *)getApiUsername{
    
    if (nextApiUsernameIndex < treApiUserNames.count - 1)
        nextApiUsernameIndex++;
    else
        nextApiUsernameIndex = 0;
    
    return treApiUserNames[nextApiUsernameIndex];
}

- (void)parseStopLines:(BusStop *)stop {
    if (stop.lines) {
        //Expected line format - 11 1:Sarankulma - Korvenkatu 44 (code direction:destination)
        NSMutableArray *stopLinesArray = [@[] mutableCopy];
        for (NSString *lineString in stop.lines) {
            StopLine *line = [StopLine new];
            NSArray *info = [lineString componentsSeparatedByString:@":"];
            if (info.count == 2) {
                line.name = info[1];
                line.destination = info[1];
                NSString *lineCode = info[0];
                line.fullCode = lineCode;
                
                NSArray *lineComps = [lineCode componentsSeparatedByString:@" "];
                line.code = [TRECommunication parseBusNumFromLineCode:lineComps[0]];
                if (lineComps.count > 1) {
//                    line.direction = [lineComps lastObject];
                }
            }
            line.lineType = [EnumManager lineTypeForStopType:stop.stopType];
            line.lineEnd = line.destination;
            [stopLinesArray addObject:line];
        }
        
        stop.lines = stopLinesArray;
    }
}

- (void)parseStopDepartures:(BusStop *)stop {
    if (stop.departures && stop.departures.count > 0) {
        NSMutableArray *departuresArray = [@[] mutableCopy];
        for (NSDictionary *dictionary in stop.departures) {
            if (![dictionary isKindOfClass:[NSDictionary class]])
                continue;
            
            StopDeparture *departure = [StopDeparture modelObjectWithDictionary:dictionary];
            if ([dictionary objectForKey:@"name1"])
                departure.name = [dictionary objectForKey:@"name1"];
            departure.destination = departure.name;
            //Parse line code
            departure.code = [TRECommunication parseBusNumFromLineCode:departure.code];
            //Parse dates
            departure.parsedScheduledDate = [super dateFromDateString:departure.date andHourString:departure.time];
            if (!departure.parsedScheduledDate) {
                //Do it the old school way. Might have a wrong date for after midnight times
                NSString *notFormattedTime = departure.time ;
                NSString *timeString = [ReittiStringFormatter formatHSLAPITimeWithColon:notFormattedTime];
                departure.parsedScheduledDate = [[ReittiDateHelper sharedFormatter] createDateFromString:timeString withMinOffset:0];
            }
            [departuresArray addObject:departure];
        }
        
        stop.departures = departuresArray;
    }
}

+(NSString *)parseBusNumFromLineCode:(NSString *)lineCode{
    //TODO: Test with 1230 for weird numbers of the same 24 bus.
    NSArray *codes = [lineCode componentsSeparatedByString:@" "];
    NSString *code = [codes firstObject];
    
    return code;
}

#pragma mark - overriden methods
//- (void)StopFetchDidComplete{
//    [delegate treStopFetchDidComplete:self];
//}
//- (void)StopFetchFailed:(int)errorCode{
//    [self.delegate treStopFetchFailed:errorCode];
//}
//- (void)StopInAreaFetchDidComplete{
//    [delegate treStopInAreaFetchDidComplete:self];
//}
//- (void)StopInAreaFetchFailed:(int)errorCode{
//    [self.delegate treStopInAreaFetchFailed:errorCode];
//}
//- (void)LineInfoFetchDidComplete{
//    [delegate treLineInfoFetchDidComplete:self];
//}
//- (void)LineInfoFetchFailed{
//    [delegate treLineInfoFetchFailed:self];
//}
//- (void)GeocodeSearchDidComplete{
//    [delegate treGeocodeSearchDidComplete:self];
//}
//- (void)GeocodeSearchFailed:(int)errorCode{
//    [self.delegate treGeocodeSearchFailed:errorCode];
//}
//- (void)ReverseGeocodeSearchDidComplete{
//    [self.delegate treReverseGeocodeSearchDidComplete:self];
//}
//- (void)ReverseGeocodeSearchFailed:(int)errorCode{
//    [self.delegate treReverseGeocodeSearchFailed:errorCode];
//}
//- (void)RouteSearchDidComplete{
//    [delegate treRouteSearchDidComplete:self];
//}
//- (void)RouteSearchFailed:(int)errorCode{
//    [self.delegate treRouteSearchFailed:errorCode];
//}
//- (void)DisruptionFetchComplete{
//    [delegate treDisruptionFetchComplete:self];
//}
//- (void)DisruptionFetchFailed:(int)errorCode{
//    [self.delegate treDisruptionFetchFailed:errorCode];
//}

@end
