//
//  MatkaApiClient.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 3/5/16.
//  Copyright © 2016 Anteneh Sahledengel. All rights reserved.
//

#import "MatkaApiClient.h"
#import "APIClient.h"
#import "MatkaObjectMapping.h"
#import "MatkaModels.h"
#import "BusStopE.h"
#import "ReittiStringFormatter.h"
#import "RouteE.h"

@interface MatkaApiClient ()

@property (strong, nonatomic)APIClient *timeTableApiClient;
@property (strong, nonatomic)APIClient *genericApiClient;

@end

@implementation MatkaApiClient

@synthesize timeTableApiClient, genericApiClient;

- (id)init{
    self = [super init];
    if (self) {
        timeTableApiClient = [[APIClient alloc] init];
        timeTableApiClient.apiBaseUrl = @"http://api.matka.fi/timetables";
        
        genericApiClient = [[APIClient alloc] init];
        genericApiClient.apiBaseUrl = @"http://api.matka.fi";
        
//        apiUserNames = @[@"asacommuter"];
    }
    
    return self;
}

- (void)searchRouteForFromCoords:(CLLocationCoordinate2D)fromCoords andToCoords:(CLLocationCoordinate2D)toCoords withOptions:(NSDictionary *)optionsDict andCompletionBlock:(ActionBlock)completionBlock {
    NSMutableDictionary *searchParameters;
    if (!optionsDict) {
        searchParameters = [@{} mutableCopy];
    } else {
        searchParameters = [[self apiRequestParametersDictionaryForRouteOptions:optionsDict] mutableCopy];
    }
    
    [searchParameters setValue:@"asacommuter" forKey:@"user"];
    [searchParameters setValue:@"rebekah" forKey:@"pass"];
    
    AGSPoint *fromPoint = [ReittiStringFormatter convertCoordsToKkj3Point:fromCoords];
    AGSPoint *toPoint = [ReittiStringFormatter convertCoordsToKkj3Point:toCoords];
    if (!fromPoint || !toPoint) return;
    
    [searchParameters setValue:[NSString stringWithFormat:@"%d,%d", (int)fromPoint.x, (int)fromPoint.y] forKey:@"a"];
    [searchParameters setValue:[NSString stringWithFormat:@"%d,%d", (int)toPoint.x, (int)toPoint.y] forKey:@"b"];
    [searchParameters setValue:@"5" forKey:@"show"];
    
    [genericApiClient doXmlApiFetchWithParams:searchParameters responseDescriptor:[MatkaObjectMapping routeResponseDescriptor] andCompletionBlock:^(NSArray *matkaRoutes, NSError *error) {
        if (!error) {
            NSMutableArray *responseArray = [@[] mutableCopy];
            for (MatkaRoute *route in matkaRoutes) {
                RouteE *reittiRoute = [RouteE routeFromMatkaRoute:route];
                if (reittiRoute) [responseArray addObject:reittiRoute];
            }
            
            completionBlock(responseArray, nil);
        } else {
            completionBlock(nil, error); //TODO: Proper error message
        }
    }];
}

- (void)fetchStopForCode:(NSString *)code completionBlock:(ActionBlock)completionBlock {
    
    NSMutableDictionary *options = [@{} mutableCopy];
    [options setValue:@"stopid" forKey:@"m"];
    [options setValue:@"50" forKey:@"count"];
    
    [options setValue:@"asacommuter" forKey:@"user"];
    [options setValue:@"rebekah" forKey:@"pass"];
    
    [options setValue:code forKey:@"stopid"];
    
    [timeTableApiClient doXmlApiFetchWithParams:options responseDescriptor:[MatkaObjectMapping stopResponseDescriptorForPath:@"MATKAXML.STOP2TIMES.STOP"] andCompletionBlock:^(NSArray *matkaStops, NSError *error) {
        if (!error && matkaStops.count > 0) {
            BusStopE *stop = [BusStopE stopFromMatkaStop:matkaStops[0]];
            
            completionBlock(stop, nil);
        } else {
            //API seems to fail if there is no departure. Differentiate that with other failures
            completionBlock(nil, nil); //TODO: Proper error message
        }
    }];
}

#pragma mark - Route search options
-(NSDictionary *)apiRequestParametersDictionaryForRouteOptions:(NSDictionary *)searchOptions{
    NSMutableDictionary *parametersDict = [@{} mutableCopy];
    
    if (!searchOptions)
        return parametersDict;
    
    /* Optimization string */
    NSString *optimizeString;
    if ((RouteSearchOptimization)searchOptions[kSelectedRouteSearchOptimizationKey] == RouteSearchOptionFastest) {
        optimizeString = @"2";
    }else if ((RouteSearchOptimization)searchOptions[kSelectedRouteSearchOptimizationKey] == RouteSearchOptionLeastTransfer) {
        optimizeString = @"3";
    }else if ((RouteSearchOptimization)searchOptions[kSelectedRouteSearchOptimizationKey] == RouteSearchOptionLeastWalking) {
        optimizeString = @"4";
    }else{
        optimizeString = @"1";
    }
    
    [parametersDict setObject:optimizeString forKey:@"optimize"];
    
    /* Change Margine */
    if (searchOptions[kSelectedChangeMargineKey] != nil && ![searchOptions[kSelectedChangeMargineKey] isEqualToString:@"3 minutes (Default)"]) {
        [parametersDict setObject:[self.changeMargineOptions objectForKey:searchOptions[kSelectedChangeMargineKey]] forKey:@"margin"];
    }
    
    /* Walking Speed */
    if (searchOptions[kSelectedWalkingSpeedKey] != nil && ![searchOptions[kSelectedWalkingSpeedKey] isEqualToString:@"Normal Walking (Default)"]) {
        [parametersDict setObject:[self.walkingSpeedOptions objectForKey:searchOptions[kSelectedWalkingSpeedKey]] forKey:@"walkspeed"];
    }
    
    [parametersDict setObject:@"3" forKey:@"show"];

    return parametersDict;
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

@end
