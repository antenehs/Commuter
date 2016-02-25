//
//  HSLCommunication.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 12/4/15.
//  Copyright (c) 2015 Anteneh Sahledengel. All rights reserved.
//

#import "HSLCommunication.h"
#import "HSLLine.h"
#import "ReittiStringFormatter.h"
#import "AppManager.h"
#import "CacheManager.h"
#import "ReittiAnalyticsManager.h"
#import "ASA_Helpers.h"

@interface HSLCommunication ()

@property (nonatomic, strong) NSDictionary *transportTypeOptions;
@property (nonatomic, strong) NSDictionary *ticketZoneOptions;
@property (nonatomic, strong) NSDictionary *changeMargineOptions;
@property (nonatomic, strong) NSDictionary *walkingSpeedOptions;

@property (nonatomic, strong) APIClient *poikkeusInfoApi;

@end

@implementation HSLCommunication

-(id)init{
    self = [super init];
    super.apiBaseUrl = @"http://api.reittiopas.fi/hsl/1_2_0/";
    
    self.poikkeusInfoApi = [[APIClient alloc] init];
    self.poikkeusInfoApi.apiBaseUrl = @"http://www.poikkeusinfo.fi/xml/v2";
    
    hslApiUserNames = @[@"asacommuterstops", @"asacommuterstops2", @"asacommuterstops3", @"asacommuterstops4", @"asacommuterstops5",                        @"asacommuterstops6", @"asacommuterstops7", @"asacommuterstops8",
                        @"asacommuterroutes", @"asacommuterroutes2", @"asacommuterroutes3", @"asacommuterroutes4", @"asacommuterroutes5", @"asacommuterroutes6", @"asacommuterroutes7", @"asacommuterroutes8",
                        @"asacommuternearby", @"asacommuternearby2", @"asacommuternearby3", @"asacommuternearby4", @"asacommuternearby5", @"asacommuternearby6", @"asacommuternearby7", @"asacommuternearby8",
                        @"asacommutersearch", @"asacommutersearch2", @"asacommutersearch3", @"asacommutersearch4", @"asacommutersearch5", @"asacommutersearch6", @"asacommutersearch7", @"asacommutersearch8",
                        @"asacommuter", @"asacommuter2", @"asacommuter3", @"asacommuter4", @"commuterreversegeo" ];
    
    nextApiUsernameIndex = arc4random_uniform((int)hslApiUserNames.count);
    
    return self;
}

#pragma mark - Route search protocol implementation
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
                            if (!leg.lineCode)
                                continue;

                            leg.lineName = [HSLCommunication parseBusNumFromLineCode:leg.lineCode];
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
    
    [[ReittiAnalyticsManager sharedManager] trackApiUseEventForAction:kActionSearchedRouteFromApi label:@"HSL" value:nil];
}

#pragma mark - Datasource value mapping

-(NSDictionary *)apiRequestParametersDictionaryForRouteOptions:(RouteSearchOptions *)searchOptions{
    NSMutableDictionary *parametersDict = [@{} mutableCopy];
    
    /* Optimization string */
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
    
    /* Ticket Zone */
    if (searchOptions.selectedTicketZone != nil && ![searchOptions.selectedTicketZone isEqualToString:@"All HSL Regions (Default)"]) {
        [parametersDict setObject:[self.ticketZoneOptions objectForKey:searchOptions.selectedTicketZone] forKey:@"zone"];
    }
    
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

-(NSDictionary *)transportTypeOptions{
    if (!_transportTypeOptions) {
        _transportTypeOptions = @{@"Bus" : @"bus",
                                 @"Metro" : @"metro",
                                 @"Train" : @"train",
                                 @"Tram" : @"tram",
                                 @"Ferry" : @"ferry",
                                 @"Uline" : @"uline"};
    }
    
    return _transportTypeOptions;
}

-(NSDictionary *)ticketZoneOptions{
    if (!_ticketZoneOptions) {
        _ticketZoneOptions = @{@"All HSL Regions (Default)" : @"whole",
                               @"Regional" : @"region",
                               @"Helsinki Internal" : @"helsinki",
                               @"Espoo Internal" : @"espoo",
                               @"Vantaa Internal" : @"vantaa"};
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
                                 @"Bolting" : @"500"};
    }
    
    return _walkingSpeedOptions;
}

#pragma mark - Route Search Options
-(NSArray *)allTrasportTypeNames{
    return @[@"Bus", @"Metro", @"Train", @"Tram", @"Ferry", @"Uline"];
}

