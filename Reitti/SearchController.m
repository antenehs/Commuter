//
//  SearchController.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 15/1/14.
//  Copyright (c) 2014 Anteneh Sahledengel. All rights reserved.

#import "SearchController.h"
#import <QuartzCore/QuartzCore.h>
#import "AppDelegate.h"
#import "SVProgressHUD.h"
#import "MyFixedLayoutGuide.h"
#import "RouteSearchViewController.h"
#import "InfoViewController.h"
#import "WidgetSettingsViewController.h"
#import <Social/Social.h>
#import "TSMessage.h"
#import "ReittiNotificationHelper.h"
#import "WelcomeViewController.h"
#import "DetailImageView.h"
#import "AppManager.h"
#import "HSLLiveTrafficManager.h"
#import "Vehicle.h"
#import "CoreDataManager.h"
#import "DroppedPinManager.h"
#import "GCThumbnailAnnotation.h"
#import "ReittiAppShortcutManager.h"
#import "ReittiSearchManager.h"
#import "ASA_Helpers.h"
#import "ReittiAnalyticsManager.h"
#import "ICloudManager.h"
#import "MainTabBarController.h"
#import "ReittiDateFormatter.h"
#import "BikeStation.h"

#define degreesToRadians(x) (M_PI * x / 180.0)
#define radiansToDegrees(x) (x * 180.0 / M_PI)

CGFloat  kDeparturesRefreshInterval = 60;

@interface SearchController ()

@property (nonatomic, strong) id previewingContext;

@end

@implementation SearchController

#define CUSTOME_FONT(s) [UIFont fontWithName:@"Aspergit" size:s]
#define CUSTOME_FONT_BOLD(s) [UIFont fontWithName:@"AspergitBold" size:s]
#define CUSTOME_FONT_LIGHT(s) [UIFont fontWithName:@"AspergitLight" size:s]
#define SYSTEM_GRAY_COLOR [UIColor colorWithWhite:0.1 alpha:0.98]
#define SYSTEM_BLUE_COLOR [UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0];
#define SYSTEM_GREEN_COLOR [UIColor colorWithRed:39.0/255.0 green:174.0/255.0 blue:96.0/255.0 alpha:1.0];
#define SYSTEM_ORANGE_COLOR [UIColor colorWithRed:230.0/255.0 green:126.0/255.0 blue:34.0/255.0 alpha:1.0];

@synthesize managedObjectContext;
@synthesize reittiDataManager, settingsManager;
//@synthesize stopViewController;
@synthesize searchViewHidden;
@synthesize searchedStopList;
@synthesize nearByStopList;
@synthesize disruptionList;
@synthesize currentUserLocation;
@synthesize StopView, searchResultsView;
@synthesize departures, _busStop, _stopLinesDetail;
@synthesize refreshControl;
@synthesize notificationTimer;
@synthesize notificationView;
@synthesize searchResultListViewMode;
@synthesize darkMode, mapMode;
@synthesize droppedPinGeoCode;
@synthesize mapView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initDataComponentsAndModules];
    [self updateAppShortcuts];
    [self reindexSavedDataForSpotlight];
    [self initViewComponents];
    
    if (![AppManager isProVersion])
        [self showGoProNotification];
    
    [self showRateAppNotification];
    
    if ([AppManager isNewInstallOrNewVersion]) {
        if ([AppManager isNewInstall]) {
            [[ReittiAnalyticsManager sharedManager] trackAppInstallationWithDevice:[AppManager iosDeviceModel] osversion:[AppManager iosVersionNumber] value:nil];
        }
        
        [self performSegueWithIdentifier:@"showWelcomeView" sender:self];
        
        //Do new version migrations
        //TODO: The next version me - Esti be clever here and find a way for supporting a version jumping update
        [self.reittiDataManager doVersion4_1CoreDataMigration];
        
        [AppManager setCurrentAppVersion];
    }
    
    [self.navigationController setToolbarHidden:YES animated:NO];
    [self fetchDisruptions];
    
    NSInteger startingIndex = [SettingsManager getStartingIndexTab];
    if (startingIndex >= 0 && startingIndex <= 3) {
        self.tabBarController.selectedIndex = startingIndex;
    }
    
    //Test
//    [AppManager isProVersion];
}

- (void)showRateAppNotification{
    appOpenCount = [self.reittiDataManager getAppOpenCountAndIncreament];
    if (appOpenCount > 5 && ![AppManager isNewInstallOrNewVersion]) {
     
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Enjoy Using The App?"
                                                                       message:@"The gift of 5 little starts is satisfying for both of us more than you think."
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"Rate" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {
                                                                  [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[AppManager appAppstoreRateLink]]];
                                                                  [self.reittiDataManager setAppOpenCountValue:-50];
                                                                  
                                                              }];
        
        UIAlertAction* laterAction = [UIAlertAction actionWithTitle:@"Maybe later" style:UIAlertActionStyleCancel
                                                            handler:^(UIAlertAction * action) {
                                                                [self.reittiDataManager setAppOpenCountValue:-8];
                                                            }];
        
        [alert addAction:laterAction];
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

- (void)showGoProNotification{
    if ([AppManager getAndIncrimentAppOpenCountForGoingPro] < 8)
        return;
    
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Go Pro"
                                                                   message:@"Go pro to get more cool features."
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"Learn more" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {
                                                              [AppManager setAppOpenCountForGoingPro:-20];
                                                              [self performSegueWithIdentifier:@"showProFeatures" sender:self];
                                                          }];
    
    UIAlertAction* appStoreAction = [UIAlertAction actionWithTitle:@"Go to AppStore" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {
                                                              [AppManager setAppOpenCountForGoingPro:-20];
                                                              [[UIApplication sharedApplication] openURL:[NSURL URLWithString:kProAppAppstoreLink]];
                                                          }];
    
    UIAlertAction* laterAction = [UIAlertAction actionWithTitle:@"Maybe later" style:UIAlertActionStyleCancel
                                                          handler:^(UIAlertAction * action) {
                                                              [AppManager setAppOpenCountForGoingPro:-20];
                                                          }];
    
    [alert addAction:laterAction];
    [alert addAction:appStoreAction];
    [alert addAction:defaultAction];
    [self presentViewController:alert animated:YES completion:nil];
}

//-(void)viewWillAppear:(BOOL)animated{
//    [super viewWillAppear:animated];
//    
//    [mainSearchBar asa_setTextColorAndPlaceholderText:[UIColor whiteColor] placeHolderColor:[UIColor lightTextColor]];
//    
//}

- (void)appWillEnterForeground:(NSNotification *)notification {
    [self initDeparturesRefreshTimer];
}

- (void)appWillEnterBackground:(NSNotification *)notification {
    [departuresRefreshTimer invalidate];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];

    [mainSearchBar asa_setTextColorAndPlaceholderText:[UIColor whiteColor] placeHolderColor:[UIColor lightTextColor]];
    
    [self setNavBarSize];
    [mainSearchBar setPlaceholder:@"address, stop or poi"];
    
    //StartVehicleFetching
    if ([settingsManager shouldShowLiveVehicles]) {
        [self startFetchingLiveVehicles];
    }else{
        [self removeAllVehicleAnnotation];
    }
    
    stopFetchActivityIndicator.circleLayer.lineWidth = 1.5;
    stopFetchActivityIndicator.alternatingColors = @[[AppManager systemGreenColor], [AppManager systemOrangeColor]];
    
    if (viewApearForTheFirstTime){
        [self hideNearByStopsView:YES animated:YES];
    }
    
    [self initDeparturesRefreshTimer];
    
    viewApearForTheFirstTime = NO;
}

-(void)viewDidDisappear:(BOOL)animated{
    [reittiDataManager stopFetchingLiveVehicles];
    [self removeAllVehicleAnnotation];
    
    [reittiDataManager stopUpdatingBikeStations];
    
    [departuresRefreshTimer invalidate];
    
    [super viewDidDisappear:animated];
}


- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self setNavBarSize];
    
    [self hideNearByStopsView:[self isNearByStopsListViewHidden] animated:YES];
    
    [centerLocatorView removeFromSuperview];
    [mapView addSubview:centerLocatorView];
}

- (id<UILayoutSupport>)bottomLayoutGuide {
    return [[MyFixedLayoutGuide alloc]initWithLength:bottomLayoutGuide];
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    if (darkMode) {
        return UIStatusBarStyleDefault;
    }else{
        return UIStatusBarStyleDefault;
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:userlocationChangedNotificationName object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:mapModeChangedNotificationName object:nil];
}

#pragma - mark initialization Methods

- (void)initDataComponentsAndModules
{
    [self initVariablesAndConstants];
    [self initDataManagers];
    [self initializeMapComponents];
    [self initDisruptionFetching];
    [self setBookmarkedStopsToDefaults];
    [self registerFor3DTouchIfAvailable];
}

- (void)updateAppShortcuts
{
    if([UIApplicationShortcutItem class]){
        [[ReittiAppShortcutManager sharedManager] updateAppShortcuts];
    }
}

- (void)reindexSavedDataForSpotlight{
    [[ReittiSearchManager sharedManager] updateSearchableIndexes];
}

- (void)initViewComponents
{
    /*init View Components*/
    
    [currentLocationButton asa_updateAsCurrentLocationButtonWithBorderColor:[AppManager systemGreenColor] animated:NO];
    activityIndicator.hidden = NO;
    
    [self initGuestureRecognizers];
    [self setNeedsStatusBarAppearanceUpdate];
    [self setNavBarApearance];
    [self setMapModeForSettings];
    [self setupListTableViewAppearance];
    [self hideNearByStopsView:YES animated:NO];
}

-(void)initDataComponentsAndModulesWithManagedObjectCOntext:(NSManagedObjectContext *)mngdObjectContext{
    self.managedObjectContext = mngdObjectContext;
    [self initDataComponentsAndModules];
}

- (void)initDataManagers
{
    if (self.managedObjectContext == nil) {
        self.managedObjectContext = [[CoreDataManager sharedManager] managedObjectContext];
    }
    
    RettiDataManager * dataManger = [[RettiDataManager alloc] initWithManagedObjectContext:self.managedObjectContext];
    //dataManger.managedObjectContext = self.managedObjectContext;
    self.reittiDataManager = dataManger;
    
    self.settingsManager = [[SettingsManager alloc] initWithDataManager:self.reittiDataManager];
    [self.reittiDataManager setUserLocationToRegion:[settingsManager userLocation]];
    
    //Clean history more than the specified date
    if ([settingsManager isClearingHistoryEnabled]) {
        [self.reittiDataManager clearHistoryOlderThanDays:[settingsManager numberOfDaysToKeepHistory]];
    }
    
    //StartVehicleFetching
    if ([settingsManager shouldShowLiveVehicles]) {
        [self startFetchingLiveVehicles];
    }
    
    //Start Bike station fetching.
    [self startFetchingBikeStations];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(mapModeSettingsValueChanged:)
                                                 name:mapModeChangedNotificationName object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(userLocationSettingsValueChanged:)
                                                 name:userlocationChangedNotificationName object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(shouldShowVehiclesSettingsValueChanged:)
                                                 name:shouldShowVehiclesNotificationName object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
}

- (void)initGuestureRecognizers
{
    stopViewDragGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(dragStopView:)];
    
    [StopView addGestureRecognizer:stopViewDragGestureRecognizer];
    
    searchResultsViewGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(listNearbyStopsPressed:)];
    
    searchResultViewDragGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(dragStopView:)];
    
    [searchResultsView addGestureRecognizer:searchResultViewDragGestureRecognizer];
}

- (void)initVariablesAndConstants
{
    //Vars
    topLayoutGuide = 46;
    bottomLayoutGuide = -10;
    bookmarkViewMode = 0;
    
    //Map vars
    bigAnnotationWidth = 90;
    bigAnnotationHeight = 97;
    smallAnnotationWidth = 35;
    smallAnnotationHeight = 37;
    
    //Default values
    viewApearForTheFirstTime = YES;
    darkMode = YES;
    centerMap = YES;
    isStopViewDisplayed = NO;
    isSearchResultsViewDisplayed = NO;
    justReloading = NO;
    stopViewDragedDown = NO;
    tableViewIsDecelerating = NO;
    requestedForListing = NO;
    departuresTableIndex = nil;
    selectedStopLongCode = nil;
    prevSelectedStopLongCode = nil;
    annotationSelectionChanged = YES;
    lastSelectionDismissed = NO;
    ignoreRegionChange = NO;
    canShowDroppedPin = NO;
    ignoreMapRegionChangeForCurrentLocationButtonStatus = NO;
    retryCount = 0;
    annotationAnimCounter = 0;
    
    firstRecievedLocation = YES;
    userLocationUpdated = NO;
    
    mapMode = MainMapViewModeStopsAndLive;
    
    self.searchResultListViewMode = RSearchResultViewModeNearByStops;
}

-(void)initDeparturesRefreshTimer{
    departuresRefreshTimer = [NSTimer scheduledTimerWithTimeInterval:kDeparturesRefreshInterval target:self selector:@selector(refreshDepartures:) userInfo:nil repeats:YES];
}

-(void)initCenterLocator:(CGPoint)point{
    centerLocatorView = [[UIView alloc] initWithFrame:[self centerLocatorFrameForCenter:point]];
    centerLocatorView.layer.borderWidth = 3.0f;
    centerLocatorView.layer.cornerRadius = 12.0f;
    centerLocatorView.layer.borderColor = [UIColor whiteColor].CGColor;
    centerLocatorView.backgroundColor = [AppManager systemOrangeColor];
    
    centerLocatorView.layer.shadowColor = [UIColor darkGrayColor].CGColor;
    centerLocatorView.layer.shadowOffset = CGSizeMake(0.0f, 1.0f);
    centerLocatorView.layer.shadowRadius = 1.0f;
    centerLocatorView.layer.shadowOpacity = 0.3f;
    
    //Add touch guesture recognizer
    centerTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(centerLocatorTapped:)];
    [centerLocatorView addGestureRecognizer:centerTapRecognizer];
}

- (CGRect)centerLocatorFrameForCenter:(CGPoint)center{
    return CGRectMake(center.x - 12, center.y + 12, 24, 24);
}

- (void)updateCenterLocationPosition{
    if ([self shouldShowDroppedPin]) {
        CGPoint centerPoint = [self visibleMapRectCenter];
        if (centerLocatorView == nil)
            [self initCenterLocator:centerPoint];
        else{
            centerLocatorView.frame = [self centerLocatorFrameForCenter:centerPoint];
        }
        
        [self.view addSubview:centerLocatorView];
        
        CLLocationCoordinate2D coordinate = [mapView convertPoint:centerLocatorView.center toCoordinateFromView:mapView];
        [self searchReverseGeocodeForCoordinate:coordinate];
    }else{
        [centerLocatorView removeFromSuperview];
    }
}

