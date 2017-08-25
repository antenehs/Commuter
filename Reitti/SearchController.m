//
//  SearchController.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 15/1/14.
//  Copyright (c) 2014 Anteneh Sahledengel. All rights reserved.

#import "SearchController.h"
#import <QuartzCore/QuartzCore.h>
#import "AppDelegate.h"
#import "MyFixedLayoutGuide.h"
#import "RouteSearchViewController.h"
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
#import "ReittiDateHelper.h"
#import "BikeStation.h"
#import "DepartureTableViewCell.h"
#import "NearbyTableViewCell.h"
#import "NearbyInfoTableViewCell.h"
#import "AnnotationFilter.h"
#import "AnnotationFilterView.h"
#import "CoreDataManagers.h"
#import "MigrationViewController.h"
#import "MappingExtensions.h"
#import "JPSThumbnailAnnotationView.h"
#import "ReittiLocationManager.h"
#import "SwiftHeaders.h"
#import "AppFeatureManager.h"
#import "InAppPurchaseViewController.h"

@import Firebase;

#define degreesToRadians(x) (M_PI * x / 180.0)
#define radiansToDegrees(x) (x * 180.0 / M_PI)

#define kDisapearingZoomLevel 14
#define kShrinkingZoomLevel 15

#define kMinHeightForListTableView 110.0
#define kMinTopSpaceForListTableView 0

CGFloat  kDeparturesRefreshInterval = 10;

@interface SearchController () {
    NearbyListInfoType nearbyListInfoType;
    BOOL createdTestNotif;
}

@property (nonatomic, strong) id previewingContext;
@property (nonatomic, strong) AnnotationFilter *annotationFilter;

@property (strong, nonatomic) IBOutlet AnnotationFilterView *filterAnnotationsView;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *filterAnnotationViewWidthConstraint;


@property (strong, nonatomic) RettiDataManager *reittiDataManager;
@property (strong, nonatomic) SettingsManager *settingsManager;
@property (strong, nonatomic) MapViewManager *mapViewManager;

@property (strong, nonatomic) NSArray *nearbyRows;

@end

@implementation SearchController

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

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)viewDidLoad {
    [super viewDidLoad];
    
    [nearbyStopsListsTable registerNib:[UINib nibWithNibName:@"DepartureTableViewCell" bundle:nil] forCellReuseIdentifier:@"departureCell"];
    
    [nearbyStopsListsTable registerNib:[UINib nibWithNibName:@"NearbyTableViewCell" bundle:nil] forCellReuseIdentifier:@"nearByCell"];
    
    [nearbyStopsListsTable registerNib:[UINib nibWithNibName:@"NearbyInfoTableViewCell" bundle:nil] forCellReuseIdentifier:@"nearByInfoCell"];
    
    [self initDataComponentsAndModules];
    [self updateAppShortcuts];
    [self reindexSavedDataForSpotlight];
    [self initViewComponents];
    
    if ([AppManager isNewInstallOrNewVersion]) {
        if (![AppManager isNewInstall]) {
            if ([AppManager isPreDigiTransitVersion]) {
                [self presentViewController:[MigrationViewController instantiate] animated:NO completion:nil];
            } else {
                UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:[NewInVersionViewController generateNewInVersionVc]];
                [self presentViewController:navController animated:YES completion:nil];
            }
            
            isShowingWelcomeView = YES;
            
            //Do this only once for this version. To clean change in device id
            [[ICloudManager sharedManager] deleteAllRecordsWithCompletion:^(NSString *error){}];
        }
        
        [AppManager setCurrentAppVersion];
    } else {
        if (![AppFeatureManager proFeaturesAvailable])
            [self showGoProNotification];
        
        [self performSelector:@selector(showRateAppNotification) withObject:nil afterDelay:10];
    }
    
    [self.navigationController setToolbarHidden:YES animated:NO];
    [self fetchDisruptions];
    
    NSInteger startingIndex = [SettingsManager startingIndexTab];
    if (startingIndex >= 0 && startingIndex <= 3) {
        self.tabBarController.selectedIndex = startingIndex;
    }
    
    currentLocationButton.hidden = YES; // just to prevent annoying color splash on sreen when view loads
}

-(void)showRateAppNotification {
    [self asa_ExecuteBlockInUIThread:^{
        [ReittiNotificationHelper showRateAppNotificationInController:self];
        
//        appOpenCount = [AppManager getAndIncrimentAppOpenCountForRating];
//        
//        if (appOpenCount < 5 || [AppManager isNewInstallOrNewVersion]) return;
//        
//        if ([SKStoreReviewController class]) {
//            [SKStoreReviewController requestReview];
//            [AppManager setAppOpenCountForRating:-8];
//            return;
//        }
//        
//        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Enjoy Using The App?"
//                                                                       message:@"The gift of 5 little starts is satisfying for both of us more than you think."
//                                                                preferredStyle:UIAlertControllerStyleAlert];
//        
//        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"Rate" style:UIAlertActionStyleDefault
//                                                              handler:^(UIAlertAction * action) {
//                                                                  [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[AppManager appAppstoreRateLink]]];
//                                                                  [AppManager setAppOpenCountForRating:-50];
//                                                                  
//                                                              }];
//        
//        UIAlertAction* laterAction = [UIAlertAction actionWithTitle:@"Maybe later" style:UIAlertActionStyleCancel
//                                                            handler:^(UIAlertAction * action) {
//                                                                [AppManager setAppOpenCountForRating:-8];
//                                                            }];
//        
//        [alert addAction:laterAction];
//        [alert addAction:defaultAction];
//        [self presentViewController:alert animated:YES completion:nil];
    }];
}

-(void)showGoProNotification {
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

-(void)appWillEnterForeground:(NSNotification *)notification {
    [self initDeparturesRefreshTimer];
    [self initDisruptionFetching];
    
    //StartVehicleFetching
    if ([settingsManager showLiveVehicles]) {
        [self startFetchingLiveVehicles];
    }else{
        [self removeAllVehicleAnnotation];
    }
    
    [self fetchStopsInCurrentMapViewRegion];
    
    [self startFetchingBikeStations];
}

-(void)appWillEnterBackground:(NSNotification *)notification {
    [departuresRefreshTimer invalidate];
    [refreshTimer invalidate];
    
    [reittiDataManager stopFetchingLiveVehicles];
    [reittiDataManager stopUpdatingBikeStations];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    currentLocationButton.hidden = NO;
    
    //Do this here not to show permission popup on welcome view.
    if (!isShowingWelcomeView) {
        //Check if notification is allowed.
//        if (![[ReittiRemindersManager sharedManger] isLocalNotificationEnabled]) {
//            [[ReittiRemindersManager sharedManger] registerNotification];
//        }
        
        [self initializeMapComponents];
    }
    
    [mainSearchBar asa_setTextColorAndPlaceholderText:[UIColor whiteColor] placeHolderColor:[UIColor lightTextColor]];
    
    [mainSearchBar setPlaceholder:@"address, stop or place"];
    
    //StartVehicleFetching
    if ([settingsManager showLiveVehicles]) {
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
    isShowingWelcomeView = NO; //View can appear only once while showing welcome view
}

-(void)viewDidDisappear:(BOOL)animated{
    [reittiDataManager stopFetchingLiveVehicles];
    [self removeAllVehicleAnnotation];
    
    [reittiDataManager stopUpdatingBikeStations];
    
    [departuresRefreshTimer invalidate];
    
    [super viewDidDisappear:animated];
}


-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [self hideNearByStopsView:[self isNearByStopsListViewHidden] animated:YES];
    
    [centerLocatorView removeFromSuperview];
    [mapView addSubview:centerLocatorView];
}

-(id<UILayoutSupport>)bottomLayoutGuide {
    return [[MyFixedLayoutGuide alloc]initWithLength:bottomLayoutGuide];
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    if (darkMode) {
        return UIStatusBarStyleDefault;
    }else{
        return UIStatusBarStyleDefault;
    }
}

-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}

#pragma - mark initialization Methods

-(void)initDataComponentsAndModules {
    [self updateFilter]; //This should be called first.
    [self initVariablesAndConstants];
    [self initDataManagers];
    [self initDisruptionFetching];
//    [self setBookmarkedStopsToDefaults];
    [self registerFor3DTouchIfAvailable];
}

-(void)updateAppShortcuts {
    if([UIApplicationShortcutItem class]){
        [[ReittiAppShortcutManager sharedManager] updateAppShortcuts];
    }
}

-(void)reindexSavedDataForSpotlight{
    [[ReittiSearchManager sharedManager] updateSearchableIndexes];
}

-(void)initViewComponents {
    /*init View Components*/
    
    [currentLocationButton asa_updateAsCurrentLocationButtonWithBorderColor:[AppManager systemGreenColor] animated:NO];
    activityIndicator.hidden = NO;
    
//    [nearbyStopsListsTable registerNib:[UINib nibWithNibName:@"DepartureTableViewCell" bundle:nil] forCellReuseIdentifier:@"departureCell"];
    
    [self updateFilter];
    [self initGuestureRecognizers];
    [self setNeedsStatusBarAppearanceUpdate];
    [self setNavBarApearance];
    [self setMapModeForSettings];
    [self setupListTableViewAppearance];
    [self hideNearByStopsView:YES animated:NO];
    [self plotBookmarks];
    [self plotRegionBoundaries];
}

-(void)initDataManagers {
    
    self.reittiDataManager = [[RettiDataManager alloc] init];
    
    self.settingsManager = [SettingsManager sharedManager];
    
    self.mapViewManager = [MapViewManager managerForMapView:mapView];
    self.mapViewManager.delegate = self;
    
    //StartVehicleFetching
    if ([settingsManager showLiveVehicles]) {
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
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(plotBookmarks)
                                                 name:kBookmarksWithAnnotationUpdated object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
}

-(void)initGuestureRecognizers {
//    stopViewDragGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(dragStopView:)];
    
//    [StopView addGestureRecognizer:stopViewDragGestureRecognizer];
    
    searchResultsViewGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(listNearbyStopsPressed:)];
    
//    searchResultViewDragGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(dragStopView:)];
    
//    [searchResultsView addGestureRecognizer:searchResultViewDragGestureRecognizer];
    
    mapViewTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideFilterViewOptions)];
    
    [self.mapView addGestureRecognizer:mapViewTapGestureRecognizer];
}

-(void)initVariablesAndConstants {
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
    createdTestNotif = NO;
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
//    self.mapViewManager.ignoreRegionChange = NO;
    canShowDroppedPin = NO;
    ignoreMapRegionChangeForCurrentLocationButtonStatus = NO;
    retryCount = 0;
    annotationAnimCounter = 0;
    
    isShowingWelcomeView = NO;
    
    firstRecievedLocation = YES;
    userLocationUpdated = NO;
    
    mapMode = MainMapViewModeStopsAndLive;
    
    if (!self.annotationFilter) self.annotationFilter = [[AnnotationFilter alloc] init];
    
    self.searchResultListViewMode = RSearchResultViewModeNearByStops;
}

