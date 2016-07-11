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

@interface HomeInterfaceController() <CLLocationManagerDelegate>

@property (strong, nonatomic) NSUserDefaults *sharedDefaults;
@property (strong, nonatomic) NSArray *namedBookmarks;
@property (strong, nonatomic) NSArray *transferredRoutes;

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
    
    self.communicationManager = [WatchCommunicationManager sharedManager];
    self.communicationManager.delegate = self;
    // Configure interface objects here.
    
    //TODO: Read if there are named bookmarks saved
    [self loadSavedBookmarks];
    
    //TODO: Request for new data from phone
    //Setup table view
    [self setUpTableView];
    
}

- (void)willActivate {
    // This method is called when watch view controller is about to be visible to user
    [self initLocationManager];
    [super willActivate];
}

- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    [self.locationRefreshTimer invalidate];
    [super didDeactivate];
}

-(void)handleUserActivity:(NSDictionary *)userInfo {
    NSDate *timeLineEntryDate = [userInfo objectForKey:@"CLKLaunchedTimelineEntryDateKey"];
    if (timeLineEntryDate) { //Launched from complecation
        [self dismissController]; //Dismis routes view if showing
        Route *complicationRoute = [[ComplicationDataManager sharedManager] routeForComplication];
        if (complicationRoute) {
            [self showRoute:complicationRoute];
        }
    }
}

#pragma mark - Table view methods
-(void)setUpTableView {
    NamedBookmarkE *home = [self getHomeBookmark];
    NamedBookmarkE *work = [self getWorkBookmark];
    
    NSMutableArray *otherBookmarks = [self.namedBookmarks mutableCopy];
    if (home) [otherBookmarks removeObject:home];
    if (work) [otherBookmarks removeObject:work];
    
//    bool homeOrWorkExist = home || work;
    
    NSMutableArray *rowTypes = [@[] mutableCopy];
//    if (homeOrWorkExist)
    [rowTypes addObject:@"HomeAndWorkRow"];
    
    for (int i = 0; i < otherBookmarks.count; i++)
        [rowTypes addObject:@"LocationRow"];
    
    if (rowTypes.count == 0) {
        [rowTypes addObject:@"InfoRow"];
        [self.titleLabel setHidden:YES];
    } else {
        [self.titleLabel setHidden:NO];
    }
    
    [self.bookmarksTable setRowTypes:rowTypes];
    
    //Setup home and work first
    
    for (int i = 0; i < self.bookmarksTable.numberOfRows; i++) {
        if (i == 0) {
            HomeAndWorkRowController *controller = (HomeAndWorkRowController *)[self.bookmarksTable rowControllerAtIndex:i];
            [controller setUpWithHomeBookmark:home andWorkBookmark:work];
            controller.delegate = self;
        } else if (otherBookmarks.count > 0) {
            LocationRowController *controller = (LocationRowController *)[self.bookmarksTable rowControllerAtIndex:i];
            [controller setUpWithNamedBookmark:otherBookmarks[i - 1]];
        }
    }
}

-(void)table:(WKInterfaceTable *)table didSelectRowAtIndex:(NSInteger)rowIndex {
    LocationRowController *controller = (LocationRowController *)[self.bookmarksTable rowControllerAtIndex:rowIndex];
    [self checkLocationAndGetRouteToBookmark:controller.bookmark];
}

#pragma mark - Route methods
-(void)checkLocationAndGetRouteToBookmark:(NamedBookmarkE *)bookmark {
    RouteSearchBlock searchRouteBlock = ^(CLLocation *fromLocation){
        [self searchRouteToBookmark:bookmark fromLocation:fromLocation];
    };
    
    if (!self.locationAuthorized) {
        [self showLocationNotAuthorizedMessage];
        return;
    }
    
    //TODO: Check that current location is not old.
    if (self.currentUserLocation) {
        searchRouteBlock(self.currentUserLocation);
    } else {
        [self.locationRefreshTimer invalidate]; //Go into manual update mode.
        self.pendingRouteSearchBlock = searchRouteBlock;
        [self showActivityWithText:@"Getting location..."];
        [self requestLocation];
    }
}
                                           