- (void)bounceAnimateCenterLocator {
    //Do spring animation
    CGRect originalFrame = centerLocatorView.frame;
    CGRect shrinkedFrame = CGRectMake(originalFrame.origin.x + 8, originalFrame.origin.y + 8, originalFrame.size.width - 16, originalFrame.size.height - 16);
    CGRect expandedFrame = CGRectMake(originalFrame.origin.x - 2, originalFrame.origin.y - 2, originalFrame.size.width + 4, originalFrame.size.height + 4);
//    centerLocatorView.frame = CGRectMake(self.mapView.center.x - 12, self.mapView.center.y + 12, 24, 24);
    [UIView transitionWithView:searchResultsView duration:0.1 options:UIViewAnimationOptionCurveEaseIn animations:^{
        centerLocatorView.frame = shrinkedFrame;
    } completion:^(BOOL finished) {
        [UIView transitionWithView:searchResultsView duration:0.1 options:UIViewAnimationOptionCurveEaseIn animations:^{
            centerLocatorView.frame = expandedFrame;
        } completion:^(BOOL finished) {
            [UIView transitionWithView:searchResultsView duration:0.1 options:UIViewAnimationOptionCurveEaseIn animations:^{
                centerLocatorView.frame = originalFrame;
            } completion:^(BOOL finished) {}];
        }];
    }];
}

#pragma mark - Nav bar and toolbar methods
- (void)setNavBarSize {
    CGSize navigationBarSize = self.navigationController.navigationBar.frame.size;
    UIView *titleView = self.navigationItem.titleView;
    CGRect titleViewFrame = titleView.frame;
    titleViewFrame.size.width = navigationBarSize.width;
    self.navigationItem.titleView.frame = titleViewFrame;
}

- (void)setNavBarApearance{
    [self setNavBarSize];
    [self.navigationItem setTitle:@""];
    //Set search bar text color
    [mainSearchBar asa_setTextColorAndPlaceholderText:[UIColor whiteColor] placeHolderColor:[UIColor lightTextColor]];
    [mainSearchBar setImage:[UIImage imageNamed:@"search-icon-25.png"] forSearchBarIcon:UISearchBarIconSearch state:UIControlStateNormal];
    if (self.darkMode) {
        mainSearchBar.keyboardAppearance = UIKeyboardAppearanceDark;
    }else{
        mainSearchBar.keyboardAppearance = UIKeyboardAppearanceDefault;
    }
}

-(int)searchViewLowerBound{
    return self.view.bounds.origin.y;
}

#pragma mark - extension methods
- (void)setBookmarkedStopsToDefaults{
    
    NSArray *savedStops = [self.reittiDataManager fetchAllSavedStopsFromCoreData];
    [self.reittiDataManager updateSavedStopsDefaultValueForStops:savedStops];
    //test
//    NSUserDefaults *sharedDefaults2 = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.ewketApps.commuterDepartures"];
//    NSUserDefaults *sharedDefaults2 = [[NSUserDefaults alloc] initWithSuiteName:[AppManager nsUserDefaultsStopsWidgetSuitName]];
}

#pragma mark - Annotation helpers
-(void)openRouteForAnnotationWithTitle:(NSString *)title subtitle:(NSString *)subTitle andCoords:(CLLocationCoordinate2D)coords{
    NSString *toLocationName = [NSString stringWithFormat:@"%@ (%@)", title,subTitle];
    NSString *coordString = [ReittiStringFormatter convert2DCoordToString:coords];
    
    RouteSearchParameters *searchParms = [[RouteSearchParameters alloc] initWithToLocation:toLocationName toCoords:coordString fromLocation:nil fromCoords:nil];
    [self switchToRouteSearchViewWithRouteParameter:searchParms];
    
    [[ReittiAnalyticsManager sharedManager] trackFeatureUseEventForAction:kActionSearchedRoute label:@"From annotation" value:nil];
}

-(void)openRouteForNamedAnnotationWithTitle:(NSString *)title andCoords:(CLLocationCoordinate2D)coords{
    NSString *toLocationName = [NSString stringWithFormat:@"%@", title];
    if (droppedPinGeoCode != nil) {
        if ([title isEqualToString:@"Dropped pin"]) {
            toLocationName = [droppedPinGeoCode getStreetAddressString];
            [[ReittiAnalyticsManager sharedManager] trackFeatureUseEventForAction:kActionSearchedRoute label:@"From dropped pin" value:nil];
        }else{
            [[ReittiAnalyticsManager sharedManager] trackFeatureUseEventForAction:kActionSearchedRoute label:@"From annotation" value:nil];
        }
    }
    
    NSString *coordString = [ReittiStringFormatter convert2DCoordToString:coords];
    
    RouteSearchParameters *searchParms = [[RouteSearchParameters alloc] initWithToLocation:toLocationName toCoords:coordString fromLocation:nil fromCoords:nil];
    [self switchToRouteSearchViewWithRouteParameter:searchParms];
    
    [[ReittiAnalyticsManager sharedManager] trackFeatureUseEventForAction:kActionSearchedRoute label:@"From annotation" value:nil];
}

-(void)openRouteFromAnnotationWithTitle:(NSString *)title andCoords:(CLLocationCoordinate2D)coords{
    NSString *fromLocation = title;
    if (droppedPinGeoCode != nil) {
        if ([title isEqualToString:@"Dropped pin"]) {
            fromLocation = [droppedPinGeoCode getStreetAddressString];
        }
    }
    
    NSString *coordString = [ReittiStringFormatter convert2DCoordToString:coords];
    RouteSearchParameters *searchParms = [[RouteSearchParameters alloc] initWithToLocation:nil toCoords:nil fromLocation:fromLocation fromCoords:coordString];
    [self switchToRouteSearchViewWithRouteParameter:searchParms];
    
    [[ReittiAnalyticsManager sharedManager] trackFeatureUseEventForAction:kActionSearchedRoute label:@"From dropped pin" value:nil];
}

-(void)showNamedBookmark:(NamedBookmark *)namedBookmark{
    selectedNamedBookmark = namedBookmark;
    [self performSegueWithIdentifier:@"showNamedBookmark" sender:nil];
}

-(void)showGeoCode:(GeoCode *)geoCode{
    selectedGeoCode = geoCode;
    [self performSegueWithIdentifier:@"showGeoCode" sender:nil];
}

-(void)showDroppedPinGeoCode{
    if (droppedPinGeoCode != nil) {
        selectedGeoCode = droppedPinGeoCode;
        [self performSegueWithIdentifier:@"showGeoCode" sender:nil];
    }
    
    [[ReittiAnalyticsManager sharedManager] trackFeatureUseEventForAction:kActionOpenGeoLocationFromDroppedPin label:nil value:nil];
}

-(void)openStopViewForCode:(NSNumber *)code shortCode:(NSString *)shortCode name:(NSString *)name andCoords:(CLLocationCoordinate2D)coords{
    selectedStopCode = [NSString stringWithFormat:@"%d", [code intValue]];
    selectedStopAnnotationCoords = coords;
    selectedStopShortCode = shortCode;
    selectedStopName = name;
    [self performSegueWithIdentifier:@"openStopView" sender:nil];
}

-(void)openStopViewForCode:(NSString *)code{
    NSInteger intCode = [code integerValue];
    
    NSNumber *codeNumber = [NSNumber numberWithInteger:intCode];
    
    StopEntity *stop = [reittiDataManager fetchSavedStopFromCoreDataForCode:codeNumber];
    if (!stop)
        return;
    [self openStopViewForCode:codeNumber shortCode:stop.busStopShortCode name:stop.busStopName andCoords:[ReittiStringFormatter convertStringTo2DCoord:stop.busStopCoords]];
}

#pragma - mark StopView methods

- (void)requestStopInfoAsyncForCode:(NSString *)code{
    
//    [self.reittiDataManager fetchStopsForCode:code];
}

- (void)showProgressHUD{
    [activityIndicator beginRefreshing];
    //MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    //hud.labelText = @"Loading...";
//    [SVProgressHUD show];
    //[SVProgressHUD setBackgroundColor:[UIColor grayColor]];
    //[SVProgressHUD setBackgroundColor:[UIColor colorWithWhite:0.95 alpha:1]];
}

#pragma mark - stop detail handling
-(NSMutableDictionary *)stopDetailMap{
    if (!_stopDetailMap) {
        _stopDetailMap = [@{} mutableCopy];
    }
    
    return _stopDetailMap;
}

- (BusStop *)getDetailStopForBusStopShort:(BusStopShort *)shortStop{
    return [self.stopDetailMap objectForKey:[shortStop.code stringValue]];
}

- (BusStop *)getDetailStopForTableViewCell:(NSInteger)section{
    if (nearByStopList.count > section) {
        BusStopShort *stopForCell = [nearByStopList objectAtIndex:section];
        return [self getDetailStopForBusStopShort:stopForCell];
    }
    
    return nil;
}

- (void)setDetailStopForBusStopShort:(BusStopShort *)shortStop busStop:(BusStop *)stop{
    if (stop) {
        [self.stopDetailMap setObject:stop forKey:[shortStop.code stringValue]];
    }
}

- (void)clearStopDetailMap{
    [self.stopDetailMap removeAllObjects];
}

- (BOOL)isthereValidDetailForShortStop:(BusStopShort *)shortStop{
    
    @try {
        BusStop *detailStop = [self getDetailStopForBusStopShort:shortStop];
        
        if (!detailStop || !detailStop.departures || detailStop.departures.count < 1)
            return NO;
        
        NSMutableArray *departuresCopy = [detailStop.departures mutableCopy];
        for (int i = 0; i < departuresCopy.count;i++) {
            StopDeparture *departure = [departuresCopy objectAtIndex:i];
            if ([departure.parsedDate timeIntervalSinceNow] < 0){
                [departuresCopy removeObject:departure];
            }else{
                [detailStop setDepartures:departuresCopy];
                return YES;
            }
            
            if (i == departuresCopy.count - 1) {
                return NO;
            }
        }
    }
    @catch (NSException *exception) {
        return NO;
    }
    
    return NO;
}

- (BOOL)isThereValidDetailForTableViewSection:(NSInteger)section{
    if (nearByStopList.count > section) {
        BusStopShort *stopForCell = [nearByStopList objectAtIndex:section];
        return [self isthereValidDetailForShortStop:stopForCell];
    }
    
    return NO;
}

- (NSInteger)busStopShortIndexForCode:(NSNumber *)code{
    NSInteger index = 0;
    @try {
        for (BusStopShort *stop in nearByStopList) {
            if ([stop.code integerValue] == [code integerValue]) {
                return index;
            }
            
            index++;
        }
    }
    @catch (NSException *exception) {}
    
    return NSNotFound;
}

#pragma mark - nearby stops list methods
-(void)setupNearByStopsListTableviewFor:(NSArray *)nearByStops{
    if (![self isNearByStopsListViewHidden]) {
        if (nearByStops.count > 3) {
            [self fetchStopsDetailsForBusStopShorts:[nearByStops objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 3)]]];
        }else{
            [self fetchStopsDetailsForBusStopShorts:nearByStops];
        }
        
//        [self clearStopDetailMap];
    }
    
    [self setupTableViewForNearByStops:nearByStops];
}
-(void)setupTableViewForNearByStops:(NSArray *)result{
    self.searchResultListViewMode = RSearchResultViewModeNearByStops;
    [nearbyStopsListsTable reloadData];
    [nearbyStopsListsTable scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
}
-(void)setupListTableViewAppearance{
    nearbyStopsListsTable.backgroundColor = [UIColor clearColor];
    [searchResultsView setBlurTintColor:nil];
    searchResultsView.layer.borderWidth = 0.5;
    searchResultsView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    
    hideSearchResultViewButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
}

-(void)hideNearByStopsView:(BOOL)hidden animated:(BOOL)anim{
    
    [UIView transitionWithView:searchResultsView duration:anim ? 0.3 : 0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        [self hideNearByStopsView:hidden];
    } completion:^(BOOL finished) {
        //For a little bounce effect
        if (!hidden) {
            [UIView transitionWithView:searchResultsView duration:anim ? 0.2 : 0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                [self increamentNearByStopViewTopSpaceBy:10];
            } completion:^(BOOL finished) {}];
        }
    }];
}

- (void)hideNearByStopsView:(BOOL)hidden{
    if (hidden) {
        [self setNearbyStopsViewTopSpacing:self.view.frame.size.height - 44 - self.tabBarController.tabBar.frame.size.height];
        isSearchResultsViewDisplayed = NO;
    }else{
        [self setNearbyStopsViewTopSpacing:self.view.frame.size.height/2 - 10];
        isSearchResultsViewDisplayed = YES;
    }
    
    if(!hidden)
        [self setupNearByStopsListTableviewFor:self.nearByStopList];
}

- (void)decelerateStopListViewFromVelocity:(CGFloat)velocity withCompletionBlock:(ActionBlock)completionBlock{
    
    [UIView animateWithDuration:1 delay:0 usingSpringWithDamping:0.9 initialSpringVelocity:0.5 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        [self increamentNearByStopViewTopSpaceBy:velocity/4];
    } completion:^(BOOL finished) {
        if (completionBlock) {
            completionBlock();
        }
    }];
}

- (CGFloat)nearbyStopViewTopSpacing{
    return nearByStopsViewTopSpacing.constant;
}

- (void)setNearbyStopsViewTopSpacing:(CGFloat)topSpace{
    if (topSpace < 0)
        topSpace = 0;
    
    if (topSpace > self.view.frame.size.height - 44 - self.tabBarController.tabBar.frame.size.height)
        topSpace = self.view.frame.size.height - 44 - self.tabBarController.tabBar.frame.size.height;

    CGFloat spaceDiff = topSpace - nearByStopsViewTopSpacing.constant;
    
    nearByStopsViewTopSpacing.constant = topSpace;
    [self.view layoutSubviews];
    
    if ([self isNearByStopsListViewHidden]) {
        [hideSearchResultViewButton setImage:[UIImage imageNamed:@"list-white-100.png"] forState:UIControlStateNormal];
        searchResultsLabel.text = @"LIST NEARBY STOPS";
    }else{
        [hideSearchResultViewButton setImage:[UIImage imageNamed:@"reload-128.png"] forState:UIControlStateNormal];
        searchResultsLabel.text = @"NEARBY STOPS";
    }
    
    //Set center locator position
    [self updateCenterLocationPosition];
    
    //Adjust map
    [self scrollMapViewByPoint:CGPointMake(0, -spaceDiff/2) animated:NO];
    
}

- (void)increamentNearByStopViewTopSpaceBy:(CGFloat)increament{
    [self setNearbyStopsViewTopSpacing:nearByStopsViewTopSpacing.constant + increament];
}

- (BOOL)isNearByStopsListViewHidden{
    return [self nearbyStopViewTopSpacing] > self.view.frame.size.height - 60 - self.tabBarController.tabBar.frame.size.height;
}

