//
//  InterfaceController.m
//  WatchRoutes Extension
//
//  Created by Anteneh Sahledengel on 26/6/16.
//  Copyright © 2016 Anteneh Sahledengel. All rights reserved.
//

#import "HomeInterfaceController.h"
#import "AppManagerBase.h"
#import "NamedBookmarkE.h"
#import "WatchDataManager.h"
#import "Route.h"
#import "ComplicationDataManager.h"
#import "RoutableLocation.h"
#import "WidgetHelpers.h"
#import "StopEntity.h"
#import "BusStopE.h"
#import "ReittiStringFormatterE.h"

@interface HomeInterfaceController() <CLLocationManagerDelegate>

@property (strong, nonatomic) NSUserDefaults *sharedDefaults;
@property (strong, nonatomic) NSArray *namedBookmarks;
@property (strong, nonatomic) NSArray *savedStops;
@property (strong, nonatomic) NSMutableArray *fetchedStops;
@property (strong, nonatomic) NSArray *transferredRoutes;
@property (strong, nonatomic) NSDictionary *routeSearchOptions;

@property (strong, nonatomic) IBOutlet WKInterfaceLabel *titleLabel;
@property (strong, nonatomic) IBOutlet WKInterfaceTable *bookmarksTable;
@property (strong, nonatomic) IBOutlet WKInterfaceImage *activityImage;
@property (strong, nonatomic) IBOutlet WKInterfaceLabel *activityLabel;
@property (strong, nonatomic) IBOutlet WKInterfaceGroup *activityGroup;

@property (strong, nonatomic) WatchCommunicationManager *communicationManager;
@property (strong, nonatomic) WatchDataManager *watchDataManager;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CLLocation * currentUserLocation;
@property (nonatomic) BOOL locationAuthorized;

@property (nonatomic)RouteSearchBlock pendingRouteSearchBlock;

@property (strong, nonatomic) NSTimer * locationRefreshTimer;

@end

@implementation HomeInterfaceController

-(instancetype)init {
    self = [super init];
    if (self) {
//        [WKInterfaceController reloadRootControllersWithNames:@[@"Third", @"Third"] contexts:@[@"Home", @"Second"]];
        self.watchDataManager = [WatchDataManager new];
    }
    
    return self;
}

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];

//    [self readNamedBookmarksFromUserDefaults];
    [self endActivity];
    self.fetchedStops = [@[] mutableCopy];
    
    self.communicationManager = [WatchCommunicationManager sharedManager];
    self.communicationManager.delegate = self;
    
    [self loadSavedBookmarks];
    [self loadSavedStops];
    [self loadSavedStopsWithDepartures];
    self.routeSearchOptions = [self.watchDataManager getRouteSearchOptions];
    
    [self setUpTableView];
}

- (void)willActivate {
    // This method is called when watch view controller is about to be visible to user
    [self initLocationManager];
    [self setUpTableView];
    
    [super willActivate];
}

- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    [self.locationRefreshTimer invalidate];
    
    [super didDeactivate];
}

-(void)handleUserActivity:(NSDictionary *)userInfo {
    NSDate *timeLineEntryDate = [userInfo objectForKey:@"CLKLaunchedTimelineEntryDateKey"];
    if (timeLineEntryDate) { //Launched from complication
        [self dismissController]; //Dismis routes view if showing
        Route *complicationRoute = [[ComplicationDataManager sharedManager] getComplicationRoute];
        //Check route is not old
        if (complicationRoute) {
            [self showRoute:complicationRoute];
        }
    }
}

