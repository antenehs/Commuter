//
//  WidgetDataManager.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 10/12/15.
//  Copyright © 2015 Anteneh Sahledengel. All rights reserved.
//

#import "WidgetDataManager.h"
#import "WidgetHelpers.h"
#import "BusStop.h"
#import "DigiTransitCommunicator.h"
#import "AppManager.h"
#import "ReittiRegionManager.h"

@interface WidgetDataManager ()

@property (strong, nonatomic)DigiTransitCommunicator *digiHslApiClient;
@property (strong, nonatomic)DigiTransitCommunicator *digiFinlandApiClient;

@end

@implementation WidgetDataManager

-(id)init{
    self = [super init];
    if (self) {
        self.digiHslApiClient = [DigiTransitCommunicator hslDigiTransitCommunicator];
        self.digiFinlandApiClient = [DigiTransitCommunicator finlandDigiTransitCommunicator];
    }
    
    return self;
}

//#ifndef DEPARTURES_WIDGET
-(void)getRouteForNamedBookmark:(NamedBookmark *)namedBookmark fromLocation:(CLLocation *)location routeOptions:(RouteSearchOptions *)searchOptions andCompletionBlock:(ActionBlock)completionBlock{
    
    searchOptions.numberOfResults = 2;
    searchOptions.date = [NSDate date];
    if ([AppManager isDebugMode]) {
        searchOptions.date = [[NSDate date] dateByAddingTimeInterval:28000];
    }
    
    id dataSourceManager = [self getDataSourceForCurrentUserLocation:location.coordinate];
    if ([dataSourceManager conformsToProtocol:@protocol(RouteSearchProtocol)]) {
        Region fromRegion = [self identifyRegionOfCoordinate:location.coordinate];
        CLLocationCoordinate2D toCoords = [WidgetHelpers convertStringTo2DCoord:namedBookmark.coords];
        Region toRegion = [self identifyRegionOfCoordinate:toCoords];
        
        if (fromRegion == toRegion) {
            [(NSObject<RouteSearchProtocol> *)dataSourceManager searchRouteForFromCoords:location.coordinate andToCoords:toCoords withOptions:searchOptions andCompletionBlock:^(id response, NSString *errorString){
                completionBlock(response, errorString);
            }];
        }else{
            [self.digiFinlandApiClient searchRouteForFromCoords:location.coordinate andToCoords:toCoords withOptions:searchOptions andCompletionBlock:^(id response, NSString *errorString){
                NSLog(@"Route search completed.");
                if (!errorString) {
                    completionBlock(response, nil);
                }else{
                    completionBlock(nil, errorString);
                }
            }];
        }

    } else {
        completionBlock(nil, @"Route search not supported in this region.");
    }
    
    
}
//#endif

#pragma mark - Stop search methods
-(void)fetchStopForCode:(NSString *)code fetchFromApi:(ReittiApi)api withCompletionBlock:(ActionBlock)completionBlock {
    
    id dataSourceManager = [self getDataSourceForApi:api];
    if ([dataSourceManager conformsToProtocol:@protocol(StopDetailFetchProtocol)]) {
        [(NSObject<StopDetailFetchProtocol> *)dataSourceManager fetchStopDetailForCode:code withCompletionBlock:^(BusStop * response, NSString *error){
            if (!error && response) {
                completionBlock(response, error);
            }else{
                completionBlock(nil, @"Fetching stop detail failed. Please try again later.");
            }
        }];
    }else{
        [self.digiFinlandApiClient fetchStopDetailForCode:code withCompletionBlock:^(BusStop * response, NSString *error){
            if (!error) {
                completionBlock(response, nil);
            }else{
                completionBlock(nil, @"Fetching stop detail failed. Please try again later.");
            }
        }];
    }
}

#pragma mark - DataSorce management

-(id)getDataSourceForApi:(ReittiApi)api {
//    if (api == ReittiHSLApi) {
//        return self.hslApiClient;
//    } else if (api == ReittiTREApi) {
//        return self.treApiClient;
//    } else {
//        return self.matkaApiClient;
//    }
    
    if (api == ReittiHSLApi) {
        return self.digiHslApiClient;
    } else {
        return self.digiFinlandApiClient;
    }
}

-(id)getDataSourceForCurrentUserLocation:(CLLocationCoordinate2D)coordinate{
    Region currentUserLocation = [self identifyRegionOfCoordinate:coordinate];
//    if (currentUserLocation == TRERegion) {
//        return self.treApiClient;
//    } else if (currentUserLocation == HSLRegion)  {
//        return self.hslApiClient;
//    } else {
//        return self.matkaApiClient;
//    }
    
    if (currentUserLocation == HSLRegion) {
        return self.digiHslApiClient;
    } else {
        return self.digiFinlandApiClient;
    }
}

-(Region)identifyRegionOfCoordinate:(CLLocationCoordinate2D)coords {
    return [[ReittiRegionManager sharedManager] identifyRegionOfCoordinate: coords];
}

#pragma mark - Helpers


@end
