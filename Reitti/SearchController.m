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
#import "JPSThumbnailAnnotation.h"
#import <Social/Social.h>

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
@synthesize reittiDataManager;
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
@synthesize darkMode;

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
    darkMode = YES;
    centerMap = YES;
    isStopViewDisplayed = NO;
    isSearchResultsViewDisplayed = NO;
    justReloading = NO;
    stopViewDragedDown = NO;
    requestedForListing = NO;
    departuresTableIndex = nil;
    selectedStopLongCode = nil;
    prevSelectedStopLongCode = nil;
    annotationSelectionChanged = YES;
    lastSelectionDismissed = NO;
    ignoreRegionChange = NO;
    retryCount = 0;
    annotationAnimCounter = 0;
    
    [self selectSystemColors];
    
    AppDelegate *appDelegate = [[AppDelegate alloc] init];
    self.managedObjectContext = appDelegate.managedObjectContext;
    
    RettiDataManager * dataManger = [[RettiDataManager alloc] initWithManagedObjectContext:self.managedObjectContext];
    dataManger.delegate = self;
    dataManger.disruptionFetchDelegate = self;
    //dataManger.managedObjectContext = self.managedObjectContext;
    self.reittiDataManager = dataManger;
    appOpenCount = [self.reittiDataManager getAppOpenCountAndIncreament];
    if (appOpenCount > 3) {
//        sendEmailButton.hidden = NO;
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Enjoy Using The App?"
                                                            message:@"Please write a review for this app in the App Store if you think it has been useful."
                                                           delegate:self
                                                  cancelButtonTitle:@"Maybe later"
                                                  otherButtonTitles:@"Rate", nil];
        alertView.tag = 1001;
        [alertView show];
    }else{
//        sendEmailButton.hidden = YES;
    }
    
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
    
	// Do any additional setup after loading the view.
    tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureDetected:)];
    tapGestureRecognizer.delegate = self;
    
    [mapView addGestureRecognizer:tapGestureRecognizer];
    
    blurViewGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(blurViewGestureDetected:)];
    
    [blurView addGestureRecognizer:blurViewGestureRecognizer];
    
    toolBarGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(blurViewGestureDetected:)];
    
    //[toolBar addGestureRecognizer:toolBarGestureRecognizer];
    
    stopViewGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(stopViewGestureDetected:)];
    
    stopViewDragGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(dragStopView:)];
    
    [StopView addGestureRecognizer:stopViewDragGestureRecognizer];
    
    [StopView addGestureRecognizer:stopViewGestureRecognizer];
    
    searchResultsViewGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(searchResultViewGestureDetected:)];
    
    searchResultViewDragGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(dragStopView:)];
    
    [searchResultsView addGestureRecognizer:searchResultViewDragGestureRecognizer];
    
//    [searchResultsTable addGestureRecognizer:searchResultViewDragGestureRecognizer];
    
//    [searchResultsView addGestureRecognizer:searchResultsViewGestureRecognizer];
    
    [self setNeedsStatusBarAppearanceUpdate];
    [self setBlurViewApearance];
    [self setCommandViewApearance];
    
    [self initNotificationView];
    [self hideStopView:YES animated:NO];
    [self hideSearchResultView:YES animated:NO];
    [self hideCommandView:YES];
    [self initializeMapView];
    [self initDisruptionFetching];
    [self setBookmarkedStopsToDefaults];
    
    self.searchResultListViewMode = RSearchResultViewModeNearByStops;
    
    //Testing
//    NSUserDefaults *sharedDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.commuterAppExtension"];
//    
//    [sharedDefaults setInteger:9 forKey:@"MyNumberKey"];
//    [sharedDefaults synchronize];
}

-(void)viewWillAppear:(BOOL)animated{
    [self initDisruptionFetching];   
}