- (void)moveSearchResultViewByPoint:(CGPoint)displacement animated:(BOOL)anim{
    [UIView transitionWithView:searchResultsView duration:0.15 options:UIViewAnimationOptionCurveEaseIn animations:^{
        [self increamentNearByStopViewTopSpaceBy:displacement.y];
    } completion:^(BOOL finished) {
        [self hideNearByStopsView:NO animated:YES];
    }];
}

- (void)showStopFetchActivityIndicator:(BOOL)show{
    if ([self isNearByStopsListViewHidden]) {
        hideSearchResultViewButton.hidden = NO;
        [stopFetchActivityIndicator endRefreshing];
        return;
    }
    
    hideSearchResultViewButton.hidden = show;
    
    if (show){
        [stopFetchActivityIndicator beginRefreshing];
    }else{
        [stopFetchActivityIndicator endRefreshing];
    }
}

//- (void)listNearByStops{
//    
//    MKCoordinateSpan span = {.latitudeDelta =  0.02, .longitudeDelta =  0.02};
//    MKCoordinateSpan minSpan = {.latitudeDelta =  0.01, .longitudeDelta =  0.01};
//    
//    //Stop annotations are removed so request new
//    requestedForListing = YES;
//    MKCoordinateRegion region = mapView.region;
//    
//    if (region.span.latitudeDelta > 0.02) {
//        region.span = span;
//    }
//    
//    if (region.span.latitudeDelta < 0.01) {
//        region.span = minSpan;
//    }
//    
//    [self showProgressHUD];
//    
//    [self fetchStopsInMapViewRegion:region];
//}

#pragma mark - Table view datasource and delegate methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (self.nearByStopList.count == 0)
        return 1;
    
    return self.nearByStopList.count > 30 ? 30 : self.nearByStopList.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([self isThereValidDetailForTableViewSection:section]) {
        BusStop *detailStop = [self getDetailStopForTableViewCell:section];
        if (detailStop && detailStop.departures) {
            if (detailStop.departures.count == 0) {
                return 1;
            }else if (detailStop.departures.count == 1) {
                return 2;
            }else if (detailStop.departures.count == 2){
                return 3;
            }else{
                return 4;
            }
        }
        return 1;
    }
    
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    
    if (nearByStopList.count > 0) {
        BusStopShort *stop = [nearByStopList objectAtIndex:indexPath.section];
        
        if (indexPath.row == 0) {
            cell = [nearbyStopsListsTable dequeueReusableCellWithIdentifier:@"searchResultCell"];
            
            UIImageView *imageView = (UIImageView *)[cell viewWithTag:3001];
            [imageView setImage:[AppManager stopAnnotationImageForStopType:stop.stopType]];
            
            UILabel *codeLabel = (UILabel *)[cell viewWithTag:3004];
            codeLabel.text = @"";
            
            NSString *linesString = nil;
            if ([self isThereValidDetailForTableViewSection:indexPath.section]) {
                BusStop *detailStop = [self getDetailStopForBusStopShort:stop];
                linesString = detailStop.linesString;
            }
            
            NSString *shortCode = stop.codeShort != nil && ![stop.codeShort isEqualToString:@""] ? stop.codeShort : nil;
            if(linesString && shortCode){
                codeLabel.text = [NSString stringWithFormat:@"Code: %@ · %@",shortCode, linesString];
            }else if(linesString && !shortCode){
                codeLabel.text = [NSString stringWithFormat:@"Code: %@", linesString];
            }else if (!linesString && shortCode){
                codeLabel.text = [NSString stringWithFormat:@"Code: %@", shortCode];
            }else{
                codeLabel.text = @"";
            }
            
            UILabel *nameLabel = (UILabel *)[cell viewWithTag:3002];
            nameLabel.text = stop.name;
            
            UILabel *distanceLabel = (UILabel *)[cell viewWithTag:3003];
            distanceLabel.text = [NSString stringWithFormat:@"%dm", [stop.distance intValue]];
            
            return cell;
        }else{
            cell = [nearbyStopsListsTable dequeueReusableCellWithIdentifier:@"departureCell"];
            
            BusStop *detailStop = [self getDetailStopForBusStopShort:stop];
            
            StopDeparture *departure = [detailStop.departures objectAtIndex:(indexPath.row - 1)];
            
            @try {
                UILabel *timeLabel = (UILabel *)[cell viewWithTag:1001];
                NSString *formattedHour = [[ReittiDateFormatter sharedFormatter] formatHourStringFromDate:departure.parsedDate];
                
                if ([departure.parsedDate timeIntervalSinceNow] < 300) {
                    timeLabel.attributedText = [ReittiStringFormatter highlightSubstringInString:formattedHour
                                                                                       substring:formattedHour
                                                                                  withNormalFont:timeLabel.font];
                    ;
                }else{
                    timeLabel.text = formattedHour;
                }
                
                UILabel *codeLabel = (UILabel *)[cell viewWithTag:1003];
                
                codeLabel.text = departure.code;
                
                UILabel *destinationLabel = (UILabel *)[cell viewWithTag:1004];
                destinationLabel.text = departure.destination;
                
                return cell;
            }
            @catch (NSException *exception) {}
        }
    }else{
        cell = [nearbyStopsListsTable dequeueReusableCellWithIdentifier:@"noStopCell"];
        UILabel *infoLabel = (UILabel *)[cell viewWithTag:2003];
        
        if (nearbyStopsFetchErrorMessage) {
            infoLabel.text = nearbyStopsFetchErrorMessage;
        }else{
            infoLabel.text = @"No Stops Nearby";
        }
    }
	
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row > 0) {
        return 35;
    }
    
    return 60;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 1.0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 10.0;
}

#pragma mark - Nearby stops list departures methods

#pragma - mark Map methods

- (void)initializeMapComponents
{
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.distanceFilter = kCLDistanceFilterNone;
    locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
    [locationManager startUpdatingLocation];
    [locationManager requestWhenInUseAuthorization];
    
    mapView.showsBuildings = YES;
    mapView.pitchEnabled = YES;
    
}

/**
 Region of the map not covered by the nearbylist tableview
 */
-(MKCoordinateRegion)visibleMapRegion{
    return [self.mapView convertRect:[self visibleMapRect] toRegionFromView:self.mapView.superview];
}

/**
 Rect of the map not covered by the nearbylist tableview in the self.view coordinate system
 */
-(CGRect)visibleMapRect{
    CGRect fullMapFrame = self.mapView.frame;
    CGFloat visibleHeight = [self nearbyStopViewTopSpacing];
    
    fullMapFrame.size.height = visibleHeight;
    
    return fullMapFrame;
}

-(CGPoint)visibleMapRectCenter{
    CGRect visibleRect = [self visibleMapRect];
    
    return CGPointMake(visibleRect.origin.x + visibleRect.size.width/2, visibleRect.origin.y + visibleRect.size.height/2 );
}

-(void)scrollMapViewByPoint:(CGPoint)point animated:(BOOL)animated{
    CGPoint currentCenter = [self.mapView convertCoordinate:self.mapView.region.center toPointToView:self.mapView];
    currentCenter.x += point.x;
    currentCenter.y += point.y;
    
    CLLocationCoordinate2D coordinate = [self.mapView convertPoint:currentCenter toCoordinateFromView:self.mapView];
    ignoreRegionChange = YES;
    [mapView setCenterCoordinate:coordinate animated:animated];
}

-(BOOL)centerMapRegionToCoordinate:(CLLocationCoordinate2D)coordinate{
    
    BOOL toReturn = YES;
    
    if (![self isLocationServiceAvailableWithNotification:NO]) {
        if ([settingsManager userLocation] == HSLRegion) {
            //Helsinki center location
            coordinate = kHslRegionCenter;
        }else{
            //tampere center location
            coordinate = kTreRegionCenter;
        }
        
        toReturn = NO;
    }
    
    CGFloat spanSize = 0.005;
    
    if (![self isNearByStopsListViewHidden]) {
        //Adjust for the span difference
        CGFloat heightRatio = [self visibleMapRect].size.height/self.mapView.frame.size.height;
        CGFloat spanDiff = spanSize * (1 - heightRatio);
        
        coordinate.latitude =  coordinate.latitude - spanDiff/2;
    }
    
    MKCoordinateSpan span = {.latitudeDelta =  spanSize, .longitudeDelta =  spanSize};
    MKCoordinateRegion region = {coordinate, span};
    
    //If centered on current user location. Set mode before the region is changed. Longitude is used for the check,
    //because latitude could be changed depending on nearby lists position
    if (toReturn && coordinate.longitude == self.currentUserLocation.coordinate.longitude) {
        [mapView setUserTrackingMode:MKUserTrackingModeNone];
        [currentLocationButton asa_updateAsCenteredAtCurrentLocationWithBackgroundColor:[AppManager systemGreenColor] animated:YES];
        ignoreMapRegionChangeForCurrentLocationButtonStatus = YES;
    }
    
    [mapView setRegion:region animated:YES];
    
    return toReturn;
}

-(BOOL)isLocationServiceAvailableWithNotification:(BOOL)notify{
    BOOL accessGranted = [CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse;
    BOOL locationServicesEnabled = [CLLocationManager locationServicesEnabled];
    
    if (!locationServicesEnabled) {
        if (notify) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Uh-Oh"
                                                                message:@"Looks like location services is not enabled. Enable it from Settings."
                                                               delegate:self
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:@"Settings", nil];
            alertView.tag = 2003;
            [alertView show];
        }
        
        return NO;
    }
    
    if (!accessGranted) {
        if (notify) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Uh-Oh"
                                                                message:@"Looks like access is not granted to this app for location services. Grant access from Settings."
                                                               delegate:self
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:@"Settings", nil];
            alertView.tag = 2003;
            [alertView show];
        }
    
        return NO;
    }
    
    return YES;
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    self.currentUserLocation = [locations lastObject];
    if (centerMap) {
        [self centerMapRegionToCoordinate:self.currentUserLocation.coordinate];
        centerMap = NO;
    }
    
    if (!firstRecievedLocation && !userLocationUpdated) {
        Region currentRegion = [self.reittiDataManager getRegionForCoords:self.currentUserLocation.coordinate];
        
        if (currentRegion != [settingsManager userLocation]) {
            if (currentRegion == HSLRegion || currentRegion == TRERegion) {
                //Notify and ask for confirmation
                [settingsManager setUserLocation:currentRegion];
                if (![AppManager isNewInstallOrNewVersion]) {
                    NSString *title = [NSString stringWithFormat:@"Moved to the %@?",[reittiDataManager getNameOfRegion:currentRegion]];
                    NSString *body = [NSString stringWithFormat:@"Your location has been updated to %@. You can change it anytime from settings.",[reittiDataManager getNameOfRegion:currentRegion]];
                    
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
                                                                        message:body
                                                                       delegate:self
                                                              cancelButtonTitle:@"Settings"
                                                              otherButtonTitles:@"Cool", nil];
                    alertView.tag = 1003;
                    [alertView show];
                }
            }else{
                [settingsManager setUserLocation:FINRegion];
            }
        }
        
        userLocationUpdated = YES;
        
        [self fetchDisruptions];
    }
    
    firstRecievedLocation = false;
}

- (NSMutableArray *)collectStopCodes:(NSArray *)stopList
{
    
    NSMutableArray *codeList = [[NSMutableArray alloc] init];
    for (BusStopShort *stop in stopList) {
        [codeList addObject:stop.code];
    }
    return codeList;
}

- (NSArray *)collectStopsForCodes:(NSArray *)codeList fromStops:(NSArray *)stopList
{
    return [stopList filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"%@ containsObject:self.code",codeList ]];
}

-(void)plotStopAnnotations:(NSArray *)stopList{
    @try {
        NSMutableArray *codeList;
        codeList = [self collectStopCodes:stopList];
        
        NSMutableArray *annotToRemove = [[NSMutableArray alloc] init];
        NSMutableArray *newStops = [[NSMutableArray alloc] init];
        
        if (stopList.count > 0) {
            //This is to avoid the flickering effect of removing and adding annotations
            for (id<MKAnnotation> annotation in mapView.annotations) {
                if ([annotation isKindOfClass:[JPSThumbnailAnnotation class]]) {
                    JPSThumbnailAnnotation *annot = (JPSThumbnailAnnotation *)annotation;
                    
                    if (![codeList containsObject:annot.code]) {
                        //Remove stop if it doesn't exist in the new list
                        if (annot.annotationType == NearByStopType) {
                            [annotToRemove addObject:annotation];
                        }
                    }else{
                        //remove annot if type is bus because it might have been updated with another call from pubtrans
                        [codeList removeObject:annot.code];
                    }
                }
            }
            newStops = [NSMutableArray arrayWithArray:[self collectStopsForCodes:codeList fromStops:stopList]];
            
            [mapView removeAnnotations:annotToRemove];
            
            NSMutableArray *allAnots = [@[] mutableCopy];
            
            for (BusStopShort *stop in newStops) {
                UIImage *stopImage = [AppManager stopAnnotationImageForStopType:stop.stopType];
                
                CLLocationCoordinate2D coordinate = [ReittiStringFormatter convertStringTo2DCoord:stop.coords];
                if (coordinate.latitude < 30 || coordinate.latitude > 90 || coordinate.longitude < 10 || coordinate.longitude > 90)
                    continue;
                NSString * name = stop.name;
                NSString * codeShort = stop.codeShort ? stop.codeShort : @"";
                
                JPSThumbnail *stopAnT = [[JPSThumbnail alloc] init];
                stopAnT.image = stopImage;
                stopAnT.code = stop.code;
                stopAnT.shortCode = codeShort;
                stopAnT.title = name;
                stopAnT.subtitle = [NSString stringWithFormat:@"Code: %@", codeShort];
                stopAnT.coordinate = coordinate;
                stopAnT.annotationType = NearByStopType;
                stopAnT.stopType = stop.stopType;
                stopAnT.reuseIdentifier = @"NearByStopAnnotation";
                stopAnT.primaryButtonBlock = ^{ [self openRouteForAnnotationWithTitle:name subtitle:codeShort andCoords:coordinate];};
                if (stop.code) {
                    stopAnT.secondaryButtonBlock = ^{ [self openStopViewForCode:stop.code shortCode:codeShort name:name andCoords:coordinate];};
                    stopAnT.disclosureBlock = ^{ [self openStopViewForCode:stop.code shortCode:codeShort name:name andCoords:coordinate];};
                }
                
                [allAnots addObject:[JPSThumbnailAnnotation annotationWithThumbnail:stopAnT]];
            }
            
            if (allAnots.count > 0) {
                @try {
                    [self.mapView addAnnotations:allAnots];
                }
                @catch (NSException *exception) {
                     NSLog(@"Adding annotations failed!!! Exception %@", exception);
                }
            }
        }
    }
    @catch (NSException *exception) {
        NSLog(@"Adding annotations failed!!! Exception %@", exception);
    }
}

