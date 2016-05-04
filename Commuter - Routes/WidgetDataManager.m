//
//  WidgetDataManager.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 10/12/15.
//  Copyright © 2015 Anteneh Sahledengel. All rights reserved.
//

#import "WidgetDataManager.h"
#import "WidgetHelpers.h"
#import "BusStopE.h"
#import "ReittiRegionManager.h"

@interface WidgetDataManager ()

//@property (nonatomic) RTCoordinateRegion helsinkiRegion;
//@property (nonatomic) RTCoordinateRegion tampereRegion;

@property (strong, nonatomic)HSLAPIClient *hslApiClient;
@property (strong, nonatomic)TREAPIClient *treApiClient;
@property (strong, nonatomic)MatkaApiClient *matkaApiClient;

@end

@implementation WidgetDataManager

-(id)init{
    self = [super init];
    if (self) {
//        [self initRegionCoordinates];
        self.hslApiClient = [[HSLAPIClient alloc] init];
        self.treApiClient = [[TREAPIClient alloc] init];
        self.matkaApiClient = [[MatkaApiClient alloc] init];
    }
    
    return self;
}

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
    if ([dataSourceManager conformsToProtocol:@protocol(WidgetStopSearchProtocol)]) {
        [(NSObject<WidgetStopSearchProtocol> *)dataSourceManager fetchStopForCode:code completionBlock:^(BusStopE * response, NSString *error){
            if (!error && response) {
                completionBlock(response, error);
            }else{
                completionBlock(nil, @"Fetching stop detail failed. Please try again later.");
            }
        }];
    }else{
        [self.matkaApiClient fetchStopForCode:code completionBlock:^(BusStopE * response, NSString *error){
            if (!error) {
                completionBlock(response, nil);
            }else{
                completionBlock(nil, @"Fetching stop detail failed. Please try again later.");
            }
        }];
    }
}

#pragma mark - DataSorce management

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

-(id)getDataSourceForApi:(ReittiApi)api {
    if (api == ReittiHSLApi) {
        return self.hslApiClient;
    } else if (api == ReittiTREApi) {
        return self.treApiClient;
    } else {
        return self.matkaApiClient;
    }
}


#pragma mark - Region Management
//- (void)initRegionCoordinates {
//    CLLocationCoordinate2D coord1 = {.latitude = 60.765052 , .longitude = 23.742929 };
//    CLLocationCoordinate2D coord2 = {.latitude = 59.928294 , .longitude = 25.786386};
//    RTCoordinateRegion helsinkiRegionCoords = { coord1,coord2 };
//    self.helsinkiRegion = helsinkiRegionCoords;
//    
//    CLLocationCoordinate2D coord3 = {.latitude = 61.892057 , .longitude = 22.781625 };
//    CLLocationCoordinate2D coord4 = {.latitude = 61.092114 , .longitude = 24.716342};
//    RTCoordinateRegion tampereRegionCoords = { coord3,coord4 };
//    self.tampereRegion = tampereRegionCoords;
//}

-(Region)identifyRegionOfCoordinate:(CLLocationCoordinate2D)coords{
    
//    if ([self isCoordinateInRegion:self.helsinkiRegion coordinate:coords]) {
//        return HSLRegion;
//    }
//    
//    if ([self isCoordinateInRegion:self.tampereRegion coordinate:coords]) {
//        return TRERegion;
//    }
//    
//    return OtherRegion;
    
    if ([[ReittiRegionManager sharedManager] isCoordinateInHSLRegion:coords]) {
        return HSLRegion;
    }
    
    if ([[ReittiRegionManager sharedManager] isCoordinateInTRERegion:coords]) {
        return TRERegion;
    }
    
    return FINRegion;
}

//-(BOOL)isCoordinateInRegion:(RTCoordinateRegion)region coordinate:(CLLocationCoordinate2D)coords{
//    if (coords.latitude < region.topLeftCorner.latitude &&
//        coords.latitude > region.bottomRightCorner.latitude &&
//        coords.longitude > region.topLeftCorner.longitude &&
//        coords.longitude < region.bottomRightCorner.longitude) {
//        return YES;
//    }else
//        return NO;
//}

#pragma mark - Helpers


@end