-(NSArray *)getTransportTypeOptions{
    return @[@{displayTextOptionKey : @"Bus", valueOptionKey : @"bus", pictureOptionKey : [AppManager lightColorImageForLegTransportType:LegTypeBus]},
             @{displayTextOptionKey : @"Metro", valueOptionKey : @"metro", pictureOptionKey : [UIImage imageNamed:@"Subway-100.png"]},
             @{displayTextOptionKey : @"Train", valueOptionKey : @"train", pictureOptionKey : [AppManager lightColorImageForLegTransportType:LegTypeTrain]},
             @{displayTextOptionKey : @"Tram", valueOptionKey : @"tram", pictureOptionKey : [AppManager lightColorImageForLegTransportType:LegTypeTram]},
             @{displayTextOptionKey : @"Ferry", valueOptionKey : @"ferry", pictureOptionKey : [AppManager lightColorImageForLegTransportType:LegTypeFerry]},
             @{displayTextOptionKey : @"Uline", valueOptionKey : @"uline", pictureOptionKey : [AppManager lightColorImageForLegTransportType:LegTypeBus]}];
}

-(NSArray *)getTicketZoneOptions{
    return @[@{displayTextOptionKey : @"All HSL Regions (Default)", valueOptionKey : @"whole", defaultOptionKey : @"yes"},
             @{displayTextOptionKey : @"Regional" , valueOptionKey: @"region"},
             @{displayTextOptionKey : @"Helsinki Internal", valueOptionKey : @"helsinki"},
             @{displayTextOptionKey : @"Espoo Internal", valueOptionKey : @"espoo"},
             @{displayTextOptionKey : @"Vantaa Internal", valueOptionKey : @"vantaa"}];
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
             @{displayTextOptionKey : @"Bolting", detailOptionKey : @"500 m/minute", valueOptionKey : @"500"}];
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
    
    [[ReittiAnalyticsManager sharedManager] trackApiUseEventForAction:kActionSearchedNearbyStopsFromApi label:@"HSL" value:nil];
    
}

#pragma mark - stop detail fetch protocol implementation

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
                
                //Parse lines and departures
                [self parseStopLines:stop];
                [self parseStopDepartures:stop];
                
                completionBlock(stop, nil);
            }
        }else{
            completionBlock(nil, error);
        }
    }];
    
    [[ReittiAnalyticsManager sharedManager] trackApiUseEventForAction:kActionSearchedStopFromApi label:@"HSL" value:nil];
}

#pragma mark - Line detail fetch protocol implementation
-(void)fetchLineForSearchterm:(NSString *)searchTerm withCompletionBlock:(ActionBlock)completionBlock{
    NSMutableDictionary *optionsDict = [@{} mutableCopy];
    
    NSString *username = [self getApiUsername];
    
    [optionsDict setValue:username forKey:@"user"];
    [optionsDict setValue:@"rebekah" forKey:@"pass"];
    
    [super fetchLineDetailForSearchterm:searchTerm andOptionsDictionary:optionsDict withcompletionBlock:completionBlock];
    
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
    
    [[ReittiAnalyticsManager sharedManager] trackApiUseEventForAction:kActionSearchedAddressFromApi label:@"HSL" value:nil];
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

#pragma mark - Disruption fetching
-(void)fetchTrafficDisruptionsWithCompletionBlock:(ActionBlock)completionBlock{
    //TODO: Not so good mapping. Targets could be an array if there are more than one lines affected
    RKObjectMapping* textMapping = [RKObjectMapping mappingForClass:[DisruptionText class] ];
    [textMapping addAttributeMappingsFromDictionary: @{ @"text" : @"text",
                                                        @"lang" : @"language"
                                                        }];
    
    RKObjectMapping* lineMapping = [RKObjectMapping mappingForClass:[DisruptionLine class] ];
    [lineMapping addAttributeMappingsFromDictionary: @{ @"id" : @"lineId",
                                                        @"direction" : @"lineDirection",
                                                        @"linetype" : @"lineType",
                                                        @"text" : @"lineName"
                                                     }];
    
    RKObjectMapping* disruptionMapping = [RKObjectMapping mappingForClass:[Disruption class] ];
    [disruptionMapping addAttributeMappingsFromDictionary:@{
                                                         @"id" : @"disruptionId",
                                                         @"type" : @"disruptionType",
                                                         @"source" : @"disruptionSource",
                                                         @"VALIDITY.from" : @"disruptionStartTime",
                                                         @"VALIDITY.to" : @"disruptionEndTime"
                                                         }];
    
    [disruptionMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"INFO.TEXT"
                                                                                   toKeyPath:@"disruptionTexts"
                                                                                 withMapping:textMapping]];
    
    [disruptionMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"TARGETS.LINE"
                                                                                      toKeyPath:@"disruptionLines"
                                                                                    withMapping:lineMapping]];
    
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:disruptionMapping
                                                                                            method:RKRequestMethodAny
                                                                                       pathPattern:nil
                                                                                           keyPath:@"DISRUPTIONS.DISRUPTION"
                                                                                       statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    [self.poikkeusInfoApi doXmlApiFetchWithParams:nil responseDescriptor:responseDescriptor andCompletionBlock:^(NSArray *disruptions, NSError *error){
        if (!error) {
            for (Disruption *disruption in disruptions) {
                for (DisruptionLine *line in disruption.disruptionLines) {
                    line.lineFullCode = [HSLAndTRECommon lineJoreCodeForCode:line.lineId andDirection:[line.lineDirection stringValue]];
                }
            }
            completionBlock(disruptions, nil);
        }else{
            completionBlock(nil, @"Disruption fetch failed.");
        }
    }];
}