- (id<UILayoutSupport>)topLayoutGuide {
    return [[MyFixedLayoutGuide alloc]initWithLength:blurView.frame.size.height];
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

#pragma mark - Search view methods
- (void)selectSystemColors{
    if (self.darkMode) {
//        systemBackgroundColor = [UIColor clearColor];
        systemBackgroundColor = [UIColor colorWithRed:0/255 green:0/255 blue:0/255 alpha:1];
        systemTextColor = SYSTEM_GREEN_COLOR;
        systemSubTextColor = [UIColor lightGrayColor];
    }else{
        systemBackgroundColor = nil;
        systemTextColor = SYSTEM_GREEN_COLOR;
        systemSubTextColor = [UIColor darkGrayColor];
    }
}
- (void)setBlurViewApearance{
//    appTitileLable.font = CUSTOME_FONT_BOLD(30.0f);
    
    [blurView setBlurTintColor:systemBackgroundColor];
    //blurView.alpha = 0.97;
    blurView.layer.borderWidth = 0.5;
    blurView.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    
    //searchBarFrame = mainSearchBar.frame;
    
    //Set search bar text color
    for (UIView *subView in mainSearchBar.subviews)
    {
        for (UIView *secondLevelSubview in subView.subviews){
            if ([secondLevelSubview isKindOfClass:[UITextField class]])
            {
                UITextField *searchBarTextField = (UITextField *)secondLevelSubview;
                
                //set font color here
                searchBarTextField.textColor = systemSubTextColor;
                
                break;
            }
        }
    }
    
    if (self.darkMode) {
        mainSearchBar.keyboardAppearance = UIKeyboardAppearanceDark;
    }else{
        mainSearchBar.keyboardAppearance = UIKeyboardAppearanceDefault;
    }
    
}

-(int)searchViewLowerBound{
    return blurView.frame.origin.y + blurView.frame.size.height;
}

#pragma mark - extension methods
- (void)setBookmarkedStopsToDefaults{
    
    NSArray *savedStops = [self.reittiDataManager fetchAllSavedStopsFromCoreData];
    [self.reittiDataManager updateSavedStopsDefaultValueForStops:savedStops];
    //test
    NSUserDefaults *sharedDefaults2 = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.ewketApps.commuterDepartures"];
    NSLog(@"%@",[sharedDefaults2 dictionaryRepresentation]);
}

#pragma - mark Command view methods

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

#pragma mark - Annotation helpers
-(void)openRouteForAnnotationWithTitle:(NSString *)title subtitle:(NSString *)subTitle andCoords:(CLLocationCoordinate2D)coords{
    selectedAnnotationUniqeName = [NSString stringWithFormat:@"%@ (%@)", title,subTitle];
    selectedAnnotationCoords = [NSString stringWithFormat:@"%f,%f",coords.longitude, coords.latitude];
    [self performSegueWithIdentifier:@"routeSearchController" sender:nil];
}

-(void)openStopViewForCode:(NSNumber *)code{
    selectedStopCode = [NSString stringWithFormat:@"%d", [code intValue]];
    [self performSegueWithIdentifier:@"openStopView" sender:nil];
}

#pragma - mark Notification methods
-(void)initNotificationView{
    notificationView.layer.borderWidth = 1;
    notificationView.layer.borderColor = [SYSTEM_GRAY_COLOR CGColor];
    [notificationView setBlurTintColor:SYSTEM_GRAY_COLOR];
//    notificationMessageLabel.font = CUSTOME_FONT_BOLD(17.0f);
    [self hideNotificationView:YES animated:NO];
}
-(void)hideNotificationView:(BOOL)hidden{
    CGRect viewFrame = notificationView.frame;
    
    if (hidden) {
        viewFrame.origin.y = [self searchViewLowerBound] - viewFrame.size.height;
        notificationView.frame = viewFrame;
        //notificationView.hidden = YES;
    }else{
        [self setNotificationViewVerticalPosition];
        notificationView.hidden = NO;
    }
}

-(void)hideNotificationView:(BOOL)hidden animated:(BOOL)anim{
    
    //[self setNotificationViewVerticalPosition];
    
    if (!hidden) {
        [self hideNotificationView:YES];
    }
    if (anim) {
        [UIView transitionWithView:notificationView duration:0.5 options:UIViewAnimationOptionCurveEaseIn animations:^{
            
            [self hideNotificationView:hidden];
            
        } completion:^(BOOL finished) {
            if (hidden) {
                notificationView.hidden = YES;
            }
        }];
    }else{
        [self hideNotificationView:hidden];
        if (hidden) {
            notificationView.hidden = YES;
        }
    }
}

-(void)setNotificationViewVerticalPosition{
    CGRect viewFrame = notificationView.frame;
    viewFrame.origin.y = [self searchViewLowerBound] + 5;
    notificationView.frame = viewFrame;
}

-(void)showNotificationWithMessage:(NSString *)message messageType:(RNotificationType)type forSeconds:(int)seconds keppingSearchView:(BOOL)keepSearchView{
    [notificationTimer invalidate];
    notificationImageView.hidden = NO;
    switch (type) {
        case RNotificationTypeInfo:
            notificationImageView.hidden = YES;
            break;
            
        case RNotificationTypeConfirmation:
            [notificationImageView setImage:[UIImage imageNamed:@"done_notification.png"]];
            break;
            
        case RNotificationTypeWarning:
            [notificationImageView setImage:[UIImage imageNamed:@"warning_notification.png"]];
            break;
            
        case RNotificationTypeError:
            [notificationImageView setImage:[UIImage imageNamed:@"error_notification.png"]];
            break;
            
        default:
            break;
    }
    notificationMessageLabel.text = message;
    if (isStopViewDisplayed || isSearchResultsViewDisplayed) {
    }
    
    [self hideNotificationView:NO animated:YES];
    
    self.notificationTimer = [NSTimer scheduledTimerWithTimeInterval:seconds target:self selector:@selector(notificationTimerCallback) userInfo:nil repeats:YES];
}

-(void)notificationTimerCallback {
    [self hideNotificationView:YES animated:YES];
    if (isStopViewDisplayed || isSearchResultsViewDisplayed) {
    
    }
    [self.notificationTimer invalidate];
    self.notificationTimer = nil;
}

#pragma - mark StopView methods

- (void)requestStopInfoAsyncForCode:(NSString *)code{
    
    [self.reittiDataManager fetchStopsForCode:code];
}

- (void)showProgressHUD{
    
    //MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    //hud.labelText = @"Loading...";
    [SVProgressHUD show];
    //[SVProgressHUD setBackgroundColor:[UIColor grayColor]];
    //[SVProgressHUD setBackgroundColor:[UIColor colorWithWhite:0.95 alpha:1]];
}


- (void)displayStopView:(NSArray *)stopList{
    
    @try {
        if (stopList.count > 1) {
            [self displaySearchResults:stopList];
        }else{
            if (searchedStopList.count == 1) {
                [self hideSearchResultView:YES animated:YES];
            }
            [self setUpStopViewForBusStop:[stopList objectAtIndex:0]];
            if ([self.reittiDataManager saveHistoryToCoreDataStop:self._busStop]) {
                if (justReloading) {
                    [self hideStopView:NO animated:NO];
                }else{
                    [self hideStopView:NO animated:YES];
                }
                justReloading = NO;
                
            }else{
                [self showNotificationWithMessage:@"Uh-oh! Displaying stop failed. Must be a corrupted data." messageType:RNotificationTypeError forSeconds:5 keppingSearchView:YES];
            }
        }
    }
    @catch (NSException *exception) {
        NSLog(@"Saving history info failed");
        [self showNotificationWithMessage:@"Uh-oh! Displaying stop failed. Might be a corupted data." messageType:RNotificationTypeError forSeconds:5 keppingSearchView:YES];
    }
}

-(void)setUpStopViewForBusStop:(BusStop *)busStop{
    //set the state of add bookmark button
    if ([reittiDataManager isBusStopSaved:busStop]) {
        addBookmarkButton.hidden = YES;
    }else{
        addBookmarkButton.hidden = NO;
    }
//    StopView.layer.cornerRadius = 10;
    StopView.layer.borderWidth = 1;
    StopView.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    departuresTable.layer.borderWidth = 0.5;
//  departuresTable.layer.cornerRadius = 10;
    departuresTable.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    
    self.departures = busStop.departures;
    self._busStop = busStop;
    self._stopLinesDetail = [RettiDataManager convertStopLinesArrayToDictionary:busStop.lines];
    [self.refreshControl endRefreshing];
    [self initRefreshControl];
//    departuresTable.backgroundColor = [UIColor clearColor];
    [departuresTable reloadData];
    [departuresTable scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
    
    [stopCodeLabel setText:[busStop code_short]];
//    stopCodeLabel.font = CUSTOME_FONT_BOLD(42.0f);
    [stopNameLabel setText:[busStop name_fi]];
//    stopNameLabel.font = CUSTOME_FONT_BOLD(19.0f);
    [cityNameLabel setText:[busStop city_fi]];
//    cityNameLabel.font = CUSTOME_FONT(40.0f);
}

-(void)hideStopView:(BOOL)hidden animated:(BOOL)anim{
    if (!hidden) {
        //[self hideStopView:YES];
        StopView.hidden = NO;
    }
    if (anim) {
        [UIView transitionWithView:blurView duration:0.5 options:UIViewAnimationOptionCurveEaseIn animations:^{
            
            [self hideStopView:hidden];
            
        } completion:^(BOOL finished) {
            if (hidden) {
                StopView.hidden = YES;
            }
        }];
    }else{
        [self hideStopView:hidden];
        if (hidden) {
            StopView.hidden = YES;
        }
    }
}

- (void)hideStopView:(BOOL)hidden{
    CGRect stopFrame = StopView.frame;
    
    if (hidden) {
        stopFrame.origin.y = self.view.bounds.size.height + 5;
        reloadBarButtonItem.enabled = NO;
        isStopViewDisplayed = NO;
    }else{
        stopFrame.origin.y = 105;
        reloadBarButtonItem.enabled = YES;
        isStopViewDisplayed = YES;
    }
    
    StopView.frame = stopFrame;
}

- (void)moveStopViewByPoint:(CGPoint)displacement animated:(BOOL)anim{
    [UIView transitionWithView:StopView duration:0.15 options:UIViewAnimationOptionCurveEaseIn animations:^{
        
        CGRect stopFrame = StopView.frame;
        stopFrame.origin.y = stopFrame.origin.y + displacement.y;
        StopView.frame = stopFrame;
        
    } completion:^(BOOL finished) {
        [self hideStopView:NO animated:YES];
    }];
}

#pragma - mark searchResultsView methods
-(void)displaySearchResults:(NSArray *)result{
    [self setupSearchResultViewForSearchResult:result];
    [self hideStopView:YES animated:YES];
    [self hideSearchResultView:NO animated:YES];
}
-(void)setupSearchResultViewForSearchResult:(NSArray *)result{
    [self setupSearchResultViewAppearance];
    
    self.searchResultListViewMode = RSearchResultViewModeSearchResults;
    searchResultsLabel.text = [NSString stringWithFormat:@"%lu stops found", (unsigned long)result.count];
//    searchResultsLabel.font = CUSTOME_FONT_BOLD(16.0f);
    [searchResultsTable reloadData];
    [searchResultsTable scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
}
-(void)displayNearByStopsList:(NSArray *)nearByStops{
    [self setupSearchResultViewForNearByStops:nearByStops];
    [self hideStopView:YES animated:YES];
    [self hideSearchResultView:NO animated:YES];
}
-(void)setupSearchResultViewForNearByStops:(NSArray *)result{
    [self setupSearchResultViewAppearance];
    
    self.searchResultListViewMode = RSearchResultViewModeNearByStops;
    searchResultsLabel.text = @"Nearby stops";
//    searchResultsLabel.font = CUSTOME_FONT_BOLD(16.0f);
    [searchResultsTable reloadData];
    [searchResultsTable scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
}
-(void)setupSearchResultViewAppearance{
    searchResultsTable.backgroundColor = [UIColor clearColor];
    [searchResultsView setBlurTintColor:nil];
    searchResultsView.layer.borderWidth = 0.5;
    searchResultsView.layer.borderColor = [SYSTEM_GRAY_COLOR CGColor];
}
-(void)hideSearchResultView:(BOOL)hidden animated:(BOOL)anim{
    if (!hidden) {
        //[self hideSearchResultView:YES];
        searchResultsView.hidden = NO;
    }
    if (anim) {
        [UIView transitionWithView:searchResultsView duration:0.3 options:UIViewAnimationOptionCurveEaseIn animations:^{
            
            [self hideSearchResultView:hidden];
            
        } completion:^(BOOL finished) {
            if (hidden) {
                searchResultsView.hidden = YES;
                [self.reittiDataManager fetchStopsInAreaForRegion:[mapView region]];
            }
        }];
    }else{
        [self hideSearchResultView:hidden];
        if (hidden) {
            searchResultsView.hidden = YES;
            [self.reittiDataManager fetchStopsInAreaForRegion:[mapView region]];
        }
    }
}

- (void)hideSearchResultView:(BOOL)hidden{
    CGRect frame = searchResultsView.frame;
    CGRect tableFrame = searchResultsTable.frame;
    
    if (hidden) {
        frame.origin.y = self.view.bounds.size.height + 5;
        isSearchResultsViewDisplayed = NO;
        [listNearbyStops setImage:[UIImage imageNamed:@"list_nearBy.png"] forState:UIControlStateNormal];
    }else{
        frame.origin.y = blurView.frame.size.height;
        frame.size.height = self.view.bounds.size.height - blurView.frame.size.height;
        frame.size.height = self.view.bounds.size.height - blurView.frame.size.height;
        isSearchResultsViewDisplayed = YES;
        
        [listNearbyStops setImage:[UIImage imageNamed:@"showMap-icon.png"] forState:UIControlStateNormal];
    }
    searchResultsView.frame = frame;
    tableFrame.size.height = frame.size.height;
    searchResultsTable.frame = tableFrame;
    requestedForListing = NO;
}

- (void)moveSearchResultViewByPoint:(CGPoint)displacement animated:(BOOL)anim{
    [UIView transitionWithView:searchResultsView duration:0.15 options:UIViewAnimationOptionCurveEaseIn animations:^{
        
        CGRect stopFrame = searchResultsView.frame;
        stopFrame.origin.y = stopFrame.origin.y + displacement.y;
        searchResultsView.frame = stopFrame;
        
    } completion:^(BOOL finished) {
        [self hideSearchResultView:NO animated:YES];
    }];
}

- (void)listNearByStops{
    
    MKCoordinateSpan span = {.latitudeDelta =  0.02, .longitudeDelta =  0.02};
    MKCoordinateRegion region = {self.currentUserLocation.coordinate, span};
    
    requestedForListing = YES;
    
    if ([self isLocationServiceAvailable]) {
        [self.reittiDataManager fetchStopsInAreaForRegion:region];
        [self showProgressHUD];
    }else{
        requestedForListing = NO;
    }
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
    NSLog(@"Number of departures is: %lu",(unsigned long)self.departures.count);
    if (tableView.tag == 1000) {
        return self.departures.count;
    }else if (tableView.tag == 0){
        if (self.searchResultListViewMode == RSearchResultViewModeSearchResults){
            return self.nearByStopList.count;
        }else if (self.searchResultListViewMode == RSearchResultViewModeNearByStops){
            return self.nearByStopList.count;
        }
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView.tag == 1000) {
        CustomeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"departureCell"];
        
        CustomeTableViewCell __weak *weakCell = cell;
        NSMutableArray * leftUtilityButtons = [NSMutableArray new];
        [leftUtilityButtons sw_addUtilityButtonWithColor:
                        [UIColor colorWithRed:51.0/255.0 green:153.0/255.0 blue:102.0/255.0 alpha:1.0]
                                                                   icon:[UIImage imageNamed:@"alarmClock_small.png"]];
        
        NSArray *buttonsArray = [NSArray arrayWithArray:leftUtilityButtons];
        
        [cell setAppearanceWithBlock:^{
            weakCell.leftUtilityButtons = buttonsArray;
            weakCell.delegate = self;
            weakCell.containingTableView = tableView;
        } force:NO];
        
        NSDictionary *departure = [self.departures objectAtIndex:indexPath.row];
        if (departure) {
            
            @try {
                UILabel *timeLabel = (UILabel *)[cell viewWithTag:1001];
                NSString *notFormattedTime = [NSString stringWithFormat:@"%d" ,[(NSNumber *)[departure objectForKey:@"time"] intValue]];
                timeLabel.text = [ReittiStringFormatter formatHSLAPITimeWithColon:notFormattedTime];
                //cell.cellTimeLabel.text = [ReittiStringFormatter formatHSLAPITimeWithColon:notFormattedTime];
//                timeLabel.font = CUSTOME_FONT_BOLD(25.0f);
                
                //            UILabel *dateLabel = (UILabel *)[cell viewWithTag:1002];
                //            NSString *notFormattedDate = [NSString stringWithFormat:@"%d" ,[(NSNumber *)[departure objectForKey:@"date"] intValue]];
                //            dateLabel.text = [ReittiStringFormatter formatHSLDateWithDots:notFormattedDate];
                //            dateLabel.font = CUSTOME_FONT(20.0f);
                
                UILabel *codeLabel = (UILabel *)[cell viewWithTag:1003];
                NSString *notParsedCode = [departure objectForKey:@"code"];
                codeLabel.text = [ReittiStringFormatter parseBusNumFromLineCode:notParsedCode];
//                codeLabel.font = CUSTOME_FONT_BOLD(25.0f);
                
                UILabel *destinationLabel = (UILabel *)[cell viewWithTag:1004];
                if (_stopLinesDetail != NULL) {
                    destinationLabel.text = [_stopLinesDetail objectForKey:[departure objectForKey:@"code"]];
                    //destinationLabel.font = CUSTOME_FONT_BOLD(16.0f);
                }else{
                    destinationLabel.text = @"";
                }
            }
            @catch (NSException *exception) {
                if (self.departures.count == 1) {
                    UITableViewCell *infoCell = [tableView dequeueReusableCellWithIdentifier:@"infoCell"];
                    //                infoCell.backgroundColor = [UIColor clearColor];
                    return infoCell;
                }
            }
            @finally {
                NSLog(@"finally");
            }
        }
        
        [cell setCellHeight:cell.frame.size.height];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        
        return cell;
        
    }else if (tableView.tag == 0){
        if (self.searchResultListViewMode == RSearchResultViewModeSearchResults) {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"searchResultCell"];
            
            BusStop *stop = [searchedStopList objectAtIndex:indexPath.row];
            
            UILabel *codeLabel = (UILabel *)[cell viewWithTag:3001];
            codeLabel.text = stop.code_short;
//            codeLabel.font = CUSTOME_FONT_BOLD(25.0f);
            
            UILabel *nameLabel = (UILabel *)[cell viewWithTag:3002];
            nameLabel.text = stop.name_fi;
//            nameLabel.font = CUSTOME_FONT_BOLD(22.0f);
            
            UILabel *cityLabel = (UILabel *)[cell viewWithTag:3003];
            cityLabel.text = stop.city_fi;
//            cityLabel.font = CUSTOME_FONT_BOLD(15.0f);
            
            cell.backgroundColor = [UIColor clearColor];
            
            return cell;
        }else if (self.searchResultListViewMode == RSearchResultViewModeNearByStops){
            if (nearByStopList.count > 0) {
                UITableViewCell *cell = [searchResultsTable dequeueReusableCellWithIdentifier:@"searchResultCell"];
                
                BusStopShort *stop = [nearByStopList objectAtIndex:indexPath.row];
                
                UILabel *codeLabel = (UILabel *)[cell viewWithTag:3001];
                codeLabel.text = stop.codeShort;
//                codeLabel.font = CUSTOME_FONT_BOLD(22.0f);
                
                UILabel *nameLabel = (UILabel *)[cell viewWithTag:3002];
                nameLabel.text = stop.name;
//                nameLabel.font = CUSTOME_FONT_BOLD(20.0f);
                
                UILabel *distanceLabel = (UILabel *)[cell viewWithTag:3003];
                distanceLabel.text = [NSString stringWithFormat:@"%d m", [stop.distance intValue]];
//                distanceLabel.font = CUSTOME_FONT_BOLD(15.0f);
                
                cell.backgroundColor = [UIColor clearColor];
                
                return cell;
            }else{
                
            }
        }
    }
	
    return nil;
}


// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return NO;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
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
}

- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerLeftUtilityButtonWithIndex:(NSInteger)index {
    UIActionSheet *actionSheet;
    EKAuthorizationStatus status;
    switch (index) {
        case 0:
            status = [EKEventStore authorizationStatusForEntityType:EKEntityTypeReminder];
            
            if (status != EKAuthorizationStatusAuthorized) {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"No Access to Reminders app"                                                                                      message:@"Please grant access to the Reminders app from Settings/Privacy/Reminders to use this feature."
                                                                   delegate:nil
                                                          cancelButtonTitle:@"OK"
                                                          otherButtonTitles:nil];
                [alertView show];
                [cell hideUtilityButtonsAnimated:YES];
                break;
            }
            actionSheet = [[UIActionSheet alloc] initWithTitle:@"When do you want to be reminded." delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"1 min before", @"5 min before",@"10 min before",@"15 min before", @"30 min before", nil];
            //actionSheet.tintColor = SYSTEM_GRAY_COLOR;
            actionSheet.tag = 2001;
            [actionSheet showInView:self.view];
            timeToSetAlarm = [(UILabel *)[cell viewWithTag:1001] text];
            [cell hideUtilityButtonsAnimated:YES];
            
            break;
        default:
            break;
    }
}