-(void)initDeparturesRefreshTimer{
    departuresRefreshTimer = [NSTimer scheduledTimerWithTimeInterval:kDeparturesRefreshInterval target:self selector:@selector(refreshDepartures:) userInfo:nil repeats:YES];
}

#pragma mark - Center locator methods

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

-(CGRect)centerLocatorFrameForCenter:(CGPoint)center{
    return CGRectMake(center.x - 12, center.y + 12, 24, 24);
}

-(void)updateCenterLocationPositionWithGeocodeUpdate:(BOOL)updateGeocode {
    if ([self shouldShowDroppedPin]) {
        CGPoint centerPoint = [self visibleMapRectCenter];
        if (centerLocatorView == nil)
            [self initCenterLocator:centerPoint];
        else{
            centerLocatorView.frame = [self centerLocatorFrameForCenter:centerPoint];
        }
        
        [self.view addSubview:centerLocatorView];
        if (updateGeocode) {
            CLLocationCoordinate2D coordinate = [mapView convertPoint:centerLocatorView.center toCoordinateFromView:mapView];
            [self searchReverseGeocodeForCoordinate:coordinate];
        }
    }else{
        [centerLocatorView removeFromSuperview];
    }
}

-(void)bounceAnimateCenterLocator {
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

#pragma mark - stop filter method
-(void)updateFilter {
    if ([AppFeatureManager proFeaturesAvailable]) {
        NSArray *optionsForRegion = [reittiDataManager annotationFilterOptions];
        
        for (AnnotationFilterOption *option in optionsForRegion) {
            option.isEnabled = [SettingsManager isAnnotationTypeEnabled:option.annotType];
        }
        
        self.annotationFilter = [AnnotationFilter initWithOptions:optionsForRegion];
    }
    
    [self updateFilterView];
}

-(void)updateFilterView {
    if (self.annotationFilter.filterOptions == nil) {
        self.filterAnnotationsView.hidden = YES;
    } else {
        self.filterAnnotationsView.hidden = NO;
        __weak SearchController *weakSelf = self;
        [self.filterAnnotationsView setUpWithFilter:self.annotationFilter
                              withFilterChangeBlock:^(AnnotationFilter *newFilter, AnnotationFilterOption *changedOption){
                                  [SettingsManager saveAnnotationTypeEnabled:changedOption.isEnabled type:changedOption.annotType];
                                  [weakSelf updateViewForFilterChange:newFilter changedOption:changedOption];
                              }
                              withSizeChangeHandler:^(CGSize size){
                                  weakSelf.filterAnnotationViewWidthConstraint.constant = size.width;
                                  [weakSelf.view updateConstraintsIfNeeded];
                              }];
    }
}

-(void)updateViewForFilterChange:(AnnotationFilter *)newFilter changedOption:(AnnotationFilterOption *)changedOption {
    self.annotationFilter = newFilter;
    
    //If enabled,
    if (changedOption.isEnabled) {
        //Nearby stops
        if ([EnumManager isNearbyStopAnnotationType:changedOption.annotType]) {
            [self plotNearbyStopAnnotations:self.nearByStopList];
            [self fetchStopsInCurrentMapViewRegion];
        }
        
        //Bike stations
        if (changedOption.annotType == BikeStationLocation) {
            [self plotBikeStationAnnotations:self.allBikeStations];
            [self startFetchingBikeStations];
        }
    } else {
//        [self removeAllAnnotationsOfType:changedOption.annotType];
        [self.mapViewManager removeAllReittiAnotationsOfType:changedOption.annotType];
        
        if (changedOption.annotType == BikeStationLocation) {
           [reittiDataManager stopUpdatingBikeStations];
        }
        
        [self setupNearByPlacesListTableView];
    }
    
    [[ReittiAnalyticsManager sharedManager] trackFeatureUseEventForAction:kActionFilteredStops label:[NSString stringWithFormat:@"%@ - %@", changedOption.name, changedOption.isEnabled ? @"On" : @"Off"] value:nil];
}

-(NSArray *)filterStopsForAnnotationFilter:(NSArray<BusStopShort *> *)stopList {
    if (!stopList)
        return nil;
    
    if (!self.annotationFilter || self.annotationFilter.filterOptions == nil) {
        return stopList;
    }
    
    return [stopList filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(BusStopShort *  _Nullable evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
        ReittiAnnotationType annotType = [EnumManager annotTypeForStopType:evaluatedObject.stopType];
        return [self.annotationFilter isAnnotationTypeEnabled:annotType];
    }]];
}

-(void)hideFilterViewOptions {
    [self.filterAnnotationsView setFilterOptionsHidden:YES];
}

#pragma mark - Nav bar and toolbar methods
-(void)setNavBarSize {
    CGSize navigationBarSize = self.navigationController.navigationBar.frame.size;
    UIView *titleView = self.navigationItem.titleView;
    CGRect titleViewFrame = titleView.frame;
    titleViewFrame.size.width = navigationBarSize.width;
    self.navigationItem.titleView.frame = titleViewFrame;
    [self.view layoutIfNeeded];
}