-(void)plotStopAnnotation:(BusStopShort *)stop withSelect:(bool)select{
    for (id<MKAnnotation> annotation in mapView.annotations) {
        if ([annotation isKindOfClass:[JPSThumbnailAnnotation class]]) {
            JPSThumbnailAnnotation *sAnnotation = (JPSThumbnailAnnotation *)annotation;
            if ([sAnnotation.code intValue] == [stop.code intValue]) {
                [mapView removeAnnotation:annotation];
            }
            
            if (sAnnotation.annotationType == SearchedStopType) {
                [mapView removeAnnotation:annotation];
            }
        }
    }
    
    CLLocationCoordinate2D coordinate = [ReittiStringFormatter convertStringTo2DCoord:stop.coords];
    
    NSString * name = stop.name;
    NSString * shortCode = stop.codeShort ? stop.codeShort : @"";
    
    JPSThumbnail *stopAnT = [[JPSThumbnail alloc] init];
    UIImage *stopImage = [AppManager stopAnnotationImageForStopType:stop.stopType];
    stopAnT.image = stopImage;
    stopAnT.code = stop.code;
    stopAnT.shortCode = shortCode;
    stopAnT.title = name;
    stopAnT.subtitle = [NSString stringWithFormat:@"Code: %@", shortCode];
    stopAnT.coordinate = coordinate;
    stopAnT.annotationType = SearchedStopType;
    stopAnT.reuseIdentifier = @"SearchedStopAnnotation";
    stopAnT.primaryButtonBlock = ^{ [self openRouteForAnnotationWithTitle:name subtitle:shortCode andCoords:coordinate];};
    if (stop.code) {
        stopAnT.secondaryButtonBlock = ^{ [self openStopViewForCode:stop.code  shortCode:shortCode name:name  andCoords:coordinate];};
        stopAnT.disclosureBlock = ^{ [self openStopViewForCode:stop.code  shortCode:shortCode name:name  andCoords:coordinate];};
    }
    JPSThumbnailAnnotation *annot = [JPSThumbnailAnnotation annotationWithThumbnail:stopAnT];
    [mapView addAnnotation:annot];
    
//    StopAnnotation *newAnnotation = [[StopAnnotation alloc] initWithTitle:shortCode andSubtitle:name andCoordinate:coordinate];
//    newAnnotation.code = stop.code;
//    newAnnotation.isSelected = select;
//    
//    [mapView addAnnotation:newAnnotation];
    
    if (select) {
        [mapView selectAnnotation:annot animated:YES];
    }
    
    [self centerMapRegionToCoordinate:[ReittiStringFormatter convertStringTo2DCoord:stop.coords]];

}

-(void)plotGeoCodeAnnotation:(GeoCode *)geoCode{
    
    for (id<MKAnnotation> annotation in mapView.annotations) {
        if ([annotation isKindOfClass:[JPSThumbnailAnnotation class]]) {
            JPSThumbnailAnnotation *sAnnotation = (JPSThumbnailAnnotation *)annotation;
            if (sAnnotation.annotationType == SearchedStopType) {
                [mapView removeAnnotation:annotation];
            }
        }
    }
        
    CLLocationCoordinate2D coordinate = [ReittiStringFormatter convertStringTo2DCoord:geoCode.coords];
    NSString * name = @"";
    NSString * city = @"";
    
    if (geoCode.getLocationType == LocationTypePOI) {
        name = geoCode.name;
        city = geoCode.city;
    }else if (geoCode.getLocationType  == LocationTypeAddress){
        name = [NSString stringWithFormat:@"%@ %@", geoCode.name, geoCode.getHouseNumber];
        city = geoCode.city;
    }else{
        //[self plotStopAnnotation:<#(StopEntity *)#> forCoordinate:<#(NSString *)#>]
    }
    
    JPSThumbnail *geoAnT = [[JPSThumbnail alloc] init];
    geoAnT.image = [UIImage imageNamed:@"geoCodeAnnotation2.png"];
    geoAnT.title = name;
    geoAnT.subtitle = city;
    geoAnT.coordinate = coordinate;
    geoAnT.annotationType = GeoCodeType;
    geoAnT.reuseIdentifier = @"geoLocationAnnotation";
    geoAnT.primaryButtonBlock = ^{ [self openRouteForAnnotationWithTitle:name subtitle:city andCoords:coordinate];};
    geoAnT.secondaryButtonBlock = ^{ [self showGeoCode:geoCode];};
    JPSThumbnailAnnotation *annot = [JPSThumbnailAnnotation annotationWithThumbnail:geoAnT];
    [mapView addAnnotation:annot];
    
    [mapView selectAnnotation:annot animated:YES];

    [self centerMapRegionToCoordinate:coordinate];
    
//    GeoCodeAnnotation *newAnnotation = [[GeoCodeAnnotation alloc] initWithTitle:name andSubtitle:city coordinate:coordinate andLocationType:geoCode.getLocationType];
    
//    [mapView addAnnotation:newAnnotation];
}

-(void)plotNamedBookmarkAnnotation:(NamedBookmark *)namedBookmark{
    
    for (id<MKAnnotation> annotation in mapView.annotations) {
        if ([annotation isKindOfClass:[JPSThumbnailAnnotation class]]) {
            JPSThumbnailAnnotation *sAnnotation = (JPSThumbnailAnnotation *)annotation;
            if (sAnnotation.annotationType == SearchedStopType) {
                [mapView removeAnnotation:annotation];
            }
        }
    }
    
    CLLocationCoordinate2D coordinate = [ReittiStringFormatter convertStringTo2DCoord:namedBookmark.coords];
    NSString * name = @"";
    NSString * subtitle = @"";
    
    
    name = namedBookmark.name;
    subtitle = [NSString stringWithFormat:@"%@, %@", namedBookmark.streetAddress , namedBookmark.city];
    
    JPSThumbnail *bookmrkAnT = [[JPSThumbnail alloc] init];
    bookmrkAnT.image = [UIImage imageNamed:@"geoCodeAnnotation2.png"];
    bookmrkAnT.title = name;
    bookmrkAnT.subtitle = subtitle;
    bookmrkAnT.coordinate = coordinate;
    bookmrkAnT.annotationType = GeoCodeType;
    bookmrkAnT.reuseIdentifier = @"geoLocationAnnotation";
    bookmrkAnT.primaryButtonBlock = ^{ [self openRouteForNamedAnnotationWithTitle:name andCoords:coordinate];};
    bookmrkAnT.secondaryButtonBlock = ^{ [self showNamedBookmark:namedBookmark];};
    JPSThumbnailAnnotation *annot = [JPSThumbnailAnnotation annotationWithThumbnail:bookmrkAnT];
    [mapView addAnnotation:annot];
    
    [mapView selectAnnotation:annot animated:YES];
    
    [self centerMapRegionToCoordinate:coordinate];
    
}


- (void)dropAnnotation:(CLLocationCoordinate2D)coordinate{
//    if (gestureRecognizer.state != UIGestureRecognizerStateBegan)
//        return;
    
    for (id<MKAnnotation> annotation in mapView.annotations) {
        if ([annotation isKindOfClass:[GCThumbnailAnnotation class]]) {
//            GCThumbnailAnnotation *sAnnotation = (GCThumbnailAnnotation *)annotation;
            [mapView removeAnnotation:annotation];
        }
    }
    
    GCThumbnail *annotTN = [[GCThumbnail alloc] init];
    annotTN.image = [UIImage imageNamed:@"dropped-pin-annotation.png"];
    annotTN.title = @"Dropped pin";
    annotTN.subtitle = @"Searching address";
    annotTN.coordinate = coordinate;
//    annotTN.annotationType = DroppedPinType;
    annotTN.reuseIdentifier = @"geoLocationAnnotation";
    annotTN.primaryButtonBlock = ^{ [self openRouteFromAnnotationWithTitle:@"Dropped pin" andCoords:coordinate];};
    annotTN.secondaryButtonBlock = ^{ [self openRouteForNamedAnnotationWithTitle:@"Dropped pin" andCoords:coordinate];};
    annotTN.middleButtonBlock = ^{ [self showDroppedPinGeoCode];};
    GCThumbnailAnnotation *annot = [GCThumbnailAnnotation annotationWithThumbnail:annotTN];
    [mapView addAnnotation:annot];
    
    droppedPinLocation = @"Dropped pin";
    droppedPinCoords = coordinate;
    
    droppedPinGeoCode = [[GeoCode alloc] init];
    droppedPinGeoCode.name = @"Unknown address";
    droppedPinGeoCode.matchedName = @"Unknown address";
    droppedPinGeoCode.city = @"Unknown";
    droppedPinGeoCode.coords = [ReittiStringFormatter convert2DCoordToString:coordinate];
    [droppedPinGeoCode setLocationType:LocationTypeDroppedPin];
    
    [[DroppedPinManager sharedManager] setDroppedPin:self.droppedPinGeoCode];
    
    //Find the coordinate for the center. Not the annotation
    CLLocationCoordinate2D coords = [mapView convertPoint:centerLocatorView.center toCoordinateFromView:mapView];
    [self searchReverseGeocodeForCoordinate:coords];
}

-(void)plotBikeStationAnnotations:(NSArray *)stationList{
    @try {
        if (stationList && stationList.count > 0) {
            
            [self removeAllBikeStationAnnotations];
            
            NSMutableArray *allAnots = [@[] mutableCopy];
            for (BikeStation *station in stationList) {
                if (![ReittiMapkitHelper isValidCoordinate:station.coordinates])
                    continue;
                NSString * name = station.name;
                NSString * codeShort = station.stationId;
                
                JPSThumbnail *bikeAnT = [[JPSThumbnail alloc] init];
                bikeAnT.image = [UIImage imageNamed:[AppManager stationAnnotionImageNameForBikeStation:station]];
//                stopAnT.code = station.stationId;
                bikeAnT.shortCode = codeShort;
                bikeAnT.title = name;
                bikeAnT.subtitle = [NSString stringWithFormat:@"%@ - %@", station.bikesAvailableString, station.spacesAvailableString];
                bikeAnT.coordinate = station.coordinates;
                bikeAnT.annotationType = BikeStationType;
                bikeAnT.reuseIdentifier = [AppManager stationAnnotionImageNameForBikeStation:station];
                bikeAnT.primaryButtonBlock = ^{ [self openRouteForAnnotationWithTitle:name subtitle:codeShort andCoords:station.coordinates];};
                
                [allAnots addObject:[JPSThumbnailAnnotation annotationWithThumbnail:bikeAnT]];
            }
            
            if (allAnots.count > 0) {
                @try {
                    [self.mapView addAnnotations:allAnots];
                }
                @catch (NSException *exception) {
                    NSLog(@"Adding annotations failed!!! Exception %@", exception);
                }
            }
            
            isShowingBikeAnnotations = YES;
        }
    }
    @catch (NSException *exception) {
        NSLog(@"Adding annotations failed!!! Exception %@", exception);
    }
}

- (NSMutableArray *)collectVehicleCodes:(NSArray *)vehicleList
{
    
    NSMutableArray *codeList = [[NSMutableArray alloc] init];
    for (Vehicle *vehicle in vehicleList) {
        [codeList addObject:vehicle.vehicleId];
    }
    return codeList;
}

- (NSArray *)collectVehiclesForCodes:(NSArray *)codeList fromVehicles:(NSArray *)vehicleList
{
    return [vehicleList filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"%@ containsObject:self.vehicleId",codeList ]];
}

- (double)getHeadingForDirectionFromCoordinate:(CLLocationCoordinate2D)fromLoc toCoordinate:(CLLocationCoordinate2D)toLoc
{
    double fLat = degreesToRadians(fromLoc.latitude);
    double fLng = degreesToRadians(fromLoc.longitude);
    double tLat = degreesToRadians(toLoc.latitude);
    double tLng = degreesToRadians(toLoc.longitude);
    
    double degree = radiansToDegrees(atan2(sin(tLng-fLng)*cos(tLat), cos(fLat)*sin(tLat)-sin(fLat)*cos(tLat)*cos(tLng-fLng)));
    
    if (degree >= 0) {
        return degree;
    } else {
        return 360+degree;
    }
}

-(void)plotVehicleAnnotations:(NSArray *)vehicleList isTrainVehicles:(BOOL)isTrain{
//    for (id<MKAnnotation> annotation in mapView.annotations) {
//        if ([annotation isKindOfClass:[LVThumbnailAnnotation class]]) {
////            LVThumbnailAnnotation *sAnnotation = (LVThumbnailAnnotation *)annotation;
//            [mapView removeAnnotation:annotation];
//        }
//    }
    
    NSMutableArray *codeList = [self collectVehicleCodes:vehicleList];
    
    NSMutableArray *annotToRemove = [[NSMutableArray alloc] init];
    
    NSMutableArray *existingVehicles = [[NSMutableArray alloc] init];
    
    for (id<MKAnnotation> annotation in mapView.annotations) {
        if ([annotation isKindOfClass:[LVThumbnailAnnotation class]]) {
            LVThumbnailAnnotation *annot = (LVThumbnailAnnotation *)annotation;
            
//            if (isTrain) {
//                if (annot.vehicleType != VehicleTypeTrain) {
//                    continue;
//                }
//            }else{
//                if (annot.vehicleType == VehicleTypeTrain) {
//                    continue;
//                }
//            }
            
            if (![codeList containsObject:annot.code]) {
                [annotToRemove addObject:annotation];
            }else{
                [codeList removeObject:annot.code];
                [existingVehicles addObject:annotation];
            }
        }
    }
    
    for (id<MKAnnotation> annotation in existingVehicles) {
        if ([annotation isKindOfClass:[LVThumbnailAnnotation class]]) {
            LVThumbnailAnnotation *annot = (LVThumbnailAnnotation *)annotation;
            @try {
                Vehicle *vehicleToUpdate = [[self collectVehiclesForCodes:@[annot.code] fromVehicles:vehicleList] firstObject];
                
                if (vehicleToUpdate.vehicleType == VehicleTypeBus ) {
                    vehicleToUpdate.bearing = [self getHeadingForDirectionFromCoordinate:annot.coordinate toCoordinate:vehicleToUpdate.coords];
                    //Vehicle did not move
                    if (vehicleToUpdate.bearing == 0) {
                        vehicleToUpdate.bearing = [annot.thumbnail.bearing doubleValue];
                    }else{
                        [annot updateVehicleImage:[AppManager vehicleImageForVehicleType:vehicleToUpdate.vehicleType]];
                    }
                }
                
                annot.coordinate = vehicleToUpdate.coords;
                
                if (vehicleToUpdate.bearing != -1) {
                    [((NSObject<LVThumbnailAnnotationProtocol> *)annot) updateBearing:[NSNumber numberWithDouble:vehicleToUpdate.bearing]];
                }
            }
            @catch (NSException *exception) {
                NSLog(@"Failed to update annotation for vehicle with code: %@", annot.code);
                [annotToRemove addObject:annot];
                [codeList addObject:annot.code];
            }
        }
    }
    
    [mapView removeAnnotations:annotToRemove];
    
    NSArray *newVehicles = [self collectVehiclesForCodes:codeList fromVehicles:vehicleList];
//    [mapView removeAnnotations:mapView.annotations];
    
    for (Vehicle *vehicle in newVehicles) {
        LVThumbnail *vehicleAnT = [[LVThumbnail alloc] init];
        vehicleAnT.bearing = [NSNumber numberWithDouble:vehicle.bearing];
        if (vehicle.bearing != -1 ) {
            vehicleAnT.image = [AppManager vehicleImageForVehicleType:vehicle.vehicleType];
        }else{
            vehicleAnT.image = [AppManager vehicleImageWithNoBearingForVehicleType:vehicle.vehicleType];
        }
        vehicleAnT.code = vehicle.vehicleId;
        vehicleAnT.title = vehicle.vehicleName;
        vehicleAnT.lineId = vehicle.vehicleLineId;
        vehicleAnT.vehicleType = vehicle.vehicleType;
        vehicleAnT.coordinate = vehicle.coords;
        vehicleAnT.reuseIdentifier = [NSString stringWithFormat:@"reusableIdentifierFor%@", vehicle.vehicleId];
        
        [mapView addAnnotation:[LVThumbnailAnnotation annotationWithThumbnail:vehicleAnT]];
    }
}

