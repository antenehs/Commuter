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

@implementation StopViewController

#define CUSTOME_FONT(s) [UIFont fontWithName:@"Aspergit" size:s]
#define CUSTOME_FONT_BOLD(s) [UIFont fontWithName:@"AspergitBold" size:s]
#define CUSTOME_FONT_LIGHT(s) [UIFont fontWithName:@"AspergitLight" size:s]

#define SYSTEM_GRAY_COLOR [UIColor colorWithWhite:0.1 alpha:1]
#define SYSTEM_GREEN_COLOR [UIColor colorWithRed:39.0/255.0 green:174.0/255.0 blue:96.0/255.0 alpha:1.0];

//@synthesize StopView;
@synthesize departures, _busStop, stopEntity;
@synthesize _stopLinesDetail;
@synthesize reittiDataManager;
@synthesize stopCode;
@synthesize managedObjectContext;
@synthesize backButtonText;
@synthesize delegate;
@synthesize refreshControl;
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
    
    stopBookmarked = NO;
    departuresTableIndex = nil;
    pressTime = 0;
    
    [self setNeedsStatusBarAppearanceUpdate];
    self.reittiDataManager.delegate = self;
    [self selectSystemColors];
    [self setUpLoadingView];
    [self setStopViewApearance];
    [self requestStopInfoAsyncForCode:stopCode];
    [self initNotifications];
   
}

- (id<UILayoutSupport>)topLayoutGuide {
    return [[MyFixedLayoutGuide alloc] initWithLength:topBarView.frame.size.height];
}

- (id<UILayoutSupport>)bottomLayoutGuide {
    return [[MyFixedLayoutGuide alloc] initWithLength:-bottomBarView.frame.origin.y];
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    if (darkMode) {
        return UIStatusBarStyleLightContent;
    }else{
        return UIStatusBarStyleDefault;
    }    
}

#pragma mark - View methods
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
-(void)setUpLoadingView{
    [activityView startAnimating];
    stopView.hidden = YES;
}

-(void)setUpMainView{
    self.view.backgroundColor = [UIColor whiteColor];
    stopView.hidden = NO;
    [activityView stopAnimating];
    
    if ([self.reittiDataManager isBusStopSaved:self._busStop]) {
        [self setStopBookmarkedState];
    }else{
        [self setStopNotBookmarkedState];
    }
}

- (void)setStopViewApearance{
    
    [stopView setBlurTintColor:systemBackgroundColor];
    [topBarView setBlurTintColor:systemBackgroundColor];
    topBarView.alpha = 0.95;
    [bottomBarView setBlurTintColor:systemBackgroundColor];
    bottomBarView.alpha = 0.95;
    topBarView.layer.borderWidth = 0.5;
    topBarView.layer.borderColor = [[UIColor blackColor] CGColor];
    bottomBarView.layer.borderWidth = 0.5;
    bottomBarView.layer.borderColor = [[UIColor blackColor] CGColor];
    if (backButtonText != nil) {
        [cancelButton setTitle:backButtonText forState:UIControlStateNormal];
    }
    cancelButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    
    CGRect dVFrame = departuresTableViewContainer.frame;
    CGRect dTFrame = departuresTable.frame;
    
    dVFrame.size.height = self.view.bounds.size.height - topBarView.frame.size.height - bottomBarView.frame.size.height;
    
    dTFrame.size.height = dVFrame.size.height;
    
    departuresTableViewContainer.frame = dVFrame;
    departuresTable.frame = dTFrame;
    
    CGRect botomFrame = bottomBarView.frame;
    
    bottomBarView.frame = CGRectMake(0, self.view.bounds.size.height - botomFrame.size.height, botomFrame.size.width, botomFrame.size.height);
}

- (void)initNotifications{
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

- (void)initMapViewForBusStop:(BusStop *)busStop{
    
    [self centerMapRegionToCoordinate:[ReittiStringFormatter convertStringTo2DCoord:busStop.coords]];
    [self plotStopAnnotation:busStop];
}

#pragma mark - ibactions

- (IBAction)BackButtonPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil ];
}

- (IBAction)BookmarkButtonPressed:(id)sender {
    if (stopBookmarked) {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Are you sure you want to delete your bookmark?" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Delete" otherButtonTitles:nil];
        actionSheet.tag = 1001;
        [actionSheet showInView:self.view];
        
    }else{
        self._stopLinesDetail = [RettiDataManager convertStopLinesArrayToDictionary:self._busStop.lines];
        [self.reittiDataManager saveToCoreDataStop:self._busStop withLines:self._stopLinesDetail];
        
        [self setStopBookmarkedState];
        [delegate savedStop:self.stopEntity];
    }
    
}

