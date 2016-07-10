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
@property (strong, nonatomic) IBOutlet WKInterfaceGroup *activityGroup;

@property (strong, nonatomic) WatchCommunicationManager *communicationManager;
@property (strong, nonatomic) WatchDataManager *watchDataManager;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CLLocation * currentUserLocation;

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
    [self initLocationManager];
    
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
    [self startLocationupdate];
    [super willActivate];
}

- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    [self.locationRefreshTimer invalidate];
    [super didDeactivate];
}

#pragma mark - Table view methods
-(void)setUpTableView {
    NamedBookmarkE *home = [self getHomeBookmark];
    NamedBookmarkE *work = [self getWorkBookmark];
    
    NSMutableArray *otherBookmarks = [self.namedBookmarks mutableCopy];
    if (home) [otherBookmarks removeObject:home];
    if (work) [otherBookmarks removeObject:work];
    
    bool homeOrWorkExist = home || work;
    
    NSMutableArray *rowTypes = [@[] mutableCopy];
    if (homeOrWorkExist)
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
        if (i == 0 && homeOrWorkExist) {
            HomeAndWorkRowController *controller = (HomeAndWorkRowController *)[self.bookmarksTable rowControllerAtIndex:i];
            [controller setUpWithHomeBookmark:home andWorkBookmark:work];
            controller.delegate = self;
        } else if (otherBookmarks.count > 0) {
            LocationRowController *controller = (LocationRowController *)[self.bookmarksTable rowControllerAtIndex:i];
            [controller setUpWithNamedBookmark:otherBookmarks[i - (homeOrWorkExist ? 1 : 0)]];
        }
    }
}

-(void)table:(WKInterfaceTable *)table didSelectRowAtIndex:(NSInteger)rowIndex {
    LocationRowController *controller = (LocationRowController *)[self.bookmarksTable rowControllerAtIndex:rowIndex];
    [self searchRouteToBookmark:controller.bookmark];
}

#pragma mark - Route methods
-(void)searchRouteToBookmark:(NamedBookmarkE *)bookmark {
    CLLocation *fromLocation = [[CLLocation alloc] initWithLatitude:60.215413888458 longitude:24.866182201828];

    //TODO: update location and wait for a new one.
//    if (!self.currentUserLocation) {
//        //TODO: Show alert
//        WKAlertAction *action = [WKAlertAction actionWithTitle:@"OK" style:WKAlertActionStyleDefault handler:^{}];
//        [self presentAlertControllerWithTitle:@"Unauthorized Location Access" message: @"Please open commuter on your iPhone and tap on current location." preferredStyle:WKAlertControllerStyleAlert actions:@[action]];
//        return;
//    }
    [self showActivity];
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
    //TODO: Filter out expired routes
    NSMutableArray *controllerNames = [@[] mutableCopy];
    NSMutableArray *contexts = [@[] mutableCopy];
    
    for (Route *route in routes) {
        [controllerNames addObject:@"RouteView"];
        [contexts addObject:route];
    }
    
    [self presentControllerWithNames:controllerNames contexts:contexts];
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
    [self searchRouteToBookmark:bookmark];
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
    if (routes.count > 0)
        [[ComplicationDataManager sharedManager] setRoute:routes[0]];
}

#pragma mark - CLLocation Manager

-(void)requestLocation {
    if (self.locationManager) {
        [self.locationManager requestLocation];
    }
}

-(void)startLocationupdate {
    [self requestLocation];
    self.locationRefreshTimer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(requestLocation) userInfo:nil repeats:YES];
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
        [self startLocationupdate];
    } else {
        WKAlertAction *action = [WKAlertAction actionWithTitle:@"OK" style:WKAlertActionStyleDefault handler:^{}];
        [self presentAlertControllerWithTitle:@"Unauthorized Location Access" message: @"Please open commuter on your iPhone and tap on current location." preferredStyle:WKAlertControllerStyleAlert actions:@[action]];
    }
    
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    if ([locations count] == 0) {
        // error
        return;
    }
    
    // success
    self.currentUserLocation = [locations firstObject];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(nonnull NSError *)error {
    // error
}

#pragma mark - Activity indicator
-(void)showActivity {
    [self.titleLabel setHidden:YES];
    [self.bookmarksTable setHidden:YES];
    [self.activityGroup setHidden:NO];
//    [self.activityGroup setAlpha:0];
    
    
    [self.activityImage setImageNamed:@"Activity"];
    [self.activityImage startAnimatingWithImagesInRange:NSMakeRange(1, 14) duration:1.3 repeatCount:0];
//    [self animateWithDuration:0.3 animations:^{
//        [self.activityGroup setAlpha:1];
//    }];
}

-(void)endActivity {
    [self.titleLabel setHidden:NO];
    [self.bookmarksTable setHidden:NO];
    [self.activityGroup setHidden:YES];
}

@end