-(void)removeAllVehicleAnnotation{
    for (id<MKAnnotation> annotation in mapView.annotations) {
        if ([annotation isKindOfClass:[LVThumbnailAnnotation class]]) {
            [mapView removeAnnotation:annotation];
        }
    }
}

-(void)removeAllGeocodeAnnotation{
    for (id<MKAnnotation> annotation in mapView.annotations) {
        if ([annotation isKindOfClass:[GCThumbnailAnnotation class]]) {
            [mapView removeAnnotation:annotation];
        }
    }
}

- (MKAnnotationView *)mapView:(MKMapView *)_mapView viewForAnnotation:(id <MKAnnotation>)annotation {
//    static NSString *identifier = @"otherLocations";
//    static NSString *selectedIdentifier = @"selectedLocation";
    static NSString *poiIdentifier = @"poiIdentifier";
    
    if ([annotation conformsToProtocol:@protocol(JPSThumbnailAnnotationProtocol)]) {
        return [((NSObject<JPSThumbnailAnnotationProtocol> *)annotation) annotationViewInMap:mapView];
    }else if ([annotation conformsToProtocol:@protocol(LVThumbnailAnnotationProtocol)]) {
        
        return [((NSObject<LVThumbnailAnnotationProtocol> *)annotation) annotationViewInMap:mapView];
    }else if ([annotation conformsToProtocol:@protocol(GCThumbnailAnnotationProtocol)]) {
        if ([annotation isKindOfClass:[GCThumbnailAnnotation class]]) {
            droppedPinAnnotationView = [((NSObject<GCThumbnailAnnotationProtocol> *)annotation) annotationViewInMap:mapView];
        }
        
        return [((NSObject<GCThumbnailAnnotationProtocol> *)annotation) annotationViewInMap:mapView];
    }else if ([annotation isKindOfClass:[GeoCodeAnnotation class]]) {
        MKAnnotationView *annotationView = (MKAnnotationView *) [_mapView dequeueReusableAnnotationViewWithIdentifier:poiIdentifier];
        if (annotationView == nil) {
            annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:poiIdentifier];
            annotationView.enabled = YES;
            annotationView.image = [UIImage imageNamed:@"locationAnnotation.png"];
            [annotationView setFrame:CGRectMake(0, 0, bigAnnotationWidth, bigAnnotationHeight)];
            annotationView.centerOffset = CGPointMake(0,-48);
            
        }else{
            annotationView.annotation = annotation;
        }
        
        return annotationView;
    }
    
    return nil;
}

- (void)mapView:(MKMapView *)affectedMapView didSelectAnnotationView:(MKAnnotationView *)view{
    if ([view conformsToProtocol:@protocol(JPSThumbnailAnnotationViewProtocol)]) {
        ignoreRegionChange = YES;
        [((NSObject<JPSThumbnailAnnotationViewProtocol> *)view) didSelectAnnotationViewInMap:mapView];
        selectedAnnotationView = (NSObject<JPSThumbnailAnnotationViewProtocol> *)view;
        id<MKAnnotation> ann = view.annotation;
        CLLocationCoordinate2D coord = ann.coordinate;
//        NSLog(@"lat = %f, lon = %f", coord.latitude, coord.longitude);
        
        NSString *fromCoordsString = [NSString stringWithFormat:@"%f,%f", self.currentUserLocation.coordinate.longitude, self.currentUserLocation.coordinate.latitude];
        
        NSString *toCoordsString = [NSString stringWithFormat:@"%f,%f", coord.longitude, coord.latitude];
        
        [self.reittiDataManager getFirstRouteForFromCoords:fromCoordsString andToCoords:toCoordsString andCompletionBlock:^(NSArray *result, NSString *error, ReittiApi usedApi){
            if (!error) {
                [self routeSearchDidComplete:result];
            }else{
                [self routeSearchDidFail:error];
            }
        }];
        
        if ([view.annotation isKindOfClass:[JPSThumbnailAnnotation class]])
        {
            JPSThumbnailAnnotation *stopAnnotation = (JPSThumbnailAnnotation *)view.annotation;
            NSString *code = @"";
            if([stopAnnotation.thumbnail.code isKindOfClass:[NSNumber class]])
                code = [stopAnnotation.thumbnail.code stringValue];
            else{
                code = (NSString *)stopAnnotation.thumbnail.code;
            }
            
            [self.reittiDataManager fetchStopsForCode:code andCoords:coord withCompletionBlock:^(BusStop *stop, NSString *errorString){
                if (!errorString) {
                    [self detailStopFetchCompleted:stop];
                }
            }];
        }
        
        [centerLocatorView removeFromSuperview];
        if (droppedPinAnnotationView)
            [mapView removeAnnotation:droppedPinAnnotationView.annotation];
        
    }else if ([view conformsToProtocol:@protocol(GCThumbnailAnnotationViewProtocol)]) {
        [((NSObject<GCThumbnailAnnotationViewProtocol> *)view) didSelectAnnotationViewInMap:mapView];
    }else if ([view conformsToProtocol:@protocol(LVThumbnailAnnotationViewProtocol)]) {
//        id<MKAnnotation> annotation = [mapView.selectedAnnotations objectAtIndex:0];
//        if ([annotation isKindOfClass:[LVThumbnailAnnotation class]]) {
//            LVThumbnailAnnotation *annot = (LVThumbnailAnnotation *)annotation;
//            if (annot.lineId != nil) {
//                [self.reittiDataManager fetchLineInfoForCodeList:annot.lineId];
//            }
//        }
    }
}

- (void)mapView:(MKMapView *)affectedMapView didDeselectAnnotationView:(MKAnnotationView *)view{
//    MKAnnotationView *annotationView = [[MKAnnotationView alloc] initWithAnnotation:view.annotation reuseIdentifier:@"otherLocations"];
//    @try{
//        [affectedMapView removeAnnotation:view.annotation];
//        [affectedMapView addAnnotation:annotationView.annotation];
//    }@catch(id anException){
//        //do nothing, obviously it wasn't attached because an exception was thrown
//    }
//    [self hideCommandView:NO animated:YES];
    
    if ([view conformsToProtocol:@protocol(JPSThumbnailAnnotationViewProtocol)]) {
        [((NSObject<JPSThumbnailAnnotationViewProtocol> *)view) didDeselectAnnotationViewInMap:mapView];
        selectedAnnotationView = nil;
    }
    
    if ([view conformsToProtocol:@protocol(GCThumbnailAnnotationViewProtocol)]) {
        [((NSObject<GCThumbnailAnnotationViewProtocol> *)view) didDeselectAnnotationViewInMap:mapView];
        selectedAnnotationView = nil;
    }
}

- (void)mapView:(MKMapView *)mapViewToUse deselectStopAnnotation:(StopAnnotation *)annotation{
    
    annotation.isSelected = NO;
    
    MKAnnotationView *prevAnnotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"otherLocations"];
    @try{
        [mapViewToUse removeAnnotation:annotation];
        [mapViewToUse addAnnotation:prevAnnotationView.annotation];
    }@catch(id anException){
        //do nothing, obviously it wasn't attached because an exception was thrown
    }

}

- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views {
    
    MKAnnotationView *aV;
    for (aV in views) {
        //CGRectMake(0, 0, bigAnnotationWidth, bigAnnotationHeight)
        //CGRectMake(0, 0, smallAnnotationWidth, smallAnnotationHeight)
        if ([aV.annotation isKindOfClass:[StopAnnotation class]]) {
            //StopAnnotation *sAnnotation = (StopAnnotation *)aV.annotation;
            //[lastSelectedAnnotation.code intValue] != [sAnnotation.code intValue]
            if (annotationSelectionChanged) {
                CGRect endFrame = aV.frame;
                
                //large to small animation
                if (endFrame.size.width == smallAnnotationWidth && lastSelectionDismissed) {
                    aV.frame = CGRectMake(aV.frame.origin.x - ((aV.frame.size.width/2) + (smallAnnotationWidth/2)),
                                          aV.frame.origin.y - (aV.frame.size.height + smallAnnotationHeight),
                                          bigAnnotationWidth, bigAnnotationHeight);
                    lastSelectionDismissed = NO;
                }else if(endFrame.size.width == bigAnnotationWidth){
                    aV.frame = CGRectMake(aV.frame.origin.x + ((aV.frame.size.width/2) - (smallAnnotationWidth/2)),
                                          aV.frame.origin.y + (aV.frame.size.height - smallAnnotationHeight),
                                          smallAnnotationWidth, smallAnnotationHeight);
                }else{
                    aV.frame = CGRectMake(aV.frame.origin.x + (aV.frame.size.width/4) ,
                                          aV.frame.origin.y + aV.frame.size.height/2,
                                          smallAnnotationWidth/2, smallAnnotationHeight/2);
                }
                
                [UIView beginAnimations:nil context:NULL];
                [UIView setAnimationDuration:0.25];
                [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
                [aV setFrame:endFrame];
                [UIView commitAnimations];
                
                //Used just to allow animation of the first selection
                if (lastSelectedAnnotation != nil)
                    annotationAnimCounter++;
            }
        }else if([aV.annotation isKindOfClass:[GeoCodeAnnotation class]]){
//            [self setUpCommandViewForAnnotation:aV.annotation];
//            [self hideCommandView:NO animated:YES];
            
            CGRect endFrame = aV.frame;
            aV.frame = CGRectMake(aV.frame.origin.x + aV.frame.size.width/2,
                                  aV.frame.origin.y + aV.frame.size.height,
                                  0, 0);
            [UIView beginAnimations:nil context:NULL];
            [UIView setAnimationDuration:0.25];
            [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
            [aV setFrame:endFrame];
            [UIView commitAnimations];
        }else if ([aV.annotation isKindOfClass:[JPSThumbnailAnnotation class]]){
            JPSThumbnailAnnotation *annot = (JPSThumbnailAnnotation *)aV.annotation ;
            if (annot.annotationType == DroppedPinType || annot.annotationType == GeoCodeType) {
                CGRect endFrame = aV.frame;
                
                aV.frame = CGRectMake(endFrame.origin.x, -40, endFrame.size.width, endFrame.size.height);
                
                [UIView beginAnimations:nil context:NULL];
                [UIView setAnimationDuration:0.25];
                [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
                [aV setFrame:endFrame];
                [UIView commitAnimations];
            }
        }
        
    }
}

- (void)openAnnotation:(id)annotation;
{
    //mv is the mapView
    [mapView selectAnnotation:annotation animated:YES];
    
}

- (void)removeAllStopAnnotations {
    NSMutableArray *tempArray = [@[] mutableCopy];
    for (id<MKAnnotation> annotation in mapView.annotations) {
        if ([annotation isKindOfClass:[JPSThumbnailAnnotation class]]) {
            JPSThumbnailAnnotation *annot = (JPSThumbnailAnnotation *)annotation;
            
            if (annot.annotationType == NearByStopType) {
                [tempArray addObject:annot];
            }
        }
    }
    
    [self.mapView removeAnnotations:tempArray];
}

- (void)removeAllBikeStationAnnotations {
    for (id<MKAnnotation> annotation in mapView.annotations) {
        if ([annotation isKindOfClass:[JPSThumbnailAnnotation class]]) {
            JPSThumbnailAnnotation *annot = (JPSThumbnailAnnotation *)annotation;
            if (annot.annotationType == BikeStationType) {
                [mapView removeAnnotation:annotation];
            }
        }
    }
    
    isShowingBikeAnnotations = NO;
}

-(void)mapViewDidFinishLoadingMap:(MKMapView *)mapView{
    canShowDroppedPin = YES;
}

- (void)mapView:(MKMapView *)_mapView regionWillChangeAnimated:(BOOL)animated{
    if (ignoreRegionChange)
        return;
    
    if (currentLocationButton.tag != kCompasModeCurrentLocationButtonTag) {
        currentLocationButton.alpha = 0.3;
    }
    
    if (centerLocatorView != nil){
        centerLocatorView.alpha = 0.3;
    }
    [self removeAllGeocodeAnnotation];
}



- (void)mapView:(MKMapView *)_mapView regionDidChangeAnimated:(BOOL)animated{
    if (ignoreRegionChange){
        ignoreRegionChange = NO;
        return;
    }
    
    if (self.mapMode == MainMapViewModeStops || self.mapMode == MainMapViewModeStopsAndLive) {
        if ([self shouldShowNearByStops]) {
            if ([self shouldUpdateNearByStops]){
                [self fetchStopsInMapViewRegion:[self visibleMapRegion]];
                //If the location is valid, save the center
                previousValidLocation = [[CLLocation alloc] initWithLatitude:self.mapView.region.center.latitude longitude:self.mapView.region.center.longitude];
                
            }
            
            if (self.allBikeStations && !isShowingBikeAnnotations)
                [self plotBikeStationAnnotations:self.allBikeStations];
        }else{
            [self removeAllStopAnnotations];
            [self removeAllBikeStationAnnotations];
            nearByStopList = @[];
            nearbyStopsFetchErrorMessage = @"Zoom in to get nearby stops.";
            [self setupTableViewForNearByStops:nearByStopList];
        }
    }
    
    [self updateCenterLocationPosition];
    
    currentLocationButton.alpha = 1;
    listNearbyStops.alpha = 1;
    
    //the third check is because setting usertracking mode changes the region and the tag of the button might not yet be updated at that time.
    if (currentLocationButton.tag == kCenteredCurrentLocationButtonTag && !ignoreMapRegionChangeForCurrentLocationButtonStatus && mapView.userTrackingMode != MKUserTrackingModeFollowWithHeading) {
        [currentLocationButton asa_updateAsCurrentLocationButtonWithBorderColor:[AppManager systemGreenColor] animated:YES];
        [mapView setUserTrackingMode:MKUserTrackingModeNone];
    }
    
    if (currentLocationButton.tag == kCompasModeCurrentLocationButtonTag && mapView.userTrackingMode != MKUserTrackingModeFollowWithHeading ) {
        [currentLocationButton asa_updateAsCurrentLocationButtonWithBorderColor:[AppManager systemGreenColor] animated:YES];
    }
    
    if (centerLocatorView != nil){
        centerLocatorView.alpha = 1;
        [self bounceAnimateCenterLocator];
    }
    
    ignoreMapRegionChangeForCurrentLocationButtonStatus = NO;
}

-(BOOL)shouldShowDroppedPin{
    
    if (!canShowDroppedPin) {
        return NO;
    }
    
    if (mapView.userTrackingMode == MKUserTrackingModeFollowWithHeading) {
        return NO;
    }
    
    //if there is another seleced annotation
    if (mapView.selectedAnnotations != nil && mapView.selectedAnnotations.count > 0) {
        id<MKAnnotation> annotation = [mapView.selectedAnnotations objectAtIndex:0];
        if (![annotation isKindOfClass:[LVThumbnailAnnotation class]]) {
            return NO;
        }
    }
    
    //Check if the region is out of supported regions
    CGPoint centerPoint = self.mapView.center;
    CLLocationCoordinate2D coordinate = [mapView convertPoint:centerPoint toCoordinateFromView:mapView];
    
//    Region pointRegion = [reittiDataManager getRegionForCoords:coordinate];
//    
//    if (pointRegion == OtherRegion) {
//        return NO;
//    }
    
    //Check if at least 250m from current location
    CLLocation *location = [[CLLocation alloc] initWithLatitude:coordinate.latitude longitude:coordinate.longitude];
    CLLocationDistance dist = [location distanceFromLocation:self.currentUserLocation];
    if (dist < 250 && self.currentUserLocation != nil) {
        return NO;
    }
    
    //Check the zoom level
    if ([self zoomLevelForMapRect:mapView.visibleMapRect withMapViewSizeInPixels:mapView.bounds.size] < 10) {
        return NO;
    }
    
    //Do not show if the list view is taking more than 2/3 of the screen
    if ([self nearbyStopViewTopSpacing] < self.view.frame.size.height/3) {
        return NO;
    }
    
    return YES;
}

-(BOOL)shouldShowNearByStops{
    //Check the zoom level
    if ([self zoomLevelForMapRect:mapView.visibleMapRect withMapViewSizeInPixels:mapView.bounds.size] >= 14)
        return YES;
    
    return NO;
}

-(BOOL)shouldUpdateNearByStops{
    
    CLLocation *currentCenteredLocation = [[CLLocation alloc] initWithLatitude:self.mapView.region.center.latitude longitude:self.mapView.region.center.longitude];

    if (!previousValidLocation || !currentCenteredLocation)
        return YES;
    
    CLLocationDistance dist = [previousValidLocation distanceFromLocation:currentCenteredLocation];
    if (dist > 70)
        return YES;
    
    return NO;
}

-(NSUInteger)zoomLevelForMapRect:(MKMapRect)mRect withMapViewSizeInPixels:(CGSize)viewSizeInPixels
{
    NSUInteger zoomLevel = 20; // MAXIMUM_ZOOM is 20 with MapKit
    MKZoomScale zoomScale = mRect.size.width / viewSizeInPixels.width; //MKZoomScale is just a CGFloat typedef
    double zoomExponent = log2(zoomScale);
    zoomLevel = (NSUInteger)(20 - ceil(zoomExponent));
    return zoomLevel;
}



#pragma mark - disruptions methods
- (void)initDisruptionFetching{
    //init a timer
    [self fetchDisruptions];
    refreshTimer = [NSTimer scheduledTimerWithTimeInterval:90 target:self selector:@selector(fetchDisruptions) userInfo:nil repeats:YES];
}

- (void)fetchDisruptions{
    [self.reittiDataManager fetchDisruptionsWithCompletionBlock:^(NSArray *disruption, NSString *errorString){
        if (!errorString) {
            [self disruptionFetchDidComplete:disruption];
        }else{
            [self disruptionFetchDidFail:errorString];
        }
    }];
}

- (void)showDisruptionCustomBadge:(bool)show{
//    if (customBadge == nil && show) {
//        customBadge = [CustomBadge customBadgeWithString:@"!"
//                                                      withStringColor:[UIColor whiteColor]
//                                                       withInsetColor:[UIColor colorWithRed:230.0/255.0 green:126.0/255.0 blue:34.0/255.0 alpha:1.0] withBadgeFrame:YES
//                                                  withBadgeFrameColor:[UIColor whiteColor]
//                                                            withScale:1.0
//                                                          withShining:NO];
//        [customBadge setFrame:CGRectMake(infoAndAboutButton.frame.origin.x + infoAndAboutButton.frame.size.width - 3 - customBadge.frame.size.width/2, infoAndAboutButton.frame.origin.y - customBadge.frame.size.height/2, customBadge.frame.size.width, customBadge.frame.size.height)];
//        
//        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOnBadgeDetected)];
//        tapGesture.delegate = self;
//        
//        [customBadge addGestureRecognizer:tapGesture];
//        
//        [rightNavButtonsView addSubview:customBadge];
//    }else{
//        customBadge.hidden = !show;
//    }
    UITabBarItem *moreTabBarItem = [self.tabBarController.tabBar.items objectAtIndex:4];

    if (show) {
        moreTabBarItem.badgeValue = @"!";
    }else{
        moreTabBarItem.badgeValue = nil;
    }
}

- (void)tapOnBadgeDetected{
//    [self performSegueWithIdentifier:@"infoViewSegue" sender:nil ];
}


#pragma mark - text field mehthods

//- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
//    
////    [self.view endEditing:YES];
////    
////    if (![searchBar.text isEqualToString:@""]) {
////        [self requestStopInfoAsyncForCode:[searchBar.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
////        [self showProgressHUD];
////    }
//}

//- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
//    
//}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar{
    [self performSegueWithIdentifier: @"addressSearchController" sender: self];
}

//- (void)searchBarTextDidEndEditing:(UISearchBar *)thisSearchBar {
//    //[thisSearchBar setFrame:searchBarFrame];
//}

#pragma - mark View transition methods

- (IBAction)openRouteSearchView:(id)sender{
    RouteSearchParameters *searchParms = [[RouteSearchParameters alloc] initWithToLocation:mainSearchBar.text toCoords:prevSearchedCoords fromLocation:nil fromCoords:nil];
    [self switchToRouteSearchViewWithRouteParameter:searchParms];
}

//- (void)openRouteViewToNamedBookmarkNamed:(NSString *)bookmarkName{
//    NamedBookmark *bookmark = [self.reittiDataManager fetchSavedNamedBookmarkFromCoreDataForName:bookmarkName];
//    if (bookmark) {
//        RouteSearchParameters *searchParms = [[RouteSearchParameters alloc] initWithToLocation:bookmark.name toCoords:bookmark.coords fromLocation:@"Current location" fromCoords:nil];
//        [self switchToRouteSearchViewWithRouteParameter:searchParms];
//    }
//}

-(void)openRouteViewForSavedRouteWithName:(NSString *)savedRoute{
    RouteEntity *route = [self.reittiDataManager fetchSavedRouteFromCoreDataForCode:savedRoute];
    if (route) {
        RouteSearchParameters *searchParms = [[RouteSearchParameters alloc] initWithToLocation:route.toLocationName toCoords:route.toLocationCoordsString fromLocation:route.fromLocationName fromCoords:route.fromLocationCoordsString];
        [self switchToRouteSearchViewWithRouteParameter:searchParms];
    }
}

- (void)openRouteViewForFromLocation:(MKDirectionsRequest *)directionsInfo{
    MKMapItem *source = directionsInfo.source;
    NSString *fromLocation, *fromCoords, *toLocation, *toCoords;
    if (source.isCurrentLocation) {
        fromLocation = @"Current location";
    }else{
        fromCoords = [NSString stringWithFormat:@"%f,%f",source.placemark.location.coordinate.longitude, source.placemark.location.coordinate.latitude];
        fromLocation = [NSString stringWithFormat:@"%@",
                                       [[source.placemark.addressDictionary objectForKey:@"FormattedAddressLines"] componentsJoinedByString:@" "]
                                       ];
    }
    
    MKMapItem *destination = directionsInfo.destination;
    if (destination.isCurrentLocation) {
        toLocation = @"Current location";
    }else{
        toCoords = [NSString stringWithFormat:@"%f,%f",destination.placemark.location.coordinate.longitude, destination.placemark.location.coordinate.latitude];
//        NSLog(@"Address of placemark: %@", ABCreateStringWithAddressDictionary(destination.placemark.addressDictionary, NO));
//        NSLog(@"Address Dictionary: %@",destination.placemark.addressDictionary);
        if ([destination.placemark.addressDictionary objectForKey:@"FormattedAddressLines"] != nil) {
            toLocation = [NSString stringWithFormat:@"%@",
                                           [[destination.placemark.addressDictionary objectForKey:@"FormattedAddressLines"] componentsJoinedByString:@" "]
                                           ];
        }else{
            toLocation = [NSString stringWithFormat:@"%@, %@",
                                           [destination.placemark.addressDictionary objectForKey:@"Street"],
                                           [destination.placemark.addressDictionary objectForKey:@"City"]
                                          ];
        }
    }
    
    RouteSearchParameters *searchParms = [[RouteSearchParameters alloc] initWithToLocation:toLocation toCoords:toCoords fromLocation:fromLocation fromCoords:fromCoords];
    [self switchToRouteSearchViewWithRouteParameter:searchParms];
}

-(void)openWidgetSettingsView{
    [self performSegueWithIdentifier:@"openWidgetSettingFromHome" sender:self];
}

#pragma mark - helper methods


- (GeoCode *)castNamedBookmarkToGeoCode:(NamedBookmark *)namedBookmark{
    GeoCode * newGeoCode = [[GeoCode alloc] init];
    newGeoCode.name = namedBookmark.name;
    
    return newGeoCode;
}

#pragma - mark IBActions

- (IBAction)centerCurrentLocationButtonPressed:(id)sender {
    [self isLocationServiceAvailableWithNotification:YES];
    
    if (currentLocationButton.tag == kNormalCurrentLocationButtonTag) {
        [self centerMapRegionToCoordinate:self.currentUserLocation.coordinate];
    }else if (currentLocationButton.tag == kCenteredCurrentLocationButtonTag) {
        //Make sure the properties are set in this order
        [mapView setUserTrackingMode:MKUserTrackingModeFollowWithHeading animated:YES];
        [currentLocationButton asa_updateAsCompassModeCurrentLocationWithBackgroundColor:[AppManager systemGreenColor] animated:YES];
        ignoreMapRegionChangeForCurrentLocationButtonStatus = YES;
    }else if (currentLocationButton.tag == kCompasModeCurrentLocationButtonTag) {
        [mapView setUserTrackingMode:MKUserTrackingModeNone];
        [currentLocationButton asa_updateAsCurrentLocationButtonWithBorderColor:[AppManager systemGreenColor] animated:YES];
    }
    
}

- (IBAction)listNearbyStopsPressed:(id)sender {
    if ([self isNearByStopsListViewHidden]) {
        [self hideNearByStopsView:NO animated:YES];
        [[ReittiAnalyticsManager sharedManager] trackFeatureUseEventForAction:kActionListNearByStops label:nil value:nil];
    }else{
        [self hideNearByStopsView:YES animated:YES];
    }
}

- (IBAction)refreshOrShowListButtonPressed:(id)sender{
    if ([self isNearByStopsListViewHidden]) {
        [self listNearbyStopsPressed:self];
    }else{
        [departuresRefreshTimer invalidate];
        [self initDeparturesRefreshTimer];
        [self refreshDepartures:self];
    }
}

- (IBAction)refreshDepartures:(id)sender{
    if(![self isNearByStopsListViewHidden]){
        //Show activity indicator no matter what
        [self showStopFetchActivityIndicator:YES];
        [self performSelector:@selector(showStopFetchActivityIndicator:) withObject:NO afterDelay:1];
        
        [self setupNearByStopsListTableviewFor:self.nearByStopList];
        
    }
}

- (void)centerLocatorTapped:(id)sender{
    CGPoint mapCenter = centerLocatorView.center;
    //The center has to be moved up from the center so that the annotation will be positioned right above it.
    mapCenter.y -= 20;
    
    CLLocationCoordinate2D coordinate = [mapView convertPoint:mapCenter toCoordinateFromView:mapView];
    
    [self dropAnnotation:coordinate];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag == 1001) {
//        if (buttonIndex == 0) {
//            [self.reittiDataManager setAppOpenCountValue:-7];
//        }else if(buttonIndex == 1){
//            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[AppManager appAppstoreLink]]];
//            [self.reittiDataManager setAppOpenCountValue:-50];
//        }
    }else if (alertView.tag == 1003) {
        if (buttonIndex == 0) {
            [self openSettingsButtonPressed:self];
        }
    }else if (alertView.tag == 2003) {
        if (buttonIndex == 1) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
        }
    }
}

-(IBAction)dragStopView:(UIPanGestureRecognizer *)recognizer {
    
    CGPoint translation = [recognizer translationInView:self.view];
    if ((recognizer.view.frame.origin.y + translation.y) > ([self searchViewLowerBound])  ) {
        [self increamentNearByStopViewTopSpaceBy:translation.y];
    }
    
    if (recognizer.state != UIGestureRecognizerStateEnded){
        stopViewDragedDown = translation.y > 0;
        stopViewDragVelocity = [recognizer velocityInView:self.view];
    }
    
    [recognizer setTranslation:CGPointMake(0, 0) inView:self.view];
    
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        //Continue the drag acceleration
//        NSLog(@"Velocity: %f", stopViewDragVelocity.x);
        [self decelerateStopListViewFromVelocity:stopViewDragVelocity.y withCompletionBlock:^(){
            if (recognizer.view.frame.origin.y > ([self searchViewLowerBound] + (recognizer.view.frame.size.height / 1.5)) && stopViewDragedDown) {
                if (recognizer.view.tag == 0) {
                    //                [self hideStopView:YES animated:YES];
                }else{
                    [self hideNearByStopsView:YES animated:YES];
                }
            }else if(recognizer.view.frame.origin.y < 0){
                [self setNearbyStopsViewTopSpacing:0];
            }
        }];
    }
}

- (IBAction)openSettingsButtonPressed:(id)sender {
    [self performSegueWithIdentifier:@"showSettings" sender:self];
}

- (IBAction)hideSearchResultViewPressed:(id)sender {
    [self hideNearByStopsView:YES animated:YES];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    // Return YES so the pan gesture of the containing table view is not cancelled by the long press recognizer
    return YES;
}