- (void)swipeableTableViewCell:(SWTableViewCell *)cell scrollingToState:(SWCellState)state{
    NSIndexPath *index = [departuresTable indexPathForCell:cell];
    if (departuresTableIndex != nil && state == kCellStateLeft && index.row != departuresTableIndex.row) {
        [(CustomeTableViewCell *)[departuresTable cellForRowAtIndexPath:departuresTableIndex] hideUtilityButtonsAnimated:YES];
    }
    departuresTableIndex = [departuresTable indexPathForCell:cell];
    
}


- (void)initRefreshControl{
    
    UITableViewController *tableViewController = [[UITableViewController alloc] init];
    tableViewController.tableView = departuresTable;
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(reloadButtonPressed:) forControlEvents:UIControlEventValueChanged];
    //refresh.attributedTitle = [[NSAttributedString alloc] initWithString:@"Pull to Refresh"];
    tableViewController.refreshControl = self.refreshControl;
}


#pragma - mark Map methods

- (void)initializeMapView
{
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.distanceFilter = kCLDistanceFilterNone;
    locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
    [locationManager startUpdatingLocation];
    [locationManager requestWhenInUseAuthorization];
    
}

-(BOOL)centerMapRegionToCoordinate:(CLLocationCoordinate2D)coordinate{
    
    BOOL toReturn = YES;
    
    if (![self isLocationServiceAvailable]) {
        CLLocationCoordinate2D coord = {.latitude =  60.1733239, .longitude =  24.9410248};
        coordinate = coord;
        
        toReturn = NO;
    }
    
    //CLLocationCoordinate2D coord = {.latitude =  60.1733239, .longitude =  24.9410248};
    MKCoordinateSpan span = {.latitudeDelta =  0.01, .longitudeDelta =  0.01};
    MKCoordinateRegion region = {coordinate, span};
    
    [mapView setRegion:region animated:YES];
    
    
    
//    ///Testing only
//    StopAnnotation *newAnnotation = [[StopAnnotation alloc] initWithTitle:@"1230" andSubtitle:@"Lepasuonkatu" andCoordinate:coordinate];
//    //newAnnotation.image = [UIImage imageNamed:@"bus_stop_hsl.png"];
//    
//    [mapView addAnnotation:newAnnotation];
    
    return toReturn;
}

