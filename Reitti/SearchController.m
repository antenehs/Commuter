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
#import "LiveTrafficManager.h"
#import "Vehicle.h"
#import "CoreDataManager.h"
#import "DroppedPinManager.h"
#import "GCThumbnailAnnotation.h"

@interface SearchController ()

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
@synthesize reittiDataManager, settingsManager, cacheManager;
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
    
    /*init View Components*/
    
    [self initGuestureRecognizers];
    [self setNeedsStatusBarAppearanceUpdate];
    [self setNavBarApearance];
    [self setMapModeForSettings];
//    [self setUpToolBarWithMiddleImage:@"list-100.png"];
//    [self setUpModeSelector];
    [self hideNearByStopsView:YES animated:NO];
    
    appOpenCount = [self.reittiDataManager getAppOpenCountAndIncreament];
    if (appOpenCount > 3 && ![AppManager isNewInstallOrNewVersion]) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Enjoy Using The App?"
                                                            message:@"The gift of 5 little starts is satisfying for both of us more than you think."
                                                           delegate:self
                                                  cancelButtonTitle:@"Maybe later"
                                                  otherButtonTitles:@"Try it", nil];
        alertView.tag = 1001;
        [alertView show];
    }
    
    if ([AppManager isNewInstallOrNewVersion]) {
        [self performSegueWithIdentifier:@"showWelcomeView" sender:self];
        
    }
    
//    [TSMessage showNotificationInViewController:self
//                                          title:@"Update available"
//                                       subtitle:@"Please update the app"
//                                          image:nil
//                                           type:TSMessageNotificationTypeMessage
//                                       duration:TSMessageNotificationDurationAutomatic
//                                       callback:nil
//                                    buttonTitle:@"Update"
//                                 buttonCallback:^{
//                                     NSLog(@"User tapped the button");
//                                 }
//                                     atPosition:TSMessageNotificationPositionTop
//                           canBeDismissedByUser:YES];
    
    //Testing
//    NSUserDefaults *sharedDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.commuterAppExtension"];
//    
//    [sharedDefaults setInteger:9 forKey:@"MyNumberKey"];
//    [sharedDefaults synchronize];
    
}

-(void)viewWillAppear:(BOOL)animated{
    for (UIView *subView in mainSearchBar.subviews)
    {
        for (UIView *secondLevelSubview in subView.subviews){
            if ([secondLevelSubview isKindOfClass:[UITextField class]])
            {
                UITextField *searchBarTextField = (UITextField *)secondLevelSubview;
                
                //set font color here
                searchBarTextField.textColor = [UIColor whiteColor];
                
                break;
            }
        }
    }
    [self fetchDisruptions];
    [self hideNearByStopsView:YES animated:YES];
    [self.navigationController setToolbarHidden:YES animated:NO];
}

-(void)viewDidAppear:(BOOL)animated{
//    [super viewDidAppear:animated];
//    [[UILabel appearanceWhenContainedIn:[UISearchBar class], nil] setTextColor:[UIColor whiteColor]];
    
    for (UIView *subView in mainSearchBar.subviews)
    {
        for (UIView *secondLevelSubview in subView.subviews){
            if ([secondLevelSubview isKindOfClass:[UITextField class]])
            {
                UITextField *searchBarTextField = (UITextField *)secondLevelSubview;
                
                //set font color here
                searchBarTextField.textColor = [UIColor whiteColor];
                
                break;
            }
        }
    }
    
    [self setNavBarSize];
    [mainSearchBar setPlaceholder:@"address, stop or poi"];
    
    //StartVehicleFetching
    if (settingsManager.userLocation == HSLRegion && [settingsManager shouldShowLiveVehicles]) {
        [reittiDataManager fetchAllLiveVehicles];
    }else{
        [self removeAllVehicleAnnotation];
    }
}

-(void)viewDidDisappear:(BOOL)animated{
    [reittiDataManager stopFetchingLiveVehicles];
    [self removeAllVehicleAnnotation];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self setNavBarSize];
//    [self setSegmentControlSize];
}

//- (id<UILayoutSupport>)topLayoutGuide {
//    return [[MyFixedLayoutGuide alloc]initWithLength:0];
//}

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
    [[NSNotificationCenter defaultCenter] removeObserver:self name:[SettingsManager userlocationChangedNotificationName] object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:[SettingsManager mapModeChangedNotificationName] object:nil];
}

#pragma - mark initialization Methods

- (void)initDataComponentsAndModules
{
    [self initVariablesAndConstants];
    
//    [self selectSystemColors];
    [self initDataManagers];
    [self initReminderStore];
    [self initializeMapComponents];
    [self initDisruptionFetching];
    [self setBookmarkedStopsToDefaults];
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
    dataManger.delegate = self;
    dataManger.routeSearchdelegate = self;
    dataManger.disruptionFetchDelegate = self;
    dataManger.reverseGeocodeSearchdelegate = self;
    dataManger.vehicleFetchDelegate = self;
    //dataManger.managedObjectContext = self.managedObjectContext;
    self.reittiDataManager = dataManger;
    
    self.settingsManager = [[SettingsManager alloc] initWithDataManager:self.reittiDataManager];
    
    //Clean history more than the specified date
    if ([settingsManager isClearingHistoryEnabled]) {
        [self.reittiDataManager clearHistoryOlderThanDays:[settingsManager numberOfDaysToKeepHistory]];
    }
    
    //StartVehicleFetching
    if (settingsManager.userLocation == HSLRegion && [settingsManager shouldShowLiveVehicles]) {
        [reittiDataManager fetchAllLiveVehicles];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(mapModeSettingsValueChanged:)
                                                 name:[SettingsManager mapModeChangedNotificationName] object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(userLocationSettingsValueChanged:)
                                                 name:[SettingsManager userlocationChangedNotificationName] object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(shouldShowVehiclesSettingsValueChanged:)
                                                 name:[SettingsManager shouldShowVehiclesNotificationName] object:nil];
    
    [self.reittiDataManager setUserLocationToRegion:[settingsManager userLocation]];
    
    self.cacheManager = [CacheManager sharedManager];
}

- (void)initReminderStore
{
    _eventStore = [[EKEventStore alloc] init];
    
    [_eventStore requestAccessToEntityType:EKEntityTypeReminder
                                completion:^(BOOL granted, NSError *error) {
                                    if (!granted){
                                        NSLog(@"Access to store not granted");
                                        //                                        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"No Access to Reminders app"                                                                                      message:@"Please grant access to the Reminders app from Settings/Privacy/Reminders later to use the reminder feature."
                                        //                                                                                       delegate:nil
                                        //                                                                              cancelButtonTitle:@"OK"
                                        //                                                                              otherButtonTitles:nil];
                                        //                                        [alertView show];
                                    }
                                }];
}

- (void)initGuestureRecognizers
{
    //    [blurView addGestureRecognizer:blurViewGestureRecognizer];
    
//    stopViewGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(stopViewGestureDetected:)];
    
    stopViewDragGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(dragStopView:)];
    
    [StopView addGestureRecognizer:stopViewDragGestureRecognizer];
    
//    [StopView addGestureRecognizer:stopViewGestureRecognizer];
    
    searchResultsViewGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(nearByStopsListViewGestureDetected:)];
    
    searchResultViewDragGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(dragStopView:)];
    
    [searchResultsView addGestureRecognizer:searchResultViewDragGestureRecognizer];
    
    UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc]
                                          initWithTarget:self action:@selector(dropAnnotation:)];
    lpgr.minimumPressDuration = 1.0; //user needs to press for 2 seconds
    [mapView addGestureRecognizer:lpgr];
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
    locNotAvailableNotificationShow = NO;
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
    retryCount = 0;
    annotationAnimCounter = 0;
    
    firstRecievedLocation = YES;
    userLocationUpdated = NO;
    
    mapMode = MainMapViewModeStopsAndLive;
    
    self.searchResultListViewMode = RSearchResultViewModeNearByStops;
}


#pragma mark - Nav bar and toolbar methods
//- (void)selectSystemColors{
//    if (self.darkMode) {
////        systemBackgroundColor = [UIColor clearColor];
//        systemBackgroundColor = [UIColor colorWithRed:0/255 green:0/255 blue:0/255 alpha:1];
//        systemTextColor = SYSTEM_GREEN_COLOR;
//        systemSubTextColor = [UIColor lightGrayColor];
//    }else{
//        systemBackgroundColor = nil;
//        systemTextColor = SYSTEM_GREEN_COLOR;
//        systemSubTextColor = [UIColor darkGrayColor];
//    }
//}

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
    for (UIView *subView in mainSearchBar.subviews)
    {
        for (UIView *secondLevelSubview in subView.subviews){
            if ([secondLevelSubview isKindOfClass:[UITextField class]])
            {
                UITextField *searchBarTextField = (UITextField *)secondLevelSubview;
                
                //set font color here
                searchBarTextField.textColor = [UIColor whiteColor];
                
                break;
            }
        }
    }
    
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