#pragma - mark Scroll View delegates
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
//    NSLog(@"Content offset: %f", scrollView.contentOffset.y);
    if (scrollView.contentOffset.y < -1) { /* drag the stop view down if table view is fully scrolled down */
        [self increamentNearByStopViewTopSpaceBy:-scrollView.contentOffset.y];
        stopViewDragedDown = YES;
        scrollView.contentOffset = CGPointMake(scrollView.contentOffset.x, 0);
        
    }else if(scrollView.contentOffset.y > 0 ){
        if ([self nearbyStopViewTopSpacing] > 0) {
            [self increamentNearByStopViewTopSpaceBy:-scrollView.contentOffset.y];
            stopViewDragedDown = NO;
            scrollView.contentOffset = CGPointMake(scrollView.contentOffset.x, 0);
        }else{
            stopViewDragedDown = NO;
            //
            nearbyStopsListsTable.layer.borderColor = [[UIColor lightGrayColor] CGColor];
            nearbyStopsListsTable.layer.borderWidth = 0.5;
        }
    }else{
        nearbyStopsListsTable.layer.borderColor = [[UIColor lightGrayColor] CGColor];
        nearbyStopsListsTable.layer.borderWidth = 0;
    }
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    if (stopViewDragedDown & !decelerate) { /* drag the stop view down if table view is fully scrolled down */
        [self decelerateStopListViewFromVelocity:[scrollView.panGestureRecognizer velocityInView:nearbyStopsListsTable].y withCompletionBlock:nil];
    }
}

-(void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView{
    tableViewIsDecelerating = YES;
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    tableViewIsDecelerating = NO;
}

#pragma - mark RettiDataManager Delegate methods
-(void)stopFetchDidComplete:(NSArray *)stopList{
    if (stopList != nil) {
        self.searchedStopList = stopList;
//        [self displayStopView:self.searchedStopList];
    }
    
//    [SVProgressHUD dismiss];
    [self showStopFetchActivityIndicator:NO];
}

-(void)stopFetchDidFail:(NSString *)error{
    [self showStopFetchActivityIndicator:NO];
}

#pragma mark - Stops in area handler methods
- (void)fetchStopsInCurrentMapViewRegion {
    [self fetchStopsInMapViewRegion:[self visibleMapRegion]];
}

- (void)fetchStopsInMapViewRegion:(MKCoordinateRegion)region{
    nearbyStopsFetchErrorMessage = nil;
    [self.reittiDataManager fetchStopsInAreaForRegion:region withCompletionBlock:^(NSArray *stopsList, NSString *errorMessage){
        if (!errorMessage) {
            [self nearByStopFetchDidComplete:stopsList];
        }else{
            [self nearByStopFetchDidFail:errorMessage];
        }
    }];
}

- (void)fetchStopsDetailsForBusStopShorts:(NSArray *)busStopShorts{
    if (!busStopShorts || busStopShorts.count < 1)
        return;
    
    __block NSInteger numberOfStops = 0;
        
    for (BusStopShort *busStopShort in busStopShorts) {
        if ([self isthereValidDetailForShortStop:busStopShort])
            continue;

        [self showStopFetchActivityIndicator:YES];
        numberOfStops ++;
        
        [self.reittiDataManager fetchStopsForCode:[busStopShort.code stringValue] andCoords:[ReittiStringFormatter convertStringTo2DCoord:busStopShort.coords] withCompletionBlock:^(BusStop *stop, NSString *errorString){
            if (!errorString) {
                [self setDetailStopForBusStopShort:busStopShort busStop:stop];
                //TODO: better was to find the index
                NSInteger index = [self busStopShortIndexForCode:busStopShort.code];
                if (index != NSNotFound && index < 30 && stop.departures && stop.departures.count > 0) /* Update with animation */
                    [nearbyStopsListsTable reloadSections:[NSIndexSet indexSetWithIndex:index] withRowAnimation:UITableViewRowAnimationBottom];
                else
                    [nearbyStopsListsTable reloadData];
            }
            
            numberOfStops--;
            if (numberOfStops == 0)
                [self showStopFetchActivityIndicator:NO];
        }];
    }
}

- (void)nearByStopFetchDidComplete:(NSArray *)stopList{
    
    if (stopList.count > 0) {
        if ([stopList.firstObject isKindOfClass:NearByStop.class]) {
            //TODO: Check if update is needed by checking existing list and values in cache
            //Do the check in separate thread
            NSMutableArray *tempArray = [[NSMutableArray alloc] init];
            
            for (NearByStop *stop in stopList) {
                BusStopShort *sStop = [[BusStopShort alloc] initWithNearByStop:stop];
                [tempArray addObject:sStop];
            }
            
            self.nearByStopList = tempArray;
            //TODO: Store in stops cache
        }else{
            self.nearByStopList = stopList;
        }
    }
    
    [self setupNearByStopsListTableviewFor:stopList];
    [self plotStopAnnotations:self.nearByStopList];
    
    retryCount = 0;
}
- (void)nearByStopFetchDidFail:(NSString *)error{
    if (![error isEqualToString:@""]) {
        if ([error isEqualToString:@"Request timed out."] && retryCount < 1) {
            [self listNearbyStopsPressed:nil];
            retryCount++;
            return;
        }
    }
    
    nearbyStopsFetchErrorMessage = error;
    self.nearByStopList = [@[] mutableCopy];
    [self setupNearByStopsListTableviewFor:nil];
}

- (void)detailStopFetchCompleted:(BusStop *)stop{
    //TODO: Set linesCodes to the bus stop short
    //TODO: Check the selected anotation is the right one
    if (selectedAnnotationView && stop.linesString && stop.linesString.length > 0) {
        [selectedAnnotationView setSubtitleLabelText:[NSString stringWithFormat:@"Lines: %@", stop.linesString]];
    }
}

- (void)routeSearchDidComplete:(NSArray *)routeList{
    if (routeList != nil && routeList.count > 0) {
        Route *route = [routeList firstObject];
        NSInteger durationInSeconds = [route.routeDurationInSeconds integerValue];
        [selectedAnnotationView setGoToHereDurationString:nil duration:[NSString stringWithFormat:@"%d min", (int)durationInSeconds/60]];
    }
}
- (void)routeSearchDidFail:(NSString *)error{
    
}

#pragma mark - reverse geocode search handler methods
- (void)searchReverseGeocodeForCoordinate:(CLLocationCoordinate2D)coordinate{
    [self.reittiDataManager searchAddresseForCoordinate:coordinate withCompletionBlock:^(GeoCode *geocode, NSString *errorString){
        if (!errorString && geocode) {
            [self reverseGeocodeSearchDidComplete:geocode];
        }else{
            [self reverseGeocodeSearchDidFail:errorString];
        }
    }];
}

- (void)reverseGeocodeSearchDidComplete:(GeoCode *)geoCode{
    droppedPinGeoCode = geoCode;
    [droppedPinGeoCode setLocationType:LocationTypeDroppedPin];
    
    [[DroppedPinManager sharedManager] setDroppedPin:self.droppedPinGeoCode];
    
    if (droppedPinAnnotationView && [droppedPinAnnotationView conformsToProtocol:@protocol(GCThumbnailAnnotationViewProtocol)]) {
        [((NSObject<GCThumbnailAnnotationViewProtocol> *)droppedPinAnnotationView) enableAddressInfoButton];
    }
    
    droppedPinLocation = [geoCode getStreetAddressString];

}
- (void)reverseGeocodeSearchDidFail:(NSString *)error{
    self.droppedPinGeoCode = nil;
    [[DroppedPinManager sharedManager] setDroppedPin:nil];
 
}

#pragma mark - Live vehicle methods
- (void)startFetchingLiveVehicles {
    [self.reittiDataManager startFetchingAllLiveVehiclesWithCompletionHandler:^(NSArray *vehicles, NSString *errorString){
        if (!errorString) {
            if ([settingsManager shouldShowLiveVehicles]) {
                [self plotVehicleAnnotations:vehicles isTrainVehicles:NO];
            }
        }
    }];
}

#pragma mark - Bike station fetching
//Bike stations needs to be updated constantly to get available bikes
- (void)startFetchingBikeStations {
    [self.reittiDataManager startFetchingBikeStationsWithCompletionBlock:^(NSArray *bikeStations, NSString *errorString){
        if (!errorString && bikeStations && bikeStations.count > 0) {
            self.allBikeStations = bikeStations;
            [self plotBikeStationAnnotations:bikeStations];
        }
    }];
}

#pragma mark - Disruptions delegate
- (void)disruptionFetchDidComplete:(NSArray *)disList{
    self.disruptionList = disList;
    
    if (disList.count > 0) {
        [self showDisruptionCustomBadge:YES];
    }else{
        [self showDisruptionCustomBadge:NO];
    }
}

- (void)disruptionFetchDidFail:(NSString *)error{
    self.disruptionList = nil;
    
    [self showDisruptionCustomBadge:NO];
}

#pragma mark - Address search view delegates
- (void)searchResultSelectedARoute:(RouteEntity *)routeEntity {
    
    RouteSearchParameters *searchParms = [[RouteSearchParameters alloc] initWithToLocation:routeEntity.toLocationName toCoords:routeEntity.toLocationCoordsString fromLocation:routeEntity.fromLocationName fromCoords:routeEntity.fromLocationCoordsString];
    [self switchToRouteSearchViewWithRouteParameter:searchParms];
}

- (void)searchResultSelectedAStop:(StopEntity *)stopEntity{
    [self hideNearByStopsView:YES animated:YES];
    [self centerMapRegionToCoordinate:[ReittiStringFormatter convertStringTo2DCoord:stopEntity.busStopWgsCoords]];
    [self plotStopAnnotation:[reittiDataManager castStopEntityToBusStopShort:stopEntity] withSelect:YES];
    
    mainSearchBar.text = [NSString stringWithFormat:@"%@, %@", stopEntity.busStopName, stopEntity.busStopCity];
    prevSearchedCoords = stopEntity.busStopCoords;
}
- (void)searchResultSelectedAGeoCode:(GeoCode *)geoCode{
    [self hideNearByStopsView:YES animated:YES];
    [self centerMapRegionToCoordinate:[ReittiStringFormatter convertStringTo2DCoord:geoCode.coords]];
    //Check if it is type busstop
    if (geoCode.getLocationType == LocationTypeStop) {
        //Convert GeoCode to busStopShort
        [self plotStopAnnotation:[reittiDataManager castStopGeoCodeToBusStopShort:geoCode] withSelect:YES];
        
    }else{
        [self plotGeoCodeAnnotation:geoCode];
    }
    
    mainSearchBar.text = geoCode.getStreetAddressString;
    prevSearchedCoords = geoCode.coords;
}

- (void)searchResultSelectedANamedBookmark:(NamedBookmark *)namedBookmark{
    [self hideNearByStopsView:YES animated:YES];
    [self centerMapRegionToCoordinate:[ReittiStringFormatter convertStringTo2DCoord:namedBookmark.coords]];
    //Check if it is type busstop
    
    [self plotNamedBookmarkAnnotation:namedBookmark];
    
    mainSearchBar.text = namedBookmark.name;
    prevSearchedCoords = namedBookmark.coords;
}

- (void)searchViewControllerWillBeDismissed:(NSString *)prevSearchTerm{
//    mainSearchBar.text = prevSearchTerm;
}
- (void)searchResultSelectedCurrentLocation{
    
}

-(void)searchViewControllerDismissedToRouteSearch:(NSString *)prevSearchTerm{
    mainSearchBar.text = prevSearchTerm;
    RouteSearchParameters *searchParms = [[RouteSearchParameters alloc] initWithToLocation:mainSearchBar.text toCoords:prevSearchedCoords fromLocation:nil fromCoords:nil];
    [self switchToRouteSearchViewWithRouteParameter:searchParms];
//    [self performSegueWithIdentifier:@"switchToRouteSearchTab" sender:nil];
}

#pragma mark - settings view delegate
- (void)setMapModeForSettings {
    switch ([settingsManager getMapMode]) {
        case StandartMapMode:
            mapView.mapType = MKMapTypeStandard;
            break;
            
        case HybridMapMode:
            mapView.mapType = MKMapTypeHybrid;
            break;
            
        case SateliteMapMode:
            mapView.mapType = MKMapTypeSatellite;
            break;
            
        default:
            break;
    }
}

-(void)mapModeSettingsValueChanged:(NSNotification *)notification{
    [self setMapModeForSettings];
}

-(void)userLocationSettingsValueChanged:(NSNotification *)notification{
    if ([self.reittiDataManager getRegionForCoords:mapView.region.center] != [settingsManager userLocation]) {
        [self.reittiDataManager setUserLocationRegion:[settingsManager userLocation]];
        [self centerMapRegionToCoordinate:[RettiDataManager getCoordinateForRegion:[settingsManager userLocation]]];
    }
    
    if ([settingsManager shouldShowLiveVehicles]) {
        [self removeAllVehicleAnnotation];
        [self.reittiDataManager stopFetchingLiveVehicles];
        
        [self startFetchingLiveVehicles];
    }
    
    [self fetchDisruptions];
}


-(void)shouldShowVehiclesSettingsValueChanged:(NSNotification *)notification{
    if ([settingsManager shouldShowLiveVehicles]) {
        [self startFetchingLiveVehicles];
    }else{
        [self removeAllVehicleAnnotation];
        [reittiDataManager stopFetchingLiveVehicles];
    }
}

-(void)settingsValueChanged{
//    
//    switch ([settingsManager getMapMode]) {
//        case StandartMapMode:
//            mapView.mapType = MKMapTypeStandard;
//            break;
//            
//        case HybridMapMode:
//            mapView.mapType = MKMapTypeHybrid;
//            break;
//            
//        case SateliteMapMode:
//            mapView.mapType = MKMapTypeSatellite;
//            break;
//            
//        default:
//            break;
//    }
//    
//    if ([self.reittiDataManager getRegionForCoords:mapView.region.center] != [settingsManager userLocation]) {
//        [self.reittiDataManager setUserLocation:[settingsManager userLocation]];
//        [self centerMapRegionToCoordinate:[RettiDataManager getCoordinateForRegion:[settingsManager userLocation]]];
//    }
//    
//    [self fetchDisruptions];
    
}

#pragma mark - Bookmarks view delegate

- (void)savedStopSelected:(NSNumber *)code fromMode:(int)mode{
//    bookmarkViewMode = mode;
////    [self hideStopView:YES animated:NO];
//    [self requestStopInfoAsyncForCode:[NSString stringWithFormat:@"%d", [code intValue]]];
//    [self showProgressHUD];
}

- (void)viewControllerWillBeDismissed:(int)mode{
    bookmarkViewMode = mode;
}

- (void)deletedSavedStopForCode:(NSNumber *)code{
//    [self.reittiDataManager deleteSavedStopForCode:code];
}

- (void)deletedHistoryStopForCode:(NSNumber *)code{
//    [self.reittiDataManager deleteHistoryStopForCode:code];
}

- (void)deletedSavedRouteForCode:(NSString *)code{
//    [self.reittiDataManager deleteSavedRouteForCode:code];
}
- (void)deletedHistoryRouteForCode:(NSString *)code{
//    [self.reittiDataManager deleteHistoryRouteForCode:code];
}

- (void)deletedAllSavedStops{
//    [self.reittiDataManager deleteAllSavedStop];
//    [self.reittiDataManager deleteAllSavedroutes];
}

- (void)deletedAllHistoryStops{
//    [self.reittiDataManager deleteAllHistoryStop];
//    [self.reittiDataManager deleteAllHistoryRoutes];
}

-(RouteSearchFromStopHandler)stopViewRouteSearchHandler {
    return ^(RouteSearchParameters *searchParams){
        //        [self.navigationController popToViewController:self animated:YES];
        [self switchToRouteSearchViewWithRouteParameter:searchParams];
    };
}

#pragma mark - View transitions
-(void)switchToRouteSearchViewWithRouteParameter:(RouteSearchParameters  *)searchParameters {
    MainTabBarController *tabBarController = (MainTabBarController *)[UIApplication sharedApplication].delegate.window.rootViewController;
    [tabBarController setupAndSwithToRouteSearchViewWithSearchParameters:searchParameters];
}

#pragma mark - Seague

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"seeFullTimeTable"]) {
        WebViewController *webViewController = (WebViewController *)segue.destinationViewController;
        NSURL *url = [NSURL URLWithString:self._busStop.timetable_link];
        webViewController._url = url;
        webViewController._pageTitle = _busStop.code_short;
    }
    
    if ([segue.identifier isEqualToString:@"openStopView"] || [segue.identifier isEqualToString:@"openNearbyStop"] || [segue.identifier isEqualToString:@"openNearbyStop2"])
    {
        StopViewController *stopViewController = (StopViewController *)segue.destinationViewController;
        
        if ([segue.identifier isEqualToString:@"openNearbyStop"] || [segue.identifier isEqualToString:@"openNearbyStop2"] ) {
            NSIndexPath *selectedRowIndexPath = [nearbyStopsListsTable indexPathForSelectedRow];
            
            BusStopShort *selected = [self.nearByStopList objectAtIndex:selectedRowIndexPath.section];
            
            [self configureStopViewController:stopViewController withBusStopShort:selected];
            [[ReittiAnalyticsManager sharedManager] trackFeatureUseEventForAction:kActionViewedAStop label:@"From nearby list" value:nil];
        }else{
            [self configureStopViewControllerWithAnnotation:stopViewController];
            [[ReittiAnalyticsManager sharedManager] trackFeatureUseEventForAction:kActionViewedAStop label:@"From annotation" value:nil];
        }
        
    }
    if ([segue.identifier isEqualToString:@"addressSearchController"]) {
        UINavigationController *navigationController = (UINavigationController *)segue.destinationViewController;
        AddressSearchViewController *addressSearchViewController = [[navigationController viewControllers] lastObject];
        
        NSArray * savedStops = [self.reittiDataManager fetchAllSavedStopsFromCoreData];
        NSArray * savedRoutes = [self.reittiDataManager fetchAllSavedRoutesFromCoreData];
        NSArray * recentStops = [self.reittiDataManager fetchAllSavedStopHistoryFromCoreData];
        NSArray * recentRoutes = [self.reittiDataManager fetchAllSavedRouteHistoryFromCoreData];
        NSArray * namedBookmarks = [self.reittiDataManager fetchAllSavedNamedBookmarksFromCoreData];
        
        addressSearchViewController.savedStops = [NSMutableArray arrayWithArray:savedStops];
        addressSearchViewController.recentStops = [NSMutableArray arrayWithArray:recentStops];
        addressSearchViewController.savedRoutes = [NSMutableArray arrayWithArray:savedRoutes];
        addressSearchViewController.recentRoutes = [NSMutableArray arrayWithArray:recentRoutes];
        addressSearchViewController.namedBookmarks = [NSMutableArray arrayWithArray:namedBookmarks];
        
        addressSearchViewController.routeSearchMode = NO;
        addressSearchViewController.simpleSearchMode = YES;
//        addressSearchViewController.darkMode = self.darkMode;
        addressSearchViewController.prevSearchTerm = mainSearchBar.text;
//        addressSearchViewController.droppedPinGeoCode = droppedPinGeoCode;
        addressSearchViewController.delegate = self;
        addressSearchViewController.reittiDataManager = [[RettiDataManager alloc] initWithManagedObjectContext:self.managedObjectContext];
        [addressSearchViewController.reittiDataManager setUserLocationToRegion:[settingsManager userLocation]];
//        addressSearchViewController.reittiDataManager = self.reittiDataManager;
    }
    
    if ([segue.identifier isEqualToString:@"infoViewSegue"]) {
        UINavigationController *navController = (UINavigationController *)[segue destinationViewController];
        InfoViewController *infoViewController = [[navController viewControllers] lastObject];
        
        infoViewController.disruptionsList = self.disruptionList;
        infoViewController.reittiDataManager = [[RettiDataManager alloc] initWithManagedObjectContext:self.managedObjectContext];
        [infoViewController.reittiDataManager setUserLocationToRegion:[settingsManager userLocation]];
    }
    
    if ([segue.identifier isEqualToString:@"openWidgetSettingFromHome"]) {
        UINavigationController *navigationController = (UINavigationController *)segue.destinationViewController;
        WidgetSettingsViewController *controller = (WidgetSettingsViewController *)[[navigationController viewControllers] lastObject];
        
        controller.savedStops = [self.reittiDataManager fetchAllSavedStopsFromCoreData];
    }
    
    if ([segue.identifier isEqualToString:@"showSettings"]) {
        UINavigationController *navigationController = (UINavigationController *)segue.destinationViewController;
        SettingsViewController *controller = (SettingsViewController *)[[navigationController viewControllers] lastObject];
        
        controller.mapRegion = mapView.region;
        controller.settingsManager = settingsManager;
        controller.delegate = self;
    }
    
    if ([segue.identifier isEqualToString:@"showNamedBookmark"]) {
        UINavigationController *navigationController = (UINavigationController *)segue.destinationViewController;
        EditAddressTableViewController *controller = (EditAddressTableViewController *)[[navigationController viewControllers] lastObject];
        
        controller.namedBookmark = selectedNamedBookmark;
        controller.viewControllerMode = ViewControllerModeViewNamedBookmark;
        controller.reittiDataManager = [[RettiDataManager alloc] initWithManagedObjectContext:self.managedObjectContext];
        [controller.reittiDataManager setUserLocationToRegion:[settingsManager userLocation]];
    }
    
    if ([segue.identifier isEqualToString:@"showGeoCode"]) {
        UINavigationController *navigationController = (UINavigationController *)segue.destinationViewController;
        EditAddressTableViewController *controller = (EditAddressTableViewController *)[[navigationController viewControllers] lastObject];
        
//        controller.droppedPinGeoCode = droppedPinGeoCode;
        
        if ([self.reittiDataManager fetchSavedNamedBookmarkFromCoreDataForCoords:selectedGeoCode.coords] != nil) {
            controller.namedBookmark = [self.reittiDataManager fetchSavedNamedBookmarkFromCoreDataForCoords:selectedGeoCode.coords];
            controller.viewControllerMode = ViewControllerModeViewNamedBookmark;
            controller.reittiDataManager = [[RettiDataManager alloc] initWithManagedObjectContext:self.managedObjectContext];
            [controller.reittiDataManager setUserLocationToRegion:[settingsManager userLocation]];
        }else{
            controller.geoCode = selectedGeoCode;
            controller.currentUserLocation = self.currentUserLocation;
            controller.viewControllerMode = ViewControllerModeViewGeoCode;
            controller.reittiDataManager = [[RettiDataManager alloc] initWithManagedObjectContext:self.managedObjectContext];
            [controller.reittiDataManager setUserLocationToRegion:[settingsManager userLocation]];
        }
    }
    
    if ([segue.identifier isEqualToString:@"showProFeatures"]) {
        UINavigationController *navController = (UINavigationController *)segue.destinationViewController;
        WebViewController *webViewController = (WebViewController *)[navController.viewControllers lastObject];
        NSURL *url = [NSURL URLWithString:kGoProDetailUrl];
        
        webViewController.modalMode = YES;
        webViewController._url = url;
        webViewController._pageTitle = @"COMMUTER PRO";
        
        webViewController.actionButtonTitle = @"Go to AppStore";
        webViewController.action = ^{
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:kProAppAppstoreLink]];
            [[ReittiAnalyticsManager sharedManager] trackFeatureUseEventForAction:kActionGoToProVersionAppStore label:@"Notification" value:nil];
        };
        webViewController.bottomContentOffset = 80.0;
        
        [[ReittiAnalyticsManager sharedManager] trackFeatureUseEventForAction:kActionViewedGoProDetail label:@"Notification" value:nil];
    }
}