-(BOOL)isLocationServiceAvailable{
    BOOL accessGranted = [CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse;
    NSLog(@"%d",[CLLocationManager authorizationStatus]);
    BOOL locationServicesEnabled = [CLLocationManager locationServicesEnabled];
    
    if (!locationServicesEnabled) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Uh-Oh"
                                                            message:@"Looks like location services is not enabled. Enable it from Settings/Privacy/Location Services to get nearby stops suggestions."
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        [alertView show];
        
        return NO;
    }
    
    if (!accessGranted) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Uh-Oh"
                                                            message:@"Looks like access is not granted to this app for location services. Grant access from Settings/Privacy/Location Services to get nearby stops suggestions."
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        [alertView show];
        
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
////    NSMutableArray *collectedList = [[NSMutableArray alloc] init];
////    for (BusStopShort *stop in stopList) {
////        if ([codeList containsObject:stop.code]) {
////            [collectedList addObject:stop];
////        }
////    }
//    return collectedList;
}

-(void)plotStopAnnotations:(NSArray *)stopList{
    NSMutableArray *codeList;
    codeList = [self collectStopCodes:stopList];
    
    NSMutableArray *annotToRemove = [[NSMutableArray alloc] init];
    
    for (id<MKAnnotation> annotation in mapView.annotations) {
        if ([annotation isKindOfClass:[JPSThumbnailAnnotation class]]) {
            JPSThumbnailAnnotation *annot = (JPSThumbnailAnnotation *)annotation;
            
            if (![codeList containsObject:annot.code]) {
                if (annot.annotationType == NearByStopType) {
                    [annotToRemove addObject:annotation];
                }
            }else{
                [codeList removeObject:annot.code];
            }
        }
    }
    [mapView removeAnnotations:annotToRemove];
    
    NSArray *newStops = [self collectStopsForCodes:codeList fromStops:stopList];
    
    UIImage *stopImage = [UIImage imageNamed:@"stopAnnotation.png"];
    
    for (BusStopShort *stop in newStops) {
        
        CLLocationCoordinate2D coordinate = [ReittiStringFormatter convertStringTo2DCoord:stop.coords];
        NSString * name = stop.name;
        NSString * codeShort = [NSString stringWithFormat:@"%@", stop.codeShort];
        
        JPSThumbnail *stopAnT = [[JPSThumbnail alloc] init];
        stopAnT.image = stopImage;
        stopAnT.code = stop.code;
        stopAnT.title = name;
        stopAnT.subtitle = codeShort;
        stopAnT.coordinate = coordinate;
        stopAnT.annotationType = NearByStopType;
        stopAnT.reuseIdentifier = @"NearByStopAnnotation";
        stopAnT.primaryButtonBlock = ^{ [self openRouteForAnnotationWithTitle:name subtitle:codeShort andCoords:coordinate];};
        stopAnT.secondaryButtonBlock = ^{ [self openStopViewForCode:stop.code];};
        
        [mapView addAnnotation:[JPSThumbnailAnnotation annotationWithThumbnail:stopAnT]];
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
    stopAnT.image = [UIImage imageNamed:@"stopAnnotation.png"];
    stopAnT.code = stop.code;
    stopAnT.title = name;
    stopAnT.subtitle = shortCode;
    stopAnT.coordinate = coordinate;
    stopAnT.annotationType = SearchedStopType;
    stopAnT.reuseIdentifier = @"SearchedStopAnnotation";
    stopAnT.primaryButtonBlock = ^{ [self openRouteForAnnotationWithTitle:name subtitle:shortCode andCoords:coordinate];};
    stopAnT.secondaryButtonBlock = ^{ [self openStopViewForCode:stop.code];};
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
    geoAnT.image = [UIImage imageNamed:@"geoCodeAnnotation.png"];
    geoAnT.title = name;
    geoAnT.subtitle = city;
    geoAnT.coordinate = coordinate;
    geoAnT.annotationType = GeoCodeType;
    geoAnT.reuseIdentifier = @"geoLocationAnnotation";
    geoAnT.primaryButtonBlock = ^{ [self openRouteForAnnotationWithTitle:name subtitle:city andCoords:coordinate];};
    JPSThumbnailAnnotation *annot = [JPSThumbnailAnnotation annotationWithThumbnail:geoAnT];
    [mapView addAnnotation:annot];
    
    [mapView selectAnnotation:annot animated:YES];

    
//    GeoCodeAnnotation *newAnnotation = [[GeoCodeAnnotation alloc] initWithTitle:name andSubtitle:city coordinate:coordinate andLocationType:geoCode.getLocationType];
    
//    [mapView addAnnotation:newAnnotation];
}


- (MKAnnotationView *)mapView:(MKMapView *)_mapView viewForAnnotation:(id <MKAnnotation>)annotation {
//    static NSString *identifier = @"otherLocations";
//    static NSString *selectedIdentifier = @"selectedLocation";
    static NSString *poiIdentifier = @"poiIdentifier";
    
//    if ([annotation isKindOfClass:[StopAnnotation class]]) {
//        StopAnnotation *sAnnotation = (StopAnnotation *)annotation;
//        if([sAnnotation.code intValue] == [selectedStopLongCode intValue]){
////        if(sAnnotation.isSelected){
//            MKAnnotationView *annotationView = (MKAnnotationView *) [_mapView dequeueReusableAnnotationViewWithIdentifier:selectedIdentifier];
//            if (annotationView == nil) {
//                annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:selectedIdentifier];
//                annotationView.enabled = YES;
//                //annotationView.canShowCallout = YES;
//                annotationView.image = [UIImage imageNamed:@"busStopAnnotation.png"];
//                [annotationView setFrame:CGRectMake(0, 0, bigAnnotationWidth, bigAnnotationHeight)];
//                annotationView.centerOffset = CGPointMake(0,-48);
//                
//                annotationView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
//                annotationView.leftCalloutAccessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bus_stop_hsl_orig.png"]];
//            } else {
//                annotationView.annotation = annotation;
//            }
//            StopAnnotation *sAnnotation = (StopAnnotation *)annotationView.annotation;
//            if (lastSelectedAnnotation != nil)
//                annotationSelectionChanged = ([lastSelectedAnnotation.code intValue] != [sAnnotation.code intValue]);
//            lastSelectedAnnotation = annotationView.annotation;
//            return annotationView;
//        }else{
//            MKAnnotationView *annotationView = (MKAnnotationView *) [_mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
//            if (annotationView == nil) {
//                annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
//                annotationView.enabled = YES;
//                
//                annotationView.image = [UIImage imageNamed:@"busStopAnnotation-small-blue.png"];
//                [annotationView setFrame:CGRectMake(0, 0, smallAnnotationWidth, smallAnnotationHeight)];
//                annotationView.centerOffset = CGPointMake(0,-13);
//                
//                annotationView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
//                annotationView.leftCalloutAccessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bus_stop_hsl_orig.png"]];
//            } else {
//                annotationView.annotation = annotation;
//            }
//            
//            return annotationView;
//        }
//        
//    }
    if ([annotation conformsToProtocol:@protocol(JPSThumbnailAnnotationProtocol)]) {
        return [((NSObject<JPSThumbnailAnnotationProtocol> *)annotation) annotationViewInMap:mapView];
    }
    else if ([annotation isKindOfClass:[GeoCodeAnnotation class]]) {
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
    sendEmailButton.alpha = 0.3;
    listNearbyStops.alpha = 0.3;
}

- (void)mapView:(MKMapView *)affectedMapView didSelectAnnotationView:(MKAnnotationView *)view{
//    if ([view.annotation isKindOfClass:[StopAnnotation class]]) {
//        if (![self isCommandViewHidden])
//            [self hideCommandView:YES animated:NO];
//        [self setUpCommandViewForAnnotation:view.annotation];
//        
//        [self hideCommandView:NO animated:YES];
//        
//        StopAnnotation *sAnnotation = (StopAnnotation *)view.annotation;
//        sAnnotation.isSelected = YES;
//        MKAnnotationView *annotationView = [[MKAnnotationView alloc] initWithAnnotation:sAnnotation reuseIdentifier:@"selectedLocation"];
//        @try{
//            [affectedMapView removeAnnotation:view.annotation];
//        }@catch(id anException){
//            //do nothing, obviously it wasn't attached because an exception was thrown
//        }
//        
//        [affectedMapView addAnnotation:annotationView.annotation];
//        
//        if (lastSelectedAnnotation != nil && (lastSelectedAnnotation.code != sAnnotation.code) && !lastSelectionDismissed) {
//            
////            [self mapView:mapView deselectStopAnnotation:lastSelectedAnnotation];
//            
////            lastSelectionDismissed = true;
//            
//            StopAnnotation *lastSAnnotation = (StopAnnotation *)lastSelectedAnnotation;
//            
//            lastSAnnotation.isSelected = NO;
//
//            MKAnnotationView *prevAnnotationView = [[MKAnnotationView alloc] initWithAnnotation:lastSAnnotation reuseIdentifier:@"otherLocations"];
//            @try{
//                [affectedMapView removeAnnotation:lastSelectedAnnotation];
//                [affectedMapView addAnnotation:prevAnnotationView.annotation];
//                lastSelectionDismissed = true;
//            }@catch(id anException){
//                //do nothing, obviously it wasn't attached because an exception was thrown
//            }
//        }
//        
//        //lastSelectedAnnotation = annotationView.annotation;
//    }
//    if ([view.annotation isKindOfClass:[GeoCodeAnnotation class]]){
//        if (![self isCommandViewHidden])
//            [self hideCommandView:YES animated:NO];
//        [self setUpCommandViewForAnnotation:view.annotation];
//        
//        [self hideCommandView:NO animated:YES];
//        
//        MKAnnotationView *annotationView = [[MKAnnotationView alloc] initWithAnnotation:view.annotation reuseIdentifier:@"selectedLocation"];
//        @try{
//            [affectedMapView removeAnnotation:view.annotation];
//        }@catch(id anException){
//            //do nothing, obviously it wasn't attached because an exception was thrown
//        }
//        
//        [affectedMapView addAnnotation:annotationView.annotation];
//    }
    
    if ([view conformsToProtocol:@protocol(JPSThumbnailAnnotationViewProtocol)]) {
        ignoreRegionChange = YES;
        [((NSObject<JPSThumbnailAnnotationViewProtocol> *)view) didSelectAnnotationViewInMap:mapView];
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
            [self setUpCommandViewForAnnotation:aV.annotation];
            [self hideCommandView:NO animated:YES];
            
            CGRect endFrame = aV.frame;
            aV.frame = CGRectMake(aV.frame.origin.x + aV.frame.size.width/2,
                                  aV.frame.origin.y + aV.frame.size.height,
                                  0, 0);
            [UIView beginAnimations:nil context:NULL];
            [UIView setAnimationDuration:0.25];
            [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
            [aV setFrame:endFrame];
            [UIView commitAnimations];
        }
        
    }
}

- (void)openAnnotation:(id)annotation;
{
    //mv is the mapView
    [mapView selectAnnotation:annotation animated:YES];
    
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
    StopAnnotation *stopAnnotation = (StopAnnotation*)view.annotation;
    
    [self requestStopInfoAsyncForCode:[NSString stringWithFormat:@"%d", [stopAnnotation.code intValue]]];
    [self showProgressHUD];
}

- (void)mapView:(MKMapView *)_mapView regionDidChangeAnimated:(BOOL)animated{
    if (!ignoreRegionChange) {
        
    }else{
        ignoreRegionChange = NO;
    }
    
    [self.reittiDataManager fetchStopsInAreaForRegion:[_mapView region]];
    currentLocationButton.alpha = 1;
    sendEmailButton.alpha = 1;
    listNearbyStops.alpha = 1;
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
    if (customBadge == nil && show) {
        customBadge = [CustomBadge customBadgeWithString:@"!"
                                                      withStringColor:[UIColor whiteColor]
                                                       withInsetColor:[UIColor colorWithRed:230.0/255.0 green:126.0/255.0 blue:34.0/255.0 alpha:1.0] withBadgeFrame:YES
                                                  withBadgeFrameColor:[UIColor whiteColor]
                                                            withScale:1.0
                                                          withShining:NO];
        [customBadge setFrame:CGRectMake(infoAndAboutButton.frame.origin.x + infoAndAboutButton.frame.size.width - 3 - customBadge.frame.size.width/2, infoAndAboutButton.frame.origin.y - customBadge.frame.size.height/2, customBadge.frame.size.width, customBadge.frame.size.height)];
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOnBadgeDetected)];
        tapGesture.delegate = self;
        
        [customBadge addGestureRecognizer:tapGesture];
        
        [self.view addSubview:customBadge];
    }else{
        customBadge.hidden = !show;
    }
}