#pragma mark - Table view methods
-(void)setUpTableView {
    NamedBookmarkE *home = [self getHomeBookmark];
    NamedBookmarkE *work = [self getWorkBookmark];
    
    NSMutableArray *bookmarksIndexes = [@[] mutableCopy];
    NSMutableArray *recentLocationIndexes = [@[] mutableCopy];
    NSMutableArray *stopsIndexes = [@[] mutableCopy];
    
    NSMutableArray *otherBookmarks = [self.namedBookmarks mutableCopy];
    if (home) [otherBookmarks removeObject:home];
    if (work) [otherBookmarks removeObject:work];
    
    NSMutableArray *rowTypes = [@[] mutableCopy];
    [rowTypes addObject:@"HomeAndWorkRow"];
    
    if (otherBookmarks.count > 0) {
        for (int i = 0; i < otherBookmarks.count; i++) {
            [bookmarksIndexes addObject:[NSNumber numberWithInt:rowTypes.count]];
            [rowTypes addObject:@"LocationRow"];
        }
    }
    
    NSArray *recentLocations = [self.watchDataManager getOtherRecentLocations];
    if (recentLocations.count > 0) {
        [rowTypes addObject:@"OtherLocationHeader"];
        for (int i = 0; i < recentLocations.count; i++) {
            [recentLocationIndexes addObject:[NSNumber numberWithInt:rowTypes.count]];
            [rowTypes addObject:@"LocationRow"];
        }
    }
    
    if (self.savedStops.count > 0) {
        [rowTypes addObject:@"StopsHeader"];
        for (int i = 0; i < self.savedStops.count; i++) {
            [stopsIndexes addObject:[NSNumber numberWithInt:rowTypes.count]];
            [rowTypes addObject:@"StopRow"];
        }
    }
    
    if (rowTypes.count == 0) {
        [rowTypes addObject:@"InfoRow"];
        [self.titleLabel setHidden:YES];
    } else {
        [self.titleLabel setHidden:NO];
    }
    
    [self.bookmarksTable setRowTypes:rowTypes];
    
    for (int i = 0; i < self.bookmarksTable.numberOfRows; i++) {
        if (i == 0) {
            HomeAndWorkRowController *controller = (HomeAndWorkRowController *)[self.bookmarksTable rowControllerAtIndex:i];
            [controller setUpWithHomeBookmark:home andWorkBookmark:work];
            controller.delegate = self;
        } else if ([rowTypes[i] isEqualToString:@"LocationRow"]) {
            NSInteger index1 = [bookmarksIndexes indexOfObject:[NSNumber numberWithInt:i]];
            if (index1 != NSNotFound) {
                LocationRowController *controller = (LocationRowController *)[self.bookmarksTable rowControllerAtIndex:i];
                [controller setUpWithNamedBookmark:otherBookmarks[index1]];
            }
            
            NSInteger index2 = [recentLocationIndexes indexOfObject:[NSNumber numberWithInt:i]];
            if (index2 != NSNotFound) {
                LocationRowController *controller = (LocationRowController *)[self.bookmarksTable rowControllerAtIndex:i];
                [controller setUpWithNamedBookmark:recentLocations[index2]];
            }
            
        } else if ([rowTypes[i] isEqualToString:@"StopRow"]) {
            NSInteger index = [stopsIndexes indexOfObject:[NSNumber numberWithInt:i]];
            if (index != NSNotFound) {
                StopRowController *controller = (StopRowController *)[self.bookmarksTable rowControllerAtIndex:i];
                [controller setUpWithStop:self.savedStops[index]];
            }
        }
    }
}

-(void)table:(WKInterfaceTable *)table didSelectRowAtIndex:(NSInteger)rowIndex {
    id rowController = [self.bookmarksTable rowControllerAtIndex:rowIndex];
    if ([rowController isKindOfClass:[LocationRowController class]]) {
        [self checkCurrentLocationAndGetRouteToLocation:((LocationRowController *)rowController).location];
    }
    
    if ([rowController isKindOfClass:[StopRowController class]]) {
        [self searchStopForStop:((StopRowController *)rowController).stop];
    }
}

#pragma mark - Route methods
-(void)saveSearchOptionsToUserDefaults {
    [self.watchDataManager saveBookmarks:self.namedBookmarks];
}

-(void)loadSavedSearchOptions {
    NSArray * savedBookmarks = [self.watchDataManager getSavedNamedBookmarkDictionaries];
    if (savedBookmarks) {
        [self initBookmarksFromBookmarksDictionaries:savedBookmarks];
        [self setUpTableView];
    }
}
-(void)checkCurrentLocationAndGetRouteToLocation:(NSObject<RoutableLocationProtocol> *)location {
    RouteSearchBlock searchRouteBlock = ^(CLLocation *fromLocation){
        [self searchRouteToLocation:location fromLocation:fromLocation];
    };
    
    if (!self.locationAuthorized) {
        [self showLocationNotAuthorizedMessage];
        return;
    }
    
    if (self.currentUserLocation) {
        searchRouteBlock(self.currentUserLocation);
    } else {
        [self.locationRefreshTimer invalidate]; //Go into manual update mode.
        self.pendingRouteSearchBlock = searchRouteBlock;
        [self showActivityWithText:@"Getting location..."];
        [self requestLocation];
    }
}
                                           