//-(void)setUpToolBarWithMiddleImage:(NSString *)imageName{
//    CGRect frame = CGRectMake(0, 0, 25, 26);
//    CGRect settingsFrame = CGRectMake(0, 0, 26, 26);
//    CGRect liveFrame = CGRectMake(0, 0, 28, 26);
////    CGRect middleButFrame = CGRectMake(0, 0, 30, 25);
//    CGRect middleButFrame = CGRectMake(0, 0, 26, 25);
//    
//    UIImage *image1 = [UIImage imageNamed:@"settings-green-100.png"];
//    settingsBut = [[UIButton alloc] initWithFrame:settingsFrame];
//    [settingsBut setBackgroundImage:image1 forState:UIControlStateNormal];
//    
//    [settingsBut addTarget:self action:@selector(openSettingsButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
//    
//    UIBarButtonItem* locBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:settingsBut];
//    
//    
//    UIBarButtonItem *flexiSpace1 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
//    
////    UIImage *image2 = [UIImage imageNamed:imageName];
//    UIImage *image2 = [UIImage imageNamed:@"plan-green-100.png"];
//    
//    listButton = [[UIButton alloc] initWithFrame:middleButFrame];
//    [listButton setBackgroundImage:image2 forState:UIControlStateNormal];
//    
//    [listButton addTarget:self action:@selector(listNearbyStopsPressed:) forControlEvents:UIControlEventTouchUpInside];
//    
//    UIBarButtonItem* listBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:listButton];
//    
//    UIBarButtonItem *flexiSpace2 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
//    
//    UIImage *image3 = [UIImage imageNamed:@"bookmark-green-filled-100.png"];
//    
//    bookmarkButton = [[UIButton alloc] initWithFrame:frame];
//    [bookmarkButton setBackgroundImage:image3 forState:UIControlStateNormal];
//    
//    [bookmarkButton addTarget:self action:@selector(openBookmarkedButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
//    
//    UIBarButtonItem* bookmarkBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:bookmarkButton];
//    
//    UIBarButtonItem *flexiSpace3 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
//    
//    UIImage *image4 = [UIImage imageNamed:@"more-green-100.png"];
//    
//    UIButton *moreButton = [[UIButton alloc] initWithFrame:liveFrame];
//    [moreButton setBackgroundImage:image4 forState:UIControlStateNormal];
//    [moreButton addTarget:self action:@selector(openMoreViewButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
//    
//    UIBarButtonItem* moreBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:moreButton];
//    
//    NSMutableArray *items = [[NSMutableArray alloc] init];
//    [items addObject:bookmarkBarButtonItem];
//    [items addObject:flexiSpace1];
//    [items addObject:listBarButtonItem];
//    [items addObject:flexiSpace2];
//    [items addObject:locBarButtonItem];
//    [items addObject:flexiSpace3];
//    [items addObject:moreBarButtonItem];
//    self.toolbarItems = items;
//}

//-(void)setUpModeSelector{
//    //     Segmented control with more customization and indexChangeBlock
//    segmentedControl = [[HMSegmentedControl alloc] initWithSectionTitles:@[@"Stops", @"Live"]];
//    [self setSegmentControlSize];
//    [segmentedControl setIndexChangeBlock:^(NSInteger index) {
////        NSLog(@"Selected index %ld (via block)", (long)index);
//        mapMode = (int)index;
//        if (mapMode == MainMapViewModeStops) {
//            [reittiDataManager fetchStopsInAreaForRegion:[mapView region]];
//            [mapView removeAnnotations:mapView.annotations];
//            [reittiDataManager stopFetchingLiveVehicles];
//            
//        }else{
//            [mapView removeAnnotations:mapView.annotations];
//            [reittiDataManager fetchAllLiveVehicles];
//        }
//    }];
////    [segmentedControl addTarget:self action:@selector(mapModeSegmentedControlChangedValue:) forControlEvents:UIControlEventValueChanged];
//    segmentedControl.selectionIndicatorHeight = 4.0f;
//    segmentedControl.backgroundColor = [UIColor colorWithWhite:0.97 alpha:1];
//    segmentedControl.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor colorWithRed:39.0/255.0 green:174.0/255.0 blue:96.0/255.0 alpha:1.0], NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue" size:17.0f]};
////    segmentedControl.titleTextAttributes = @{NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue-Light" size:18.0f]};
//    segmentedControl.selectionIndicatorColor = [UIColor colorWithRed:39.0/255.0 green:174.0/255.0 blue:96.0/255.0 alpha:1.0];
//    segmentedControl.selectionStyle = HMSegmentedControlSelectionStyleBox;
//    segmentedControl.selectedSegmentIndex = mapMode;
//    segmentedControl.selectionIndicatorLocation = HMSegmentedControlSelectionIndicatorLocationDown;
//    segmentedControl.shouldAnimateUserSelection = YES;
//    segmentedControl.tag = 2;
//    segmentedControl.layer.borderWidth = 0.5;
//    segmentedControl.layer.borderColor = [[UIColor grayColor] CGColor];
//    [self.view addSubview:segmentedControl];
//}

-(void)setSegmentControlSize{
    BOOL landscapeMode = self.view.frame.size.width > self.view.frame.size.height;
    CGFloat height = landscapeMode ? 30 : 40;
    [segmentedControl setFrame:CGRectMake(0, segmentedControl.hidden ? 0 - height : 0 , self.view.frame.size.width, height)];
}

- (void)hideSegmentControlView:(bool)hidden animated:(bool)anim{
    
    if (!hidden) {
        segmentedControl.hidden = hidden;
    }
    
    [UIView transitionWithView:self.view duration:anim?0.35:0 options:UIViewAnimationOptionTransitionNone animations:^{
        
        CGRect frame = segmentedControl.frame;
        frame.origin.y = hidden ? 0 - frame.size.height : 0;
        
        segmentedControl.frame = frame;
        
    } completion:^(BOOL finished) {
        if (hidden) {
            segmentedControl.hidden = hidden;
        }
    }];
}

#pragma mark - extension methods
- (void)setBookmarkedStopsToDefaults{
    
    NSArray *savedStops = [self.reittiDataManager fetchAllSavedStopsFromCoreData];
    [self.reittiDataManager updateSavedStopsDefaultValueForStops:savedStops];
    //test
    NSUserDefaults *sharedDefaults2 = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.ewketApps.commuterDepartures"];
    NSLog(@"%@",[sharedDefaults2 dictionaryRepresentation]);
}

//#pragma - mark Command view methods

/*
- (void)setCommandViewApearance{
//    selectedStopLabel.font = CUSTOME_FONT_BOLD(30.0f);
    
    [commandView setBlurTintColor:systemBackgroundColor];
    commandView.alpha = 0.97;
    commandView.layer.borderWidth = 0.5;
    blurView.layer.borderColor = [[UIColor blackColor] CGColor];
    
    //currentLocationButton.hidden = YES;
    listNearbyStops.hidden = NO;
    sendEmailButton.hidden = YES;
    
}

- (void)hideCommandView:(bool)hidden animated:(bool)anim{
    
    if (anim) {
        [UIView transitionWithView:blurView duration:0.35 options:UIViewAnimationOptionTransitionNone animations:^{
            
            [self hideCommandView:hidden];
            
        } completion:^(BOOL finished) {}];
    }else{
        [self hideCommandView:hidden];
    }
    
}

-(void)hideCommandView:(BOOL)hidden{
    
    CGRect commandViewFrame = commandView.frame;
    CGRect cLBFrame = currentLocationButton.frame;
    CGRect nBSBFrame = listNearbyStops.frame;
    CGRect sEBFrame = sendEmailButton.frame;
    
    if (hidden) {
        if (![self isCommandViewHidden]) {
            [commandView setFrame:CGRectMake(0.f, [self view].bounds.size.height, commandViewFrame.size.width, commandViewFrame.size.height)];
            [currentLocationButton setFrame:CGRectMake(cLBFrame.origin.x, cLBFrame.origin.y + commandViewFrame.size.height, cLBFrame.size.width, cLBFrame.size.height)];
            [listNearbyStops setFrame:CGRectMake(nBSBFrame.origin.x, nBSBFrame.origin.y + commandViewFrame.size.height, nBSBFrame.size.width, nBSBFrame.size.height)];
            [sendEmailButton setFrame:CGRectMake(sEBFrame.origin.x, sEBFrame.origin.y + commandViewFrame.size.height, sEBFrame.size.width, sEBFrame.size.height)];
        }
    }
    else
    {
        if ([self isCommandViewHidden]) {
            [commandView setFrame:CGRectMake(0.f, [self view].bounds.size.height - commandViewFrame.size.height, commandViewFrame.size.width, commandViewFrame.size.height)];
            [currentLocationButton setFrame:CGRectMake(cLBFrame.origin.x, cLBFrame.origin.y - commandViewFrame.size.height, cLBFrame.size.width, cLBFrame.size.height)];
            [listNearbyStops setFrame:CGRectMake(nBSBFrame.origin.x, nBSBFrame.origin.y - commandViewFrame.size.height, nBSBFrame.size.width, nBSBFrame.size.height)];
            [sendEmailButton setFrame:CGRectMake(sEBFrame.origin.x, sEBFrame.origin.y - commandViewFrame.size.height, sEBFrame.size.width, sEBFrame.size.height)];
        }
    }
}

-(BOOL)isCommandViewHidden{
    //NSLog(@"%f",[self view].bounds.size.height);
    //NSLog(@"%f",commandView.frame.origin.y);
    bool hidden = commandView.frame.origin.y >= [self view].bounds.size.height;
    return hidden;
    
}

-(void)setUpCommandViewForAnnotation:(id <MKAnnotation>)annotation{
    selectedStopLabel.text = [annotation title];
    selectedStopNameLabel.text = [annotation subtitle];
    StopAnnotation *sAnnotation = (StopAnnotation *)annotation;
    NSLog(@"%@", sAnnotation.code);
    selectedStopCode = [NSString stringWithFormat:@"%d", [sAnnotation.code intValue]];
    selectedStopLongCode = sAnnotation.code;
    
    if ([annotation isKindOfClass:[StopAnnotation class]]) {
        selectedAnnotationUniqeName = [NSString stringWithFormat:@"%@ (%@)", selectedStopNameLabel.text, selectedStopLabel.text];
        selectedAnnotationCoords = [NSString stringWithFormat:@"%f,%f",sAnnotation.coordinate.longitude, sAnnotation.coordinate.latitude];
        showStopTimeTableButton.hidden = NO;
        commandViewButtonSeparator.hidden = NO;
    }else if ([annotation isKindOfClass:[GeoCodeAnnotation class]]) {
        selectedAnnotationUniqeName = [NSString stringWithFormat:@"%@, %@", selectedStopLabel.text, selectedStopNameLabel.text];
        selectedAnnotationCoords = [NSString stringWithFormat:@"%f,%f",sAnnotation.coordinate.longitude, sAnnotation.coordinate.latitude];
        showStopTimeTableButton.hidden = YES;
        commandViewButtonSeparator.hidden = NO;
    }
    
    BOOL firstTime = NO;
    if (prevSelectedStopLongCode == nil) {
        prevSelectedStopLongCode = selectedStopLongCode;
        firstTime = YES;
    }
    if (firstTime || [prevSelectedStopLongCode intValue] != [selectedStopLongCode intValue]) {
        //[self plotStopAnnotations:self.nearByStopList];
        prevSelectedStopLongCode = selectedStopLongCode;
    }
    
}
*/
#pragma mark - Annotation helpers
-(void)openRouteForAnnotationWithTitle:(NSString *)title subtitle:(NSString *)subTitle andCoords:(CLLocationCoordinate2D)coords{
    selectedAnnotationUniqeName = [NSString stringWithFormat:@"%@ (%@)", title,subTitle];
    selectedAnnotationCoords = [NSString stringWithFormat:@"%f,%f",coords.longitude, coords.latitude];
    [self performSegueWithIdentifier:@"routeSearchController" sender:nil];
}

