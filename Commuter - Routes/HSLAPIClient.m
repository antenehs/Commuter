//
//  HSLAPIClient.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 10/12/15.
//  Copyright © 2015 Anteneh Sahledengel. All rights reserved.
//

#import "HSLAPIClient.h"
#import "WidgetHelpers.h"
#import "HSLRouteOptionManager.h"
#import "ReittiStringFormatterE.h"

@implementation HSLAPIClient

- (id)init{
    self = [super init];
    if (self) {
        self.apiClient = [[APIClient alloc] init];
        self.apiClient.apiBaseUrl = @"http://api.reittiopas.fi/hsl/1_2_0/";
    }
    
    return self;
}

#pragma mark - route search
- (void)searchRouteForFromCoords:(CLLocationCoordinate2D)fromCoords andToCoords:(CLLocationCoordinate2D)toCoords withOptions:(NSDictionary *)optionsDict andCompletionBlock:(ActionBlock)completionBlock {
    
    NSDictionary *searchParameters;
    if (!optionsDict) {
        searchParameters = [@{} mutableCopy];
    } else {
        searchParameters = [[self apiRequestParametersDictionaryForRouteOptions:optionsDict] mutableCopy];
    }
    
    [searchParameters setValue:@"asacommuterwidget2" forKey:@"user"];
    [searchParameters setValue:@"rebekah" forKey:@"pass"];
    
    [super searchRouteForFromCoords:fromCoords andToCoords:toCoords withOptions:searchParameters andCompletionBlock:completionBlock];
}

#pragma mark - stop search

-(void)fetchStopForCode:(NSString *)code completionBlock:(ActionBlock)completionBlock {
    NSMutableDictionary *optionsDict = [@{} mutableCopy];
    
    [optionsDict setValue:@"asacommuterwidget" forKey:@"user"];
    [optionsDict setValue:@"rebekah" forKey:@"pass"];
    
    [super fetchStopForCode:code withOptions:optionsDict andCompletionBlock:completionBlock];
}

#pragma mark - Datasource value mapping

-(NSDictionary *)apiRequestParametersDictionaryForRouteOptions:(NSDictionary *)searchOptions{
    NSMutableDictionary *parametersDict = [@{} mutableCopy];
    
    if (!searchOptions)
        return parametersDict;
    
    parametersDict = [[[HSLRouteOptionManager sharedManager] apiRequestParametersDictionaryForRouteOptions:searchOptions] mutableCopy];
    [parametersDict setObject:@"3" forKey:@"show"];
    
    //Make sure there is default
    [parametersDict removeObjectForKey:@"date"];
    [parametersDict removeObjectForKey:@"time"];
    [parametersDict removeObjectForKey:@"timeType"];
    
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

@end