#pragma mark - Helpers
- (NSString *)getRandomUsername{
    int r = arc4random_uniform((int)hslApiUserNames.count);
    
    return hslApiUserNames[r];
}

- (NSString *)getApiUsername{
    
    if (nextApiUsernameIndex < hslApiUserNames.count - 1)
        nextApiUsernameIndex++;
    else
        nextApiUsernameIndex = 0;
    
    return hslApiUserNames[nextApiUsernameIndex];
}

- (void)parseStopLines:(BusStop *)stop {
    //Parse departures and lines
    if (stop.lines) {
        NSMutableArray *stopLinesArray = [@[] mutableCopy];
        for (NSString *lineString in stop.lines) {
            StopLine *line = [StopLine new];
            NSArray *info = [lineString asa_stringsBySplittingOnString:@":"];
            if (info.count >= 2) {
                line.name = info[1];
                line.destination = info[1];
                NSString *lineCode = info[0];
                line.fullCode = lineCode;
                line.code = [HSLCommunication parseBusNumFromLineCode:lineCode];
                
                if (lineCode.length == 7) {
                    line.direction = [lineCode substringWithRange:NSMakeRange(6, 1)];
                }
            }
            
            [stopLinesArray addObject:line];
        }
        
        stop.lines = stopLinesArray;
    }
}

- (void)parseStopDepartures:(BusStop *)stop{
    if (stop.departures && stop.departures.count > 0) {
        NSMutableArray *departuresArray = [@[] mutableCopy];
        for (NSDictionary *dictionary in stop.departures) {
            if (![dictionary isKindOfClass:[NSDictionary class]]) 
                continue;
                
            StopDeparture *departure = [StopDeparture modelObjectWithDictionary:dictionary];
            //Parse line code
            NSString *lineFullCode = departure.code;
            departure.destination = [stop destinationForLineFullCode:lineFullCode];
            
            departure.code = [HSLCommunication parseBusNumFromLineCode:departure.code];
            //Parse dates
            departure.parsedDate = [super dateFromDateString:departure.date andHourString:departure.time];
            if (!departure.parsedDate) {
                //Do it the old school way. Might have a wrong date for after midnight times
                NSString *notFormattedTime = departure.time ;
                NSString *timeString = [ReittiStringFormatter formatHSLAPITimeWithColon:notFormattedTime];
                departure.parsedDate = [ReittiStringFormatter createDateFromString:timeString withMinOffset:0];
            }
            [departuresArray addObject:departure];
        }
        
        stop.departures = departuresArray;
    }
}