- (void)tapOnBadgeDetected{
    [self performSegueWithIdentifier:@"infoViewSegue" sender:nil ];
}


#pragma mark - text field mehthods

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    
    [self.view endEditing:YES];
    
    if (![searchBar.text isEqualToString:@""]) {
        [self requestStopInfoAsyncForCode:[searchBar.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
        [self showProgressHUD];
    }
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar{
    [self performSegueWithIdentifier: @"addressSearchController" sender: self];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)thisSearchBar {
    //[thisSearchBar setFrame:searchBarFrame];
}

- (void)openBookmarksView{
    [self performSegueWithIdentifier: @"openBookmarks" sender: self];
}

- (void)openRouteSearchView{
    [self performSegueWithIdentifier: @"switchToRouteSearch" sender: self];
}

#pragma mark - helper methods
- (void)sendEmailWithSubject:(NSString *)subject{
    // Email Subject
    NSString *emailTitle = subject;
    // Email Content
    NSString *messageBody = @"";
    // To address
    NSArray *toRecipents = [NSArray arrayWithObject:@"ewketapps@gmail.com"];
    
    MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
    mc.mailComposeDelegate = self;
    [mc setSubject:emailTitle];
    [mc setMessageBody:messageBody isHTML:NO];
    [mc setToRecipients:toRecipents];
    
    // Present mail view controller on screen
    [self presentViewController:mc animated:YES completion:NULL];
    
}

- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    switch (result)
    {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail cancelled");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail saved");
            break;
        case MFMailComposeResultSent:
            NSLog(@"Mail sent");
//            [self.reittiDataManager setAppOpenCountValue:-100];
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail sent failure: %@", [error localizedDescription]);
            break;
        default:
            break;
    }
    
    // Close the Mail Interface
    [self dismissViewControllerAnimated:YES completion:NULL];
}

