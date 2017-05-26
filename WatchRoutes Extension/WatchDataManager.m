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
#import "StopEntity.h"
#import "BusStopE.h"
#import "ReittiRegionManager.h"
#import "DigiTransitCommunicator.h"
#import "NamedBookmark.h"
#import "BusStop.h"

@interface WatchDataManager ()

@property (strong, nonatomic)WatchHslApi *hslApiClient;
@property (strong, nonatomic)DigiTransitCommunicator *digiHslApiClient;
@property (strong, nonatomic)DigiTransitCommunicator *digiFinlandApiClient;

@end

@implementation WatchDataManager

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.hslApiClient = [[WatchHslApi alloc] init];
        self.digiHslApiClient = [DigiTransitCommunicator hslDigiTransitCommunicator];
        self.digiFinlandApiClient = [DigiTransitCommunicator finlandDigiTransitCommunicator];
    }
    return self;
}

#pragma mark - Saved to defaults
-(void)saveRouteSearchOptions:(RouteSearchOptions *)searchOptions {
    if (!searchOptions && ![searchOptions isKindOfClass:[RouteSearchOptions class]]) return;
    
    [self saveObjectToDefaults:[searchOptions dictionaryRepresentation] withKey:@"RouteSearchOptions"];
}

-(RouteSearchOptions *)getRouteSearchOptions {
    NSDictionary *optionsDict = [self getObjectFromDefaultsForKey:@"RouteSearchOptions"];
    if (optionsDict) return [RouteSearchOptions modelObjectFromDictionary:optionsDict];
    else return [RouteSearchOptions defaultOptions];
}

-(void)saveStops:(NSArray *)stops {
    NSMutableArray *stopsArray = [@[] mutableCopy];
    if (stops) {
        for (StopEntity *stop in stops)
            [stopsArray addObject:[stop dictionaryRepresentation]];
    }
    
    [self saveObjectToDefaults:stopsArray withKey:@"previousReceivedStops"];
}

-(NSArray *)getSavedStopsDictionaries {
    return [self getObjectFromDefaultsForKey:@"previousReceivedStops"];
}

-(void)saveStopsWithDepartures:(NSArray *)stops {
    NSMutableArray *stopsArray = [@[] mutableCopy];
    if (stops) {
        for (BusStopE *stop in stops)
            [stopsArray addObject:[stop toDictionary]];
    }
    
    [self saveObjectToDefaults:stopsArray withKey:@"previousReceivedStopsWithDepartures"];
}

-(NSArray *)getSavedStopsWithDeparturesDictionaries {
    NSArray *stopsDict = [self getObjectFromDefaultsForKey:@"previousReceivedStopsWithDepartures"];
    if (!stopsDict) return @[];
    
    NSMutableArray *busStops = [@[] mutableCopy];
    for (NSDictionary *dict in stopsDict) {
        BusStopE *stop = [[BusStopE alloc] initWithDictionary:dict parseLines:YES];
        if (stop)
            [busStops addObject:stop];
    }
    
    return busStops;
}

-(void)saveBookmarks:(NSArray *)bookmarks {
    NSMutableArray *bookmarksArray = [@[] mutableCopy];
    if (bookmarks) {
        for (NamedBookmark *bookmark in bookmarks)
            [bookmarksArray addObject:[bookmark dictionaryRepresentation]];
    }
    
    [self saveObjectToDefaults:bookmarksArray withKey:@"previousReceivedBookmark"];
}