- (void)configureStopViewController:(StopViewController *)stopViewController withBusStopShort:(BusStopShort *)busStop{
    if ([stopViewController isKindOfClass:[StopViewController class]]) {
        stopViewController.stopCode = [NSString stringWithFormat:@"%d", [busStop.code intValue]];
        stopViewController.stopCoords = [ReittiStringFormatter convertStringTo2DCoord:busStop.coords];
        stopViewController.stopShortCode = busStop.codeShort;
        stopViewController.stopName = busStop.name;
        
        stopViewController.routeSearchHandler = [self stopViewRouteSearchHandler];
        stopViewController.reittiDataManager = [[RettiDataManager alloc] initWithManagedObjectContext:self.managedObjectContext];
        [stopViewController.reittiDataManager setUserLocationToRegion:[settingsManager userLocation]];
    }
}

- (void)configureStopViewControllerWithAnnotation:(StopViewController *)stopViewController{
    if ([stopViewController isKindOfClass:[StopViewController class]]) {
        stopViewController.stopCode = selectedStopCode;
        stopViewController.stopCoords = selectedStopAnnotationCoords;
        stopViewController.stopShortCode = selectedStopShortCode;
        stopViewController.stopName = selectedStopName;
        
        stopViewController.routeSearchHandler = [self stopViewRouteSearchHandler];
        stopViewController.reittiDataManager = [[RettiDataManager alloc] initWithManagedObjectContext:self.managedObjectContext];
        [stopViewController.reittiDataManager setUserLocationToRegion:[settingsManager userLocation]];
    }
}

#pragma mark === UIViewControllerPreviewingDelegate Methods ===

- (UIViewController *)previewingContext:(id<UIViewControllerPreviewing>)previewingContext
              viewControllerForLocation:(CGPoint)location {
    
    UIView *view = [self.view hitTest:location withEvent:UIEventTypeTouches];
    if ([view isKindOfClass:[MKAnnotationView class]]) {
        MKAnnotationView *annotationView = (MKAnnotationView *)view;
        NSString *stopCode, *stopShortCode, *stopName;
        CLLocationCoordinate2D stopCoords;
        
        if ([annotationView.annotation isKindOfClass:[JPSThumbnailAnnotation class]])
        {
            JPSThumbnailAnnotation *stopAnnotation = (JPSThumbnailAnnotation *)annotationView.annotation;
            if (stopAnnotation.thumbnail.annotationType == NearByStopType || stopAnnotation.thumbnail.annotationType == SearchedStopType) {
                stopCode = [NSString stringWithFormat:@"%d", [stopAnnotation.code intValue]];
                stopCoords = stopAnnotation.coordinate;
                stopShortCode = stopAnnotation.thumbnail.shortCode;
                stopName = stopAnnotation.thumbnail.title;
            }
            
            if (stopCode != nil && ![stopCode isEqualToString:@""]) {
                //            UINavigationController *navigationController = (UINavigationController *)segue.destinationViewController;
                
                StopViewController *stopViewController = (StopViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"ASAStopViewController"];
                stopViewController.stopCode = stopCode;
                stopViewController.stopShortCode = stopShortCode;
                stopViewController.stopName = stopName;
                stopViewController.stopCoords = stopCoords;
                stopViewController.stopEntity = nil;
                //            stopViewController.modalMode = [NSNumber numberWithBool:NO];
                stopViewController.reittiDataManager = self.reittiDataManager;
                stopViewController.delegate = nil;
                
                [[ReittiAnalyticsManager sharedManager] trackFeatureUseEventForAction:kActionUsed3DTouch label:@"Stop Annotation" value:nil];
                
                return stopViewController;
            }else{
                return nil;
            }
            
        }else{
            return nil;
        }
        
    }else{
        CGPoint locationInTableView = [self.view convertPoint:location toView:nearbyStopsListsTable];
        
        NSIndexPath *selectedRowIndexPath = [nearbyStopsListsTable indexPathForRowAtPoint:locationInTableView];
        UITableViewCell *cell = [nearbyStopsListsTable cellForRowAtIndexPath:selectedRowIndexPath];
        
        BusStopShort *selected = self.nearByStopList.count > selectedRowIndexPath.section ? [self.nearByStopList objectAtIndex:selectedRowIndexPath.section] : nil;
        if (cell && selected) {
            CGRect convertedRect = [cell.superview convertRect:[nearbyStopsListsTable rectForSection:selectedRowIndexPath.section] toView:self.view];
            previewingContext.sourceRect = convertedRect;
            StopViewController *stopViewController = (StopViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"ASAStopViewController"];
            
            [self configureStopViewController:stopViewController withBusStopShort:selected];
            
            [[ReittiAnalyticsManager sharedManager] trackFeatureUseEventForAction:kActionUsed3DTouch label:@"Nearby list" value:nil];
            
            return stopViewController;
        }
    }
    
    return nil;
}

- (void)previewingContext:(id<UIViewControllerPreviewing>)previewingContext commitViewController:(UIViewController *)viewControllerToCommit{
    [self.navigationController showViewController:viewControllerToCommit sender:nil];
}

-(void)registerFor3DTouchIfAvailable{
    // Register for 3D Touch Previewing if available
    if ([self isForceTouchAvailable])
    {
        self.previewingContext = [self registerForPreviewingWithDelegate:self sourceView:self.view];
    }else{
        NSLog(@"3D Touch is not available on this device.!");
        
        // handle a 3D Touch alternative (long gesture recognizer)
    }
}

- (BOOL)isForceTouchAvailable {
    BOOL isForceTouchAvailable = NO;
    if ([self.traitCollection respondsToSelector:@selector(forceTouchCapability)]) {
        isForceTouchAvailable = self.traitCollection.forceTouchCapability == UIForceTouchCapabilityAvailable;
    }
    return isForceTouchAvailable;
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    [super traitCollectionDidChange:previousTraitCollection];
    if ([self isForceTouchAvailable]) {
        if (!self.previewingContext) {
            self.previewingContext = [self registerForPreviewingWithDelegate:self sourceView:self.view];
        }
    } else {
        if (self.previewingContext) {
            [self unregisterForPreviewingWithContext:self.previewingContext];
            self.previewingContext = nil;
        }
    }
}

#pragma - mark MemoryWarning
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