-(void)setReminderWithMinOffset:(int)minute andHourString:(NSString *)timeString{
    EKAuthorizationStatus status = [EKEventStore authorizationStatusForEntityType:EKEntityTypeReminder];
    
    if (status == EKAuthorizationStatusAuthorized) {
        if ([self createEKReminderWithMinOffset:minute andHourString:timeString]) {
            [self showNotificationWithMessage:@"Reminder set successfully!" messageType:RNotificationTypeConfirmation forSeconds:5 keppingSearchView:YES];
        }
        
    }else{
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"No Access to Reminders app"                                                                                      message:@"Please grant access to the Reminders app from Settings/Privacy/Reminders to use this feature."
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        [alertView show];
    }
}

-(BOOL)createEKReminderWithMinOffset:(int)minutes andHourString:(NSString *)timeString{
    NSDate *date = [ReittiStringFormatter createDateFromString:timeString withMinOffset:minutes];
    
    if (date == nil) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Uh-oh"                                                                                      message:@"Setting reminder failed."
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        [alertView show];
        return NO;
    }
    
    if ([[NSDate date] compare:date] == NSOrderedDescending ) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Just so you know"                                                                                      message:@"The alarm time you set has already past."
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        [alertView show];
    }
    
    EKReminder *reminder = [EKReminder reminderWithEventStore:_eventStore];
    
    reminder.title = [NSString stringWithFormat:@"Your ride will leave in %d minutes.", minutes];
    
    reminder.calendar = [_eventStore defaultCalendarForNewReminders];
    
    EKAlarm *alarm = [EKAlarm alarmWithAbsoluteDate:date];
    
    [reminder addAlarm:alarm];
    
    NSError *error = nil;
    
    [_eventStore saveReminder:reminder commit:YES error:&error];
    
    return YES;
}