-(void)openRouteForNamedAnnotationWithTitle:(NSString *)title andCoords:(CLLocationCoordinate2D)coords{
    selectedAnnotationUniqeName = [NSString stringWithFormat:@"%@", title];
    if (droppedPinGeoCode != nil) {
        if ([title isEqualToString:@"Dropped pin"]) {
            selectedAnnotationUniqeName = [droppedPinGeoCode getStreetAddressString];
        }
    }
    
    selectedAnnotationCoords = [NSString stringWithFormat:@"%f,%f",coords.longitude, coords.latitude];
    
    [self performSegueWithIdentifier:@"routeSearchController" sender:nil];
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
}

-(void)openStopViewForCode:(NSNumber *)code shortCode:(NSString *)shortCode name:(NSString *)name andCoords:(CLLocationCoordinate2D)coords{
    selectedStopCode = [NSString stringWithFormat:@"%d", [code intValue]];
    selectedStopAnnotationCoords = coords;
    selectedStopShortCode = shortCode;
    selectedStopName = name;
    [self performSegueWithIdentifier:@"openStopView" sender:nil];
}

-(void)openStopViewForCode:(NSNumber *)code{
    StopEntity *stop = [reittiDataManager fetchSavedStopFromCoreDataForCode:code];
    [self openStopViewForCode:code shortCode:stop.busStopShortCode name:stop.busStopName andCoords:[ReittiStringFormatter convertStringTo2DCoord:stop.busStopCoords]];
}


#pragma - mark StopView methods

- (void)requestStopInfoAsyncForCode:(NSString *)code{
    
//    [self.reittiDataManager fetchStopsForCode:code];
}

- (void)showProgressHUD{
    
    //MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    //hud.labelText = @"Loading...";
    [SVProgressHUD show];
    //[SVProgressHUD setBackgroundColor:[UIColor grayColor]];
    //[SVProgressHUD setBackgroundColor:[UIColor colorWithWhite:0.95 alpha:1]];
}


#pragma - mark nearby stops list methods
//-(void)displaySearchResults:(NSArray *)result{
////    [self setupSearchResultViewForSearchResult:result];
////    [self hideSearchResultView:NO animated:YES];
//}
//-(void)setupSearchResultViewForSearchResult:(NSArray *)result{
////    [self setupSearchResultViewAppearance];
////    
////    self.searchResultListViewMode = RSearchResultViewModeSearchResults;
////    searchResultsLabel.text = [NSString stringWithFormat:@"%lu stops found", (unsigned long)result.count];
//////    searchResultsLabel.font = CUSTOME_FONT_BOLD(16.0f);
////    [searchResultsTable reloadData];
////    [searchResultsTable scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
//}
-(void)displayNearByStopsList:(NSArray *)nearByStops{
    [self setupTableViewForNearByStops:nearByStops];
    [self hideNearByStopsView:NO animated:YES];
}
-(void)setupTableViewForNearByStops:(NSArray *)result{
    [self setupListTableViewAppearance];
    
    self.searchResultListViewMode = RSearchResultViewModeNearByStops;
    searchResultsLabel.text = @"Nearby stops";
    [searchResultsTable reloadData];
    [searchResultsTable scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
}
-(void)setupListTableViewAppearance{
    searchResultsTable.backgroundColor = [UIColor clearColor];
    [searchResultsView setBlurTintColor:nil];
    searchResultsView.layer.borderWidth = 0.5;
    searchResultsView.layer.borderColor = [SYSTEM_GRAY_COLOR CGColor];
}
-(void)hideNearByStopsView:(BOOL)hidden animated:(BOOL)anim{
    if (!hidden) {
        //[self hideSearchResultView:YES];
        searchResultsView.hidden = NO;
    }
    if (anim) {
        [UIView transitionWithView:searchResultsView duration:0.3 options:UIViewAnimationOptionCurveEaseIn animations:^{
            
            [self hideNearByStopsView:hidden];
            
        } completion:^(BOOL finished) {
            if (hidden) {
                searchResultsView.hidden = YES;
                if (mapMode == MainMapViewModeStops || mapMode == MainMapViewModeStopsAndLive) {
                    if ([self zoomLevelForMapRect:mapView.visibleMapRect withMapViewSizeInPixels:mapView.bounds.size] >= 15) {
                        [self.reittiDataManager fetchStopsInAreaForRegion:[mapView region]];
                    }
                }
            }
        }];
    }else{
        [self hideNearByStopsView:hidden];
        if (hidden) {
            searchResultsView.hidden = YES;
            if (mapMode == MainMapViewModeStops || mapMode == MainMapViewModeStopsAndLive) {
                if ([self zoomLevelForMapRect:mapView.visibleMapRect withMapViewSizeInPixels:mapView.bounds.size] >= 15) {
                    [self.reittiDataManager fetchStopsInAreaForRegion:[mapView region]];
                }
            }
        }
    }
    
    [self hideSegmentControlView:!hidden animated:anim];
}

- (void)hideNearByStopsView:(BOOL)hidden{
//    CGRect frame = searchResultsView.frame;
//    CGRect tableFrame = searchResultsTable.frame;
    
    searchResultsTable.scrollEnabled = !hidden;
    
    if (hidden) {
//        frame.origin.y = self.view.bounds.size.height + 5;
        nearByStopsViewTopSpacing.constant = self.view.bounds.size.height;
        isSearchResultsViewDisplayed = NO;
//        [self setUpToolBarWithMiddleImage:@"list-100.png"];
    }else{
//        frame.origin.y = blurView.frame.size.height;
//        frame.size.height = self.view.bounds.size.height - blurView.frame.size.height;
//        frame.size.height = self.view.bounds.size.height - blurView.frame.size.height;
        nearByStopsViewTopSpacing.constant = 0;
        isSearchResultsViewDisplayed = YES;
//        [self setUpToolBarWithMiddleImage:@"map-green-100.png"];
    }
    [self.view layoutSubviews];
//    searchResultsView.frame = frame;
//    tableFrame.size.height = frame.size.height;
//    searchResultsTable.frame = tableFrame;
    requestedForListing = NO;
}

- (void)moveSearchResultViewByPoint:(CGPoint)displacement animated:(BOOL)anim{
    [UIView transitionWithView:searchResultsView duration:0.15 options:UIViewAnimationOptionCurveEaseIn animations:^{
        
//        CGRect stopFrame = searchResultsView.frame;
//        stopFrame.origin.y = stopFrame.origin.y + displacement.y;
//        searchResultsView.frame = stopFrame;
        
        nearByStopsViewTopSpacing.constant += displacement.y;
        [self.view layoutSubviews];
        
    } completion:^(BOOL finished) {
        [self hideNearByStopsView:NO animated:YES];
    }];
}

- (void)listNearByStops{
    
    MKCoordinateSpan span = {.latitudeDelta =  0.02, .longitudeDelta =  0.02};
    MKCoordinateSpan minSpan = {.latitudeDelta =  0.01, .longitudeDelta =  0.01};
    
    //Stop annotations are removed so request new
    requestedForListing = YES;
    MKCoordinateRegion region = mapView.region;
    
    //Evaluate region
    if ([settingsManager userLocation] != [reittiDataManager getRegionForCoords:region.center]) {
        [ReittiNotificationHelper showErrorBannerMessage:@"Sorry" andContent:@"Service not available in this area. Try changing the region in settings."];
        return;
    }
    
    if (region.span.latitudeDelta > 0.02) {
        region.span = span;
    }
    
    if (region.span.latitudeDelta < 0.01) {
        region.span = minSpan;
    }
    [self.reittiDataManager fetchStopsInAreaForRegion:region];
    [self showProgressHUD];
    
//
//    if ([self zoomLevelForMapRect:mapView.visibleMapRect withMapViewSizeInPixels:mapView.bounds.size] < 15) {
//        
//    }
    
//    if ([self isLocationServiceAvailableWithNotification:!locNotAvailableNotificationShow]) {
//        [self.reittiDataManager fetchStopsInAreaForRegion:region];
//        [self showProgressHUD];
//    }else{
//        requestedForListing = NO;
//        if (locNotAvailableNotificationShow) {
//            [ReittiNotificationHelper showErrorBannerMessage:@"Uh-Oh" andContent:@"Location services is not enabled. Enable it from Settings/Privacy/Location Services to get nearby stops suggestions."];
//        }
//        
//        locNotAvailableNotificationShow = YES;
//    }
}

#pragma mark - Table view datasource and delegate methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
//    NSLog(@"Number of departures is: %lu",(unsigned long)self.departures.count);
//    if (tableView.tag == 1000) {
//        return self.departures.count;
//    }else if (tableView.tag == 0){
//        if (self.searchResultListViewMode == RSearchResultViewModeSearchResults){
//            return self.nearByStopList.count;
//        }else if (self.searchResultListViewMode == RSearchResultViewModeNearByStops){
//            return self.nearByStopList.count;
//        }
//    }
    
    return self.nearByStopList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (nearByStopList.count > 0) {
        UITableViewCell *cell = [searchResultsTable dequeueReusableCellWithIdentifier:@"searchResultCell"];
        
        BusStopShort *stop = [nearByStopList objectAtIndex:indexPath.row];
        
        UIImageView *imageView = (UIImageView *)[cell viewWithTag:3001];
        [imageView setImage:[AppManager stopAnnotationImageForStopType:stop.stopType]];
        
        UILabel *codeLabel = (UILabel *)[cell viewWithTag:3004];
        codeLabel.text = @"";
        
        codeLabel.text = [stop linesString];
        
        //                codeLabel.font = CUSTOME_FONT_BOLD(22.0f);
        
        UILabel *nameLabel = (UILabel *)[cell viewWithTag:3002];
        NSString *shortCode = stop.codeShort != nil && ![stop.codeShort isEqualToString:@""] ? [NSString stringWithFormat:@" - %@", stop.codeShort] : @"";
        nameLabel.text = [NSString stringWithFormat:@"%@ %@", stop.name, shortCode];
        //                nameLabel.font = CUSTOME_FONT_BOLD(20.0f);
        
        UILabel *distanceLabel = (UILabel *)[cell viewWithTag:3003];
        distanceLabel.text = [NSString stringWithFormat:@"%dm", [stop.distance intValue]];
        //                distanceLabel.font = CUSTOME_FONT_BOLD(15.0f);
        
//        cell.backgroundColor = [UIColor clearColor];
        
        return cell;
    }else{
        
    }
	
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (nearByStopList.count > 0) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"searchResultCell"];
        UILabel *codesLabel = (UILabel *)[cell viewWithTag:3004];
        codesLabel.frame = CGRectMake(codesLabel.frame.origin.x, codesLabel.frame.origin.y, self.view.frame.size.width - 52, codesLabel.frame.size.height);
        BusStopShort *stop = [nearByStopList objectAtIndex:indexPath.row];
        
        CGSize maxSize = CGSizeMake(codesLabel.bounds.size.width, CGFLOAT_MAX);
        
        CGRect labelSize = [stop.linesString boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin
                                                                attributes:@{
                                                                             NSFontAttributeName :codesLabel.font
                                                                             }
                                                                   context:nil];;
        if (labelSize.size.height < 26) {
            labelSize.size.height = 26;
        }
        
        if (labelSize.size.height > 75) {
            labelSize.size.height = 75;
        }
        return labelSize.size.height + 40;
    }
    
    return 65;
}