//Expected format is XXXX(X) X
//Parsing logic https://github.com/HSLdevcom/navigator-proto/blob/master/src/routing.coffee#L40
//Original logic - http://developer.reittiopas.fi/pages/en/http-get-interface/frequently-asked-questions.php
+(NSString *)parseBusNumFromLineCode:(NSString *)lineCode{
    //TODO: Test with 1230 for weird numbers of the same 24 bus. 
//    NSArray *codes = [lineCode componentsSeparatedByString:@" "];
//    NSString *code = [codes objectAtIndex:0];
    
    //Line codes from HSL live could be only 4 characters
    if (lineCode.length < 4)
        return lineCode;
    
    //Try getting from line cache
    CacheManager *cacheManager = [CacheManager sharedManager];
    
    NSString * lineName = [cacheManager getRouteNameForCode:lineCode];
    
    if (lineName != nil && ![lineName isEqualToString:@""]) {
        return lineName;
    }
    
    //Can be assumed a metro
    if ([lineCode hasPrefix:@"1300"])
        return @"Metro";
    
    //Can be assumed a ferry
    if ([lineCode hasPrefix:@"1019"])
        return @"Ferry";
    
    //Can be assumed a train line
    if (([lineCode hasPrefix:@"3001"] || [lineCode hasPrefix:@"3002"]) && lineCode.length > 4) {
        NSString * trainLineCode = [lineCode substringWithRange:NSMakeRange(4, 1)];
        if (trainLineCode != nil && trainLineCode.length > 0)
            return trainLineCode;
    }
    
    //2-4. character = line code (e.g. 102)
    NSString *codePart = [lineCode substringWithRange:NSMakeRange(1, 3)];
    while ([codePart hasPrefix:@"0"]) {
        codePart = [codePart substringWithRange:NSMakeRange(1, codePart.length - 1)];
    }
    
    if (lineCode.length <= 4)
        return codePart;
    
    //5 character = letter variant (e.g. T)
    NSString *firstLetterVariant = [lineCode substringWithRange:NSMakeRange(4, 1)];
    if ([firstLetterVariant isEqualToString:@" "])
        return codePart;

    if (lineCode.length <= 5)
        return [NSString stringWithFormat:@"%@%@", codePart, firstLetterVariant];
    
    //6 character = letter variant or numeric variant (ignore number variant)
    NSString *secondLetterVariant = [lineCode substringWithRange:NSMakeRange(5, 1)];
    if ([secondLetterVariant isEqualToString:@" "] || [secondLetterVariant intValue])
        return [NSString stringWithFormat:@"%@%@", codePart, firstLetterVariant];
    
    return [NSString stringWithFormat:@"%@%@%@", codePart, firstLetterVariant, secondLetterVariant];
}

#pragma mark - overriden methods
//- (void)StopFetchDidComplete{
//    [delegate hslStopFetchDidComplete:self];
//}
//- (void)StopFetchFailed:(int)errorCode{
//    [self.delegate hslStopFetchFailed:errorCode];
//}
//- (void)StopInAreaFetchDidComplete{
//    [delegate hslStopInAreaFetchDidComplete:self];
//}
//- (void)StopInAreaFetchFailed:(int)errorCode{
//    [self.delegate hslStopInAreaFetchFailed:errorCode];
//}
//- (void)LineInfoFetchDidComplete{
////    [delegate hslLineInfoFetchDidComplete:self];
//}
//- (void)LineInfoFetchFailed{
////    [delegate hslLineInfoFetchFailed:self];
//}
//
//- (void)LineInfoFetchDidComplete:(NSData *)objectNotation{
////    NSError *error = nil;
////    NSArray *lines = [HSLCommunication lineFromJSON:objectNotation error:&error];
////
////    if (lines != nil) {
////        [delegate hslLineInfoFetchDidComplete:lines];
////    }else{
////        [delegate hslLineInfoFetchFailed:error];
////    }
//
//}
//- (void)LineInfoFetchFailed:(NSError *)error{
//    [delegate hslLineInfoFetchFailed:error];
//}
//
//- (void)GeocodeSearchDidComplete{
//    [delegate hslGeocodeSearchDidComplete:self];
//}
//- (void)GeocodeSearchFailed:(int)errorCode{
//    [self.delegate hslGeocodeSearchFailed:errorCode];
//}
//- (void)ReverseGeocodeSearchDidComplete{
//    [self.delegate hslReverseGeocodeSearchDidComplete:self];
//}
//- (void)ReverseGeocodeSearchFailed:(int)errorCode{
//    [self.delegate hslReverseGeocodeSearchFailed:errorCode];
//}
//- (void)RouteSearchDidComplete{
//    [delegate hslRouteSearchDidComplete:self];
//}
//- (void)RouteSearchFailed:(int)errorCode{
//    [self.delegate hslRouteSearchFailed:errorCode];
//}
//- (void)DisruptionFetchComplete{
//    [delegate hslDisruptionFetchComplete:self];
//}
//- (void)DisruptionFetchFailed:(int)errorCode{
//    [self.delegate hslDisruptionFetchFailed:errorCode];
//}

#pragma mark - Helper methods


@end