- (IBAction)showMapViewButtonPressed:(id)sender {
    departuresTableViewContainer.hidden = YES;
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

#pragma mark - mapView methods
-(BOOL)centerMapRegionToCoordinate:(CLLocationCoordinate2D)coordinate{
    
    BOOL toReturn = YES;
    
//    CLLocationCoordinate2D coord = {.latitude =  60.1733239, .longitude =  24.9410248};
    MKCoordinateSpan span = {.latitudeDelta =  0.01, .longitudeDelta =  0.01};
    MKCoordinateRegion region = {coordinate, span};
    
    [mapView setRegion:region animated:YES];
    
//    mapView.pitchEnabled = YES;
//    MKMapCamera *myCamera = [[MKMapCamera alloc] init];
//    myCamera.centerCoordinate = coordinate;
//    myCamera.pitch = 45;
//    myCamera.altitude = 700;
//    
//    [mapView setCamera:myCamera];
    
    return toReturn;
}

-(void)plotStopAnnotation:(BusStop *)stop{
  
    CLLocationCoordinate2D coordinate = [ReittiStringFormatter convertStringTo2DCoord:stop.coords];
    
    NSString * name = stop.name_fi;
    NSString * shortCode = stop.code_short;
    
    StopAnnotation *newAnnotation = [[StopAnnotation alloc] initWithTitle:shortCode andSubtitle:name andCoordinate:coordinate];
    newAnnotation.code = stop.code;
    
    [mapView addAnnotation:newAnnotation];
    
}

- (MKAnnotationView *)mapView:(MKMapView *)_mapView viewForAnnotation:(id <MKAnnotation>)annotation {
    static NSString *selectedIdentifier = @"selectedLocation";
    if ([annotation isKindOfClass:[StopAnnotation class]]) {
        MKAnnotationView *annotationView = (MKAnnotationView *) [_mapView dequeueReusableAnnotationViewWithIdentifier:selectedIdentifier];
        if (annotationView == nil) {
            annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:selectedIdentifier];
            annotationView.enabled = YES;
            annotationView.image = [UIImage imageNamed:@"busStopAnnotation.png"];
            [annotationView setFrame:CGRectMake(0, 0, 50, 54)];
            annotationView.centerOffset = CGPointMake(0,-27);
            
        } else {
            annotationView.annotation = annotation;
        }
        
        return annotationView;
    }
    
    return nil;
}