- (void)postToFacebook {
    if([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]) {
        
        SLComposeViewController *controller = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
        
        [controller setInitialText:@"Easy way to get HSL timetables and stop locations!Check Commuter out."];
        [controller addURL:[NSURL URLWithString:@"http://itunes.com/apps/antenehseifu"]];
        [controller addImage:[UIImage imageNamed:@"appicon4.png"]];
        
        [self presentViewController:controller animated:YES completion:Nil];
        
    }else{
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Sorry"
                                                            message:@"You can't post to Facebook right now. Make sure your device has an internet connection and you have                               at least one Facebook account setup"
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        [alertView show];
    }
}

#pragma - mark IBActions
- (IBAction)hideButtonPressed:(id)sender {
    //[self toggleSearchViewHiddenAnimated:YES];
}
- (IBAction)centerCurrentLocationButtonPressed:(id)sender {
    [self centerMapRegionToCoordinate:self.currentUserLocation.coordinate];
}
- (IBAction)sendFeedBackButtonPressed:(id)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Your feedbacks and opinions are highly valued." delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Share on Facebook", @"Send Feature Request",@"Send FeedBack",@"Rate In AppStore", nil];
    //actionSheet.tintColor = SYSTEM_GRAY_COLOR;
    actionSheet.tag = 1001;
    [actionSheet showInView:self.view];
}

- (IBAction)listNearbyStopsPressed:(id)sender {
    if (searchResultsView.hidden) {
        [self listNearByStops];
//        [listNearbyStops setImage:[UIImage imageNamed:@"showMap-icon.png"] forState:UIControlStateNormal];
    }else{
        [self hideSearchResultView:YES animated:YES];
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
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSLog(@"You have pressed the %@ button", [actionSheet buttonTitleAtIndex:buttonIndex]);
    if (actionSheet.tag == 1001) {
        switch (buttonIndex) {
            case 0:
                [self postToFacebook];
                [self.reittiDataManager setAppOpenCountValue:-30];
                break;
            case 1:
                [self sendEmailWithSubject:@"[Feature Request] - "];
                break;
            case 2:
                [self sendEmailWithSubject:@"[Feedback] - "];
                break;
            case 3:
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"itms-apps://itunes.apple.com/app/id861274235"]];
                [self.reittiDataManager setAppOpenCountValue:-30];
                break;
            default:
                break;
        }
        
        if (buttonIndex == 0) {
            
        }

    }else{
        switch (buttonIndex) {
            case 0:
                [self setReminderWithMinOffset:1 andHourString:timeToSetAlarm];
                break;
            case 1:
                [self setReminderWithMinOffset:5 andHourString:timeToSetAlarm];
                break;
            case 2:
                [self setReminderWithMinOffset:10 andHourString:timeToSetAlarm];
                break;
            case 3:
                [self setReminderWithMinOffset:15 andHourString:timeToSetAlarm];
                break;
            case 4:
                [self setReminderWithMinOffset:30 andHourString:timeToSetAlarm];
                break;
            default:
                break;
        }
    }    
}


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

-(IBAction)blurViewGestureDetected:(UIGestureRecognizer *)sender{
    self.searchViewHidden = NO;
}

-(IBAction)stopViewGestureDetected:(id)sender{
    [self.view endEditing:YES];
    [self moveStopViewByPoint:CGPointMake(0, 20) animated:YES];
}

-(IBAction)searchResultViewGestureDetected:(id)sender{
    [self.view endEditing:YES];
    [self moveSearchResultViewByPoint:CGPointMake(0, 20) animated:YES];
}

-(IBAction)dragStopView:(UIPanGestureRecognizer *)recognizer {
    
    CGPoint translation = [recognizer translationInView:self.view];
    if ((recognizer.view.frame.origin.y + translation.y) > ([self searchViewLowerBound] - 20)  ) {
        recognizer.view.center = CGPointMake(recognizer.view.center.x,
                                             recognizer.view.center.y + translation.y);
    }
    if (recognizer.state != UIGestureRecognizerStateEnded){
        stopViewDragedDown = translation.y > 0;
    }
    
    [recognizer setTranslation:CGPointMake(0, 0) inView:self.view];
    
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        if (recognizer.view.frame.origin.y > ([self searchViewLowerBound] + (recognizer.view.frame.size.height / 3)) && stopViewDragedDown) {
            if (recognizer.view.tag == 0) {
                [self hideStopView:YES animated:YES];
            }else{
                [self hideSearchResultView:YES animated:YES];
            }
        }else{
            if (recognizer.view.tag == 0) {
                [self hideStopView:NO animated:YES];
            }else{
                [self hideSearchResultView:NO animated:YES];
            }
        }
    }
}

- (IBAction)openBookmarkedButtonPressed:(id)sender {
    
}

- (IBAction)seeFullTimeTablePressed:(id)sender {
    NSURL *url = [NSURL URLWithString:self._busStop.timetable_link];
    
    if (![[UIApplication sharedApplication] openURL:url])
        
        NSLog(@"%@%@",@"Failed to open url:",[url description]);
}
- (IBAction)reloadButtonPressed:(id)sender{
    self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"Refreshing Departures ..."];
    if (_busStop != nil) {
        [self requestStopInfoAsyncForCode:[NSString stringWithFormat:@"%d", [_busStop.code intValue]]];
    }
    justReloading = YES;
}
- (IBAction)saveStopToBookmarks {
    [self.reittiDataManager saveToCoreDataStop:self._busStop withLines:self._stopLinesDetail];
    //addBookmarkButton.hidden = YES;
    //[self showNotificationWithMessage:@"Bookmark added successfully!" messageType:RNotificationTypeConfirmation forSeconds:5 keppingSearchView:YES];
}

- (IBAction)closeStopViewButtonPressed:(id)sender {
    [self hideStopView:YES animated:YES];
}
- (IBAction)hideSearchResultViewPressed:(id)sender {
    [self hideSearchResultView:YES animated:YES];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    // Return YES so the pan gesture of the containing table view is not cancelled by the long press recognizer
    return YES;
}


#pragma - mark RettiDataManager Delegate methods
-(void)stopFetchDidComplete:(NSArray *)stopList{
    if (stopList != nil) {
        self.searchedStopList = stopList;
        [self displayStopView:self.searchedStopList];
    }else{
        [self showNotificationWithMessage:@"Sorry. No stop found by that search term." messageType:RNotificationTypeWarning forSeconds:5 keppingSearchView:YES];
    }
    
    
    //[MBProgressHUD hideHUDForView:self.view animated:YES];
    [SVProgressHUD dismiss];
}