// Override to support conditional editing of the table view.
//- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    // Return NO if you do not want the specified item to be editable.
//    return NO;
//}

//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    if (tableView.tag == 0) {
//        if (self.searchResultListViewMode == RSearchResultViewModeNearByStops){
//            BusStopShort *selected = [self.nearByStopList objectAtIndex:indexPath.row];
//            [self requestStopInfoAsyncForCode:[NSString stringWithFormat:@"%d", [selected.code intValue]]];
//            [self showProgressHUD];
//        }else if (self.searchResultListViewMode == RSearchResultViewModeSearchResults){
//            BusStop * selected = [self.searchedStopList objectAtIndex:indexPath.row];
//            [self displayStopView:[NSArray arrayWithObject:selected]];
//        }
//        
//    }else if (tableView.tag == 1000) {
//        CustomeTableViewCell *cell = (CustomeTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
//        if (cell != nil) {
//            [cell showUtilityButtonsAnimated:YES];
//        }
//    }
//}

//- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerLeftUtilityButtonWithIndex:(NSInteger)index {
//    UIActionSheet *actionSheet;
//    EKAuthorizationStatus status;
//    switch (index) {
//        case 0:
//            status = [EKEventStore authorizationStatusForEntityType:EKEntityTypeReminder];
//            
//            if (status != EKAuthorizationStatusAuthorized) {
//                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"No Access to Reminders app"                                                                                      message:@"Please grant access to the Reminders app from Settings/Privacy/Reminders to use this feature."
//                                                                   delegate:nil
//                                                          cancelButtonTitle:@"OK"
//                                                          otherButtonTitles:nil];
//                [alertView show];
//                [cell hideUtilityButtonsAnimated:YES];
//                break;
//            }
//            actionSheet = [[UIActionSheet alloc] initWithTitle:@"When do you want to be reminded." delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"1 min before", @"5 min before",@"10 min before",@"15 min before", @"30 min before", nil];
//            //actionSheet.tintColor = SYSTEM_GRAY_COLOR;
//            actionSheet.tag = 2001;
//            [actionSheet showInView:self.view];
//            timeToSetAlarm = [(UILabel *)[cell viewWithTag:1001] text];
//            [cell hideUtilityButtonsAnimated:YES];
//            
//            break;
//        default:
//            break;
//    }
//}

//- (void)swipeableTableViewCell:(SWTableViewCell *)cell scrollingToState:(SWCellState)state{
//    NSIndexPath *index = [departuresTable indexPathForCell:cell];
//    if (departuresTableIndex != nil && state == kCellStateLeft && index.row != departuresTableIndex.row) {
//        [(CustomeTableViewCell *)[departuresTable cellForRowAtIndexPath:departuresTableIndex] hideUtilityButtonsAnimated:YES];
//    }
//    departuresTableIndex = [departuresTable indexPathForCell:cell];
//    
//}


//- (void)initRefreshControl{
//    
//    UITableViewController *tableViewController = [[UITableViewController alloc] init];
//    tableViewController.tableView = departuresTable;
//    
//    self.refreshControl = [[UIRefreshControl alloc] init];
//    [self.refreshControl addTarget:self action:@selector(reloadButtonPressed:) forControlEvents:UIControlEventValueChanged];
//    //refresh.attributedTitle = [[NSAttributedString alloc] initWithString:@"Pull to Refresh"];
//    tableViewController.refreshControl = self.refreshControl;
//}


#pragma - mark Map methods

- (void)initializeMapComponents
{
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.distanceFilter = kCLDistanceFilterNone;
    locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
    [locationManager startUpdatingLocation];
    [locationManager requestWhenInUseAuthorization];
    
//    mapView.mapType = MKMapTypeSatellite;
    mapView.showsBuildings = YES;
    mapView.pitchEnabled = YES;
    
}

-(BOOL)centerMapRegionToCoordinate:(CLLocationCoordinate2D)coordinate{
    
    BOOL toReturn = YES;
    
    
    if (![self isLocationServiceAvailableWithNotification:!locNotAvailableNotificationShow]) {
        if ([settingsManager userLocation] == HSLRegion) {
            //Helsinki center location
            CLLocationCoordinate2D coord = {.latitude =  60.1733239, .longitude =  24.9410248};
            coordinate = coord;
        }else{
            //tampere center location 61.4981508,23.7610254
            CLLocationCoordinate2D coord = {.latitude =  61.4981508, .longitude =  23.7610254};
            coordinate = coord;
        }
        
        toReturn = NO;
        
        locNotAvailableNotificationShow = YES;
    }
    
    //CLLocationCoordinate2D coord = {.latitude =  60.1733239, .longitude =  24.9410248};
    MKCoordinateSpan span = {.latitudeDelta =  0.005, .longitudeDelta =  0.005};
    MKCoordinateRegion region = {coordinate, span};
    
    [mapView setRegion:region animated:YES];
    
    
    
//    ///Testing only
//    StopAnnotation *newAnnotation = [[StopAnnotation alloc] initWithTitle:@"1230" andSubtitle:@"Lepasuonkatu" andCoordinate:coordinate];
//    //newAnnotation.image = [UIImage imageNamed:@"bus_stop_hsl.png"];
//    
//    [mapView addAnnotation:newAnnotation];
    
    return toReturn;
}

