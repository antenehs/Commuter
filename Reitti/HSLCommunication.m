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
#import "HSLRouteOptionManager.h"
#import "EnumManager.h"
#import "BikeStation.h"
#import "DigiTransitCommunicator.h"
#import "DigiDataModels.h"
#import "AnnotationFilterOption.h"
#import "SettingsManager.h"
#import "ReittiModels.h"

@interface HSLCommunication ()

@property (nonatomic, strong) NSDictionary *transportTypeOptions;
@property (nonatomic, strong) NSDictionary *ticketZoneOptions;
@property (nonatomic, strong) NSDictionary *changeMargineOptions;
@property (nonatomic, strong) NSDictionary *walkingSpeedOptions;

@property (nonatomic, strong) APIClient *poikkeusInfoApi;
@property (nonatomic, strong) APIClient *bikeStationApi;

@property (nonatomic, strong) DigiTransitCommunicator *digiInterface;

@property (nonatomic) ActionBlock bikeFetchingCompletionHandler;
@property (nonatomic, strong)NSTimer *bikeFetchUpdateTimer;

@end

@implementation HSLCommunication

-(id)init{
    self = [super init];
    super.apiBaseUrl = @"http://api.reittiopas.fi/hsl/1_2_0/";
    
    self.poikkeusInfoApi = [[APIClient alloc] init];
    self.poikkeusInfoApi.apiBaseUrl = @"http://www.poikkeusinfo.fi/xml/v2";
    
    self.bikeStationApi = [[APIClient alloc] init];
    self.bikeStationApi.apiBaseUrl = @"http://api.digitransit.fi/routing/v1/routers/hsl/bike_rental";
    
    self.digiInterface = [DigiTransitCommunicator hslDigiTransitCommunicator];
    
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
    //![options.selectedRouteTrasportTypes containsObject:@"City Bike"]
    if (![SettingsManager useDigiTransit]) {
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
    } else {
        [self.digiInterface searchRouteForFromCoords:fromCoords andToCoords:toCoords withOptions:options andCompletionBlock:^(NSArray *digiRoutes, NSString *errorString) {
            
            if (!errorString && digiRoutes && digiRoutes.count > 0) {
                NSMutableArray *allRoutes = [@[] mutableCopy];
                for (DigiPlan *plan in digiRoutes) {
                    Route *route = [Route routeFromDigiPlan:plan];
                    if (route) {
                        [allRoutes addObject:route];
                    }
                }
                completionBlock(allRoutes, nil);
            } else {
                completionBlock(nil, @"Route search failed.");
            }
        }];
    }
    
    [[ReittiAnalyticsManager sharedManager] trackApiUseEventForAction:kActionSearchedRouteFromApi label:@"HSL" value:nil];
}

#pragma mark - Datasource value mapping

-(NSDictionary *)apiRequestParametersDictionaryForRouteOptions:(RouteSearchOptions *)searchOptions{
    NSMutableDictionary *parametersDict = [[[HSLRouteOptionManager sharedManager] apiRequestParametersDictionaryForRouteOptions:[searchOptions dictionaryRepresentation]] mutableCopy];
    /* Options for all search */
    [parametersDict setObject:@"full" forKey:@"detail"];
    
    return parametersDict;
}

-(NSDictionary *)transportTypeOptions{
    return [HSLRouteOptionManager transportTypeOptions];
}

-(NSDictionary *)ticketZoneOptions{
    return [HSLRouteOptionManager ticketZoneOptions];
}

-(NSDictionary *)changeMargineOptions{
    return [HSLRouteOptionManager changeMargineOptions];
}

-(NSDictionary *)walkingSpeedOptions{
    return [HSLRouteOptionManager walkingSpeedOptions];
}

#pragma mark - Route Search Options
-(NSArray *)allTrasportTypeNames{
    return [HSLRouteOptionManager allTrasportTypeNames];
}

-(NSArray *)getTransportTypeOptions{
    return [HSLRouteOptionManager getTransportTypeOptionsForDisplay];
}

-(NSArray *)getTicketZoneOptions{
    return [HSLRouteOptionManager getTicketZoneOptionsForDisplay];
}

-(NSInteger)getDefaultValueIndexForTicketZoneOptions{
//    return 0;
    return [HSLRouteOptionManager getDefaultValueIndexForTicketZoneOptions];
}

-(NSArray *)getChangeMargineOptions{
    return [HSLRouteOptionManager getChangeMargineOptionsForDisplay];
}

-(NSInteger)getDefaultValueIndexForChangeMargineOptions{
//    return 2;
    return [HSLRouteOptionManager getDefaultValueIndexForChangeMargineOptions];
}

-(NSArray *)getWalkingSpeedOptions{
    return [HSLRouteOptionManager getWalkingSpeedOptionsForDisplay];
}

-(NSInteger)getDefaultValueIndexForWalkingSpeedOptions{
//    return 1;
    return [HSLRouteOptionManager getDefaultValueIndexForWalkingSpeedOptions];
}

