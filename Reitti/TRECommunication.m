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

@interface TRECommunication ()

@property (nonatomic, strong) NSDictionary *transportTypeOptions;
@property (nonatomic, strong) NSDictionary *ticketZoneOptions;
@property (nonatomic, strong) NSDictionary *changeMargineOptions;
@property (nonatomic, strong) NSDictionary *walkingSpeedOptions;

@property (nonatomic, strong) NSDateFormatter *hourFormatter;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;

@end

@implementation TRECommunication

@synthesize delegate;

-(id)init{
    self = [super init];
    super.apiBaseUrl = @"http://api.publictransport.tampere.fi/1_0_3/";
    return self;
}

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
        [parametersDict setObject:@"3" forKey:@"show"];
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

-(NSArray *)getTransportTypeOptions{
    return nil;
//    return @[@{displayTextOptionKey : @"Bus", valueOptionKey : @"bus", pictureOptionKey : [AppManager lightColorImageForLegTransportType:LegTypeBus]},
//             @{displayTextOptionKey : @"Metro", valueOptionKey : @"metro", pictureOptionKey : [UIImage imageNamed:@"Subway-100.png"]},
//             @{displayTextOptionKey : @"Train", valueOptionKey : @"train", pictureOptionKey : [AppManager lightColorImageForLegTransportType:LegTypeTrain]},
//             @{displayTextOptionKey : @"Tram", valueOptionKey : @"tram", pictureOptionKey : [AppManager lightColorImageForLegTransportType:LegTypeTram]},
//             @{displayTextOptionKey : @"Ferry", valueOptionKey : @"ferry", pictureOptionKey : [AppManager lightColorImageForLegTransportType:LegTypeFerry]},
//             @{displayTextOptionKey : @"Uline", valueOptionKey : @"uline", pictureOptionKey : [AppManager lightColorImageForLegTransportType:LegTypeBus]}];
}

-(NSArray *)getTicketZoneOptions{
    return nil;
//    return @[@{displayTextOptionKey : @"All HSL Regions (Default)", valueOptionKey : @"whole", defaultOptionKey : @"yes"},
//             @{displayTextOptionKey : @"Regional" , valueOptionKey: @"region"},
//             @{displayTextOptionKey : @"Helsinki Internal", valueOptionKey : @"helsinki"},
//             @{displayTextOptionKey : @"Espoo Internal", valueOptionKey : @"espoo"},
//             @{displayTextOptionKey : @"Vantaa Internal", valueOptionKey : @"vantaa"}];
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
    
    [optionsDict setValue:@"asacommuternearby" forKey:@"user"];
    [optionsDict setValue:@"rebekah" forKey:@"pass"];
    
    [super fetchStopsInAreaForRegionCenterCoords:regionCenter andDiameter:diameter withOptionsDictionary:optionsDict withCompletionBlock:completionBlock];
}

#pragma mark - Stop fetch method

- (void)fetchStopDetailForCode:(NSString *)stopCode withCompletionBlock:(ActionBlock)completionBlock{
    NSMutableDictionary *optionsDict = [@{} mutableCopy];
    
    [optionsDict setValue:@"asacommuterstops" forKey:@"user"];
    [optionsDict setValue:@"rebekah" forKey:@"pass"];
    
    [super fetchStopDetailForCode:stopCode andOptionsDictionary:optionsDict withCompletionBlock:^(NSArray *fetchResult, NSString *error){
        if (!error) {
            if (fetchResult.count > 0) {
                //Assuming the stop code was unique and there is only one result
                BusStop *stop = fetchResult[0];
                //Handlind a TRE API bug that returns incorrect coordinate format even if epsg_out is specified as 4326
                stop.coords = stop.wgs_coords;
                completionBlock(stop, nil);
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
    [delegate treStopFetchDidComplete:self];
}
- (void)StopFetchFailed:(int)errorCode{
    [self.delegate treStopFetchFailed:errorCode];
}
- (void)StopInAreaFetchDidComplete{
    [delegate treStopInAreaFetchDidComplete:self];
}
- (void)StopInAreaFetchFailed:(int)errorCode{
    [self.delegate treStopInAreaFetchFailed:errorCode];
}
- (void)LineInfoFetchDidComplete{
    [delegate treLineInfoFetchDidComplete:self];
}
- (void)LineInfoFetchFailed{
    [delegate treLineInfoFetchFailed:self];
}
- (void)GeocodeSearchDidComplete{
    [delegate treGeocodeSearchDidComplete:self];
}
- (void)GeocodeSearchFailed:(int)errorCode{
    [self.delegate treGeocodeSearchFailed:errorCode];
}
- (void)ReverseGeocodeSearchDidComplete{
    [self.delegate treReverseGeocodeSearchDidComplete:self];
}
- (void)ReverseGeocodeSearchFailed:(int)errorCode{
    [self.delegate treReverseGeocodeSearchFailed:errorCode];
}
- (void)RouteSearchDidComplete{
    [delegate treRouteSearchDidComplete:self];
}
- (void)RouteSearchFailed:(int)errorCode{
    [self.delegate treRouteSearchFailed:errorCode];
}
- (void)DisruptionFetchComplete{
    [delegate treDisruptionFetchComplete:self];
}
- (void)DisruptionFetchFailed:(int)errorCode{
    [self.delegate treDisruptionFetchFailed:errorCode];
}

@end