-(void)searchRouteToLocation:(NSObject<RoutableLocationProtocol> *)location fromLocation:(CLLocation *)fromLocation {
//    CLLocation *fromLocation = [[CLLocation alloc] initWithLatitude:60.215413888458 longitude:24.866182201828];
    [self showActivityWithText:@"Getting routes..."];
    
    [self.watchDataManager getRouteToLocation:(RoutableLocation *)location fromCoordLocation:fromLocation routeOptions:self.routeSearchOptions andCompletionBlock:^(NSArray *routes, NSString *errorString){
        if (!errorString && routes && routes.count > 0) {
            for (Route *route in routes) {
                route.fromLocationName = @"Current Location";
                route.toLocationName = location.name;
            }
            [self showRoutes:routes];
        } else {
            [self showAlertWithTitle:@"Oops. Route search failed." andMessage:errorString ? errorString : @"No routes returned from service."];
        }
        
        [self endActivity];
    }];
}

-(void)showRoutes:(NSArray *)routes {
    if (routes && routes.count == 1) {
        [self showRoute:routes[0]];
        return;
    }
    
    //TODO: Filter out expired routes
    NSMutableArray *controllerNames = [@[] mutableCopy];
    NSMutableArray *contexts = [@[] mutableCopy];
    
    for (Route *route in routes) {
        [controllerNames addObject:@"RouteView"];
        [contexts addObject:route];
    }
    
    [self dismissController];
    [self presentControllerWithNames:controllerNames contexts:contexts];
}

-(void)showRoute:(Route *)route {
    if (!route) return;
    [self dismissController];
    [self presentControllerWithName:@"RouteView" context:route];
}

#pragma mark - Locations methods
-(void)saveBookmarksToUserDefaults {
    [self.watchDataManager saveBookmarks:self.namedBookmarks];
}

-(void)loadSavedBookmarks {
    NSArray * savedBookmarks = [self.watchDataManager getSavedNamedBookmarkDictionaries];
    if (savedBookmarks) {
        [self initBookmarksFromBookmarksDictionaries:savedBookmarks];
    }
}

-(void)initBookmarksFromBookmarksDictionaries:(NSArray *)bookmarkdictionaries {
    NSMutableArray *readNamedBookmarks = [@[] mutableCopy];
    if (bookmarkdictionaries) {
        for (NSDictionary *bookmarkDict in bookmarkdictionaries) {
            [readNamedBookmarks addObject:[[NamedBookmarkE alloc] initWithDictionary:bookmarkDict]];
        }
        
        self.namedBookmarks = [NSArray arrayWithArray:readNamedBookmarks];
    }
}

-(NamedBookmarkE *)getHomeBookmark {
    if (self.namedBookmarks.count > 0) {
        NSArray *array = [self.namedBookmarks filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.isHomeAddress == true" ]];
        if (array != nil && array.count > 0) {
            return array[0];
        }
    }
    
    return nil;
}

-(NamedBookmarkE *)getWorkBookmark {
    if (self.namedBookmarks.count > 0) {
        NSArray *array = [self.namedBookmarks filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.isWorkAddress == true" ]];
        if (array != nil && array.count > 0) {
            return array[0];
        }
    }
    
    return nil;
}

-(void)saveRecentLocationIfNotBookmarked:(RoutableLocation *)location {
    if ([location.name.lowercaseString isEqualToString:@"current location"]) return;

    if (self.namedBookmarks.count > 0) {
        for (NamedBookmarkE *bookmark in self.namedBookmarks) {
            if ([bookmark.name isEqualToString:location.name]) return;
        }
    }
    
    //Check it doesnt exit already
    
    [self.watchDataManager saveOtherRecentLocation:location];
}

#pragma mark - Stop methods
-(void)initStopsFromStopsDictionaries:(NSArray *)stopDictionaries {
    NSMutableArray *readStops = [@[] mutableCopy];
    if (stopDictionaries) {
        for (NSDictionary *stopDict in stopDictionaries) {
            StopEntity *stop = [StopEntity initWithDictionary:stopDict];
            if (stop.fetchedFromApi == ReittiHSLApi) {
                [readStops addObject:stop];
            }
        }
        
        self.savedStops = [NSArray arrayWithArray:readStops];
    }
}

-(void)saveStopsToUserDefaults {
    [self.watchDataManager saveStops:self.savedStops];
}

-(void)loadSavedStops {
    NSArray * savedStops = [self.watchDataManager getSavedStopsDictionaries];
    if (savedStops) {
        [self initStopsFromStopsDictionaries:savedStops];
    }
}

-(void)saveStopWithDeparturesToDefaults:(BusStopE *)busStop {
    if (!busStop) return;
    
    NSInteger existingIndex = [self.fetchedStops indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop){
        BusStopE *object = (BusStopE *)obj;
        return [object.code integerValue] == [busStop.code integerValue];
    }];
    
    if (existingIndex != NSNotFound) {
        [self.fetchedStops removeObjectAtIndex:existingIndex];
    }
    
    if (busStop.departures.count > 3 && busStop.lines.count > 0) {
        [self.fetchedStops addObject:busStop];
    }
    
    [self.watchDataManager saveStopsWithDepartures:self.fetchedStops];
}

-(void)loadSavedStopsWithDepartures {
    self.fetchedStops = [[self.watchDataManager getSavedStopsWithDeparturesDictionaries] mutableCopy];
}

-(BusStopE *)fetchStopsWithValidDeparturesForCode:(NSNumber *)stopCode {
    NSInteger existingIndex = [self.fetchedStops indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop){
        BusStopE *object = (BusStopE *)obj;
        return [object.code integerValue] == [stopCode integerValue];
    }];
    
    if (existingIndex == NSNotFound) return nil;
    
    BusStopE *existingStop = self.fetchedStops[existingIndex];
    
    NSInteger sinceDate = [[ReittiStringFormatterE formatHSLDateFromDate:[NSDate date]] integerValue];
    NSInteger sinceTime = [[ReittiStringFormatterE formatHSLHourFromDate:[NSDate date]] integerValue];
    
    NSMutableArray *fDepartures = [@[] mutableCopy];
    for (NSDictionary *dept in existingStop.departures) {
        //                NSLog(@"%@",dept);
        if ([dept[@"date"] integerValue] >= sinceDate || ([dept[@"date"] integerValue] == sinceDate - 1 && sinceTime < 400)) {
            if ([dept[@"time"] integerValue] >= sinceTime) {
                [fDepartures addObject:dept];
            }
        }
    }
    
    existingStop.departures = fDepartures;
    [self saveStopWithDeparturesToDefaults:existingStop];
    
    if (fDepartures.count > 4 && existingStop.lines.count > 0)
        return existingStop;
    else
        return nil;
}