#pragma mark - Stops in areas search protocol implementation
- (void)fetchStopsInAreaForRegionCenterCoords:(CLLocationCoordinate2D)regionCenter andDiameter:(NSInteger)diameter withCompletionBlock:(ActionBlock)completionBlock{
    
    if ([SettingsManager useDigiTransit]) {
        [[DigiTransitCommunicator hslDigiTransitCommunicator] fetchStopsInAreaForRegionCenterCoords:regionCenter andDiameter:diameter withCompletionBlock:completionBlock];
    } else {
        NSMutableDictionary *optionsDict = [@{} mutableCopy];
        
        NSString *username = [self getApiUsername];
        
        [optionsDict setValue:username forKey:@"user"];
        [optionsDict setValue:@"rebekah" forKey:@"pass"];
        
        [super fetchStopsInAreaForRegionCenterCoords:regionCenter andDiameter:diameter withOptionsDictionary:optionsDict withCompletionBlock:completionBlock];
    }
    
    [[ReittiAnalyticsManager sharedManager] trackApiUseEventForAction:kActionSearchedNearbyStopsFromApi label:@"HSL" value:nil];
    
}

#pragma mark - stop detail fetch protocol implementation

- (void)fetchStopDetailForCode:(NSString *)stopCode withCompletionBlock:(ActionBlock)completionBlock{
    
    if ([SettingsManager useDigiTransit]) {
        [[DigiTransitCommunicator hslDigiTransitCommunicator] fetchStopDetailForCode:stopCode withCompletionBlock:completionBlock];
    } else {
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
    }
    
    [[ReittiAnalyticsManager sharedManager] trackApiUseEventForAction:kActionSearchedStopFromApi label:@"HSL" value:nil];
}

-(void)fetchRealtimeDeparturesForStopName:(NSString *)name andShortCode:(NSString *)code withCompletionHandler:(ActionBlock)completionBlock {
    //Use code as name in case of HSL region
    [[DigiTransitCommunicator hslDigiTransitCommunicator] fetchDeparturesForStopName:code withCompletionHandler:completionBlock];
}

#pragma mark - Line detail fetch protocol implementation
- (void)fetchLinesForSearchterm:(NSString *)searchTerm withCompletionBlock:(ActionBlock)completionBlock {
    NSMutableDictionary *optionsDict = [@{} mutableCopy];
    
    NSString *username = [self getApiUsername];
    
    [optionsDict setValue:username forKey:@"user"];
    [optionsDict setValue:@"rebekah" forKey:@"pass"];
    
    [super fetchLineDetailForSearchterm:searchTerm andOptionsDictionary:optionsDict withcompletionBlock:completionBlock];
    
    [[ReittiAnalyticsManager sharedManager] trackApiUseEventForAction:kActionSearchedLineFromApi label:@"HSL" value:nil];
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
                    line.parsedLineType = [EnumManager lineTypeForHSLLineTypeId:[line.lineType stringValue]];
                }
            }
            completionBlock(disruptions, nil);
        }else{
            completionBlock(nil, @"Disruption fetch failed.");
        }
    }];
}

#pragma mark - Bike station fetch
-(void)startFetchBikeStationsWithCompletionHandler:(ActionBlock)completion {
    [self fetchBikeStationsWithCompletionHandler:completion];
    self.bikeFetchingCompletionHandler = completion;
    self.bikeFetchUpdateTimer = [NSTimer scheduledTimerWithTimeInterval:30 target:self selector:@selector(updateBikeStations) userInfo:nil repeats:YES];
}

-(void)fetchBikeStationsWithCompletionHandler:(ActionBlock)completion {
    [self.bikeStationApi doXmlApiFetchWithParams:nil responseDescriptor:[BikeStation xmlApiResponseDiscriptorForPath:@"stations"] andCompletionBlock:^(NSArray *responseArray, NSError *error) {
        completion(responseArray, [self formattedBikeStationFetchErrorMessageForError:error]);
    }];
}

-(void)updateBikeStations {
    if (self.bikeFetchingCompletionHandler) {
        [self fetchBikeStationsWithCompletionHandler:self.bikeFetchingCompletionHandler];
    }
}

-(void)stopFetchingBikeStations {
    [self.bikeFetchUpdateTimer invalidate];
}

-(NSString *)formattedBikeStationFetchErrorMessageForError:(NSError *)error{
    if(!error) return nil;
    if (error.code == -1009) {
        return @"Internet connection appears to be offline.";
    }else if (error.code == -1001) {
        return @"Connection to the data provider could not be established. Please try again later.";
    }else{
        return @"Unknown Error Occured.";
    }
}

#pragma mark - annotation filter
-(NSArray *)annotationFilterOptions {
    return @[[AnnotationFilterOption optionForBusStop],
             [AnnotationFilterOption optionForTramStop],
             [AnnotationFilterOption optionForTrainStop],
             [AnnotationFilterOption optionForMetroStop],
             [AnnotationFilterOption optionForBikeStation]];
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
            line.lineType = [EnumManager lineTypeForStopType:stop.stopType];
            line.lineEnd = line.destination;
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
            departure.parsedScheduledDate = [super dateFromDateString:departure.date andHourString:departure.time];
            if (!departure.parsedScheduledDate) {
                //Do it the old school way. Might have a wrong date for after midnight times
                NSString *notFormattedTime = departure.time ;
                NSString *timeString = [ReittiStringFormatter formatHSLAPITimeWithColon:notFormattedTime];
                departure.parsedScheduledDate = [[ReittiDateHelper sharedFormatter] createDateFromString:timeString withMinOffset:0];
                departure.isRealTime = NO;
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

@end