-(void)stopFetchDidFail:(NSString *)error{
    [self showNotificationWithMessage:error messageType:RNotificationTypeWarning forSeconds:5 keppingSearchView:YES];
    //[MBProgressHUD hideHUDForView:self.view animated:YES];
    [SVProgressHUD dismiss];
    [self.refreshControl endRefreshing];
}

- (void)nearByStopFetchDidComplete:(NSArray *)stopList{
    self.nearByStopList = stopList;
    [self plotStopAnnotations:self.nearByStopList];
    if (requestedForListing) {
        [self displayNearByStopsList:stopList];
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
            }
            
            [self showNotificationWithMessage:error messageType:RNotificationTypeInfo forSeconds:5 keppingSearchView:YES];
        }
        
        requestedForListing = NO;
    }
    
    [SVProgressHUD dismiss];
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
    [self hideSearchResultView:YES animated:YES];
    [self centerMapRegionToCoordinate:[ReittiStringFormatter convertStringTo2DCoord:stopEntity.busStopCoords]];
    [self plotStopAnnotation:[reittiDataManager castStopEntityToBusStopShort:stopEntity] withSelect:YES];
}
- (void)searchResultSelectedAGeoCode:(GeoCode *)geoCode{
    [self hideSearchResultView:YES animated:YES];
    [self centerMapRegionToCoordinate:[ReittiStringFormatter convertStringTo2DCoord:geoCode.coords]];
    //Check if it is type busstop
    if (geoCode.getLocationType == LocationTypeStop) {
        //Convert GeoCode to busStopShort
        [self plotStopAnnotation:[reittiDataManager castStopGeoCodeToBusStopShort:geoCode] withSelect:YES];
        
    }else{
        [self plotGeoCodeAnnotation:geoCode];
    }
}
- (void)searchViewControllerWillBeDismissed:(NSString *)prevSearchTerm{
    mainSearchBar.text = prevSearchTerm;
}
- (void)searchResultSelectedCurrentLocation{
    
}

#pragma mark - Bookmarks view delegate

- (void)savedStopSelected:(NSNumber *)code fromMode:(int)mode{
    bookmarkViewMode = mode;
    [self hideStopView:YES animated:NO];
    [self requestStopInfoAsyncForCode:[NSString stringWithFormat:@"%d", [code intValue]]];
    [self showProgressHUD];
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
        
        bookmarksViewController.savedStops = [NSMutableArray arrayWithArray:savedStops];
        bookmarksViewController.savedRoutes = [NSMutableArray arrayWithArray:savedRoutes];
        bookmarksViewController.recentStops = [NSMutableArray arrayWithArray:recentStops];
        bookmarksViewController.recentRoutes = [NSMutableArray arrayWithArray:recentRoutes];
        bookmarksViewController.darkMode = self.darkMode;
        bookmarksViewController.delegate = self;
        bookmarksViewController.mode = bookmarkViewMode;
        bookmarksViewController.reittiDataManager = [[RettiDataManager alloc] initWithManagedObjectContext:self.managedObjectContext];
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
        UINavigationController *navigationController = (UINavigationController *)segue.destinationViewController;
        StopViewController *stopViewController =[[navigationController viewControllers] lastObject];
        
        if ([segue.identifier isEqualToString:@"openNearbyStop"]) {
            NSIndexPath *selectedRowIndexPath = [searchResultsTable indexPathForSelectedRow];
            
            BusStopShort *selected = [self.nearByStopList objectAtIndex:selectedRowIndexPath.row];
            
            stopViewController.stopCode = [NSString stringWithFormat:@"%d", [selected.code intValue]];
        }else{
            stopViewController.stopCode = selectedStopCode;
        }
        
        stopViewController.darkMode = self.darkMode;
        stopViewController.reittiDataManager = [[RettiDataManager alloc] initWithManagedObjectContext:self.managedObjectContext];
//        stopViewController.reittiDataManager = self.reittiDataManager;
        
    }
    if ([segue.identifier isEqualToString:@"addressSearchController"]) {
        UINavigationController *navigationController = (UINavigationController *)segue.destinationViewController;
        AddressSearchViewController *addressSearchViewController = [[navigationController viewControllers] lastObject];
        
        NSArray * savedStops = [self.reittiDataManager fetchAllSavedStopsFromCoreData];
        NSArray * savedRoutes = [self.reittiDataManager fetchAllSavedRoutesFromCoreData];
        NSArray * recentStops = [self.reittiDataManager fetchAllSavedStopHistoryFromCoreData];
        NSArray * recentRoutes = [self.reittiDataManager fetchAllSavedRouteHistoryFromCoreData];
        
        addressSearchViewController.savedStops = [NSMutableArray arrayWithArray:savedStops];
        addressSearchViewController.recentStops = [NSMutableArray arrayWithArray:recentStops];
        addressSearchViewController.savedRoutes = [NSMutableArray arrayWithArray:savedRoutes];
        addressSearchViewController.recentRoutes = [NSMutableArray arrayWithArray:recentRoutes];
        addressSearchViewController.routeSearchMode = NO;
        addressSearchViewController.darkMode = self.darkMode;
        addressSearchViewController.prevSearchTerm = mainSearchBar.text;
        addressSearchViewController.delegate = self;
        addressSearchViewController.reittiDataManager = [[RettiDataManager alloc] initWithManagedObjectContext:self.managedObjectContext];
//        addressSearchViewController.reittiDataManager = self.reittiDataManager;
    }
    if ([segue.identifier isEqualToString:@"routeSearchController"] || [segue.identifier isEqualToString:@"switchToRouteSearch"]) {
        UINavigationController *navigationController = (UINavigationController *)segue.destinationViewController;
        RouteSearchViewController *routeSearchViewController = [[navigationController viewControllers] lastObject];
        
        NSArray * savedStops = [self.reittiDataManager fetchAllSavedStopsFromCoreData];
        NSArray * recentStops = [self.reittiDataManager fetchAllSavedStopHistoryFromCoreData];
        
        routeSearchViewController.savedStops = [NSMutableArray arrayWithArray:savedStops];
        routeSearchViewController.recentStops = [NSMutableArray arrayWithArray:recentStops];
        routeSearchViewController.darkMode = self.darkMode;
        
        if ([segue.identifier isEqualToString:@"routeSearchController"]) {
            routeSearchViewController.prevToLocation = selectedAnnotationUniqeName;
            routeSearchViewController.prevToCoords = selectedAnnotationCoords;
        }
        
//        routeSearchViewController.locationManager = locationManager;
        
        //routeSearchViewController.delegate = self;
        routeSearchViewController.reittiDataManager = [[RettiDataManager alloc] initWithManagedObjectContext:self.managedObjectContext];
//        routeSearchViewController.reittiDataManager = self.reittiDataManager;
    }
    if ([segue.identifier isEqualToString:@"infoViewSegue"]) {
        UINavigationController *navController = (UINavigationController *)[segue destinationViewController];
        InfoViewController *infoViewController = [[navController viewControllers] lastObject];
        
        infoViewController.disruptionsList = self.disruptionList;
        infoViewController.reittiDataManager = [[RettiDataManager alloc] initWithManagedObjectContext:self.managedObjectContext];
    }
}

#pragma - mark MemoryWarning
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
