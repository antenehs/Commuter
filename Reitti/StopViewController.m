//
//  StopViewController.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 19/1/14.
//  Copyright (c) 2014 Anteneh Sahledengel. All rights reserved.
//

#import "StopViewController.h"
#import "WebViewController.h"
#import "MyFixedLayoutGuide.h"
#import "SVProgressHUD.h"
#import "MBProgressHUD.h"
#import "RouteSearchViewController.h"
#import "SearchController.h"
#import "UIScrollView+APParallaxHeader.h"
#import "AppManager.h"
#import "ASA_Helpers.h"
#import "CacheManager.h"

@interface StopViewController ()

@property (nonatomic) NSArray<id<UIPreviewActionItem>> *previewActions;

@end

@implementation StopViewController

#define CUSTOME_FONT(s) [UIFont fontWithName:@"Aspergit" size:s]
#define CUSTOME_FONT_BOLD(s) [UIFont fontWithName:@"AspergitBold" size:s]
#define CUSTOME_FONT_LIGHT(s) [UIFont fontWithName:@"AspergitLight" size:s]

#define SYSTEM_GRAY_COLOR [UIColor colorWithWhite:0.1 alpha:1]
#define SYSTEM_GREEN_COLOR [UIColor colorWithRed:39.0/255.0 green:174.0/255.0 blue:96.0/255.0 alpha:1.0];

//@synthesize StopView;
@synthesize modalMode;
@synthesize departures, _busStop, stopEntity;
@synthesize reittiDataManager, settingsManager, reittiReminderManager;
@synthesize stopCode, stopShortCode, stopName, stopCoords;
@synthesize managedObjectContext;
@synthesize backButtonText;
@synthesize delegate;
@synthesize refreshControl;
//@synthesize droppedPinGeoCode;

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
    [self initDataManagerIfNull];
    
    stopFetched = NO;
    stopDetailRequested = NO;
    
    stopBookmarked = NO;
    departuresTableIndex = nil;
    pressTime = 0;
    
    modalMode = [NSNumber numberWithBool:NO];
    
//    [self.navigationController setNavigationBarHidden:YES animated:NO];
    [self.navigationController setToolbarHidden:YES animated:NO];
    if (modalMode != nil && ![modalMode boolValue]) {
        self.navigationItem.leftBarButtonItem = nil;
    }
    
    if (settingsManager == nil) {
        settingsManager = [[SettingsManager alloc] initWithDataManager:self.reittiDataManager];
    }
    
//    self.reittiDataManager.delegate = self;
    [self.reittiDataManager setUserLocationToRegion:[settingsManager userLocation]];
    
    [self setNeedsStatusBarAppearanceUpdate];
    
    mapView = [[MKMapView alloc] init];
    mapView.delegate = self;
    
//    [self setStopViewApearance];
    [self initNotifications];
    
    [self setUpMainView];
//    [self setUpLoadingView];
    //    [SVProgressHUD showHUDInView:self.view];
    
    [self requestStopInfoAsyncForCode:stopCode andCoords:stopCoords];
}

-(void)viewDidAppear:(BOOL)animated{
    [self setUpMapViewForBusStop];
    [self.navigationController setToolbarHidden:YES animated:NO];
//    [self layoutAnimated:NO];
    self.activityIndicator.hidden = NO;
    
    //Done like this because some how when peeked with 3d it didn't work
    if (stopDetailRequested) {
        [self.activityIndicator beginRefreshing];
    }
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self setUpMapViewForBusStop];
    [departuresTable reloadData];
}

- (id<UILayoutSupport>)topLayoutGuide {
    return [[MyFixedLayoutGuide alloc] initWithLength:topBarView.frame.size.height];
}

- (id<UILayoutSupport>)bottomLayoutGuide {
    return [[MyFixedLayoutGuide alloc] initWithLength:-bottomBarView.frame.origin.y];
}


#pragma mark - initialization
- (void)initDataManagerIfNull {
    // Do any additional setup after loading the view.
    
    if (self.reittiDataManager == nil) {
        
        self.reittiDataManager = [[RettiDataManager alloc] initWithManagedObjectContext:self.managedObjectContext];
    }
}

