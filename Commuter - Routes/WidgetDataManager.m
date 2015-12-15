//
//  WidgetDataManager.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 10/12/15.
//  Copyright © 2015 Anteneh Sahledengel. All rights reserved.
//

#import "WidgetDataManager.h"
#import "WidgetHelpers.h"

@interface WidgetDataManager ()

@property (nonatomic) RTCoordinateRegion helsinkiRegion;
@property (nonatomic) RTCoordinateRegion tampereRegion;

@property (strong, nonatomic)HSLAPIClient *hslApiClient;
@property (strong, nonatomic)TREAPIClient *treApiClient;

@end

@implementation WidgetDataManager

-(id)init{
    self = [super init];
    if (self) {
        [self initRegionCoordinates];
        self.hslApiClient = [[HSLAPIClient alloc] init];
        self.treApiClient = [[TREAPIClient alloc] init];
    }
    
    return self;
}

-(void)getRouteForNamedBookmark:(NamedBookmarkE *)namedBookmark fromLocation:(CLLocation *)location andCompletionBlock:(ActionBlock)completionBlock{
    
    id dataSourceManager = [self getDataSourceForCurrentUserLocation:location.coordinate];
    if ([dataSourceManager conformsToProtocol:@protocol(WidgetRouteSearchProtocol)]) {
        Region fromRegion = [self identifyRegionOfCoordinate:location.coordinate];
        CLLocationCoordinate2D toCoords = [WidgetHelpers convertStringTo2DCoord:namedBookmark.coords];
        Region toRegion = [self identifyRegionOfCoordinate:toCoords];
        
        if (fromRegion == toRegion) {
            [(NSObject<WidgetRouteSearchProtocol> *)dataSourceManager searchRouteForFromCoords:location.coordinate andToCoords:toCoords withOptions:nil andCompletionBlock:^(id response, NSError *error){
                NSLog(@"Route search completed.");
                if (!error) {
                    completionBlock(response, nil);
                }else{
                    //TODO: format error message
                    completionBlock(nil, [self routeSearchErrorMessageForError:error]);
                }
            }];
        }else{
            completionBlock(nil, @"No Route available to this location.");
        }

    }
}

-(NSString *)routeSearchErrorMessageForError:(NSError *)error{
    if (error.code == -1009) {
        return @"Internet connection appears to be offline.";
    }else if (error.code == -1016) {
        return @"No route information available for the selected addresses.";
    }else{
        return @"Unknown Error Occured.";
    }
}

#pragma mark - DataSorce management

-(id)getDataSourceForCurrentUserLocation:(CLLocationCoordinate2D)coordinate{
    Region currentUserLocation = [self identifyRegionOfCoordinate:coordinate];
    if (currentUserLocation == TRERegion) {
        return self.treApiClient;
    }else{
        return self.hslApiClient;
    }
}
#pragma mark - Region Management
- (void)initRegionCoordinates {
    CLLocationCoordinate2D coord1 = {.latitude = 60.765052 , .longitude = 23.742929 };
    CLLocationCoordinate2D coord2 = {.latitude = 59.928294 , .longitude = 25.786386};
    RTCoordinateRegion helsinkiRegionCoords = { coord1,coord2 };
    self.helsinkiRegion = helsinkiRegionCoords;
    
    CLLocationCoordinate2D coord3 = {.latitude = 61.892057 , .longitude = 22.781625 };
    CLLocationCoordinate2D coord4 = {.latitude = 61.092114 , .longitude = 24.716342};
    RTCoordinateRegion tampereRegionCoords = { coord3,coord4 };
    self.tampereRegion = tampereRegionCoords;
}

-(Region)identifyRegionOfCoordinate:(CLLocationCoordinate2D)coords{
    
    if ([self isCoordinateInRegion:self.helsinkiRegion coordinate:coords]) {
        return HSLRegion;
    }
    
    if ([self isCoordinateInRegion:self.tampereRegion coordinate:coords]) {
        return TRERegion;
    }
    
    return OtherRegion;
}

-(BOOL)isCoordinateInRegion:(RTCoordinateRegion)region coordinate:(CLLocationCoordinate2D)coords{
    if (coords.latitude < region.topLeftCorner.latitude &&
        coords.latitude > region.bottomRightCorner.latitude &&
        coords.longitude > region.topLeftCorner.longitude &&
        coords.longitude < region.bottomRightCorner.longitude) {
        return YES;
    }else
        return NO;
}

#pragma mark - Helpers


@end