-(void)searchStopForStop:(StopEntity *)stopEntity {
    BusStopE *exitingStop = [self fetchStopsWithValidDeparturesForCode:stopEntity.busStopCode];
    if (exitingStop) {
        NSDictionary *stops = @{@"busStop" : exitingStop, @"stopEntity" : stopEntity};
        [self showStopDepartures:stops];
        return;
    }
    
    [self showActivityWithText:@"Getting departures..."];
    
    [self.watchDataManager fetchStopForCode:[stopEntity.busStopCode stringValue] andCompletionBlock:^(BusStopE *stop, NSString *errorString){
        if (!errorString && stop) {
            NSDictionary *stops = @{@"busStop" : stop, @"stopEntity" : stopEntity};
            [self showStopDepartures:stops];
            [self saveStopWithDeparturesToDefaults:stop];
        } else {
            [self showAlertWithTitle:@"Oops." andMessage:errorString ? errorString : @"Fetching departures failed."];
        }
        
        [self endActivity];
    }];
}

-(void)showStopDepartures:(NSDictionary *)stop {
    [self dismissController];
    [self pushControllerWithName:@"StopDeparturesView" context:stop];
}

#pragma mark - HomeAndWork table controller Delegate methods
-(void)selectedBookmark:(NamedBookmarkE * _Nonnull)bookmark {
    [self checkCurrentLocationAndGetRouteToLocation:bookmark];
}

-(void)selectedNoneExistingBookmark:(NSString * _Nonnull)bookmarkName {
    [self showNoneExistingBookmarkNamed:bookmarkName];
}

#pragma mark - Communication Manager Delegate methods
-(void)receivedNamedBookmarksArray:(NSArray *)bookmarksArray {
    
    NSLog(@"%@", bookmarksArray);
    
    //TODO: Check if anything is modified.
    [self initBookmarksFromBookmarksDictionaries:bookmarksArray];
    [self setUpTableView];
    [self saveBookmarksToUserDefaults];
    
}

-(void)receivedSavedStopsArray:(NSArray *)stopsArray {
    
    [self initStopsFromStopsDictionaries: stopsArray];
    [self setUpTableView];
    [self saveStopsToUserDefaults];
}

-(void)receivedRoutesArray:(NSArray * _Nonnull)routesArray {
    NSLog(@"%@", routesArray);
    if (![routesArray isKindOfClass:[NSArray class]]) return;
    
    NSMutableArray *routes = [@[] mutableCopy];
    for (NSDictionary *routeDict in routesArray) {
        Route *route = [Route initFromDictionary:routeDict];
        if (route) {
            [routes addObject:route];
        }
    }
    
    self.transferredRoutes = routes;
    [self showRoutes:routes];
    if (routes.count > 0) {
        //Set route here in case app is in background. Else set it in route view.
        [[ComplicationDataManager sharedManager] setRoute:routes[0]];
        Route *firstRoute = routes[0];
        if (firstRoute.toLocationName) {
            RoutableLocation *location = [RoutableLocation new];
            location.name = firstRoute.toLocationName;
            location.coords = [WidgetHelpers convert2DCoordToString:firstRoute.destinationCoords];
            [self saveRecentLocationIfNotBookmarked:location];
        }
    }
}