#pragma mark - View methods
-(void)setUpLoadingView{
//    [activityView startAnimating];
//    [SVProgressHUD showHUDInView:self.view];
    [self.activityIndicator beginRefreshing];
//    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    stopView.hidden = YES;
}

-(void)setUpMainView{
    
    if ([stopShortCode isEqualToString:@""] || stopShortCode == nil) {
        [stopViewTitle setText:stopName];
        [stopViewSubTitle setText:@""];
    }else{
        [stopViewTitle setText:stopShortCode];
        [stopViewSubTitle setText:stopName];
    }
    
    bookmarkButton.enabled = NO;
    
    departuresTable.backgroundColor = [UIColor clearColor];
    
    topToolBar.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    topToolBar.layer.borderWidth = 0.5;
    
    [self setUpMapViewForBusStop];
    
    [departuresTable reloadData];
    [departuresTable scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
}

- (void)setUpMapViewForBusStop{
    [mapView setFrame:CGRectMake(0, 0, self.view.frame.size.width, 160)];
    
    [self centerMapRegionToCoordinate:stopCoords];
    [self plotStopAnnotation];
    
    [departuresTable addParallaxWithView:mapView andHeight:160];
}

//This method is called after the busStop object is fetched
-(void)setUpStopViewForBusStop:(BusStop *)busStop{
    
    self.departures = busStop.departures;
    self._busStop = busStop;
    
    //Update title  and subttile
    [stopViewTitle setText:self._busStop.code_short];
    [stopViewSubTitle setText:self._busStop.name_fi];
    
    bookmarkButton.enabled = YES;
    
    if ([self.reittiDataManager isBusStopSaved:self._busStop]) {
        [self setStopBookmarkedState];
    }else{
        [self setStopNotBookmarkedState];
    }
    
    [self setUpMapViewForBusStop];
    
    [departuresTable reloadData];
    [departuresTable scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
    
    self.view.backgroundColor = [UIColor whiteColor];
    stopView.hidden = NO;
    fullTimeTableButton.enabled = busStop.timetable_link != nil;
    
    //    [activityView stopAnimating];
//    [SVProgressHUD dismissFromView:self.view];
    [self.activityIndicator endRefreshing];
    //    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    //    [self.navigationController setToolbarHidden:NO animated:YES];
}

- (void)initNotifications{
    reittiReminderManager = [ReittiRemindersManager sharedManger];
}

#pragma mark - ibactions
- (IBAction)BackButtonPressed:(id)sender {
//    [SVProgressHUD dismiss];
    [self dismissViewControllerAnimated:YES completion:nil ];
}

- (IBAction)BookmarkButtonPressed:(id)sender {
    if (stopBookmarked) {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Are you sure you want to delete your bookmark?" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Delete" otherButtonTitles:nil];
        actionSheet.tag = 1001;
        [actionSheet showInView:self.view];
        
    }else{
        [self.reittiDataManager saveToCoreDataStop:self._busStop];
        
        [self setStopBookmarkedState];
        [delegate savedStop:self.stopEntity];
    }
}

- (IBAction)showMapViewButtonPressed:(id)sender {
    departuresTableViewContainer.hidden = !departuresTableViewContainer.hidden;
    if (departuresTableViewContainer.hidden) {
        [showLocationBarButtonItem setTitle:@"Show departures"];
    }else{
        [showLocationBarButtonItem setTitle:@"Show on map"];
    }
    [self startTimer];
}

- (IBAction)hideMapViewButtonPressed:(id)sender {
    departuresTableViewContainer.hidden = NO;
//    NSLog(@"Time is %d", pressTime);
    if (pressTime < 1) {
        pressingInfoLabel.hidden = NO;
    }else{
        pressingInfoLabel.hidden = YES;
    }
    pressTime = 0;
    [timer invalidate];
}

-(IBAction)showFullTimeTable:(id)sender{
    [self performSegueWithIdentifier:@"seeFullTimeTable" sender:self];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSLog(@"You have pressed the %@ button", [actionSheet buttonTitleAtIndex:buttonIndex]);
    if (actionSheet.tag == 1001) {
        if (buttonIndex == 0) {
            
            [self setStopNotBookmarkedState];
            [self.reittiDataManager deleteSavedStopForCode:self._busStop.code];
            [delegate deletedSavedStop:self.stopEntity];
        }
    }else{
        switch (buttonIndex) {
            case 0:
                [[ReittiRemindersManager sharedManger] setNotificationWithMinOffset:1 andTime:timeToSetAlarm];
                break;
            case 1:
                [[ReittiRemindersManager sharedManger] setNotificationWithMinOffset:5 andTime:timeToSetAlarm];
                break;
            case 2:
                [[ReittiRemindersManager sharedManger] setNotificationWithMinOffset:10 andTime:timeToSetAlarm];
                break;
            case 3:
                [[ReittiRemindersManager sharedManger] setNotificationWithMinOffset:15 andTime:timeToSetAlarm];
                break;
            case 4:
                [[ReittiRemindersManager sharedManger] setNotificationWithMinOffset:30 andTime:timeToSetAlarm];
                break;
            default:
                break;
        }
    }
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag == 1005){
        if (buttonIndex == 1) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
        }
    }
}

