//
//  WatchDataManager.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 28/6/16.
//  Copyright © 2016 Anteneh Sahledengel. All rights reserved.
//

#import "WatchDataManager.h"
#import "WidgetHelpers.h"

@interface WatchDataManager ()

@property (strong, nonatomic)WatchHslApi *hslApiClient;

@end

@implementation WatchDataManager

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.hslApiClient = [[WatchHslApi alloc] init];
    }
    return self;
}

-(void)getRouteForNamedBookmark:(NamedBookmarkE *)namedBookmark fromLocation:(CLLocation *)location routeOptions:(NSDictionary *)options andCompletionBlock:(ActionBlock)completionBlock{
    
    //TODO: Do proper location checking
//    id dataSourceManager = [self getDataSourceForCurrentUserLocation:location.coordinate];
//    if ([dataSourceManager conformsToProtocol:@protocol(WidgetRouteSearchProtocol)]) {
//        Region fromRegion = [self identifyRegionOfCoordinate:location.coordinate];
//        CLLocationCoordinate2D toCoords = [WidgetHelpers convertStringTo2DCoord:namedBookmark.coords];
//        Region toRegion = [self identifyRegionOfCoordinate:toCoords];
//        
//        if (fromRegion == toRegion) {
//            [(NSObject<WidgetRouteSearchProtocol> *)dataSourceManager searchRouteForFromCoords:location.coordinate andToCoords:toCoords withOptions:options andCompletionBlock:^(id response, NSError *error){
//                completionBlock(response, [self routeSearchErrorMessageForError:error]);
//            }];
//        }else{
//            [self.matkaApiClient searchRouteForFromCoords:location.coordinate andToCoords:toCoords withOptions:options andCompletionBlock:^(id response, NSError *error){
//                NSLog(@"Route search completed.");
//                if (!error) {
//                    completionBlock(response, nil);
//                }else{
//                    //TODO: format error message
//                    completionBlock(nil, [self routeSearchErrorMessageForError:error]);
//                }
//            }];
//            //            completionBlock(nil, @"No Route available to this location.");
//        }
//        
//    }
    
    CLLocationCoordinate2D toCoords = [WidgetHelpers convertStringTo2DCoord:namedBookmark.coords];
    
    
    [self.hslApiClient searchRouteForFromCoords:location.coordinate andToCoords:toCoords withOptions:options andCompletionBlock:^(id response, NSError *error){
        completionBlock(response, [self routeSearchErrorMessageForError:error]);
    }];
}

-(NSString *)routeSearchErrorMessageForError:(NSError *)error{
    if (!error) return nil;
    if (error.code == -1009) {
        return @"No internet connection.";
    }else if (error.code == -1016) {
        return @"No route information available for the selected address.";
    }else{
        return @"Unknown Error Occured.";
    }
}

@end