-(void)receivedRoutesSearchOptions:(NSDictionary *)routeSearchOptions {
    self.routeSearchOptions = routeSearchOptions;
    [self.watchDataManager saveRouteSearchOptions:routeSearchOptions];
}

#pragma mark - CLLocation Manager

-(void)requestLocation {
    if (self.locationManager) {
        [self.locationManager requestLocation];
    }
}

-(void)startLocationUpdate {
    [self requestLocation];
    self.locationRefreshTimer = [NSTimer scheduledTimerWithTimeInterval:20 target:self selector:@selector(requestLocation) userInfo:nil repeats:YES];
}

-(void)initLocationManager {
    self.currentUserLocation = nil;
    if (self.locationManager == nil) {
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
        self.locationManager.distanceFilter = kCLDistanceFilterNone;
    }
    
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    if (status == kCLAuthorizationStatusAuthorizedAlways || status == kCLAuthorizationStatusAuthorizedWhenInUse) {
        self.locationAuthorized = YES;
        [self startLocationUpdate];
    } else {
        self.locationAuthorized = NO;
//        [self showLocationNotAuthorizedMessage]; //Looks like app won't start if showing alert at startup
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    if ([locations count] == 0) {
        return;
    }
    
    // success
    self.currentUserLocation = [locations firstObject];
    if (self.pendingRouteSearchBlock) {
        self.pendingRouteSearchBlock(self.currentUserLocation);
        self.pendingRouteSearchBlock = nil;
        [self startLocationUpdate]; //Continue update
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(nonnull NSError *)error {
    // error
    if (self.pendingRouteSearchBlock) {
        self.pendingRouteSearchBlock = nil;
        [self endActivity];
        [self startLocationUpdate]; //Continue update
        
        [self showAlertWithTitle:@"Getting current location failed. Please try again." andMessage:nil];
    }
}

#pragma mark - Activity indicator
-(void)showActivityWithText:(NSString *)activityText {
    [self.activityGroup setHidden:NO];
    
    [self.titleLabel setHidden:YES];
    [self.bookmarksTable setHidden:YES];
    
    if (activityText){
        [self.activityLabel setText:activityText];
        [self.activityLabel setHidden:NO];
    } else {
        [self.activityLabel setHidden:YES];
    }
    [self.activityImage setImageNamed:@"Activity"];
    [self.activityImage startAnimatingWithImagesInRange:NSMakeRange(1, 14) duration:1.3 repeatCount:0];
}

-(void)endActivity {
    [self.titleLabel setHidden:NO];
    [self.bookmarksTable setHidden:NO];
    [self.activityGroup setHidden:YES];
}

#pragma mark - Alert showing
-(void)showAlertWithTitle:(NSString *)title andMessage:(NSString *)message {
    [self showAlertWithTitle:title andMessage:message withActionTitle:nil andAction:nil andCancelAction:nil];
}

-(void)showAlertWithTitle:(NSString *)title andMessage:(NSString *)message withActionTitle:(NSString *)actionTitle andAction:(ActionBlock)actionBlock andCancelAction:(ActionBlock)cancelAction {
    NSMutableArray *actions = [@[] mutableCopy];
    
    if (actionTitle && actionBlock) {
        WKAlertAction *action = [WKAlertAction actionWithTitle:actionTitle style:WKAlertActionStyleDefault handler:actionBlock];
        [actions addObject:action];
    }
    
    WKAlertAction *cancel = [WKAlertAction actionWithTitle:@"OK" style:WKAlertActionStyleDefault handler:cancelAction ? cancelAction : ^{}];
    [actions addObject:cancel];
    
    [self presentAlertControllerWithTitle:title message: message preferredStyle:WKAlertControllerStyleAlert actions:actions];
}

#pragma mark - Specific messages
-(void)showLocationNotAuthorizedMessage {
    [self showAlertWithTitle:@"Unauthorized Location Access" andMessage:@"Please open commuter on your iPhone and tap on current location."];
}

-(void)showNoneExistingBookmarkNamed:(NSString *)bookmarkName {
    [self showAlertWithTitle:nil andMessage:[NSString stringWithFormat:@"%@ address is not set. Set it from Commuter on your iPhone to get directions.", bookmarkName]];
}

@end



