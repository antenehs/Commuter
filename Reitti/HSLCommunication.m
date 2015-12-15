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

@interface HSLCommunication ()

@property (nonatomic, strong) NSDictionary *transportTypeOptions;
@property (nonatomic, strong) NSDictionary *ticketZoneOptions;
@property (nonatomic, strong) NSDictionary *changeMargineOptions;
@property (nonatomic, strong) NSDictionary *walkingSpeedOptions;

@property (nonatomic, strong) NSDateFormatter *hourFormatter;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;

@end

@implementation HSLCommunication

@synthesize delegate;

-(id)init{
    self = [super init];
    super.apiBaseUrl = @"http://api.reittiopas.fi/hsl/1_2_0/";
    return self;
}

#pragma mark - Route search protocol implementation
-(void)searchRouteForFromCoords:(CLLocationCoordinate2D)fromCoords andToCoords:(CLLocationCoordinate2D)toCoords withOptions:(RouteSearchOptions *)options andCompletionBlock:(ActionBlock)completionBlock{
    
    NSDictionary *optionsDict = [self apiRequestParametersDictionaryForRouteOptions:options];
    
    //TODO: Select from list
    [optionsDict setValue:@"asacommuterstops" forKey:@"user"];
    [optionsDict setValue:@"rebekah" forKey:@"pass"];
    
    [super searchRouteForFromCoords:fromCoords andToCoords:toCoords withOptionsDictionary:optionsDict andCompletionBlock:completionBlock];
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
        [parametersDict setObject:@"3" forKey:@"show"];
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

#pragma mark - Stops inn areas search protocol implementation
- (void)fetchStopsInAreaForRegionCenterCoords:(CLLocationCoordinate2D)regionCenter andDiameter:(NSInteger)diameter withCompletionBlock:(ActionBlock)completionBlock{
    NSMutableDictionary *optionsDict = [@{} mutableCopy];
    
    [optionsDict setValue:@"asacommuternearby" forKey:@"user"];
    [optionsDict setValue:@"rebekah" forKey:@"pass"];
    
    [super fetchStopsInAreaForRegionCenterCoords:regionCenter andDiameter:diameter withOptionsDictionary:optionsDict withCompletionBlock:completionBlock];
    
}

#pragma mark - stop detail fetch protocol implementation
- (void)fetchStopDetailForCode:(NSString *)stopCode withCompletionBlock:(ActionBlock)completionBlock{
    NSMutableDictionary *optionsDict = [@{} mutableCopy];
    
    [optionsDict setValue:@"asacommuterstops" forKey:@"user"];
    [optionsDict setValue:@"rebekah" forKey:@"pass"];
    
    [super fetchStopDetailForCode:stopCode andOptionsDictionary:optionsDict withCompletionBlock:^(NSArray *fetchResult, NSString *error){
        if (!error) {
            if (fetchResult.count > 0) {
                //Assuming the stop code was unique and there is only one result
                completionBlock(fetchResult[0], nil);
            }
        }else{
            completionBlock(nil, error);
        }
    }];
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

#pragma mark - overriden methods
- (void)StopFetchDidComplete{
    [delegate hslStopFetchDidComplete:self];
}
- (void)StopFetchFailed:(int)errorCode{
    [self.delegate hslStopFetchFailed:errorCode];
}
- (void)StopInAreaFetchDidComplete{
    [delegate hslStopInAreaFetchDidComplete:self];
}
- (void)StopInAreaFetchFailed:(int)errorCode{
    [self.delegate hslStopInAreaFetchFailed:errorCode];
}
- (void)LineInfoFetchDidComplete{
//    [delegate hslLineInfoFetchDidComplete:self];
}
- (void)LineInfoFetchFailed{
//    [delegate hslLineInfoFetchFailed:self];
}

- (void)LineInfoFetchDidComplete:(NSData *)objectNotation{
    NSError *error = nil;
    NSArray *lines = [HSLCommunication lineFromJSON:objectNotation error:&error];
    
    if (lines != nil) {
        [delegate hslLineInfoFetchDidComplete:lines];
    }else{
        [delegate hslLineInfoFetchFailed:error];
    }
    
}
- (void)LineInfoFetchFailed:(NSError *)error{
    [delegate hslLineInfoFetchFailed:error];
}

- (void)GeocodeSearchDidComplete{
    [delegate hslGeocodeSearchDidComplete:self];
}
- (void)GeocodeSearchFailed:(int)errorCode{
    [self.delegate hslGeocodeSearchFailed:errorCode];
}
- (void)ReverseGeocodeSearchDidComplete{
    [self.delegate hslReverseGeocodeSearchDidComplete:self];
}
- (void)ReverseGeocodeSearchFailed:(int)errorCode{
    [self.delegate hslReverseGeocodeSearchFailed:errorCode];
}
- (void)RouteSearchDidComplete{
    [delegate hslRouteSearchDidComplete:self];
}
- (void)RouteSearchFailed:(int)errorCode{
    [self.delegate hslRouteSearchFailed:errorCode];
}
- (void)DisruptionFetchComplete{
    [delegate hslDisruptionFetchComplete:self];
}
- (void)DisruptionFetchFailed:(int)errorCode{
    [self.delegate hslDisruptionFetchFailed:errorCode];
}

#pragma mark - Helper methods
+ (NSArray *)lineFromJSON:(NSData *)objectNotation error:(NSError **)error{
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
            [lines addObject:line];
        }
    }
    
    return lines;
}

@end
