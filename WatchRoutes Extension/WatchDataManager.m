//
//  WatchDataManager.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 28/6/16.
//  Copyright © 2016 Anteneh Sahledengel. All rights reserved.
//

#import "WatchDataManager.h"
#import "WidgetHelpers.h"
#import "RoutableLocation.h"

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

#pragma mark - Saved to defaults
-(void)saveBookmarks:(NSArray *)bookmarks {
    NSMutableArray *bookmarksArray = [@[] mutableCopy];
    if (bookmarks) {
        for (NamedBookmarkE *bookmark in bookmarks)
            [bookmarksArray addObject:[bookmark dictionaryRepresentation]];
    }
    
    [self saveObjectToDefaults:bookmarksArray withKey:@"previousReceivedBookmark"];
}

-(NSArray *)getSavedNamedBookmarkDictionaries {
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"previousReceivedBookmark"];
}

-(void)saveOtherRecentLocation:(RoutableLocation *)location {
    //Only keep last two and check it doesnt exist already
    NSMutableArray *existingLocs = [[self getOtherRecentLocations] mutableCopy];
    [existingLocs insertObject:location atIndex:0];
    
    if (existingLocs.count > 1)
        [existingLocs removeLastObject];
    
    [self saveOtherRecentLocations:existingLocs];
}

-(void)saveOtherRecentLocations:(NSArray *)locations {
    NSMutableArray *locationsArray = [@[] mutableCopy];
    if (locations) {
        for (RoutableLocation *location in locations)
            [locationsArray addObject:[location dictionaryRepresentation]];
    }
    
    [self saveObjectToDefaults:locationsArray withKey:@"OtherRecentLocations"];
}

-(nonnull NSArray *)getOtherRecentLocations {
    NSArray *locationDicts = [[NSUserDefaults standardUserDefaults] objectForKey:@"OtherRecentLocations"];
    NSMutableArray *locArray = [@[] mutableCopy];
    if (locationDicts) {
        for (NSDictionary *dict in locationDicts) {
            RoutableLocation *rLocation = [RoutableLocation initFromDictionary:dict];
            if (rLocation)
                [locArray addObject:rLocation];
        }
    }
    return locArray;
}

-(void)saveObjectToDefaults:(id)object withKey:(NSString *)key {
    [[NSUserDefaults standardUserDefaults] setObject:object forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(id)getObjectFromDefaultsForKey:(NSString *)key {
    return [[NSUserDefaults standardUserDefaults] objectForKey:key];
}


#pragma mark - Network methods
-(void)getRouteToLocation:(RoutableLocation *)toLocation fromCoordLocation:(CLLocation *)fromLocation routeOptions:(NSDictionary *)options andCompletionBlock:(ActionBlock)completionBlock {
    
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
    
    CLLocationCoordinate2D toCoords = [WidgetHelpers convertStringTo2DCoord:toLocation.coords];
    
    
    [self.hslApiClient searchRouteForFromCoords:fromLocation.coordinate andToCoords:toCoords withOptions:options andCompletionBlock:^(id response, NSError *error){
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