#pragma mark - Peek and Pop actions support
- (NSArray<id<UIPreviewActionItem>> *)previewActionItems {
    return self.previewActions;
}

- (NSArray<id<UIPreviewActionItem>> *)previewActions {
    if (_previewActions == nil) {
        
        UIPreviewAction *printAction = [UIPreviewAction
                                        actionWithTitle:stopBookmarked ? @"UnBookmark Stop" : @"Bookmark Stop"
                                        style:UIPreviewActionStyleDefault
                                        handler:^(UIPreviewAction * _Nonnull action,
                                                  UIViewController * _Nonnull previewViewController) {
                                            StopViewController *viewController = (StopViewController *)previewViewController;
                                            [viewController BookmarkButtonPressed:self];
                                        }];
        _previewActions = @[printAction];
    }
    return _previewActions;
}

#pragma mark - mapView methods
-(BOOL)centerMapRegionToCoordinate:(CLLocationCoordinate2D)coordinate{
    
    BOOL toReturn = YES;
    
//    CLLocationCoordinate2D coord = {.latitude =  60.1733239, .longitude =  24.9410248};
    MKCoordinateSpan span = {.latitudeDelta =  0.005, .longitudeDelta =  0.005};
    MKCoordinateRegion region = {coordinate, span};
    
    [mapView setRegion:region animated:YES];
    
    return toReturn;
}

-(void)plotStopAnnotation{
  
//    CLLocationCoordinate2D coordinate = stopCoords;
    
    NSString * name = stopCode;
    NSString * shortCode = stopCode;
    
    StopAnnotation *newAnnotation = [[StopAnnotation alloc] initWithTitle:shortCode andSubtitle:name andCoordinate:stopCoords];
    newAnnotation.code = @111111;
    
    [mapView addAnnotation:newAnnotation];
    
}

- (MKAnnotationView *)mapView:(MKMapView *)_mapView viewForAnnotation:(id <MKAnnotation>)annotation {
    static NSString *selectedIdentifier = @"selectedLocation";
    if ([annotation isKindOfClass:[StopAnnotation class]]) {
        MKAnnotationView *annotationView = (MKAnnotationView *) [_mapView dequeueReusableAnnotationViewWithIdentifier:selectedIdentifier];
        if (annotationView == nil) {
            annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:selectedIdentifier];
            annotationView.enabled = YES;
            StaticStop *sStop = [[CacheManager sharedManager] getStopForCode:stopCode];
            if (sStop != nil) {
                annotationView.image = [AppManager stopAnnotationImageForStopType:sStop.reittiStopType];
            }else{
                annotationView.image = [AppManager stopAnnotationImageForStopType:StopTypeBus];
            }
            
            [annotationView setFrame:CGRectMake(0, 0, 30, 42)];
            annotationView.centerOffset = CGPointMake(0,-21);
            
        } else {
            annotationView.annotation = annotation;
        }
        
        return annotationView;
    }
    
    return nil;
}