-(NSArray *)getSavedNamedBookmarkDictionaries {
    NSArray *bookmarksDict = [[NSUserDefaults standardUserDefaults] objectForKey:@"previousReceivedBookmark"];
    return [MappingHelper mapDictionaryArray:bookmarksDict toArrayOfClassType:[NamedBookmark class]];
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

#pragma mark - Mapping
-(NSArray *)namedBookmarksFromBookmarksDictionaries:(NSArray *)bookmarkdictionaries {
    return [MappingHelper mapDictionaryArray:bookmarkdictionaries toArrayOfClassType:[NamedBookmark class]];
}

#pragma mark - Network methods
-(void)getRouteToLocation:(RoutableLocation *)toLocation fromCoordLocation:(CLLocation *)fromLocation routeOptions:(RouteSearchOptions *)searchOptions andCompletionBlock:(ActionBlock)completionBlock {
    
    searchOptions.numberOfResults = 3;
    searchOptions.date = [NSDate date];
    
    id dataSourceManager = [self getDataSourceForCurrentUserLocation:fromLocation.coordinate];
    if ([dataSourceManager conformsToProtocol:@protocol(RouteSearchProtocol)]) {
        Region fromRegion = [self identifyRegionOfCoordinate:fromLocation.coordinate];
        CLLocationCoordinate2D toCoords = [WidgetHelpers convertStringTo2DCoord:toLocation.coords];
        Region toRegion = [self identifyRegionOfCoordinate:toCoords];
        
        if (fromRegion == toRegion) {
            [(NSObject<RouteSearchProtocol> *)dataSourceManager searchRouteForFromCoords:fromLocation.coordinate andToCoords:toCoords withOptions:searchOptions andCompletionBlock:^(id response, NSString *errorString){
                completionBlock(response, errorString);
            }];
        }else{
            [self.digiFinlandApiClient searchRouteForFromCoords:fromLocation.coordinate andToCoords:toCoords withOptions:searchOptions andCompletionBlock:^(id response, NSString *errorString){
                if (!errorString) {
                    completionBlock(response, nil);
                }else{
                    completionBlock(nil, errorString);
                }
            }];
        }
        
    } else {
        completionBlock(nil,  @"Route search not supported in this region.");
    }

}

-(NSString *)routeSearchErrorMessageForError:(NSError *)error {
    if (!error) return nil;
    if (error.code == -1009) {
        return @"No internet connection.";
    }else if (error.code == -1016) {
        return @"No route information available for the selected address.";
    }else{
        return @"Unknown Error Occured.";
    }
}

- (void)fetchStopForCode:(NSString *)code andCompletionBlock:(ActionBlock)completionBlock {
    
    ReittiApi api = ReittiDigiTransitApi;
    if ([code hasPrefix:@"HSL"]) api = ReittiDigiTransitHslApi;
    
    id dataSourceManager = [self getDataSourceForApi:api];
    if ([dataSourceManager conformsToProtocol:@protocol(StopDetailFetchProtocol)]) {
        [(NSObject<StopDetailFetchProtocol> *)dataSourceManager fetchStopDetailForCode:code withCompletionBlock:^(BusStop * response, NSString *error){
            if (!error && response) {
                completionBlock(response, error);
            }else{
                completionBlock(nil, error);
            }
        }];
    }else{
        [self.digiFinlandApiClient fetchStopDetailForCode:code withCompletionBlock:^(BusStop * response, NSString *error){
            if (!error) {
                completionBlock(response, nil);
            }else{
                completionBlock(nil, error);
            }
        }];
    }
}

#pragma mark - DataSorce management

-(id)getDataSourceForApi:(ReittiApi)api {
    if (api == ReittiHSLApi) {
        return self.digiHslApiClient;
    } else {
        return self.digiFinlandApiClient;
    }
}

//#ifndef DEPARTURES_WIDGET

-(id)getDataSourceForCurrentUserLocation:(CLLocationCoordinate2D)coordinate{
    Region currentUserLocation = [self identifyRegionOfCoordinate:coordinate];
    
    if (currentUserLocation == HSLRegion) {
        return self.digiHslApiClient;
    } else {
        return self.digiFinlandApiClient;
    }
}

-(Region)identifyRegionOfCoordinate:(CLLocationCoordinate2D)coords {
    return [[ReittiRegionManager sharedManager] identifyRegionOfCoordinate: coords];
}

@end