#pragma mark - reminder methods
-(void)setReminderWithMinOffset:(int)minute andHourString:(NSString *)timeString{
    EKAuthorizationStatus status = [EKEventStore authorizationStatusForEntityType:EKEntityTypeReminder];
    
    if (status == EKAuthorizationStatusAuthorized) {
        if ([self createEKReminderWithMinOffset:minute andHourString:timeString]) {
            //[self showNotificationWithMessage:@"Reminder set successfully!" messageType:RNotificationTypeConfirmation forSeconds:5 keppingSearchView:YES];
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Got it!"
                                                                message:@"You will be reminded."
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
            [alertView show];
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

- (void)setStopBookmarkedState{
    [bookmarkButton setImage:[UIImage imageNamed:@"star-orange-128.png"] forState:UIControlStateNormal];
    stopBookmarked = YES;
}

- (void)setStopNotBookmarkedState{
    [bookmarkButton setImage:[UIImage imageNamed:@"star-128.png"] forState:UIControlStateNormal];
    stopBookmarked = NO;
}

- (IBAction)seeFullTimeTablePressed:(id)sender {
    NSURL *url = [NSURL URLWithString:self._busStop.timetable_link];
    
    if (![[UIApplication sharedApplication] openURL:url])
        
        NSLog(@"%@%@",@"Failed to open url:",[url description]);
}

- (void)requestStopInfoAsyncForCode:(NSString *)code{
    
    [self.reittiDataManager fetchStopsForCode:code];
}

-(void)setUpStopViewForBusStop:(BusStop *)busStop{
//    departuresTableViewContainer.layer.borderWidth = 2;
    //  departuresTable.layer.cornerRadius = 10;
//    departuresTableViewContainer    .layer.borderColor = [[UIColor darkGrayColor] CGColor];
    
    self.departures = busStop.departures;
    self._busStop = busStop;
    self._stopLinesDetail = [RettiDataManager convertStopLinesArrayToDictionary:busStop.lines];
    [self.refreshControl endRefreshing];
    [self initRefreshControl];
    departuresTable.backgroundColor = [UIColor clearColor];
    [departuresTable reloadData];
    [departuresTable scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
    
    [stopViewTitle setText:[busStop code_short]];
    [stopViewSubTitle setText:[busStop name_fi]];
    
    [self setUpMainView];
    [self initMapViewForBusStop:busStop];
}

- (IBAction)reloadButtonPressed:(id)sender{
    if (_busStop != nil) {
        [self requestStopInfoAsyncForCode:[NSString stringWithFormat:@"%d", [_busStop.code intValue]]];
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
    // Return the number of rows in the section.
    //NSLog(@"Number of departures is: %d",self.departures.count);
    return self.departures.count;
    //return 1;
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
    
    NSDictionary *departure = [self.departures objectAtIndex:indexPath.row];
    if (departure) {
        
        @try {
            UILabel *timeLabel = (UILabel *)[cell viewWithTag:1001];
            NSString *notFormattedTime = [NSString stringWithFormat:@"%d" ,[(NSNumber *)[departure objectForKey:@"time"] intValue]];
            timeLabel.text = [ReittiStringFormatter formatHSLAPITimeToHumanTime:notFormattedTime];
            //cell.cellTimeLabel.text = [ReittiStringFormatter formatHSLAPITimeWithColon:notFormattedTime];
            //timeLabel.font = CUSTOME_FONT_BOLD(25.0f);
            
            //            UILabel *dateLabel = (UILabel *)[cell viewWithTag:1002];
            //            NSString *notFormattedDate = [NSString stringWithFormat:@"%d" ,[(NSNumber *)[departure objectForKey:@"date"] intValue]];
            //            dateLabel.text = [ReittiStringFormatter formatHSLDateWithDots:notFormattedDate];
            //            dateLabel.font = CUSTOME_FONT(20.0f);
            
            UILabel *codeLabel = (UILabel *)[cell viewWithTag:1003];
            NSString *notParsedCode = [departure objectForKey:@"code"];
            codeLabel.text = [ReittiStringFormatter parseBusNumFromLineCode:notParsedCode];
            //codeLabel.font = CUSTOME_FONT_BOLD(25.0f);
            
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
                infoCell.backgroundColor = [UIColor clearColor];
                return infoCell;
            }
        }
        @finally {
            NSLog(@"finally");
        }
    }
    
    [cell setCellHeight:cell.frame.size.height];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    cell.backgroundColor = [UIColor clearColor];
    return cell;

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
        [cell showUtilityButtonsAnimated:YES];
    }
}


- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerLeftUtilityButtonWithIndex:(NSInteger)index {
    UIActionSheet *actionSheet;
    EKAuthorizationStatus status;
    switch (index) {
        case 0:{
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
            NSDictionary *departure = [self.departures objectAtIndex:[[departuresTable indexPathForCell:cell] row]];
            NSString *notFormattedTime = [NSString stringWithFormat:@"%d" ,[(NSNumber *)[departure objectForKey:@"time"] intValue]];
            timeToSetAlarm = [ReittiStringFormatter formatHSLAPITimeWithColon:notFormattedTime];
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
-(void)stopFetchDidComplete:(NSArray *)stopList{
    if (stopList != nil) {
        self._busStop = [stopList objectAtIndex:0];
        [self.reittiDataManager saveHistoryToCoreDataStop:self._busStop];
        
//        self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@""];
        [self setUpStopViewForBusStop:self._busStop];
    }else{
        //[self showNotificationWithMessage:@"Sorry. No stop found by that search term." messageType:RNotificationTypeWarning forSeconds:5 keppingSearchView:YES];
    }
    
    
    //[MBProgressHUD hideHUDForView:self.view animated:YES];
    //[SVProgressHUD dismiss];
}

-(void)stopFetchDidFail:(NSString *)error{
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:error                                                                                      message:nil
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
    [alertView show];
    
    [self dismissViewControllerAnimated:YES completion:nil ];
    [self.refreshControl endRefreshing];
    //[self showNotificationWithMessage:error messageType:RNotificationTypeWarning forSeconds:5 keppingSearchView:YES];
    //[MBProgressHUD hideHUDForView:self.view animated:YES];
    //[SVProgressHUD dismiss];
    //[self.refreshControl endRefreshing];
}

- (void)nearByStopFetchDidComplete:(NSArray *)stopList{
//    self.nearByStopList = stopList;
//    [self plotStopAnnotations:self.nearByStopList];
//    if (requestedForListing) {
//        [self displayNearByStopsList:stopList];
//    }
//    retryCount = 0;
//    [SVProgressHUD dismiss];
}
- (void)nearByStopFetchDidFail:(NSString *)error{
//    if (requestedForListing) {
//        if (![error isEqualToString:@""]) {
//            if ([error isEqualToString:@"Request timed out."] && retryCount < 1) {
//                [self listNearbyStopsPressed:nil];
//                retryCount++;
//            }
//            
//            [self showNotificationWithMessage:error messageType:RNotificationTypeWarning forSeconds:5 keppingSearchView:YES];
//        }
//        
//        requestedForListing = NO;
//    }
//    
//    [SVProgressHUD dismiss];
}

#pragma mark - Seague

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"seeFullTimeTable"]) {
        WebViewController *webViewController = (WebViewController *)segue.destinationViewController;
        NSURL *url = [NSURL URLWithString:self._busStop.timetable_link];
        webViewController._url = url;
        webViewController._pageTitle = _busStop.code_short;
        webViewController.darkMode = self.darkMode;
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