#pragma mark - reminder methods
- (void)setStopBookmarkedState{
    [bookmarkButton setImage:[UIImage imageNamed:@"star-filled-white-100.png"] forState:UIControlStateNormal];
    [bookmarkButton asa_bounceAnimateViewByScale:0.2];
    stopBookmarked = YES;
}

- (void)setStopNotBookmarkedState{
    [bookmarkButton setImage:[UIImage imageNamed:@"star-line-white-100.png"] forState:UIControlStateNormal];
    stopBookmarked = NO;
}

- (IBAction)seeFullTimeTablePressed:(id)sender {
    NSURL *url = [NSURL URLWithString:self._busStop.timetable_link];
    
    if (![[UIApplication sharedApplication] openURL:url])
        
        NSLog(@"%@%@",@"Failed to open url:",[url description]);
}

- (void)requestStopInfoAsyncForCode:(NSString *)code andCoords:(CLLocationCoordinate2D)coords{
    stopDetailRequested = YES;
    [self.reittiDataManager fetchStopsForCode:code andCoords:coords withCompletionBlock:^(BusStop * stop, NSString * error){
        if (!error) {
            [self stopFetchDidComplete:stop];
        }else{
            [self stopFetchDidFail:error];
        }
        stopDetailRequested = NO;
    }];
}

- (IBAction)reloadButtonPressed:(id)sender{
    if (_busStop != nil) {
        [self requestStopInfoAsyncForCode:[NSString stringWithFormat:@"%d", [_busStop.code intValue]]
                                andCoords:[ReittiStringFormatter convertStringTo2DCoord:_busStop.coords]];
    }
}

#pragma mark - Table view delegate methods