-(void)setNavBarApearance{
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

-(void)setSearchBarText:(NSString *)text isManualSearchText:(BOOL)searchedText {
    if (searchedText) {
        mainSearchBar.text = text;
        searchBarTextManuallySet = searchedText;
    }
    
    //If not search text, it is it was not previouisly searched term or is empty
    if (!searchedText && (!searchBarTextManuallySet || [NSString isNilOrEmpty:mainSearchBar.text])) {
        mainSearchBar.text = text;
        searchBarTextManuallySet = searchedText;
    }
}

#pragma mark - stop detail handling
-(NSMutableDictionary *)stopDetailMap {
    if (!_stopDetailMap) {
        _stopDetailMap = [@{} mutableCopy];
    }
    
    return _stopDetailMap;
}

-(BusStop *)getDetailStopForBusStopShort:(BusStopShort *)shortStop{
    return [self.stopDetailMap objectForKey:shortStop.gtfsId];
}

-(BusStop *)getDetailStopForTableViewCell:(NSInteger)section{
    if (nearByStopList.count > section) {
        BusStopShort *stopForCell = [nearByStopList objectAtIndex:section];
        return [self getDetailStopForBusStopShort:stopForCell];
    }
    
    return nil;
}

-(void)setDetailStopForBusStopShort:(BusStopShort *)shortStop busStop:(BusStop *)stop{
    if (stop) {
        [self.stopDetailMap setObject:stop forKey:shortStop.gtfsId];
    }
}

-(void)clearStopDetailMap {
    [self.stopDetailMap removeAllObjects];
}

-(BOOL)isthereValidDetailForShortStop:(BusStopShort *)shortStop{
    
    @try {
        BusStop *detailStop = [self getDetailStopForBusStopShort:shortStop];
        
        if (!detailStop || !detailStop.departures || detailStop.departures.count < 1)
            return NO;
        
        NSMutableArray *departuresCopy = [detailStop.departures mutableCopy];
        for (int i = 0; i < departuresCopy.count;i++) {
            StopDeparture *departure = [departuresCopy objectAtIndex:i];
            if ([departure.departureTime timeIntervalSinceNow] < 0){
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

-(BOOL)isThereValidDetailForTableViewSection:(NSInteger)section{
    if (nearByStopList.count > section) {
        BusStopShort *stopForCell = [nearByStopList objectAtIndex:section];
        return [self isthereValidDetailForShortStop:stopForCell];
    }
    
    return NO;
}

#pragma mark - nearby stops list methods
-(void)setupListTableViewAppearance{
    nearbyStopsListsTable.backgroundColor = [UIColor clearColor];
    [searchResultsView setBlurTintColor:nil];
    searchResultsView.layer.borderWidth = 0.5;
    searchResultsView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    
//    hideSearchResultViewButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    
    nearbyStopsListsTable.rowHeight = UITableViewAutomaticDimension;
    nearbyStopsListsTable.estimatedRowHeight = 50;
    
    nearbyListInfoType = NearbyListInfoTypeLoading;
}

-(void)sortPlaceAtDistance:(inout NSMutableArray *)placesArray {
    [placesArray sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        if (![obj1 conformsToProtocol:@protocol(ReittiPlaceAtDistance)] ||
            ![obj2 conformsToProtocol:@protocol(ReittiPlaceAtDistance)]) {
            return NSOrderedDescending;
        }
        
        double obj1Distance = [[(id<ReittiPlaceAtDistance>)obj1 distance] doubleValue];
        double obj2Distance = [[(id<ReittiPlaceAtDistance>)obj2 distance] doubleValue];
        
        return obj1Distance > obj2Distance;
    }];
}

-(void)buildNearbyRowsList {
    NSMutableArray *allNearbyRows = [@[] mutableCopy];
    NSArray *filteredStops = [self filterStopsForAnnotationFilter:self.nearByStopList];
    
    //TODO: Make exception for fav stops
    if (![self shouldShowNearByPlaces]) {
        self.nearbyRows = [NSArray arrayWithArray:allNearbyRows];
        return;
    }
    
    for (BusStop *stop in filteredStops) {
        if ([stop.distance intValue] > 800) {
            //TODO: Make exception for fav stops
            continue;
        }
        id groupedDepartures = stop.groupedDepartures;
        if (groupedDepartures) {
            [allNearbyRows addObjectsFromArray:groupedDepartures];
/* JUST TESTING
#if DEBUG
            //For testing only
            if (!createdTestNotif && stop.departures.count > 0) {
                [[ReittiRemindersManager sharedManger] setNotificationForDeparture:stop.departures[0]
                                                                            inStop:stop
                                                                            offset:1
                                                             showNotifInController:nil];
                createdTestNotif = YES;
            }
#endif
*/
        }
    }
    
    if ([self.annotationFilter isAnnotationTypeEnabled:BikeStationLocation] && [self shouldShowNearByPlaces] &&
        self.allBikeStations) {
        //Calculate distance from center
        CLLocation *centerLocation =  centerLocation = [[CLLocation alloc] initWithLatitude:self.visibleMapRegion.center.latitude longitude:self.mapView.region.center.longitude];;
        
        for (BikeStation *station in self.allBikeStations) {
            CLLocationDistance distance = [station.location distanceFromLocation:centerLocation];
            station.distance = [NSNumber numberWithInt:distance];
        }
        
        NSMutableArray<BikeStation *> *bikesCopy = [self.allBikeStations mutableCopy];
        [self sortPlaceAtDistance:bikesCopy];
        
        NSMutableArray *closestStations = [@[] mutableCopy];
        for (int i = 0; i < bikesCopy.count; i++) {
            if ([bikesCopy[i].distance intValue] < 500)
                [closestStations addObject:bikesCopy[i]];
            
            if (i > 9)
                break;
        }
        
        [allNearbyRows addObjectsFromArray:closestStations];
    }
    
    [self sortPlaceAtDistance:allNearbyRows];
    
    [allNearbyRows sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        if (![obj1 conformsToProtocol:@protocol(ReittiPlaceAtDistance)] ||
            ![obj2 conformsToProtocol:@protocol(ReittiPlaceAtDistance)]) {
            return NSOrderedDescending;
        }
        
        double obj1Distance = [[(id<ReittiPlaceAtDistance>)obj1 distance] doubleValue];
        double obj2Distance = [[(id<ReittiPlaceAtDistance>)obj2 distance] doubleValue];
        
        return obj1Distance > obj2Distance;
    }];
    
    self.nearbyRows = [NSArray arrayWithArray:allNearbyRows];
}

-(void)setupNearByPlacesListTableView {
//    if (![self isNearByStopsListViewHidden]) {
//        if (self.nearByStops.count > 4) {
//            [self fetchStopsDetailsForBusStopShorts:[nearByStops objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 4)]]];
//        }else{
//            [self fetchStopsDetailsForBusStopShorts:nearByStops];
//        }
//    }
    
    [self buildNearbyRowsList];
    
    self.searchResultListViewMode = RSearchResultViewModeNearByStops;
    [nearbyStopsListsTable reloadData];
//    [nearbyStopsListsTable scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
    //Adjust table size
    [self fitContentInNearbyList];
}

-(void)hideNearByStopsView:(BOOL)hidden animated:(BOOL)anim {
    [self hideNearByStopsView:hidden animated:anim completion:nil];
}

-(void)hideNearByStopsView:(BOOL)hidden animated:(BOOL)anim completion:(ActionBlock)completion {
    //Animate size
    [self.view asa_springAnimationWithDuration:anim ? 0.5 : 0 animation:^{
        [self hideNearByStopsView:hidden];
        if (completion) completion();
    } completion:nil];
}

-(void)hideNearByStopsView:(BOOL)hidden{
    if (hidden) {
        [self setNearbyStopsViewTopSpacing:self.searchViewLowerBound];
        [nearbyStopsListsTable scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
        isSearchResultsViewDisplayed = NO;
    }else{
        [self setNearbyStopsViewTopSpacing:[self searchViewUpperBound]];
        isSearchResultsViewDisplayed = YES;
        [self hideFilterViewOptions];
    }
    
    if(!hidden)
        [self setupNearByPlacesListTableView];
}

-(void)decelerateStopListViewFromVelocity:(CGFloat)velocity withCompletionBlock:(ActionBlock)completionBlock{
    
    [UIView animateWithDuration:1 delay:0 usingSpringWithDamping:0.9 initialSpringVelocity:0.5 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        [self increamentNearByStopViewTopSpaceBy:velocity/4];
    } completion:^(BOOL finished) {
        if (completionBlock) {
            completionBlock();
        }
    }];
}

-(void)setNearbyStopsViewTopSpacing:(CGFloat)topSpace animated:(BOOL) animated {
    [self.view asa_springAnimationWithDuration:animated ? 0.7 : 0 animation:^{
        [self setNearbyStopsViewTopSpacing:topSpace];
    } completion:nil];
}

-(void)setNearbyStopsViewTopSpacing:(CGFloat)topSpace{
    if (topSpace < [self searchViewUpperBound])
        topSpace = [self searchViewUpperBound];
    
    if (topSpace > self.searchViewLowerBound)
        topSpace = self.searchViewLowerBound;

    CGFloat spaceDiff = topSpace - nearByStopsViewTopSpacing.constant;
    
    nearByStopsViewTopSpacing.constant = topSpace;
    [self.view layoutSubviews];
    
    
    if (self.nearbyStopViewTopSpacing < self.viewVisibleHeight - kMinHeightForListTableView) {

    }
    
    //Set center locator position
    [self updateCenterLocationPositionWithGeocodeUpdate:NO];
    
    //Adjust map
    [self scrollMapViewByPoint:CGPointMake(0, -spaceDiff/2) animated:NO];
}

-(void)increamentNearByStopViewTopSpaceBy:(CGFloat)increament{
    [self setNearbyStopsViewTopSpacing:nearByStopsViewTopSpacing.constant + increament];
}

//
-(void)fitContentInNearbyList {
    if (self.nearbyStopViewTopSpacing > self.searchViewLowerBound) {
        [self setNearbyStopsViewTopSpacing:self.searchViewLowerBound animated:YES];
    }
    
    CGSize tableContentSize = self.tableViewContentSize;

    if (self.nearbyStopViewTopSpacing < (self.viewVisibleHeight - tableContentSize.height)) {
        [self setNearbyStopsViewTopSpacing:self.viewVisibleHeight - tableContentSize.height animated:YES];
    }
}

-(BOOL)isNearByStopsListViewHidden{
    return [self nearbyStopViewTopSpacing] >= self.searchViewLowerBound - 5;
}

-(CGSize)tableViewContentSize {
    [nearbyStopsListsTable layoutIfNeeded];
    return nearbyStopsListsTable.contentSize;
}

-(CGFloat)viewVisibleHeight {
    return self.view.frame.size.height - self.tabBarController.tabBar.frame.size.height;
}

-(CGFloat)nearbyStopViewTopSpacing {
    return nearByStopsViewTopSpacing.constant;
}

-(CGFloat)searchViewLowerBound {
    CGSize tableContentSize = self.tableViewContentSize;
    return self.viewVisibleHeight - MIN(tableContentSize.height, kMinHeightForListTableView);
}

-(CGFloat)searchViewUpperBound {
    CGSize tableContentSize = self.tableViewContentSize;
    return MAX(self.viewVisibleHeight - tableContentSize.height, kMinTopSpaceForListTableView);
}

-(void)showStopFetchActivityIndicator:(NSNumber *)show{
    stopFetchActivityIndicator.hidden = YES;
    /*
    if ([self isNearByStopsListViewHidden]) {
        hideSearchResultViewButton.hidden = NO;
        [stopFetchActivityIndicator endRefreshing];
        return;
    }
    
    hideSearchResultViewButton.hidden = [show boolValue];
    
    if ([show boolValue]){
        [stopFetchActivityIndicator beginRefreshing];
    }else{
        [stopFetchActivityIndicator endRefreshing];
    }
    */
}

#pragma mark - Table view datasource and delegate methods

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
    
//    if (self.nearByStopList.count == 0)
//        return 1;
//    
//    return self.nearByStopList.count > 30 ? 30 : self.nearByStopList.count;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//    if ([self isThereValidDetailForTableViewSection:section]) {
//        BusStop *detailStop = [self getDetailStopForTableViewCell:section];
//        if (detailStop && detailStop.departures) {
//            if (detailStop.departures.count == 0) {
//                return 1;
//            }else if (detailStop.departures.count == 1) {
//                return 2;
//            }else if (detailStop.departures.count == 2){
//                return 3;
//            }else{
//                return 4;
//            }
//        }
//        return 1;
//    }
    
    BOOL showInfoRow = nearbyListInfoType == NearbyListInfoTypeError ||
                       nearbyListInfoType == NearbyListInfoTypeLoading;
    
    NSInteger nearbyPlacesCount = self.nearbyRows ? self.nearbyRows.count : 0;
    if (nearbyPlacesCount == 0 && showInfoRow)
        nearbyPlacesCount = 1;
    
    return nearbyPlacesCount;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.nearbyRows.count > 0) {
        NearbyTableViewCell *cell = [nearbyStopsListsTable dequeueReusableCellWithIdentifier:@"nearByCell"];
        
        [cell setupFromNearByRowObject:self.nearbyRows[indexPath.row]];
        
        return cell;
        
        
        /*
        BusStopShort *stop = [nearByStopList objectAtIndex:indexPath.section];
        
        if (indexPath.row == 0) {
            UITableViewCell *cell = [nearbyStopsListsTable dequeueReusableCellWithIdentifier:@"searchResultCell"];
            
            UIImageView *imageView = (UIImageView *)[cell viewWithTag:3001];
            [imageView setImage:[AppManager stopIconForStopType:stop.stopType]];
            
            UILabel *codeLabel = (UILabel *)[cell viewWithTag:3004];
            codeLabel.text = @"";
            
            NSString *linesString = stop.linesString;
//            if ([self isThereValidDetailForTableViewSection:indexPath.section]) {
//                BusStop *detailStop = [self getDetailStopForBusStopShort:stop];
//                linesString = detailStop.linesString;
//            }
            
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
        } else {
            DepartureTableViewCell *cell = [nearbyStopsListsTable dequeueReusableCellWithIdentifier:@"departureCell"];
            
            CustomeTableViewCell __weak *weakCell = (CustomeTableViewCell *)cell;
            
            [cell setAppearanceWithBlock:^{
                weakCell.delegate = self;
                weakCell.containingTableView = tableView;
            } force:NO];
            
            BusStop *detailStop = [self getDetailStopForBusStopShort:stop];
            
            StopDeparture *departure = [detailStop.departures objectAtIndex:(indexPath.row - 1)];
            
            @try {
                [cell setupFromStopDeparture:departure compactMode:YES];
                cell.separatorInset = UIEdgeInsetsMake(0, 2000, 0, 0);
                [cell setCellHeight:35];
                return cell;
            }
            @catch (NSException *exception) {}
        }
         */
    }else{
        NearbyInfoTableViewCell *cell = [nearbyStopsListsTable dequeueReusableCellWithIdentifier:@"nearByInfoCell"];
        [cell setupForInfoType:nearbyListInfoType specialErrorMessage:nearbyStopsFetchErrorMessage];
        
//        UILabel *infoLabel = (UILabel *)[cell viewWithTag:2003];
//        
//        if (nearbyStopsFetchErrorMessage) {
//            infoLabel.text = nearbyStopsFetchErrorMessage;
//        }else{
//            infoLabel.text = @"No Stops Nearby";
//        }
        cell.separatorInset = UIEdgeInsetsMake(0, 2000, 0, 0);
        return cell;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NearbyTableViewCell *cell = (NearbyTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    if (!cell) return;
    
    if ([cell isKindOfClass:[NearbyTableViewCell class]] &&
        cell.groupedDepartures) {
        [self performSegueWithIdentifier:@"openNearbyStop2" sender:self];
    } else if ([cell isKindOfClass:[NearbyTableViewCell class]] &&
               cell.bikeStation) {
        [self hideNearByStopsView:YES animated:YES completion:^{
            [self centerMapRegionToCoordinate:cell.bikeStation.coordinates];
            [self.mapViewManager selectReittiAnnotationWithUniqueId:cell.bikeStation.stationId andType:BikeStationLocation];
        }];
    }
}

#pragma - mark Map methods

- (void)initializeMapComponents {
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
-(CGRect)visibleMapRect {
    CGRect fullMapFrame = self.mapView.frame;
    CGFloat visibleHeight = [self nearbyStopViewTopSpacing];
    
    fullMapFrame.size.height = visibleHeight;
    
    return fullMapFrame;
}

-(CGPoint)visibleMapRectCenter {
    CGRect visibleRect = [self visibleMapRect];
    
    return CGPointMake(visibleRect.origin.x + visibleRect.size.width/2, visibleRect.origin.y + visibleRect.size.height/2 );
}

-(void)scrollMapViewByPoint:(CGPoint)point animated:(BOOL)animated {
    CGPoint currentCenter = [self.mapView convertCoordinate:self.mapView.region.center toPointToView:self.mapView];
    currentCenter.x += point.x;
    currentCenter.y += point.y;
    
    CLLocationCoordinate2D coordinate = [self.mapView convertPoint:currentCenter toCoordinateFromView:self.mapView];
    self.mapViewManager.ignoreRegionChange = YES;
    [mapView setCenterCoordinate:coordinate animated:animated];
}

-(BOOL)centerMapRegionToCoordinate:(CLLocationCoordinate2D)coordinate {
    
    BOOL toReturn = YES;
    
    if (![ReittiLocationManager isLocationServiceAvailableWithMessage:NO showMessageIn:self]) {
        coordinate = [ReittiRegionManager getCoordinateForRegion:[settingsManager userLocation]];
        
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
    
    FIRCrashLog(@"Centering map to coordinate: %@", [ReittiStringFormatter convert2DCoordToString:coordinate]);
    
    return toReturn;
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    self.currentUserLocation = [locations lastObject];
    if (centerMap) {
        [self centerMapRegionToCoordinate:self.currentUserLocation.coordinate];
        centerMap = NO;
    }
    
    [self.mapViewManager drawFiveMinWalkingCircleAtCoordinate:self.currentUserLocation];
    
    if (!firstRecievedLocation && !userLocationUpdated) {
        Region currentRegion = [[ReittiRegionManager sharedManager] identifyRegionOfCoordinate:self.currentUserLocation.coordinate];
        
        if (currentRegion != [settingsManager userLocation]) {
            if (currentRegion == HSLRegion || currentRegion == TRERegion) {
                //Notify and ask for confirmation
                [settingsManager setUserLocation:currentRegion];
                
                if (![AppManager isNewInstallOrNewVersion]) {
                    NSString *title = [NSString stringWithFormat:@"Moved to the %@ region?",[[ReittiRegionManager sharedManager] getNameOfRegion:currentRegion]];
                    NSString *body = [NSString stringWithFormat:@"Your location has been updated to %@ region. You can change it anytime from settings.",[[ReittiRegionManager sharedManager] getNameOfRegion:currentRegion]];
                    UIAlertController *controller = [UIAlertController alertControllerWithTitle:title
                                                                                        message:body
                                                                                 preferredStyle:UIAlertControllerStyleAlert];
                    
                    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Cool" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) { }];
                    [controller addAction:okAction];
                    
                    UIAlertAction *settingsAction = [UIAlertAction actionWithTitle:@"Settings" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                        [self openSettingsButtonPressed:self];
                    }];
                    [controller addAction:settingsAction];
                    
                    [self presentViewController:controller animated:YES completion:nil];
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

#pragma mark - Plot annotations

-(void)plotRegionBoundaries {
#if DEBUG
    ReittiPolyline *hslRegionPolyline = [Polyline reittiPolylineFromLocationArray:[[ReittiRegionManager sharedManager] hslRegionCornerLocations]];
    hslRegionPolyline.strokeColor = [UIColor redColor];
    [self.mapViewManager drawPolyline:hslRegionPolyline];
    
    ReittiPolyline *treRegionPolyline = [Polyline reittiPolylineFromLocationArray:[[ReittiRegionManager sharedManager] treRegionCornerLocations]];
    treRegionPolyline.strokeColor = [UIColor redColor];
    [self.mapViewManager drawPolyline:treRegionPolyline];
#endif
}

-(void)plotBookmarks {
//    [self removeAllAnnotationsOfType:FavouriteType];
    [self.mapViewManager removeAllReittiAnotationsOfType:FavouriteType];
    
    NSArray *namedBookmarks = [[NamedBookmarkCoreDataManager sharedManager] fetchAllSavedNamedBookmarks];
    if (namedBookmarks && namedBookmarks.count > 0) {
        for (NamedBookmark *bookmark in namedBookmarks) {
            [self plotNamedBookmarkAnnotation:bookmark withSelect:NO];
        }
    }
    
    NSArray *savedStops = [[StopCoreDataManager sharedManager] fetchAllSavedStopsFromCoreData];
    
    if (savedStops && savedStops.count > 0) {
        NSMutableArray *busStops = [@[] mutableCopy];
        for (StopEntity *stopEnt in savedStops) {
            [busStops addObject:stopEnt.toBusStopShort];
        }
        
        [self plotSavedStops:busStops withSelectFirst:NO];
    }
}

-(void)plotNearbyStopAnnotations:(NSArray *)stopList {
    NSArray *allAnots = [self stopAnnotationsForStops:stopList
                                      areDisappearing:YES
                                         areShrinking:YES
                                       annotationType:DefaultAddressLocation
                                          applyFilter:YES];
    
    [self.mapViewManager plotOnlyNewAnnotations:allAnots forAnnotationType:AllNearByStopType];
}

-(void)plotSavedStops:(NSArray *)savedStops withSelectFirst:(BOOL)selectFirst {
    if (!savedStops || savedStops.count < 1) return;
    
    //Selection wont work if existing one is not removed
    if (selectFirst) {
        BusStop *firstStop = savedStops[0];
//        for (id<MKAnnotation> annotation in mapView.annotations) {
//            if ([annotation isKindOfClass:[DetailedAnnotation class]]) {
//                DetailedAnnotation *sAnnotation = (DetailedAnnotation *)annotation;
//                if (sAnnotation.annotationType == FavouriteType &&
//                    [sAnnotation.code isEqualToString:firstStop.gtfsId]) {
//                    [mapView removeAnnotation:annotation];
//                }
//            }
//        }
        
        [self.mapViewManager removeReittiAnnotationWithUniqueId:firstStop.gtfsId andType:FavouriteType];
    }
    
    NSArray *allAnots = [self stopAnnotationsForStops:savedStops
                                      areDisappearing:NO
                                         areShrinking:NO
                                       annotationType:FavouriteType
                                          applyFilter:NO];
    
    [self.mapViewManager plotAnnotations:allAnots];
    
    if (selectFirst && allAnots && allAnots.count > 0) {
        [mapView selectAnnotation:allAnots[0] animated:YES];
        [self centerMapRegionToCoordinate:[savedStops[0] coordinate]];
    }
}

-(void)plotSearchedStop:(BusStopShort *)busStop {
    if (!busStop) return;
    
    //remove if it is already bookmarked and ploted
    if ([[StopCoreDataManager sharedManager] isBusStopSavedWithCode:busStop.gtfsId]) {
        [self plotSavedStops:@[busStop] withSelectFirst:YES];
        return;
    }
    
    [self.mapViewManager removeAllReittiAnotationsOfType:SearchedStopType];
    
    NSArray *annotations = [self stopAnnotationsForStops:@[busStop]
                                         areDisappearing:NO
                                            areShrinking:NO
                                          annotationType:SearchedStopType
                                             applyFilter:NO];
    
    if (!annotations && annotations.count < 1) return;
    
    [self.mapViewManager plotOnlyNewAnnotations:annotations forAnnotationType:SearchedStopType];
    
    [mapView selectAnnotation:annotations[0] animated:YES];
    [self centerMapRegionToCoordinate:busStop.coordinate];
}

-(NSArray *)stopAnnotationsForStops:(NSArray *)stopList
                  areDisappearing:(BOOL)disappearing
                     areShrinking:(BOOL)shrinking
                     annotationType:(ReittiAnnotationType)annotationType
                        applyFilter:(BOOL)applyFilter {
    
    if (!stopList || stopList.count < 1) return nil;
    
    NSArray *savedStopIds = [[StopCoreDataManager sharedManager] allSavedStopCodes];
    
    NSMutableArray *allAnots = [@[] mutableCopy];
    for (BusStop *stop in stopList) {
        if (applyFilter) {
            ReittiAnnotationType type = [EnumManager annotTypeForStopType:stop.stopType];
            if (![self.annotationFilter isAnnotationTypeEnabled:type]) continue;
        }
        
        if (annotationType == DefaultAddressLocation && savedStopIds) {
            if ([savedStopIds containsObject:stop.gtfsId]) { continue; }
        }
        
        if (![ReittiMapkitHelper isValidCoordinate:stop.coordinate]) continue;
        
        DetailedAnnotation *annotation = (DetailedAnnotation *)stop.mapAnnotation;
        if (annotation) {
            if (shrinking) {
                annotation.shrinksWhenZoomedOut = YES;
                annotation.shrinkingZoomLevel = kShrinkingZoomLevel;
            }
            
            if (disappearing) {
                annotation.disappearsWhenZoomedOut = YES;
                annotation.disappearingZoomLevel = kDisapearingZoomLevel;
            }
            
            if (annotationType != DefaultAddressLocation) {
                annotation.annotationType = annotationType;
            }
            
            __weak SearchController *weakSelf = self;
            annotation.primaryAccessoryAction = ^(MKAnnotationView *annotationView){
                [weakSelf openRouteForAnnotationWithTitle:stop.name subtitle:stop.codeShort andCoords:stop.coordinate];
            };
            if (stop.gtfsId) {
                annotation.secondaryButtonBlock = ^(MKAnnotationView *annotationView){
                    [weakSelf openStopViewForCode:stop.gtfsId shortCode:stop.codeShort name:stop.name andCoords:stop.coordinate];
                };
                annotation.disclosureBlock = ^(MKAnnotationView *annotationView){
                    [weakSelf openStopViewForCode:stop.gtfsId shortCode:stop.codeShort name:stop.name andCoords:stop.coordinate];
                };
            }
            
            [allAnots addObject:annotation];
        }
    }
    
    return allAnots.count > 0 ? allAnots : nil;
}

-(void)plotGeoCodeAnnotation:(GeoCode *)geoCode {
    if (!geoCode || ![geoCode isKindOfClass:[GeoCode class]]) { return; }
    
//    [self.mapViewManager removeAllReittiAnotationsOfType:SearchedStopType];
//    [self.mapViewManager removeAllReittiAnotationsOfType:GeoCodeType];
    
    
//    NSString * name = @"";
//    NSString * city = @"";
//    
//    if (geoCode.locationType == LocationTypePOI) {
//        name = geoCode.name;
//        city = geoCode.city;
//    }else if (geoCode.locationType == LocationTypeContact) {
//        name = geoCode.name;
//        city = geoCode.fullAddressString;
//    }else if (geoCode.locationType  == LocationTypeAddress){
//        name = geoCode.getStreetAddressString;
//        city = geoCode.city;
//    }else{
//        //[self plotStopAnnotation:<#(StopEntity *)#> forCoordinate:<#(NSString *)#>]
//    }
//    
//    AnnotationThumbnail *geoAnT = [[AnnotationThumbnail alloc] init];
//    geoAnT.image = geoCode.annotationImage;
//    geoAnT.title = name;
//    geoAnT.subtitle = city;
//    geoAnT.coordinate = geoCode.coordinates;
//    geoAnT.annotationType = GeoCodeType;
//    geoAnT.reuseIdentifier = @"geoLocationAnnotation";
    
//    DetailedAnnotation *annot = [DetailedAnnotation annotationWithThumbnail:geoAnT];
    
    DetailedAnnotation *annot = (DetailedAnnotation *)geoCode.mapAnnotation;
    if (annot) {
        NSString *title = annot.thumbnail.title;
        NSString *subtitle = annot.thumbnail.subtitle;
        __weak SearchController *weakSelf = self;
        annot.primaryAccessoryAction = ^(MKAnnotationView *annotationView){ [weakSelf openRouteForAnnotationWithTitle:title subtitle:subtitle andCoords:geoCode.coordinates];};
        annot.secondaryButtonBlock = ^(MKAnnotationView *annotationView){ [weakSelf showGeoCode:geoCode];};
        
        [self.mapViewManager plotOnlyNewAnnotations:@[annot] forAnnotationType:GeoCodeType];
        
        [mapView selectAnnotation:annot animated:YES];
        
        [self centerMapRegionToCoordinate:geoCode.coordinates];
    }
}

-(void)plotNamedBookmarkAnnotation:(NamedBookmark *)namedBookmark withSelect:(BOOL)select {
//    for (id<MKAnnotation> annotation in mapView.annotations) {
//        if ([annotation isKindOfClass:[DetailedAnnotation class]]) {
//            DetailedAnnotation *sAnnotation = (DetailedAnnotation *)annotation;
//            
//            if ([sAnnotation.thumbnail.shortCode isEqualToString:namedBookmark.getUniqueIdentifier] && sAnnotation.annotationType == FavouriteType) {
//                [mapView removeAnnotation:sAnnotation];
//            }
//        }
//    }
    
//    CLLocationCoordinate2D coordinate = [ReittiStringFormatter convertStringTo2DCoord:namedBookmark.coords];
//    NSString * name = @"";
//    NSString * subtitle = @"";
//    
//    name = namedBookmark.name;
//    subtitle = namedBookmark.getFullAddress;
//    
//    
//    AnnotationThumbnail *bookmrkAnT = [[AnnotationThumbnail alloc] init];
//    bookmrkAnT.shortCode = namedBookmark.getUniqueIdentifier;
//    bookmrkAnT.image = namedBookmark.annotationImage;
//    bookmrkAnT.title = name;
//    bookmrkAnT.subtitle = subtitle;
//    bookmrkAnT.coordinate = namedBookmark.coordinates;
//    bookmrkAnT.annotationType = FavouriteType;
//    bookmrkAnT.reuseIdentifier = @"namedBookmarkAnnotation";
//    
//    FIRCrashLog(@"Named bookmark annotation coord: %@", namedBookmark.coords);
//    
//    DetailedAnnotation *annot = [DetailedAnnotation annotationWithThumbnail:bookmrkAnT];
    
    
    DetailedAnnotation *annot = (DetailedAnnotation *)namedBookmark.mapAnnotation;
    if (annot) {
        __weak SearchController *weakSelf = self;
        annot.primaryAccessoryAction = ^(MKAnnotationView *annotationView){ [weakSelf openRouteForNamedAnnotationWithTitle:namedBookmark.name andCoords:namedBookmark.coordinates];};
        annot.secondaryButtonBlock = ^(MKAnnotationView *annotationView){ [weakSelf showNamedBookmark:namedBookmark];};
        
        [self.mapViewManager removeReittiAnnotationWithUniqueId:namedBookmark.getUniqueIdentifier andType:FavouriteType];
        [self.mapViewManager plotAnnotations:@[annot]];
        
        if (select) {
            [mapView selectAnnotation:annot animated:YES];
            [self centerMapRegionToCoordinate:namedBookmark.coordinates];
        }
    }
}

-(void)plotBikeStationAnnotations:(NSArray *)stationList {
    if (![self.annotationFilter isAnnotationTypeEnabled:BikeStationLocation]) return;
    
    if (stationList && stationList.count > 0) {
        
        //Remove them so that they are updated
        [self.mapViewManager removeAllReittiAnotationsOfType:BikeStationLocation];
        
        NSMutableArray *allAnots = [@[] mutableCopy];
        for (BikeStation *station in stationList) {
            if (![ReittiMapkitHelper isValidCoordinate:station.coordinates])
                continue;
            
            DetailedAnnotation *annotation = (DetailedAnnotation *)station.mapAnnotation;
            if (annotation) {
                annotation.shrinksWhenZoomedOut = YES;
                annotation.shrinkingZoomLevel = kShrinkingZoomLevel;
                annotation.disappearsWhenZoomedOut = YES;
                annotation.disappearingZoomLevel = kDisapearingZoomLevel;
                
                __weak SearchController *weakSelf = self;
                annotation.primaryAccessoryAction = ^(MKAnnotationView *annotationView){ [weakSelf openRouteForAnnotationWithTitle:station.name subtitle:station.stationId andCoords:station.coordinates];};
                
                [allAnots addObject:annotation];
            }
        }
        
        [self.mapViewManager plotAnnotations:allAnots];
        
//        isShowingBikeAnnotations = YES;
    }
}

-(void)dropAnnotation:(CLLocationCoordinate2D)coordinate {
//    if (gestureRecognizer.state != UIGestureRecognizerStateBegan)
//        return;
    
//    for (id<MKAnnotation> annotation in mapView.annotations) {
//        if ([annotation isKindOfClass:[GCThumbnailAnnotation class]]) {
////            GCThumbnailAnnotation *sAnnotation = (GCThumbnailAnnotation *)annotation;
//            [mapView removeAnnotation:annotation];
//        }
//    }
    
    [self removeAllGeocodeAnnotation];
    
    GCThumbnail *annotTN = [[GCThumbnail alloc] init];
    annotTN.image = [UIImage imageNamed:@"dropped-pin-annotation.png"];
    annotTN.title = @"Dropped pin";
    annotTN.subtitle = @"Searching address";
    annotTN.coordinate = coordinate;
    annotTN.reuseIdentifier = @"geoLocationAnnotation";
    __weak SearchController *weakSelf = self;
    annotTN.primaryButtonBlock = ^{ [weakSelf openRouteFromAnnotationWithTitle:@"Dropped pin" andCoords:coordinate];};
    annotTN.secondaryButtonBlock = ^{ [weakSelf openRouteForNamedAnnotationWithTitle:@"Dropped pin" andCoords:coordinate];};
    annotTN.middleButtonBlock = ^{ [weakSelf saveDroppedPinGeoCode];};
    GCThumbnailAnnotation *annot = [GCThumbnailAnnotation annotationWithThumbnail:annotTN];
    
    [self.mapViewManager plotAnnotations:@[annot]];
    
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

-(void)drawWalkingPolylineForRoute:(Route *)route {
    if (selectedAnnotationView &&
        route.isOnlyWalkingRoute &&
        route.routeLegs &&
        route.routeLegs.count > 0) {
        [self.mapViewManager drawPolylineForObject:route.routeLegs[0]];
    }
}

//-(void)plotStopAnnotation:(BusStopShort *)stop withSelect:(BOOL)select isBookmark:(bool)isBookmark{
//    for (id<MKAnnotation> annotation in mapView.annotations) {
//        if ([annotation isKindOfClass:[DetailedAnnotation class]]) {
//            DetailedAnnotation *sAnnotation = (DetailedAnnotation *)annotation;
//            if ([sAnnotation.code isEqualToString: stop.gtfsId]) {
//                //If is bookmark, no need to draw again.
//                if (isBookmark && !select) {
//                    return;
//                } else {
//                    [mapView removeAnnotation:annotation];
//                }
//            }
//            
//            if (sAnnotation.annotationType == SearchedStopType) {
//                [mapView removeAnnotation:annotation];
//            }
//        }
//    }
//    
//    CLLocationCoordinate2D coordinate = stop.coordinate;
//    
//    NSString * name = stop.name;
//    NSString * shortCode = stop.codeShort ? stop.codeShort : @"";
//    NSString * stopCode = stop.gtfsId;
//    
//    AnnotationThumbnail *stopAnT = [[AnnotationThumbnail alloc] init];
//    UIImage *stopImage = [AppManager stopAnnotationImageForStopType:stop.stopType];
//    stopAnT.image = stopImage;
//    stopAnT.code = stopCode;
//    stopAnT.shortCode = shortCode;
//    stopAnT.title = name;
//    if (stop.linesString) {
//        stopAnT.subtitle = [NSString stringWithFormat:@"Code: %@ · %@", shortCode, stop.linesString];
//    } else {
//        stopAnT.subtitle = [NSString stringWithFormat:@"Code: %@", shortCode];
//    }
//    stopAnT.coordinate = coordinate;
//    stopAnT.annotationType = isBookmark ? FavouriteType : SearchedStopType;
//    stopAnT.reuseIdentifier = @"SearchedStopAnnotation";
//    
//    FIRCrashLog(@"Stop annotation name: %@ - %@ coord: %@", name, shortCode, stop.coords);
//    
//    DetailedAnnotation *annot = [DetailedAnnotation annotationWithThumbnail:stopAnT];
//    
//    __weak SearchController *weakSelf = self;
//    annot.primaryAccessoryAction = ^(MKAnnotationView *annotationView){ [weakSelf openRouteForAnnotationWithTitle:name subtitle:shortCode andCoords:coordinate];};
//    if (stopCode) {
//        annot.secondaryButtonBlock = ^(MKAnnotationView *annotationView){ [weakSelf openStopViewForCode:stopCode  shortCode:shortCode name:name  andCoords:coordinate];};
//        annot.disclosureBlock = ^(MKAnnotationView *annotationView){ [weakSelf openStopViewForCode:stopCode  shortCode:shortCode name:name  andCoords:coordinate];};
//    }
//    
//    [mapView addAnnotation:annot];
//    
//    if (select) {
//        [mapView selectAnnotation:annot animated:YES];
//        [self centerMapRegionToCoordinate:stop.coordinate];
//    }
//}

#pragma mark - Map view manager delegates

-(void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views {
    for (MKAnnotationView *aV in views) {
        if ([aV isKindOfClass:[GCThumbnailAnnotationView class]]){
            droppedPinAnnotationView = (GCThumbnailAnnotationView *)aV;
            break;
        }
    }
}

-(void)mapView:(MKMapView *)affectedMapView didSelectAnnotationView:(MKAnnotationView *)view{
    if ([view conformsToProtocol:@protocol(DetailAnnotationViewProtocol)]) {
        selectedAnnotationView = (NSObject<DetailAnnotationViewProtocol> *)view;

        CLLocationCoordinate2D coord = view.annotation.coordinate;
        
        NSString *fromCoordsString = [NSString stringWithFormat:@"%f,%f", self.currentUserLocation.coordinate.longitude, self.currentUserLocation.coordinate.latitude];
        
        NSString *toCoordsString = [NSString stringWithFormat:@"%f,%f", coord.longitude, coord.latitude];
        
        [self.reittiDataManager getFirstRouteForFromCoords:fromCoordsString andToCoords:toCoordsString andCompletionBlock:^(NSArray *result, NSString *error, ReittiApi usedApi){
            if (!error) {
                [self routeSearchDidComplete:result];
            }else{
                [self routeSearchDidFail:error];
            }
        }];
        
        //Not needed with digi transit
        //TODO: Check if detail exists already
        if ([view.annotation isKindOfClass:[DetailedAnnotation class]]) {
            DetailedAnnotation *stopAnnotation = (DetailedAnnotation *)view.annotation;
            NSString *code = stopAnnotation.thumbnail.code;;
            
            RTStopSearchParam *searchParam = [RTStopSearchParam new];
            searchParam.longCode = code;
            
            [self.reittiDataManager fetchStopsForSearchParams:searchParam andCoords:coord withCompletionBlock:^(BusStop *stop, NSString *errorString){
                if (!errorString) {
                    [self detailStopFetchCompleted:stop];
                }
            }];
        }
        
        [centerLocatorView removeFromSuperview];
        if (droppedPinAnnotationView)
            [mapView removeAnnotation:droppedPinAnnotationView.annotation];
        
    }
}

-(void)mapView:(MKMapView *)affectedMapView didDeselectAnnotationView:(MKAnnotationView *)view{
    selectedAnnotationView = nil;
    
    [self.mapViewManager removeAllOverlaysOfType:ReittiPolylineTypeRouteLeg];
}

-(void)mapViewDidFinishLoadingMap:(MKMapView *)mapView{
    canShowDroppedPin = YES;
}

-(void)mapView:(MKMapView *)_mapView regionWillChangeAnimated:(BOOL)animated{
    if (self.mapViewManager.ignoreRegionChange)
        return;
    
    if (currentLocationButton.tag != kCompasModeCurrentLocationButtonTag) {
        currentLocationButton.alpha = 0.3;
    }
    
    if (centerLocatorView != nil){
        centerLocatorView.alpha = 0.3;
    }
    [self removeAllGeocodeAnnotation];
}

-(void)mapView:(MKMapView *)_mapView regionDidChangeAnimated:(BOOL)animated{
    if (self.mapViewManager.ignoreRegionChange){
        self.mapViewManager.ignoreRegionChange = NO;
        return;
    }
    
    if (self.mapMode == MainMapViewModeStops || self.mapMode == MainMapViewModeStopsAndLive) {
        if ([self shouldShowNearByPlaces]) {
            if ([self shouldUpdateNearByStops]){
                [self setupNearByPlacesListTableView]; //Update bike station distances
                [self fetchStopsInCurrentMapViewRegion];
                //If the location is valid, save the center
                previousValidLocation = [[CLLocation alloc] initWithLatitude:self.mapView.region.center.latitude longitude:self.mapView.region.center.longitude];
                
            }
            
//            if (self.allBikeStations)
//                [self plotBikeStationAnnotations:self.allBikeStations];
        }else{
//            [self removeAllStopAnnotations];
//            [self removeAllBikeStationAnnotations];
            self.nearByStopList = @[];
            nearbyListInfoType = NearbyListInfoTypeZoomedOut;
            [self setupNearByPlacesListTableView];
        }
    }
    
    [self updateCenterLocationPositionWithGeocodeUpdate:YES];
    
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

-(void)saveDroppedPinGeoCode {
    if (droppedPinGeoCode != nil) {
        selectedGeoCode = droppedPinGeoCode;
        [self performSegueWithIdentifier:@"saveGeoCode" sender:nil];
    }
    
    [[ReittiAnalyticsManager sharedManager] trackFeatureUseEventForAction:kActionOpenGeoLocationFromDroppedPin label:nil value:nil];
}

-(void)openStopViewForCode:(NSString *)code shortCode:(NSString *)shortCode name:(NSString *)name andCoords:(CLLocationCoordinate2D)coords{
    selectedStopCode = code;
    selectedStopAnnotationCoords = coords;
    selectedStopShortCode = shortCode;
    selectedStopName = name;
    [self performSegueWithIdentifier:@"openStopView" sender:nil];
}

-(void)openStopViewForCode:(NSString *)code {
    if (!code) return;
    
    StopEntity *stop = [[StopCoreDataManager sharedManager] fetchSavedStopFromCoreDataForCode:code];
    if (!stop)
        stop = [[StopCoreDataManager sharedManager] fetchStopHistoryFromCoreDataForCode:code];
    if (!stop)
        return;
    [self openStopViewForCode:code shortCode:stop.busStopShortCode name:stop.busStopName andCoords:[ReittiStringFormatter convertStringTo2DCoord:stop.busStopCoords]];
}

#pragma mark - MapView helpers

-(void)removeAllVehicleAnnotation {
    [self.mapViewManager removeAllAnotationsOfType:[LVThumbnailAnnotation class]];
    //    for (id<MKAnnotation> annotation in mapView.annotations) {
    //        if ([annotation isKindOfClass:[LVThumbnailAnnotation class]]) {
    //            [mapView removeAnnotation:annotation];
    //        }
    //    }
}

-(void)removeAllGeocodeAnnotation {
    [self.mapViewManager removeAllAnotationsOfType:[GCThumbnailAnnotation class]];
    //    for (id<MKAnnotation> annotation in mapView.annotations) {
    //        if ([annotation isKindOfClass:[GCThumbnailAnnotation class]]) {
    //            [mapView removeAnnotation:annotation];
    //        }
    //    }
}

-(BOOL)shouldShowDroppedPin {
    if (!canShowDroppedPin) {
        return NO;
    }
    
    if (mapView.userTrackingMode == MKUserTrackingModeFollowWithHeading) {
        return NO;
    }
    
    //if there is another seleced annotation
    if (selectedAnnotationView) { return NO; }
    
    //Check if the region is out of supported regions
    CGPoint centerPoint = self.mapView.center;
    CLLocationCoordinate2D coordinate = [mapView convertPoint:centerPoint toCoordinateFromView:mapView];
    
    //Check if at least 250m from current location
    CLLocation *location = [[CLLocation alloc] initWithLatitude:coordinate.latitude longitude:coordinate.longitude];
    CLLocationDistance dist = [location distanceFromLocation:self.currentUserLocation];
    if (dist < 250 && self.currentUserLocation != nil) {
        return NO;
    }
    
    //Do not show if the list view is taking more than 2/3 of the screen
    if ([self nearbyStopViewTopSpacing] < self.view.frame.size.height/3) {
        return NO;
    }
    
    //Check the zoom level
    if ([self.mapViewManager zoomLevel] < 10) {
        return NO;
    }
    
    return YES;
}

-(BOOL)shouldShowNearByPlaces {
    return [self.mapViewManager zoomLevel] >= kDisapearingZoomLevel;
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

#pragma mark - disruptions methods
-(void)initDisruptionFetching{
    //init a timer
    [self fetchDisruptions];
    refreshTimer = [NSTimer scheduledTimerWithTimeInterval:90 target:self selector:@selector(fetchDisruptions) userInfo:nil repeats:YES];
}

-(void)fetchDisruptions{
    [self.reittiDataManager fetchDisruptionsWithCompletionBlock:^(NSArray *disruption, NSString *errorString){
        if (!errorString) {
            [self disruptionFetchDidComplete:disruption];
        }else{
            [self disruptionFetchDidFail:errorString];
        }
    }];
}

-(void)showDisruptionCustomBadge:(bool)show{
    MainTabBarController *tabBarController = (MainTabBarController *)self.tabBarController;
    [tabBarController showBadgeOnMoreTab:show];
}

#pragma mark - text field mehthods
-(void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar{
    [self performSegueWithIdentifier: @"addressSearchController" sender: self];
}

#pragma - mark View transition methods

-(IBAction)openRouteSearchView:(id)sender{
    RouteSearchParameters *searchParms = [[RouteSearchParameters alloc] initWithToLocation:mainSearchBar.text toCoords:prevSearchedCoords fromLocation:nil fromCoords:nil];
    [self switchToRouteSearchViewWithRouteParameter:searchParms];
}

-(void)openRouteViewForSavedRouteWithName:(NSString *)savedRoute{
    RouteEntity *route = [[RouteCoreDataManager sharedManager] fetchSavedRouteFromCoreDataForCode:savedRoute];
    if (route) {
        RouteSearchParameters *searchParms = [[RouteSearchParameters alloc] initWithToLocation:route.toLocationName toCoords:route.toLocationCoordsString fromLocation:route.fromLocationName fromCoords:route.fromLocationCoordsString];
        [self switchToRouteSearchViewWithRouteParameter:searchParms];
    }
}

-(void)openRouteViewForFromLocation:(MKDirectionsRequest *)directionsInfo{
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

#pragma - mark IBActions
-(IBAction)centerCurrentLocationButtonPressed:(id)sender {
    [ReittiLocationManager isLocationServiceAvailableWithMessage:YES showMessageIn:self];
    
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

-(IBAction)listNearbyStopsPressed:(id)sender {
    /*
    if ([self isNearByStopsListViewHidden]) {
        [self hideNearByStopsView:NO animated:YES];
        [[ReittiAnalyticsManager sharedManager] trackFeatureUseEventForAction:kActionListNearByStops label:nil value:nil];
    }else{
        [self hideNearByStopsView:YES animated:YES];
    }
     */
}

//-(IBAction)refreshOrShowListButtonPressed:(id)sender{
//    if ([self isNearByStopsListViewHidden]) {
//        [self listNearbyStopsPressed:self];
//    }else{
//        [departuresRefreshTimer invalidate];
//        [self initDeparturesRefreshTimer];
//        [self refreshDepartures:self];
//    }
//}

-(IBAction)refreshDepartures:(id)sender{
//    if(![self isNearByStopsListViewHidden]){
//        //Show activity indicator no matter what
//        [self showStopFetchActivityIndicator:@YES];
//        [self performSelector:@selector(showStopFetchActivityIndicator:) withObject:@NO afterDelay:1];
//        
//        [self setupNearByPlacesListTableView];
//    }
    [self setupNearByPlacesListTableView];
}

-(void)centerLocatorTapped:(id)sender{
    CGPoint mapCenter = centerLocatorView.center;
    //The center has to be moved up from the center so that the annotation will be positioned right above it.
    mapCenter.y -= 20;
    
    CLLocationCoordinate2D coordinate = [mapView convertPoint:mapCenter toCoordinateFromView:mapView];
    
    [self dropAnnotation:coordinate];
}

/*
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
            }else if(recognizer.view.frame.origin.y < [self searchViewUpperBound]){
                [self setNearbyStopsViewTopSpacing:[self searchViewUpperBound]];
            }
        }];
    }
}
*/

-(IBAction)openSettingsButtonPressed:(id)sender {
    [self performSegueWithIdentifier:@"showSettings" sender:self];
}

//-(IBAction)hideSearchResultViewPressed:(id)sender {
//    [self hideNearByStopsView:YES animated:YES];
//}

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    // Return YES so the pan gesture of the containing table view is not cancelled by the long press recognizer
    return YES;
}

#pragma - mark Scroll View delegates
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    NSLog(@"Content offset: %f", scrollView.contentOffset.y);
    if (scrollView.contentOffset.y < -1) { /* drag the stop view down if table view is fully scrolled down */
        [self increamentNearByStopViewTopSpaceBy:-scrollView.contentOffset.y];
        stopViewDragedDown = YES;
        scrollView.contentOffset = CGPointMake(scrollView.contentOffset.x, 0);
        
    }else if(scrollView.contentOffset.y > 0 ){
        if ([self nearbyStopViewTopSpacing] > [self searchViewUpperBound]) {
            [self increamentNearByStopViewTopSpaceBy:-scrollView.contentOffset.y];
            
//            if ([self nearbyStopViewTopSpacing] > 0)
                scrollView.contentOffset = CGPointMake(scrollView.contentOffset.x, 0);
        }else{
//            stopViewDragedDown = NO;
            //
//            nearbyStopsListsTable.layer.borderColor = [[UIColor lightGrayColor] CGColor];
//            nearbyStopsListsTable.layer.borderWidth = 0.5;
        }
        stopViewDragedDown = NO;

    }else{
//        nearbyStopsListsTable.layer.borderColor = [[UIColor lightGrayColor] CGColor];
//        nearbyStopsListsTable.layer.borderWidth = 0;
    }
}

//-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
//    static CGFloat previousOffset;
//    NSLog(@"Content offset: %f", previousOffset);
//    if (scrollView.contentOffset.y < -1) { /* drag the stop view down if table view is fully scrolled down */
//        [self increamentNearByStopViewTopSpaceBy:-scrollView.contentOffset.y];
//        scrollView.contentOffset = CGPointMake(scrollView.contentOffset.x, 0);
//        
//    }else if(scrollView.contentOffset.y > 0 ){
//        if ([self nearbyStopViewTopSpacing] > 0) {
//            [self increamentNearByStopViewTopSpaceBy:-scrollView.contentOffset.y];
//            scrollView.contentOffset = CGPointMake(scrollView.contentOffset.x, 0);
//        }else{
//            [self increamentNearByStopViewTopSpaceBy:-scrollView.contentOffset.y];
//        }
//    }
//    CGFloat verticalDelta = previousOffset - scrollView.contentOffset.y;
//    NSLog(@"Delta: %f", verticalDelta);
//    
//    [self increamentNearByStopViewTopSpaceBy:verticalDelta];
//    
////    if (scrollView.contentOffset.y < -1) {
////        [self increamentNearByStopViewTopSpaceBy:verticalDelta];
////        scrollView.contentOffset = CGPointMake(scrollView.contentOffset.x, 0);
////    }else
//    if ([self nearbyStopViewTopSpacing] > [self searchViewUpperBound] ||
//        scrollView.contentOffset.y < 0) {
////        previousOffset = scrollView.contentOffset.y;
//        scrollView.contentOffset = CGPointMake(scrollView.contentOffset.x, 0);
//    } else {
//        previousOffset = scrollView.contentOffset.y;
//    }
//}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    if (stopViewDragedDown && !decelerate) { /* drag the stop view down if table view is fully scrolled down */
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
//-(void)stopFetchDidComplete:(NSArray *)stopList{
//    if (stopList != nil) {
//        self.searchedStopList = stopList;
//    }
//    
//    [self showStopFetchActivityIndicator:@NO];
//}
//
//-(void)stopFetchDidFail:(NSString *)error{
//    [self showStopFetchActivityIndicator:@NO];
//}

#pragma mark - Stops in area handler methods
-(void)fetchStopsInCurrentMapViewRegion {
    [self fetchStopsInMapViewRegion:[self visibleMapRegion]];
}

-(void)fetchStopsInMapViewRegion:(MKCoordinateRegion)region{
    if (![self.annotationFilter isAnyNearByStopAnnotationEnabled]) return;
    
    nearbyListInfoType = NearbyListInfoTypeLoading;
    [self.reittiDataManager fetchStopsInAreaForRegion:region withCompletionBlock:^(NSArray *stopsList, NSString *errorMessage){
        if (!errorMessage) {
            [self nearByStopFetchDidComplete:stopsList];
        }else{
            [self nearByStopFetchDidFail:errorMessage];
        }
    }];
}

-(void)fetchStopsDetailsForBusStopShorts:(NSArray *)busStopShorts{
    if (!busStopShorts || busStopShorts.count < 1)
        return;
    
    __block NSInteger numberOfStops = 0;
        
    for (BusStopShort *busStopShort in busStopShorts) {
        if ([self isthereValidDetailForShortStop:busStopShort])
            continue;

        [self showStopFetchActivityIndicator:@YES];
        numberOfStops ++;
        
        RTStopSearchParam *searchParam = [RTStopSearchParam new];
        searchParam.longCode = busStopShort.gtfsId;
        searchParam.shortCode = busStopShort.codeShort;
        searchParam.stopName = busStopShort.name;
        
        [self.reittiDataManager fetchStopsForSearchParams:searchParam andCoords:[ReittiStringFormatter convertStringTo2DCoord:busStopShort.coords] withCompletionBlock:^(BusStop *stop, NSString *errorString){
            if (!errorString) {
                [self setDetailStopForBusStopShort:busStopShort busStop:stop];
                [nearbyStopsListsTable reloadData];
            }
            
            numberOfStops--;
            if (numberOfStops == 0)
                [self showStopFetchActivityIndicator:@NO];
        }];
    }
}

-(void)nearByStopFetchDidComplete:(NSArray *)stopList {
    //Filter for current annotation list
    NSArray *filteredStops = [self filterStopsForAnnotationFilter:stopList];
    
    self.nearByStopList = filteredStops;
    
    for (BusStop *stop in filteredStops) {
        [self setDetailStopForBusStopShort:stop busStop:stop];
    }
    
    nearbyListInfoType = NearbyListInfoTypeNothingNearby;
    [self setupNearByPlacesListTableView];
    [self plotNearbyStopAnnotations:filteredStops];
    
    retryCount = 0;
}
-(void)nearByStopFetchDidFail:(NSString *)error{
    if (![error isEqualToString:@""]) {
        if ([error isEqualToString:@"Request timed out."] && retryCount < 1) {
            [self listNearbyStopsPressed:nil];
            retryCount++;
            return;
        }
    }
    
    nearbyListInfoType = NearbyListInfoTypeError;
    nearbyStopsFetchErrorMessage = error;
    self.nearByStopList = [@[] mutableCopy];
    [self setupNearByPlacesListTableView];
}

-(void)detailStopFetchCompleted:(BusStop *)stop{
    if (selectedAnnotationView && stop.linesString && stop.linesString.length > 0) {
        [selectedAnnotationView setSubtitleLabelText:[NSString stringWithFormat:@"Code: %@ · %@", stop.codeShort, stop.linesString]];
    }
}

-(void)routeSearchDidComplete:(NSArray *)routeList{
    if (routeList != nil && routeList.count > 0) {
        Route *route = [routeList firstObject];
        NSInteger durationInSeconds = [route.routeDurationInSeconds integerValue];
        [selectedAnnotationView setGoToHereDurationString:nil duration:[NSString stringWithFormat:@"%d min", (int)durationInSeconds/60] withIconImage:route.routeIcon];
        [self drawWalkingPolylineForRoute:route];
    }
}
-(void)routeSearchDidFail:(NSString *)error {
    
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
    
    if (droppedPinAnnotationView &&
        [droppedPinAnnotationView conformsToProtocol:@protocol(GCThumbnailAnnotationViewProtocol)]) {
        [((NSObject<GCThumbnailAnnotationViewProtocol> *)droppedPinAnnotationView) enableAddressInfoButton];
    }
    
    droppedPinLocation = [geoCode getStreetAddressString];
    
    [self setSearchBarText:droppedPinLocation isManualSearchText:NO];
    if (!searchBarTextManuallySet) {
        prevSearchedCoords = geoCode.coords;
    }
}
- (void)reverseGeocodeSearchDidFail:(NSString *)error{
    self.droppedPinGeoCode = nil;
    [[DroppedPinManager sharedManager] setDroppedPin:nil];
 
}

#pragma mark - Live vehicle methods
- (void)startFetchingLiveVehicles {
    [self.reittiDataManager startFetchingAllLiveVehiclesWithCompletionHandler:^(NSArray *vehicles, NSString *errorString){
        if (!errorString) {
            if ([settingsManager showLiveVehicles]) {
                [self.mapViewManager plotVehicleAnnotations:vehicles];
            }
        }
    }];
}

#pragma mark - Bike station fetching
//Bike stations needs to be updated constantly to get available bikes
- (void)startFetchingBikeStations {
    if (![AppFeatureManager proFeaturesAvailable]) return;
    
    if (![self.annotationFilter isAnnotationTypeEnabled:BikeStationLocation]) return;
    
    [self.reittiDataManager startFetchingBikeStationsWithCompletionBlock:^(NSArray *bikeStations, NSString *errorString){
        if (!errorString && bikeStations && bikeStations.count > 0) {
            self.allBikeStations = bikeStations;
            [self setupNearByPlacesListTableView];
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
-(void)searchResultSelectedARoute:(RouteEntity *)routeEntity {
    
    RouteSearchParameters *searchParms = [[RouteSearchParameters alloc] initWithToLocation:routeEntity.toLocationName toCoords:routeEntity.toLocationCoordsString fromLocation:routeEntity.fromLocationName fromCoords:routeEntity.fromLocationCoordsString];
    [self switchToRouteSearchViewWithRouteParameter:searchParms];
}

-(void)searchResultSelectedAStop:(StopEntity *)stopEntity{
    [self hideNearByStopsView:YES animated:YES];
    [self centerMapRegionToCoordinate:stopEntity.coordinates];
    
    id busStop = stopEntity.toBusStopShort;
    if (busStop)
        [self plotSearchedStop:busStop];
    
    [self setSearchBarText:stopEntity.displayName isManualSearchText:YES];
    prevSearchedCoords = stopEntity.busStopCoords;
}

-(void)searchResultSelectedAGeoCode:(GeoCode *)geoCode{
    [self hideNearByStopsView:YES animated:YES];
    [self centerMapRegionToCoordinate:geoCode.coordinates];
    
    if (geoCode.locationType == LocationTypeStop) {
        [self plotSearchedStop:geoCode.busStop];
    }else{
        [self plotGeoCodeAnnotation:geoCode];
    }
    
    [self setSearchBarText:geoCode.getStreetAddressString isManualSearchText:YES];
    prevSearchedCoords = geoCode.coords;
}

-(void)searchResultSelectedANamedBookmark:(NamedBookmark *)namedBookmark{
    [self hideNearByStopsView:YES animated:YES];
    [self centerMapRegionToCoordinate:namedBookmark.coordinates];
    
    [self plotNamedBookmarkAnnotation:namedBookmark withSelect:YES];
    
    [self setSearchBarText:namedBookmark.name isManualSearchText:YES];
    prevSearchedCoords = namedBookmark.coords;
}

-(void)searchResultSelectedCurrentLocation {}

-(void)searchViewControllerDismissedToRouteSearch:(NSString *)prevSearchTerm{
    [self setSearchBarText:prevSearchTerm isManualSearchText:YES];
    RouteSearchParameters *searchParms = [[RouteSearchParameters alloc] initWithToLocation:mainSearchBar.text toCoords:prevSearchedCoords fromLocation:nil fromCoords:nil];
    [self switchToRouteSearchViewWithRouteParameter:searchParms];
}

#pragma mark - settings view delegate
-(void)setMapModeForSettings {
    switch ([settingsManager mapMode]) {
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
    if ([[ReittiRegionManager sharedManager] identifyRegionOfCoordinate:mapView.region.center] != [settingsManager userLocation]) {
        [self.reittiDataManager setUserLocationRegion:[settingsManager userLocation]];
        [self centerMapRegionToCoordinate:[ReittiRegionManager getCoordinateForRegion:[settingsManager userLocation]]];
    }
    
    if ([settingsManager showLiveVehicles]) {
        [self removeAllVehicleAnnotation];
        [self.reittiDataManager stopFetchingLiveVehicles];
        
        [self startFetchingLiveVehicles];
    }
    
    [self startFetchingBikeStations];
    
    [self fetchDisruptions];
    [self updateFilter];
}

-(void)shouldShowVehiclesSettingsValueChanged:(NSNotification *)notification{
    if ([settingsManager showLiveVehicles]) {
        [self startFetchingLiveVehicles];
    }else{
        [self removeAllVehicleAnnotation];
        [reittiDataManager stopFetchingLiveVehicles];
    }
}

-(void)settingsValueChanged {
    
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

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"seeFullTimeTable"]) {
        WebViewController *webViewController = (WebViewController *)segue.destinationViewController;
        NSURL *url = [NSURL URLWithString:self._busStop.timetableLink];
        webViewController._url = url;
        webViewController._pageTitle = _busStop.codeShort;
    }
    
    if ([segue.identifier isEqualToString:@"openStopView"] || [segue.identifier isEqualToString:@"openNearbyStop"] || [segue.identifier isEqualToString:@"openNearbyStop2"])
    {
        StopViewController *stopViewController = (StopViewController *)segue.destinationViewController;
        
        if ([segue.identifier isEqualToString:@"openNearbyStop"] || [segue.identifier isEqualToString:@"openNearbyStop2"] ) {
            
            NearbyTableViewCell *selectedCell = [nearbyStopsListsTable cellForRowAtIndexPath:nearbyStopsListsTable.indexPathForSelectedRow];
            if (selectedCell.groupedDepartures) {
                [self configureStopViewController:stopViewController withBusStopShort:selectedCell.groupedDepartures.stop];
            }
            
            [[ReittiAnalyticsManager sharedManager] trackFeatureUseEventForAction:kActionViewedAStop label:@"From nearby list" value:nil];
        }else{
            [self configureStopViewControllerWithAnnotation:stopViewController];
            [[ReittiAnalyticsManager sharedManager] trackFeatureUseEventForAction:kActionViewedAStop label:@"From annotation" value:nil];
        }
        
    }
    if ([segue.identifier isEqualToString:@"addressSearchController"]) {
        UINavigationController *navigationController = (UINavigationController *)segue.destinationViewController;
        AddressSearchViewController *addressSearchViewController = [[navigationController viewControllers] lastObject];
        
        addressSearchViewController.prefilDataType = AddressSearchViewControllerPrefilDataTypeAll;
        addressSearchViewController.routeSearchMode = NO;
        addressSearchViewController.simpleSearchMode = YES;
        addressSearchViewController.prevSearchTerm = mainSearchBar.text;
        addressSearchViewController.delegate = self;
    }
    
    if ([segue.identifier isEqualToString:@"showSettings"]) {
        UINavigationController *navigationController = (UINavigationController *)segue.destinationViewController;
        SettingsViewController *controller = (SettingsViewController *)[[navigationController viewControllers] lastObject];
        
        controller.settingsManager = settingsManager;
        controller.delegate = self;
    }
    
    if ([segue.identifier isEqualToString:@"showNamedBookmark"]) {
        UINavigationController *navigationController = (UINavigationController *)segue.destinationViewController;
        EditAddressTableViewController *controller = (EditAddressTableViewController *)[[navigationController viewControllers] lastObject];
        
        controller.namedBookmark = selectedNamedBookmark;
        controller.viewControllerMode = ViewControllerModeViewNamedBookmark;
    }
    
    if ([segue.identifier isEqualToString:@"showGeoCode"] || [segue.identifier isEqualToString:@"saveGeoCode"]) {
        UINavigationController *navigationController = (UINavigationController *)segue.destinationViewController;
        EditAddressTableViewController *controller = (EditAddressTableViewController *)[[navigationController viewControllers] lastObject];
        
        if ([[NamedBookmarkCoreDataManager sharedManager] fetchSavedNamedBookmarkFromCoreDataForCoords:selectedGeoCode.coords] != nil) {
            controller.namedBookmark = [[NamedBookmarkCoreDataManager sharedManager] fetchSavedNamedBookmarkFromCoreDataForCoords:selectedGeoCode.coords];
            controller.viewControllerMode = ViewControllerModeViewNamedBookmark;
        }else{
            controller.geoCode = selectedGeoCode;
            controller.currentUserLocation = self.currentUserLocation;
            controller.viewControllerMode = [segue.identifier isEqualToString:@"saveGeoCode"] ? ViewControllerModeEditAddress : ViewControllerModeViewGeoCode ;
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

-(void)configureStopViewController:(StopViewController *)stopViewController withBusStopShort:(BusStopShort *)busStop{
    if ([stopViewController isKindOfClass:[StopViewController class]]) {
        stopViewController.stopGtfsId = busStop.gtfsId;
        stopViewController.stopCoords = [ReittiStringFormatter convertStringTo2DCoord:busStop.coords];
        stopViewController.stopShortCode = busStop.codeShort;
        stopViewController.stopName = busStop.name;
        
        stopViewController.routeSearchHandler = [self stopViewRouteSearchHandler];
        stopViewController.reittiDataManager = [[RettiDataManager alloc] init];
    }
}

-(void)configureStopViewControllerWithAnnotation:(StopViewController *)stopViewController{
    if ([stopViewController isKindOfClass:[StopViewController class]]) {
        stopViewController.stopGtfsId = selectedStopCode;
        stopViewController.stopCoords = selectedStopAnnotationCoords;
        stopViewController.stopShortCode = selectedStopShortCode;
        stopViewController.stopName = selectedStopName;
        
        stopViewController.routeSearchHandler = [self stopViewRouteSearchHandler];
        stopViewController.reittiDataManager = [[RettiDataManager alloc] init];
    }
}

#pragma mark === UIViewControllerPreviewingDelegate Methods ===

- (UIViewController *)previewingContext:(id<UIViewControllerPreviewing>)previewingContext
              viewControllerForLocation:(CGPoint)location {
    
    UIView *view = [self.view hitTest:location withEvent:UIEventTypeTouches];
    //For some reason detailAnnotView returns the pins imageview for hit test
    if (![view isKindOfClass:[MKAnnotationView class]] &&
        [[view superview] isKindOfClass:[MKAnnotationView class]]) {
        view = [view superview];
    }
    
    if ([view isKindOfClass:[MKAnnotationView class]]) {
        MKAnnotationView *annotationView = (MKAnnotationView *)view;
        NSString *stopCode, *stopShortCode, *stopName;
        CLLocationCoordinate2D stopCoords;
        
        if ([annotationView.annotation isKindOfClass:[DetailedAnnotation class]])
        {
            DetailedAnnotation *stopAnnotation = (DetailedAnnotation *)annotationView.annotation;
            if ([EnumManager isNearbyStopAnnotationType:stopAnnotation.thumbnail.annotationType] || stopAnnotation.thumbnail.annotationType == SearchedStopType) {
                stopCode = stopAnnotation.code;
                stopCoords = stopAnnotation.coordinate;
                stopShortCode = stopAnnotation.thumbnail.shortCode;
                stopName = stopAnnotation.thumbnail.title;
            }
            
            if (stopCode != nil && ![stopCode isEqualToString:@""]) {
                //            UINavigationController *navigationController = (UINavigationController *)segue.destinationViewController;
                
                StopViewController *stopViewController = (StopViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"ASAStopViewController"];
                stopViewController.stopGtfsId = stopCode;
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
        NearbyTableViewCell *cell = (NearbyTableViewCell *)[nearbyStopsListsTable cellForRowAtIndexPath:selectedRowIndexPath];
        
        BusStopShort *selected = cell && [cell isKindOfClass:NearbyTableViewCell.class] ? cell.groupedDepartures.stop : nil;
        if (cell && selected) {
            CGRect convertedRect = [cell.superview convertRect:[nearbyStopsListsTable rectForRowAtIndexPath:selectedRowIndexPath] toView:self.view];
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
