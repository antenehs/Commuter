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

#ifndef DEPARTURES_WIDGET
#import "ReittiRegionManager.h"
#endif
@interface WidgetDataManager ()

//@property (nonatomic) RTCoordinateRegion helsinkiRegion;
//@property (nonatomic) RTCoordinateRegion tampereRegion;

@property (strong, nonatomic)HSLAPIClient *hslApiClient;
@property (strong, nonatomic)TREAPIClient *treApiClient;
@property (strong, nonatomic)MatkaApiClient *matkaApiClient;
@property (strong, nonatomic)DigiTransitCommunicator *digiHslApiClient;
@property (strong, nonatomic)DigiTransitCommunicator *digiFinlandApiClient;

@end

@implementation WidgetDataManager

-(id)init{
    self = [super init];
    if (self) {
//        [self initRegionCoordinates];
        self.hslApiClient = [[HSLAPIClient alloc] init];
        self.treApiClient = [[TREAPIClient alloc] init];
        self.matkaApiClient = [[MatkaApiClient alloc] init];
        self.digiHslApiClient = [DigiTransitCommunicator hslDigiTransitCommunicator];
        self.digiFinlandApiClient = [DigiTransitCommunicator finlandDigiTransitCommunicator];
    }
    
    return self;
}

#ifndef DEPARTURES_WIDGET
-(void)getRouteForNamedBookmark:(NamedBookmarkE *)namedBookmark fromLocation:(CLLocation *)location routeOptions:(NSDictionary *)options andCompletionBlock:(ActionBlock)completionBlock{
    
    id dataSourceManager = [self getDataSourceForCurrentUserLocation:location.coordinate];
    if ([dataSourceManager conformsToProtocol:@protocol(WidgetRouteSearchProtocol)]) {
        Region fromRegion = [self identifyRegionOfCoordinate:location.coordinate];
        CLLocationCoordinate2D toCoords = [WidgetHelpers convertStringTo2DCoord:namedBookmark.coords];
        Region toRegion = [self identifyRegionOfCoordinate:toCoords];
        
        if (fromRegion == toRegion) {
            [(NSObject<WidgetRouteSearchProtocol> *)dataSourceManager searchRouteForFromCoords:location.coordinate andToCoords:toCoords withOptions:options andCompletionBlock:^(id response, NSError *error){
                completionBlock(response, [self routeSearchErrorMessageForError:error]);
            }];
        }else{
            [self.matkaApiClient searchRouteForFromCoords:location.coordinate andToCoords:toCoords withOptions:options andCompletionBlock:^(id response, NSError *error){
                NSLog(@"Route search completed.");
                if (!error) {
                    completionBlock(response, nil);
                }else{
                    //TODO: format error message
                    completionBlock(nil, [self routeSearchErrorMessageForError:error]);
                }
            }];
//            completionBlock(nil, @"No Route available to this location.");
        }

    }
}
#endif

-(NSString *)routeSearchErrorMessageForError:(NSError *)error{
    if (!error) return nil;
    if (error.code == -1009) {
        return @"Internet connection appears to be offline.";
    }else if (error.code == -1016) {
        return @"No route information available for the selected addresses.";
    }else{
        return @"Unknown Error Occured.";
    }
}

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

#ifndef DEPARTURES_WIDGET

-(id)getDataSourceForCurrentUserLocation:(CLLocationCoordinate2D)coordinate{
    Region currentUserLocation = [self identifyRegionOfCoordinate:coordinate];
    if (currentUserLocation == TRERegion) {
        return self.treApiClient;
    } else if (currentUserLocation == HSLRegion)  {
        return self.hslApiClient;
    } else {
        return self.matkaApiClient;
    }
}

-(Region)identifyRegionOfCoordinate:(CLLocationCoordinate2D)coords {
    return [[ReittiRegionManager sharedManager] identifyRegionOfCoordinate: coords];
}
#endif

#pragma mark - Helpers


@end