- (void)initRefreshControl{
    
    UITableViewController *tableViewController = [[UITableViewController alloc] init];
    tableViewController.tableView = departuresTable;
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(reloadButtonPressed:) forControlEvents:UIControlEventValueChanged];
//    self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"Pull to Refresh Departures"];
    tableViewController.refreshControl = self.refreshControl;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.departures.count > 0) {
        return self.departures.count;
    }else{
        return stopFetched ? 1 : 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
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
    
    
    if (self.departures.count > 0) {
        StopDeparture *departure = [self.departures objectAtIndex:indexPath.row];
        
        @try {
            UILabel *timeLabel = (UILabel *)[cell viewWithTag:1001];
//            NSString *notFormattedTime = departure.time ;
//            NSString *timeString = [ReittiStringFormatter formatHSLAPITimeWithColon:notFormattedTime];
//            NSDate *date = [ReittiStringFormatter createDateFromString:timeString withMinOffset:0];
            
            NSString *formattedHour = [ReittiStringFormatter formatHourStringFromDate:departure.parsedDate];
            
            if ([departure.parsedDate timeIntervalSinceNow] < 300) {
                timeLabel.attributedText = [ReittiStringFormatter highlightSubstringInString:formattedHour
                                                                                           substring:formattedHour
                                                                                      withNormalFont:timeLabel.font];
                ;
            }else{
                timeLabel.text = formattedHour;
            }
            
            UILabel *codeLabel = (UILabel *)[cell viewWithTag:1003];
            
//            if (([settingsManager userLocation] != HSLRegion)) {
//                lineName = [departure objectForKey:@"code"];
//            }else{
//                if (_stopLinesDetail != nil) {
//                    lineName = [_stopLineNames objectForKey:[departure objectForKey:@"code"]];
//                }else{
//                    NSString *notParsedCode = [departure objectForKey:@"code"];
//                    lineName = [ReittiStringFormatter parseBusNumFromLineCode:notParsedCode];
//                }
//            }
//            
//            if (lineName == nil) {
//                lineName = [departure objectForKey:@"code"];
//            }
            
            
            
            codeLabel.text = departure.code;
            
            UILabel *destinationLabel = (UILabel *)[cell viewWithTag:1004];
            destinationLabel.text = departure.destination;
            //Destination is available in TRE api. Check for it first
//            if ([departure objectForKey:@"name1"] != nil) {
//                destinationLabel.text = [departure objectForKey:@"name1"];
//            }else{
//                if (_stopLinesDetail != nil) {
//                    destinationLabel.text = [_stopLinesDetail objectForKey:[departure objectForKey:@"code"]];
//                    //destinationLabel.font = CUSTOME_FONT_BOLD(16.0f);
//                }else{
//                    destinationLabel.text = @"";
//                }
//            }
        }
        @catch (NSException *exception) {
            if (self.departures.count == 1) {
                UITableViewCell *infoCell = [tableView dequeueReusableCellWithIdentifier:@"infoCell"];
                infoCell.backgroundColor = [UIColor clearColor];
                return infoCell;
            }
        }
        @finally {
//            NSLog(@"finally");
        }
    }else{
        cell = [tableView dequeueReusableCellWithIdentifier:@"infoCell"];
        cell.backgroundColor = [UIColor clearColor];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        
        return cell;
    }
    
    [cell setCellHeight:56];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    cell.backgroundColor = [UIColor clearColor];
    return cell;

}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 30;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 30)];
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 110, 30)];
    titleLabel.font = [titleLabel.font fontWithSize:14];
    titleLabel.textColor = [UIColor darkGrayColor];
    titleLabel.adjustsFontSizeToFitWidth = YES;
    if (section == 0) {
        titleLabel.text = @"   DEPARTURES";
    }
    [view addSubview:titleLabel];
    
    fullTimeTableButton = [UIButton buttonWithType:UIButtonTypeSystem];
    fullTimeTableButton.frame = CGRectMake(self.view.frame.size.width - 107, 0, 100, 30);
    [fullTimeTableButton setTitle:@"Full timetable" forState:UIControlStateNormal];
    [fullTimeTableButton setTintColor:[AppManager systemOrangeColor]];
    [fullTimeTableButton addTarget:self action:@selector(showFullTimeTable:) forControlEvents:UIControlEventTouchUpInside];
    
    fullTimeTableButton.enabled = stopFetched;
    
    [view addSubview:fullTimeTableButton];
    
    UIView *topLineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1000, 1)];
    topLineView.backgroundColor = [AppManager systemGreenColor];
    
    [view addSubview:topLineView];
    view.backgroundColor = [UIColor colorWithWhite:1 alpha:1];
    
    return view;
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    CustomeTableViewCell *cell = (CustomeTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    if (cell != nil) {
        if ([cell isKindOfClass:[CustomeTableViewCell class]]) {
            [cell showUtilityButtonsAnimated:YES];
        }
    }
}

- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerLeftUtilityButtonWithIndex:(NSInteger)index {
    UIActionSheet *actionSheet;
    switch (index) {
        case 0:{
            actionSheet = [[UIActionSheet alloc] initWithTitle:@"When do you want to be reminded." delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"1 min before", @"5 min before",@"10 min before",@"15 min before", @"30 min before", nil];
            //actionSheet.tintColor = SYSTEM_GRAY_COLOR;
            actionSheet.tag = 2001;
            [actionSheet showInView:self.view];
            StopDeparture *departure = [self.departures objectAtIndex:[[departuresTable indexPathForCell:cell] row]];
//            NSString *notFormattedTime = [NSString stringWithFormat:@"%d" ,[(NSNumber *)[departure objectForKey:@"time"] intValue]];
            timeToSetAlarm = departure.parsedDate;
//            timeToSetAlarm = [(UILabel *)[cell viewWithTag:1001] text];
            [cell hideUtilityButtonsAnimated:YES];
        }
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

#pragma mark - timer methods
- (void) startTimer {
    timer = [NSTimer scheduledTimerWithTimeInterval:0.1
                                     target:self
                                   selector:@selector(tick:)
                                   userInfo:nil
                                    repeats:YES];
}

- (void) tick:(NSTimer *) timer {
    //do something here..
    pressTime ++;
}

#pragma - mark RettiDataManager Delegate methods
-(void)stopFetchDidComplete:(BusStop *)stop{
    stopFetched = YES;
    if (stop != nil) {
        self._busStop = stop;
        [self.reittiDataManager saveHistoryToCoreDataStop:self._busStop];
        
        [self setUpStopViewForBusStop:self._busStop];
    }
}

-(void)stopFetchDidFail:(NSString *)error{
    stopFetched = YES;
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:error                                                                                      message:nil
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
    [alertView show];
    
    [self dismissViewControllerAnimated:YES completion:nil ];
}

#pragma mark - iAd methods
-(void)initAdBannerView{
    if ([ADBannerView instancesRespondToSelector:@selector(initWithAdType:)]) {
        _bannerView = [[ADBannerView alloc] initWithAdType:ADAdTypeBanner];
    } else {
        _bannerView = [[ADBannerView alloc] init];
    }
    _bannerView.delegate = self;
    
    CGRect bannerFrame = _bannerView.frame;
    bannerFrame.origin.y = self.view.bounds.size.height;
    _bannerView.frame = bannerFrame;
    
    [self.view addSubview:_bannerView];
}

- (void)layoutAnimated:(BOOL)animated
{
    // As of iOS 6.0, the banner will automatically resize itself based on its width.
    // To support iOS 5.0 however, we continue to set the currentContentSizeIdentifier appropriately.
    CGRect contentFrame = self.view.bounds;
    
    CGRect bannerFrame = _bannerView.frame;
    bannerFrame.origin.y = contentFrame.size.height;
    _bannerView.frame = bannerFrame;
    if (_bannerView.bannerLoaded) {
        contentFrame.size.height -= _bannerView.frame.size.height + self.navigationController.toolbar.frame.size.height;
        bannerFrame.origin.y = contentFrame.size.height;
    } else {
        bannerFrame.origin.y = contentFrame.size.height;
    }
    
    [UIView animateWithDuration:animated ? 0.25 : 0.0 animations:^{
        //cardView.frame = contentFrame;
        _bannerView.frame = bannerFrame;
    }];
}
- (void)bannerViewDidLoadAd:(ADBannerView *)banner
{
    [self layoutAnimated:YES];
}

- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error
{
    [self layoutAnimated:YES];
}

- (BOOL)bannerViewActionShouldBegin:(ADBannerView *)banner willLeaveApplication:(BOOL)willLeave
{
    return YES ;
}

- (void)bannerViewActionDidFinish:(ADBannerView *)banner
{
    
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
    
    if ([segue.identifier isEqualToString:@"routeToHere"] || [segue.identifier isEqualToString:@"routeFromHere"]) {
        UINavigationController * navigationController = (UINavigationController *)[segue destinationViewController];
        
        RouteSearchViewController *routeSearchViewController = (RouteSearchViewController *)[navigationController.viewControllers lastObject];
        
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
//        routeSearchViewController.droppedPinGeoCode = self.droppedPinGeoCode;
        
        if ([segue.identifier isEqualToString:@"routeToHere"]) {
            routeSearchViewController.prevToLocation = self.stopName;
            routeSearchViewController.prevToCoords = [NSString stringWithFormat:@"%f,%f",self.stopCoords.longitude, self.stopCoords.latitude];
        }
        if ([segue.identifier isEqualToString:@"routeFromHere"]) {
            routeSearchViewController.prevFromLocation = self.stopName;
            routeSearchViewController.prevFromCoords = [NSString stringWithFormat:@"%f,%f",self.stopCoords.longitude, self.stopCoords.latitude];
        }
        
        routeSearchViewController.reittiDataManager = self.reittiDataManager;
        //        routeSearchViewController.reittiDataManager = self.reittiDataManager;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    NSLog(@"StopViewController:This bitchass ARC deleted my UIView.");
}

@end