-(void)searchRouteToBookmark:(NamedBookmarkE *)bookmark fromLocation:(CLLocation *)fromLocation {
//    CLLocation *fromLocation = [[CLLocation alloc] initWithLatitude:60.215413888458 longitude:24.866182201828];
    [self showActivityWithText:@"Getting routes..."];
    [self.watchDataManager getRouteForNamedBookmark:bookmark fromLocation:fromLocation routeOptions:nil andCompletionBlock:^(NSArray *routes, NSString *errorString){
        if (!errorString && routes && routes.count > 0) {
            for (Route *route in routes) {
                route.fromLocationName = @"Current Location";
                route.toLocationName = bookmark.name;
            }
            [self showRoutes:routes];
        } else {
            //TODO: Show error message
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

#pragma mark - Bookmarks method
-(void)saveBookmarksToUserDefaults {
    NSMutableArray *bookmarksArray = [@[] mutableCopy];
    if (self.namedBookmarks) {
        for (NamedBookmarkE *bookmark in self.namedBookmarks) {
            [bookmarksArray addObject:[bookmark dictionaryRepresentation]];
        }
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:bookmarksArray forKey:@"previousReceivedBookmark"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(void)loadSavedBookmarks {
    NSArray * savedBookmarks = [[NSUserDefaults standardUserDefaults] objectForKey:@"previousReceivedBookmark"];
    if (savedBookmarks)
        [self initBookmarksFromBookmarksDictionaries:savedBookmarks];
}

-(void)initBookmarksFromBookmarksDictionaries:(NSArray *)bookmarkdictionaries {
    NSMutableArray *readNamedBookmarks = [@[] mutableCopy];
    if (bookmarkdictionaries) {
        for (NSDictionary *bookmarkDict in bookmarkdictionaries) {
            [readNamedBookmarks addObject:[[NamedBookmarkE alloc] initWithDictionary:bookmarkDict]];
        }
        
        self.namedBookmarks = [NSArray arrayWithArray:readNamedBookmarks];
    }
    
    [self setUpTableView];
}

-(NamedBookmarkE *)getHomeBookmark {
    if (self.namedBookmarks.count > 0) {
        NSArray *array = [self.namedBookmarks filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.name == %@ || self.iconPictureName == %@",@"Home", @"home-100.png" ]];
        if (array != nil && array.count > 0) {
            return array[0];
        }
    }
    
    return nil;
}

-(NamedBookmarkE *)getWorkBookmark {
    if (self.namedBookmarks.count > 0) {
        NSArray *array = [self.namedBookmarks filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.name == %@ || self.iconPictureName == %@",@"Work", @"work-filled-100.png" ]];
        if (array != nil && array.count > 0) {
            return array[0];
        }
    }
    
    return nil;
}

#pragma mark - HomeAndWork table controller Delegate methods
-(void)selectedBookmark:(NamedBookmarkE * _Nonnull)bookmark {
    [self checkLocationAndGetRouteToBookmark:bookmark];
}

-(void)selectedNoneExistingBookmark:(NSString * _Nonnull)bookmarkName {
    [self showNoneExistingBookmarkNamed:bookmarkName];
}

#pragma mark - Communication Manager Delegate methods
-(void)receivedNamedBookmarksArray:(NSArray *)bookmarksArray {
    
    NSLog(@"%@", bookmarksArray);
    
    //TODO: Check if anything is modified.
    [self initBookmarksFromBookmarksDictionaries:bookmarksArray];
    [self saveBookmarksToUserDefaults];
    
}

-(void)receivedRoutesArray:(NSArray * _Nonnull)routesArray {
    NSLog(@"%@", routesArray);
    if (![routesArray isKindOfClass:[NSArray class]]) return;
    
    NSMutableArray *routes = [@[] mutableCopy];
    for (NSDictionary *routeDict in routesArray) {
        Route *route = [Route initFromDictionary:routeDict];
        if (route) [routes addObject:route];
    }
    
    self.transferredRoutes = routes;
    [self showRoutes:routes];
    if (routes.count > 0) //Set route here in case app is in background. Else set it in route view.
        [[ComplicationDataManager sharedManager] setRoute:routes[0]];
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