-(BOOL)isLocationServiceAvailableWithNotification:(BOOL)notify{
    BOOL accessGranted = [CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse;
    NSLog(@"%d",[CLLocationManager authorizationStatus]);
    BOOL locationServicesEnabled = [CLLocationManager locationServicesEnabled];
    
    if (!locationServicesEnabled) {
        if (notify) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Uh-Oh"
                                                                message:@"Looks like location services is not enabled. Enable it from Settings/Privacy/Location Services to get nearby stops suggestions."
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
            [alertView show];
        }
        
        return NO;
    }
    
    if (!accessGranted) {
        if (notify) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Uh-Oh"
                                                                message:@"Looks like access is not granted to this app for location services. Grant access from Settings/Privacy/Location Services to get nearby stops suggestions."
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
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
            if (currentRegion != OtherRegion) {
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
                [settingsManager setUserLocation:HSLandTRERegion];
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
            //if stops are from pubtrans, only update lines and type
//            BusStopShort *firstStop = [stopList objectAtIndex:0];
//            if (firstStop.lines.count > 0) {
//                for (id<MKAnnotation> annotation in mapView.annotations) {
//                    if ([annotation isKindOfClass:[JPSThumbnailAnnotation class]]) {
//                        JPSThumbnailAnnotation *annot = (JPSThumbnailAnnotation *)annotation;
//                        if (annot.annotationType != NearByStopType)
//                            continue;
//                        
//                        NSArray *stops = [self collectStopsForCodes:@[annot.code] fromStops:stopList];
//                        
//                        if (stops == nil || stops.count == 0)
//                            continue;
//                        
//                        BusStopShort *stop = [stops firstObject];
//                        
//                        if (![annot.thumbnail.subtitle isEqualToString:stop.linesString]) {
//                            [annotToRemove addObject:annot];
//                            [newStops addObject:stop];
//                        }
//                    }
//                }
//            }else{
//                
//            }
            
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
                NSString * name = stop.name;
                NSString * codeShort = stop.codeShort;
                
                JPSThumbnail *stopAnT = [[JPSThumbnail alloc] init];
                stopAnT.image = stopImage;
                stopAnT.code = stop.code;
                stopAnT.title = name;
                stopAnT.subtitle = [stop.linesString isEqualToString:@""] || stop.linesString == nil ? codeShort : stop.linesString;
                stopAnT.coordinate = coordinate;
                stopAnT.annotationType = NearByStopType;
                stopAnT.stopType = stop.stopType;
                stopAnT.reuseIdentifier = @"NearByStopAnnotation";
                stopAnT.primaryButtonBlock = ^{ [self openRouteForAnnotationWithTitle:name subtitle:codeShort andCoords:coordinate];};
                stopAnT.secondaryButtonBlock = ^{ [self openStopViewForCode:stop.code shortCode:codeShort name:name andCoords:coordinate];};
                stopAnT.disclosureBlock = ^{ [self openStopViewForCode:stop.code shortCode:codeShort name:name andCoords:coordinate];};
                
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
    NSString * shortCode = stop.codeShort;
    
    JPSThumbnail *stopAnT = [[JPSThumbnail alloc] init];
    UIImage *stopImage = [AppManager stopAnnotationImageForStopType:stop.stopType];
    stopAnT.image = stopImage;
    stopAnT.code = stop.code;
    stopAnT.title = name;
    stopAnT.subtitle = [stop.linesString isEqualToString:@""] || stop.linesString == nil ? shortCode : stop.linesString;;
    stopAnT.coordinate = coordinate;
    stopAnT.annotationType = SearchedStopType;
    stopAnT.reuseIdentifier = @"SearchedStopAnnotation";
    stopAnT.primaryButtonBlock = ^{ [self openRouteForAnnotationWithTitle:name subtitle:shortCode andCoords:coordinate];};
    stopAnT.secondaryButtonBlock = ^{ [self openStopViewForCode:stop.code  shortCode:shortCode name:name  andCoords:coordinate];};
    stopAnT.disclosureBlock = ^{ [self openStopViewForCode:stop.code  shortCode:shortCode name:name  andCoords:coordinate];};
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


- (void)dropAnnotation:(UIGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.state != UIGestureRecognizerStateBegan)
        return;
    
    for (id<MKAnnotation> annotation in mapView.annotations) {
        if ([annotation isKindOfClass:[JPSThumbnailAnnotation class]]) {
            JPSThumbnailAnnotation *sAnnotation = (JPSThumbnailAnnotation *)annotation;
            if (sAnnotation.annotationType == DroppedPinType) {
                [mapView removeAnnotation:annotation];
            }
        }
    }
    
    CGPoint touchPoint = [gestureRecognizer locationInView:mapView];
    CLLocationCoordinate2D touchMapCoordinate =
    [mapView convertPoint:touchPoint toCoordinateFromView:mapView];
    
//    JPSThumbnail *annotTN = [[JPSThumbnail alloc] init];
//    annotTN.image = [UIImage imageNamed:@"dropped-pin-annotation.png"];
//    annotTN.title = @"Dropped pin";
//    annotTN.subtitle = @"Searching address";
//    annotTN.coordinate = touchMapCoordinate;
//    annotTN.annotationType = DroppedPinType;
//    annotTN.reuseIdentifier = @"geoLocationAnnotation";
//    annotTN.primaryButtonBlock = ^{ [self openRouteForNamedAnnotationWithTitle:@"Dropped pin" andCoords:touchMapCoordinate];};
//    annotTN.secondaryButtonBlock = ^{ [self showDroppedPinGeoCode];};
//    JPSThumbnailAnnotation *annot = [JPSThumbnailAnnotation annotationWithThumbnail:annotTN];
//    [mapView addAnnotation:annot];
    
    GCThumbnail *annotTN = [[GCThumbnail alloc] init];
    annotTN.image = [UIImage imageNamed:@"dropped-pin-annotation.png"];
    annotTN.title = @"Dropped pin";
    annotTN.subtitle = @"Searching address";
    annotTN.coordinate = touchMapCoordinate;
//    annotTN.annotationType = DroppedPinType;
    annotTN.reuseIdentifier = @"geoLocationAnnotation";
    annotTN.primaryButtonBlock = ^{ [self openRouteForNamedAnnotationWithTitle:@"Dropped pin" andCoords:touchMapCoordinate];};
    annotTN.secondaryButtonBlock = ^{ [self showDroppedPinGeoCode];};
    GCThumbnailAnnotation *annot = [GCThumbnailAnnotation annotationWithThumbnail:annotTN];
    [mapView addAnnotation:annot];
    
    droppedPinLocation = @"Dropped pin";
    droppedPinCoords = touchMapCoordinate;
    
    droppedPinGeoCode = nil;
    
    [self.reittiDataManager searchAddresseForCoordinate:touchMapCoordinate];
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
            
            if (isTrain) {
                if (annot.vehicleType != VehicleTypeTrain) {
                    continue;
                }
            }else{
                if (annot.vehicleType == VehicleTypeTrain) {
                    continue;
                }
            }
            
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
                annot.coordinate = vehicleToUpdate.coords;
//                annot.thumbnail.bearing = [NSNumber numberWithDouble:vehicleToUpdate.bearing];
                [((NSObject<LVThumbnailAnnotationProtocol> *)annot) updateBearing:[NSNumber numberWithDouble:vehicleToUpdate.bearing]];
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
        vehicleAnT.image = [AppManager vehicleImageForVehicleType:vehicle.vehicleType];
        vehicleAnT.bearing = [NSNumber numberWithDouble:vehicle.bearing];
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
            GCThumbnailAnnotation *annot = (GCThumbnailAnnotation *)annotation;
//            if (annot.annotationType == DroppedPinType) {
                droppedPinAnnotationView = [((NSObject<GCThumbnailAnnotationProtocol> *)annotation) annotationViewInMap:mapView];
//            }
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

- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated{
    currentLocationButton.alpha = 0.3;
//    sendEmailButton.alpha = 0.3;
//    listNearbyStops.alpha = 0.3;
}

- (void)mapView:(MKMapView *)affectedMapView didSelectAnnotationView:(MKAnnotationView *)view{
    if ([view conformsToProtocol:@protocol(JPSThumbnailAnnotationViewProtocol)]) {
        ignoreRegionChange = YES;
        [((NSObject<JPSThumbnailAnnotationViewProtocol> *)view) didSelectAnnotationViewInMap:mapView];
        selectedAnnotationView = (NSObject<JPSThumbnailAnnotationViewProtocol> *)view;
        id<MKAnnotation> ann = [mapView.selectedAnnotations objectAtIndex:0];
        CLLocationCoordinate2D coord = ann.coordinate;
        NSLog(@"lat = %f, lon = %f", coord.latitude, coord.longitude);
        
        NSString *fromCoordsString = [NSString stringWithFormat:@"%f,%f", self.currentUserLocation.coordinate.longitude, self.currentUserLocation.coordinate.latitude];
        
        NSString *toCoordsString = [NSString stringWithFormat:@"%f,%f", coord.longitude, coord.latitude];
        
        [self.reittiDataManager getFirstRouteForFromCoords:fromCoordsString andToCoords:toCoordsString];
    }else if ([view conformsToProtocol:@protocol(GCThumbnailAnnotationViewProtocol)]) {
        ignoreRegionChange = YES;
        [((NSObject<GCThumbnailAnnotationViewProtocol> *)view) didSelectAnnotationViewInMap:mapView];
    }else if ([view conformsToProtocol:@protocol(LVThumbnailAnnotationViewProtocol)]) {
        id<MKAnnotation> annotation = [mapView.selectedAnnotations objectAtIndex:0];
        if ([annotation isKindOfClass:[LVThumbnailAnnotation class]]) {
            LVThumbnailAnnotation *annot = (LVThumbnailAnnotation *)annotation;
            if (annot.lineId != nil) {
                [self.reittiDataManager fetchLineInfoForCodeList:annot.lineId];
            }
        }
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

//- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
////    StopAnnotation *stopAnnotation = (StopAnnotation*)view.annotation;
//    
////    [self requestStopInfoAsyncForCode:[NSString stringWithFormat:@"%d", [stopAnnotation.code intValue]]];
////    [self showProgressHUD];
//}

- (void)mapView:(MKMapView *)_mapView regionDidChangeAnimated:(BOOL)animated{
    if (!ignoreRegionChange) {
        
    }else{
        ignoreRegionChange = NO;
    }
    
    if (self.mapMode == MainMapViewModeStops || self.mapMode == MainMapViewModeStopsAndLive) {
        if ([self zoomLevelForMapRect:mapView.visibleMapRect withMapViewSizeInPixels:mapView.bounds.size] >= 15) {
            [self.reittiDataManager fetchStopsInAreaForRegion:[_mapView region]];
        }else{
            [self removeAllStopAnnotations];
        }
    }
    
//    [self removeAllStopAnnotations];
    
//    [self.reittiDataManager fetchAllLiveVehicles];
    currentLocationButton.alpha = 1;
//    sendEmailButton.alpha = 1;
    listNearbyStops.alpha = 1;
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
    [self.reittiDataManager fetchDisruptions];
    refreshTimer = [NSTimer scheduledTimerWithTimeInterval:900 target:self selector:@selector(fetchDisruptions) userInfo:nil repeats:YES];
}

- (void)fetchDisruptions{
    [self.reittiDataManager fetchDisruptions];
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
    UITabBarItem *moreTabBarItem = [self.tabBarController.tabBar.items objectAtIndex:3];

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

- (void)openBookmarksView{
    [self performSegueWithIdentifier: @"openBookmarks" sender: self];
}

- (void)openRouteSearchView{
    [self performSegueWithIdentifier: @"switchToRouteSearch" sender: self];
}

- (void)openRouteViewForFromLocation:(MKDirectionsRequest *)directionsInfo{
    MKMapItem *source = directionsInfo.source;
    if (source.isCurrentLocation) {
        selectedFromLocation = @"Current location";
    }else{
        selectedFromCoords = [NSString stringWithFormat:@"%f,%f",source.placemark.location.coordinate.longitude, source.placemark.location.coordinate.latitude];
        selectedFromLocation = [NSString stringWithFormat:@"%@",
                                       [[source.placemark.addressDictionary objectForKey:@"FormattedAddressLines"] componentsJoinedByString:@" "]
                                       ];
    }
    
    MKMapItem *destination = directionsInfo.destination;
    if (destination.isCurrentLocation) {
        selectedAnnotationUniqeName = @"Current location";
    }else{
        selectedAnnotationCoords = [NSString stringWithFormat:@"%f,%f",destination.placemark.location.coordinate.longitude, destination.placemark.location.coordinate.latitude];
        NSLog(@"Address of placemark: %@", ABCreateStringWithAddressDictionary(destination.placemark.addressDictionary, NO));
        NSLog(@"Address Dictionary: %@",destination.placemark.addressDictionary);
        if ([destination.placemark.addressDictionary objectForKey:@"FormattedAddressLines"] != nil) {
            selectedAnnotationUniqeName = [NSString stringWithFormat:@"%@",
                                           [[destination.placemark.addressDictionary objectForKey:@"FormattedAddressLines"] componentsJoinedByString:@" "]
                                           ];
        }else{
            selectedAnnotationUniqeName = [NSString stringWithFormat:@"%@, %@",
                                           [destination.placemark.addressDictionary objectForKey:@"Street"],
                                           [destination.placemark.addressDictionary objectForKey:@"City"]
                                          ];
        }
    }
    
//    NSDate *startDate = directionsInfo.departureDate;
    
    [self performSegueWithIdentifier: @"routeSearchController" sender: self];
}

-(void)openWidgetSettingsView{
    [self performSegueWithIdentifier:@"openWidgetSettingFromHome" sender:self];
}

#pragma mark - helper methods
//- (void)sendEmailWithSubject:(NSString *)subject{
//    // Email Subject
//    NSString *emailTitle = subject;
//    // Email Content
//    NSString *messageBody = @"";
//    // To address
//    NSArray *toRecipents = [NSArray arrayWithObject:@"ewketapps@gmail.com"];
//    
//    MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
//    mc.mailComposeDelegate = self;
//    [mc setSubject:emailTitle];
//    [mc setMessageBody:messageBody isHTML:NO];
//    [mc setToRecipients:toRecipents];
//    
//    // Present mail view controller on screen
//    [self presentViewController:mc animated:YES completion:NULL];
//    
//}

//- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
//{
//    switch (result)
//    {
//        case MFMailComposeResultCancelled:
//            NSLog(@"Mail cancelled");
//            break;
//        case MFMailComposeResultSaved:
//            NSLog(@"Mail saved");
//            break;
//        case MFMailComposeResultSent:
//            NSLog(@"Mail sent");
////            [self.reittiDataManager setAppOpenCountValue:-100];
//            break;
//        case MFMailComposeResultFailed:
//            NSLog(@"Mail sent failure: %@", [error localizedDescription]);
//            break;
//        default:
//            break;
//    }
//    
//    // Close the Mail Interface
//    [self dismissViewControllerAnimated:YES completion:NULL];
//}

//-(void)setReminderWithMinOffset:(int)minute andHourString:(NSString *)timeString{
//    EKAuthorizationStatus status = [EKEventStore authorizationStatusForEntityType:EKEntityTypeReminder];
//    
//    if (status == EKAuthorizationStatusAuthorized) {
//        if ([self createEKReminderWithMinOffset:minute andHourString:timeString]) {
////            [self showNotificationWithMessage:@"Reminder set successfully!" messageType:RNotificationTypeConfirmation forSeconds:5 keppingSearchView:YES];
//        }
//        
//    }else{
//        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"No Access to Reminders app"                                                                                      message:@"Please grant access to the Reminders app from Settings/Privacy/Reminders to use this feature."
//                                                           delegate:nil
//                                                  cancelButtonTitle:@"OK"
//                                                  otherButtonTitles:nil];
//        [alertView show];
//    }
//}

//-(BOOL)createEKReminderWithMinOffset:(int)minutes andHourString:(NSString *)timeString{
//    NSDate *date = [ReittiStringFormatter createDateFromString:timeString withMinOffset:minutes];
//    
//    if (date == nil) {
//        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Uh-oh"                                                                                      message:@"Setting reminder failed."
//                                                           delegate:nil
//                                                  cancelButtonTitle:@"OK"
//                                                  otherButtonTitles:nil];
//        [alertView show];
//        return NO;
//    }
//    
//    if ([[NSDate date] compare:date] == NSOrderedDescending ) {
//        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Just so you know"                                                                                      message:@"The alarm time you set has already past."
//                                                           delegate:nil
//                                                  cancelButtonTitle:@"OK"
//                                                  otherButtonTitles:nil];
//        [alertView show];
//    }
//    
//    EKReminder *reminder = [EKReminder reminderWithEventStore:_eventStore];
//    
//    reminder.title = [NSString stringWithFormat:@"Your ride will leave in %d minutes.", minutes];
//    
//    reminder.calendar = [_eventStore defaultCalendarForNewReminders];
//    
//    EKAlarm *alarm = [EKAlarm alarmWithAbsoluteDate:date];
//    
//    [reminder addAlarm:alarm];
//    
//    NSError *error = nil;
//    
//    [_eventStore saveReminder:reminder commit:YES error:&error];
//    
//    return YES;
//}


//- (void)postToFacebook {
//    if([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]) {
//        
//        SLComposeViewController *controller = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
//        
//        [controller setInitialText:@"Easy way to get HSL timetables and stop locations!Check Commuter out."];
//        [controller addURL:[NSURL URLWithString:@"http://itunes.com/apps/antenehseifu"]];
//        [controller addImage:[UIImage imageNamed:@"appicon4.png"]];
//        
//        [self presentViewController:controller animated:YES completion:Nil];
//        
//    }else{
//        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Sorry"
//                                                            message:@"You can't post to Facebook right now. Make sure your device has an internet connection and you have at least one Facebook account setup"
//                                                           delegate:nil
//                                                  cancelButtonTitle:@"OK"
//                                                  otherButtonTitles:nil];
//        [alertView show];
//    }
//}

- (GeoCode *)castNamedBookmarkToGeoCode:(NamedBookmark *)namedBookmark{
    GeoCode * newGeoCode = [[GeoCode alloc] init];
    newGeoCode.name = namedBookmark.name;
    
    return newGeoCode;
}

#pragma - mark IBActions

- (IBAction)centerCurrentLocationButtonPressed:(id)sender {
    if (![self isLocationServiceAvailableWithNotification:NO] && locNotAvailableNotificationShow) {
        [ReittiNotificationHelper showErrorBannerMessage:@"Uh-Oh" andContent:@"Location services is not enabled. Enable it from Settings/Privacy/Location Services to get nearby stops suggestions."];
    }

    [self centerMapRegionToCoordinate:self.currentUserLocation.coordinate];
}

- (IBAction)listNearbyStopsPressed:(id)sender {
    if (searchResultsView.hidden) {
        [self listNearByStops];
//        [listNearbyStops setImage:[UIImage imageNamed:@"showMap-icon.png"] forState:UIControlStateNormal];
    }else{
        [self hideNearByStopsView:YES animated:YES];
    }
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag == 1001) {
        if (buttonIndex == 0) {
            [self.reittiDataManager setAppOpenCountValue:-7];
        }else if(buttonIndex == 1){
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"itms-apps://itunes.apple.com/app/id861274235"]];
            [self.reittiDataManager setAppOpenCountValue:-50];
        }
    }else if (alertView.tag == 1003) {
        if (buttonIndex == 0) {
            [self openSettingsButtonPressed:self];
        }
    }
}

//- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
//{
//    NSLog(@"You have pressed the %@ button", [actionSheet buttonTitleAtIndex:buttonIndex]);
//    if (actionSheet.tag == 1001) {
//        switch (buttonIndex) {
//            case 0:
//                [self postToFacebook];
//                [self.reittiDataManager setAppOpenCountValue:-30];
//                break;
//            case 1:
//                [self sendEmailWithSubject:@"[Feature Request] - "];
//                break;
//            case 2:
//                [self sendEmailWithSubject:@"[Feedback] - "];
//                break;
//            case 3:
//                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"itms-apps://itunes.apple.com/app/id861274235"]];
//                [self.reittiDataManager setAppOpenCountValue:-30];
//                break;
//            default:
//                break;
//        }
//        
//        if (buttonIndex == 0) {
//            
//        }
//
//    }else{
//        switch (buttonIndex) {
//            case 0:
//                [self setReminderWithMinOffset:1 andHourString:timeToSetAlarm];
//                break;
//            case 1:
//                [self setReminderWithMinOffset:5 andHourString:timeToSetAlarm];
//                break;
//            case 2:
//                [self setReminderWithMinOffset:10 andHourString:timeToSetAlarm];
//                break;
//            case 3:
//                [self setReminderWithMinOffset:15 andHourString:timeToSetAlarm];
//                break;
//            case 4:
//                [self setReminderWithMinOffset:30 andHourString:timeToSetAlarm];
//                break;
//            default:
//                break;
//        }
//    }    
//}

/*
-(IBAction)tapGestureDetected:(UIGestureRecognizer *)sender{
    [self.view endEditing:YES];
    if ([self isCommandViewHidden]) {
//        [self hideCommandView:NO animated:YES];
    }else{
        [self hideCommandView:YES animated:YES];
        
//        CGPoint p = [sender locationInView:mapView];
//        
//        UIView *v = [mapView hitTest:p withEvent:nil];
//        
//        if (![v isKindOfClass:[MKAnnotationView class]])
//        {
//            if (lastSelectedAnnotation != nil && lastSelectedAnnotation.isSelected) {
//                [self mapView:mapView deselectStopAnnotation:lastSelectedAnnotation];
//                lastSelectionDismissed = YES;
//            }
//        }
        
    }
    
}
 
 */

//-(IBAction)blurViewGestureDetected:(UIGestureRecognizer *)sender{
//    self.searchViewHidden = NO;
//}

//-(IBAction)stopViewGestureDetected:(id)sender{
//    [self.view endEditing:YES];
//}

-(IBAction)nearByStopsListViewGestureDetected:(id)sender{
    [self.view endEditing:YES];
    [self moveSearchResultViewByPoint:CGPointMake(0, 20) animated:YES];
}

-(IBAction)dragStopView:(UIPanGestureRecognizer *)recognizer {
    
    CGPoint translation = [recognizer translationInView:self.view];
    if ((recognizer.view.frame.origin.y + translation.y) > ([self searchViewLowerBound])  ) {
//        recognizer.view.center = CGPointMake(recognizer.view.center.x, recognizer.view.center.y + translation.y);
        nearByStopsViewTopSpacing.constant += translation.y;
        [self.view layoutSubviews];
    }
    if (recognizer.state != UIGestureRecognizerStateEnded){
        stopViewDragedDown = translation.y > 0;
    }
    
    [recognizer setTranslation:CGPointMake(0, 0) inView:self.view];
    
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        if (recognizer.view.frame.origin.y > ([self searchViewLowerBound] + (recognizer.view.frame.size.height / 3)) && stopViewDragedDown) {
            if (recognizer.view.tag == 0) {
//                [self hideStopView:YES animated:YES];
            }else{
                [self hideNearByStopsView:YES animated:YES];
            }
        }else{
            if (recognizer.view.tag == 0) {
//                [self hideStopView:NO animated:YES];
            }else{
                [self hideNearByStopsView:NO animated:YES];
            }
        }
    }
}

- (IBAction)openBookmarkedButtonPressed:(id)sender {
    [self performSegueWithIdentifier:@"openBookmarks" sender:self];
}

- (IBAction)openSettingsButtonPressed:(id)sender {
    [self performSegueWithIdentifier:@"showSettings" sender:self];
}

//- (IBAction)openMoreViewButtonPressed:(id)sender {
//    [self.reittiDataManager fetchAllLiveVehicles];
//}

- (IBAction)seeFullTimeTablePressed:(id)sender {
    NSURL *url = [NSURL URLWithString:self._busStop.timetable_link];
    
    if (![[UIApplication sharedApplication] openURL:url])
        
        NSLog(@"%@%@",@"Failed to open url:",[url description]);
}
//- (IBAction)reloadButtonPressed:(id)sender{
////    self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"Refreshing Departures ..."];
////    if (_busStop != nil) {
////        [self requestStopInfoAsyncForCode:[NSString stringWithFormat:@"%d", [_busStop.code intValue]]];
////    }
////    justReloading = YES;
//}
//- (IBAction)saveStopToBookmarks {
//    [self.reittiDataManager saveToCoreDataStop:self._busStop withLines:self._stopLinesDetail];
//    //addBookmarkButton.hidden = YES;
//    //[self showNotificationWithMessage:@"Bookmark added successfully!" messageType:RNotificationTypeConfirmation forSeconds:5 keppingSearchView:YES];
//}

//- (IBAction)closeStopViewButtonPressed:(id)sender {
////    [self hideStopView:YES animated:YES];
//}
- (IBAction)hideSearchResultViewPressed:(id)sender {
    [self hideNearByStopsView:YES animated:YES];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    // Return YES so the pan gesture of the containing table view is not cancelled by the long press recognizer
    return YES;
}

#pragma - mark Scroll View delegates
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (scrollView.contentOffset.y < 0) {
        if (!tableViewIsDecelerating) {
            nearByStopsViewTopSpacing.constant += -scrollView.contentOffset.y;
            [self.view layoutSubviews];
            stopViewDragedDown = YES;
            scrollView.contentOffset = CGPointMake(scrollView.contentOffset.x, 0);
        }
        
    }else if(scrollView.contentOffset.y == 0 ){
//        stopViewDragedDown = NO;
        //
        searchResultsTable.layer.borderColor = [[UIColor lightGrayColor] CGColor];
        searchResultsTable.layer.borderWidth = 0;
    }else{
        if (nearByStopsViewTopSpacing.constant > 0) {
            nearByStopsViewTopSpacing.constant -= scrollView.contentOffset.y;
            [self.view layoutSubviews];
            stopViewDragedDown = YES;
            scrollView.contentOffset = CGPointMake(scrollView.contentOffset.x, 0);
        }else{
            stopViewDragedDown = NO;
            //
            searchResultsTable.layer.borderColor = [[UIColor lightGrayColor] CGColor];
            searchResultsTable.layer.borderWidth = 0.5;
        }
        
    }
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    if (nearByStopsViewTopSpacing.constant > ([self searchViewLowerBound] + (searchResultsView.frame.size.height / 4)) && stopViewDragedDown) {
        [self hideNearByStopsView:YES animated:YES];
    }else{
        [self hideNearByStopsView:NO animated:YES];
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
    
    [SVProgressHUD dismiss];
}

-(void)stopFetchDidFail:(NSString *)error{
    [SVProgressHUD dismiss];
//    [self.refreshControl endRefreshing];
}

- (void)nearByStopFetchDidComplete:(NSArray *)stopList{
    
    if (stopList.count > 0) {
        if ([stopList.firstObject isKindOfClass:NearByStop.class]) {
            //TODO: Check if update is needed by checking existing list and values in cache
            //TODO: Do the check in separate thread
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
    
    if (requestedForListing) {
        [self displayNearByStopsList:stopList];
    }else{
        [self plotStopAnnotations:self.nearByStopList];
    }
    
    retryCount = 0;
    [SVProgressHUD dismiss];
}
- (void)nearByStopFetchDidFail:(NSString *)error{
    if (requestedForListing) {
        if (![error isEqualToString:@""]) {
            if ([error isEqualToString:@"Request timed out."] && retryCount < 1) {
                [self listNearbyStopsPressed:nil];
                retryCount++;
            }else{
                [ReittiNotificationHelper showErrorBannerMessage:error andContent:nil];
            }
            
//            [self showNotificationWithMessage:error messageType:RNotificationTypeInfo forSeconds:5 keppingSearchView:YES];
        }
        
        requestedForListing = NO;
    }
    
    [SVProgressHUD dismiss];
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

- (void)reverseGeocodeSearchDidComplete:(GeoCode *)geoCode{
    if (droppedPinAnnotationView == nil)
        return;
    
    droppedPinGeoCode = geoCode;
    [droppedPinGeoCode setLocationType:LocationTypeDroppedPin];
    
    [[DroppedPinManager sharedManager] setDroppedPin:self.droppedPinGeoCode];
    
    if ([droppedPinAnnotationView conformsToProtocol:@protocol(GCThumbnailAnnotationViewProtocol)]) {
        ignoreRegionChange = YES;
        [mapView setSelectedAnnotations:[NSArray arrayWithObjects:droppedPinAnnotationView.annotation,nil]];
        [((NSObject<GCThumbnailAnnotationViewProtocol> *)droppedPinAnnotationView) setGeoCodeAddress:mapView address:[geoCode getStreetAddressString]];
    }
    
    droppedPinLocation = [geoCode getStreetAddressString];

}
- (void)reverseGeocodeSearchDidFail:(NSString *)error{
    if (droppedPinAnnotationView == nil)
        return;
    
    if ([droppedPinAnnotationView conformsToProtocol:@protocol(JPSThumbnailAnnotationViewProtocol)]) {
        ignoreRegionChange = YES;
        [mapView setSelectedAnnotations:[NSArray arrayWithObjects:droppedPinAnnotationView.annotation,nil]];
        [((NSObject<JPSThumbnailAnnotationViewProtocol> *)droppedPinAnnotationView) setGeoCodeAddress:mapView address:nil];
    }
}

//- (void)vehicleFetchDidComplete:(NSArray *)vehicleList{
//    [self plotVehicleAnnotations:vehicleList];
//}
//- (void)vehicleFetchDidFail:(NSError *)error{
//    
//}

- (void)vehiclesFetchCompleteFromHSlLive:(NSArray *)vehicleList{
    if ([settingsManager shouldShowLiveVehicles]) {
        [self plotVehicleAnnotations:vehicleList isTrainVehicles:NO];
    }
}
- (void)vehiclesFetchFromHSLFailedWithError:(NSError *)error{
    //TODO: Remove vehicles if call fails
}
- (void)vehiclesFetchCompleteFromPubTrans:(NSArray *)vehicleList{
    if ([settingsManager shouldShowLiveVehicles]) {
        [self plotVehicleAnnotations:vehicleList isTrainVehicles:YES];
    }
}
- (void)vehiclesFetchFromPubTransFailedWithError:(NSError *)error{
    //TODO: Remove vehicles if call fails    
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
    
    mainSearchBar.text = geoCode.FullAddressString;
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
    [self performSegueWithIdentifier:@"switchToRouteSearch" sender:nil];
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
        [self.reittiDataManager setUserLocation:[settingsManager userLocation]];
        [self centerMapRegionToCoordinate:[RettiDataManager getCoordinateForRegion:[settingsManager userLocation]]];
    }
    
    [self fetchDisruptions];
}


-(void)shouldShowVehiclesSettingsValueChanged:(NSNotification *)notification{
    if ([settingsManager shouldShowLiveVehicles]) {
        [reittiDataManager fetchAllLiveVehicles];
    }else{
        [self removeAllVehicleAnnotation];
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

#pragma mark - Seague

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSLog(@"%@",segue.identifier);
	if ([segue.identifier isEqualToString:@"openBookmarks"])
	{
        UINavigationController *navigationController = (UINavigationController *)segue.destinationViewController;
		BookmarksViewController *bookmarksViewController = [[navigationController viewControllers] lastObject];
        
        NSArray * savedStops = [self.reittiDataManager fetchAllSavedStopsFromCoreData];
        NSArray * savedRoutes = [self.reittiDataManager fetchAllSavedRoutesFromCoreData];
        NSArray * recentStops = [self.reittiDataManager fetchAllSavedStopHistoryFromCoreData];
        NSArray * recentRoutes = [self.reittiDataManager fetchAllSavedRouteHistoryFromCoreData];
        NSArray * namedBookmarks = [self.reittiDataManager fetchAllSavedNamedBookmarksFromCoreData];
        
        bookmarksViewController.savedStops = [NSMutableArray arrayWithArray:savedStops];
        bookmarksViewController.savedRoutes = [NSMutableArray arrayWithArray:savedRoutes];
        bookmarksViewController.recentStops = [NSMutableArray arrayWithArray:recentStops];
        bookmarksViewController.recentRoutes = [NSMutableArray arrayWithArray:recentRoutes];
        bookmarksViewController.savedNamedBookmarks = [NSMutableArray arrayWithArray:namedBookmarks];
        bookmarksViewController.darkMode = self.darkMode;
        bookmarksViewController.delegate = self;
        bookmarksViewController.mode = bookmarkViewMode;
//        bookmarksViewController.droppedPinGeoCode = droppedPinGeoCode;
        bookmarksViewController.reittiDataManager = [[RettiDataManager alloc] initWithManagedObjectContext:self.managedObjectContext];
        [bookmarksViewController.reittiDataManager setUserLocationToRegion:[settingsManager userLocation]];
//        bookmarksViewController.reittiDataManager = self.reittiDataManager;
    }
    if ([segue.identifier isEqualToString:@"seeFullTimeTable"]) {
        WebViewController *webViewController = (WebViewController *)segue.destinationViewController;
        NSURL *url = [NSURL URLWithString:self._busStop.timetable_link];
        webViewController._url = url;
        webViewController._pageTitle = _busStop.code_short;
    }
    if ([segue.identifier isEqualToString:@"openStopView"] || [segue.identifier isEqualToString:@"openNearbyStop"])
    {
//        UINavigationController *navigationController = (UINavigationController *)segue.destinationViewController;
//        StopViewController *stopViewController =[[navigationController viewControllers] lastObject];
        StopViewController *stopViewController = (StopViewController *)segue.destinationViewController;
        
        if ([segue.identifier isEqualToString:@"openNearbyStop"]) {
            NSIndexPath *selectedRowIndexPath = [searchResultsTable indexPathForSelectedRow];
            
            BusStopShort *selected = [self.nearByStopList objectAtIndex:selectedRowIndexPath.row];
            
            stopViewController.stopCode = [NSString stringWithFormat:@"%d", [selected.code intValue]];
            stopViewController.stopCoords = [ReittiStringFormatter convertStringTo2DCoord:selected.coords];
            stopViewController.stopShortCode = selected.codeShort;
            stopViewController.stopName = selected.name;
        }else{
            stopViewController.stopCode = selectedStopCode;
            stopViewController.stopCoords = selectedStopAnnotationCoords;
            stopViewController.stopShortCode = selectedStopShortCode;
            stopViewController.stopName = selectedStopName;
        }
        
        stopViewController.darkMode = self.darkMode;
//        stopViewController.droppedPinGeoCode = droppedPinGeoCode;
        stopViewController.reittiDataManager = [[RettiDataManager alloc] initWithManagedObjectContext:self.managedObjectContext];
        [stopViewController.reittiDataManager setUserLocationToRegion:[settingsManager userLocation]];
//        stopViewController.reittiDataManager = self.reittiDataManager;
        
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
    if ([segue.identifier isEqualToString:@"routeSearchController"] || [segue.identifier isEqualToString:@"switchToRouteSearch"]) {
        UINavigationController *navigationController = (UINavigationController *)segue.destinationViewController;
        RouteSearchViewController *routeSearchViewController = [[navigationController viewControllers] lastObject];
        
        NSArray * savedStops = [self.reittiDataManager fetchAllSavedStopsFromCoreData];
        NSArray * savedRoutes = [self.reittiDataManager fetchAllSavedRoutesFromCoreData];
        NSArray * recentStops = [self.reittiDataManager fetchAllSavedStopHistoryFromCoreData];
        NSArray * recentRoutes = [self.reittiDataManager fetchAllSavedRouteHistoryFromCoreData];
        NSArray * namedBookmarks = [self.reittiDataManager fetchAllSavedNamedBookmarksFromCoreData];
        
        routeSearchViewController.savedStops = [NSMutableArray arrayWithArray:savedStops];
        routeSearchViewController.recentStops = [NSMutableArray arrayWithArray:recentStops];
        routeSearchViewController.savedRoutes = [NSMutableArray arrayWithArray:savedRoutes];
        routeSearchViewController.recentRoutes = [NSMutableArray arrayWithArray:recentRoutes];
        routeSearchViewController.namedBookmarks = [NSMutableArray arrayWithArray:namedBookmarks];
        
//        routeSearchViewController.droppedPinGeoCode = droppedPinGeoCode;
        
        routeSearchViewController.prevToLocation = mainSearchBar.text;
        
        if ([segue.identifier isEqualToString:@"routeSearchController"]) {
            routeSearchViewController.prevToLocation = selectedAnnotationUniqeName;
            routeSearchViewController.prevToCoords = selectedAnnotationCoords;
            
            routeSearchViewController.prevFromLocation = selectedFromLocation;
            routeSearchViewController.prevFromCoords = selectedFromCoords;
        }
        
        if ([segue.identifier isEqualToString:@"switchToRouteSearch"]) {
            routeSearchViewController.prevToLocation = mainSearchBar.text;
            routeSearchViewController.prevToCoords = prevSearchedCoords;
        }
        
        routeSearchViewController.reittiDataManager = [[RettiDataManager alloc] initWithManagedObjectContext:self.managedObjectContext];
        [routeSearchViewController.reittiDataManager setUserLocationToRegion:[settingsManager userLocation]];
//        routeSearchViewController.reittiDataManager = self.reittiDataManager;
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
//        controller.droppedPinGeoCode = droppedPinGeoCode;
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
            controller.viewControllerMode = ViewControllerModeViewGeoCode;
            controller.reittiDataManager = [[RettiDataManager alloc] initWithManagedObjectContext:self.managedObjectContext];
            [controller.reittiDataManager setUserLocationToRegion:[settingsManager userLocation]];
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
