//
//  BookmarksViewController.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 23/3/14.
//  Copyright (c) 2014 Anteneh Sahledengel. All rights reserved.
//

#import "BookmarksViewController.h"
#import "StopEntity.h"
#import "HistoryEntity.h"
#import "RouteEntity.h"
#import "RouteHistoryEntity.h"
#import "StopViewController.h"
#import "RouteSearchViewController.h"
#import "WidgetSettingsViewController.h"

@interface BookmarksViewController ()

@end

@implementation BookmarksViewController

#define CUSTOME_FONT(s) [UIFont fontWithName:@"Aspergit" size:s]
#define CUSTOME_FONT_BOLD(s) [UIFont fontWithName:@"AspergitBold" size:s]
#define CUSTOME_FONT_LIGHT(s) [UIFont fontWithName:@"AspergitLight" size:s]

#define SYSTEM_GRAY_COLOR [UIColor colorWithWhite:0.1 alpha:1]
#define SYSTEM_ORANGE_COLOR [UIColor colorWithRed:230.0/255.0 green:126.0/255.0 blue:34.0/255.0 alpha:1.0];
#define SYSTEM_GREEN_COLOR [UIColor colorWithRed:39.0/255.0 green:174.0/255.0 blue:96.0/255.0 alpha:1.0];

@synthesize savedStops;
@synthesize recentStops;
@synthesize savedRoutes, recentRoutes;
@synthesize mode, darkMode;
@synthesize dataToLoad;
@synthesize delegate;
@synthesize _tintColor;
@synthesize reittiDataManager;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //defaultBlueColor = [UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0];
    //defaultGreenColor = [UIColor colorWithRed:51.0/255.0 green:153.0/255.0 blue:102.0/255.0 alpha:1.0];
    [self selectSystemColors];
    
    listSegmentControl.selectedSegmentIndex = self.mode;
    [self setUpViewForTheSelectedMode];
    
//    CGRect rect = selectorView.frame;
//    rect.origin.y = self.view.bounds.size.height - rect.size.height + 1 ;
//    rect.origin.x = -5;
//    selectorView.frame = rect;
//    selectorView.layer.borderWidth = 1;
//    selectorView.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    
//    [selectorView setBlurTintColor:systemBackgroundColor];
//    [self.navigationController.view addSubview:selectorView];
    
//    UIImageView *tempImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"TableViewBackground.png"]];
    [bluredBackView setFrame:self.tableView.frame];
    
    self.tableView.backgroundView = bluredBackView;
    
    listSegmentControl.tintColor = [UIColor darkGrayColor];
    
    
//    self.navigationController.navigationBar.barTintColor = systemBackgroundColor;
    
    self.tableView.rowHeight = 60;
    
    //[self.view addSubview:bluredBackView];
//    [self.view sendSubviewToBack:bluredBackView];
    
}

-(void)viewWillAppear:(BOOL)animated{
    [self setUpViewForTheSelectedMode];
}

#pragma mark - View methods
- (void)selectSystemColors{
    if (self.darkMode) {
        systemBackgroundColor = [UIColor clearColor];
        systemTextColor = SYSTEM_GREEN_COLOR;
        systemSubTextColor = [UIColor lightGrayColor];
    }else{
        systemBackgroundColor = nil;
        systemTextColor = SYSTEM_GREEN_COLOR;
        systemSubTextColor = [UIColor darkGrayColor];
    }
}

- (void)setUpViewForTheSelectedMode{
    if (listSegmentControl.selectedSegmentIndex == 0) {
        self.title = @"Bookmarked";
        self._tintColor = SYSTEM_GREEN_COLOR;
        dataToLoad = nil;
        dataToLoad = [[NSMutableArray alloc] initWithArray:savedStops];
        [dataToLoad addObjectsFromArray:savedRoutes];
        if (self.savedStops != nil) {
             {
                 if (self.savedStops.count < 1) {
                     self.navigationController.toolbar.hidden = YES;
                 }else{
                     self.navigationController.toolbar.hidden = NO;
                 }
            }
        }else{
            self.navigationController.toolbar.hidden = YES;
        }
        
    }else{
        self.title = @"Recents";
        self._tintColor = SYSTEM_ORANGE_COLOR;
        dataToLoad = nil;
        dataToLoad = [[NSMutableArray alloc] initWithArray:recentStops];
        [dataToLoad addObjectsFromArray:recentRoutes];
        
        self.navigationController.toolbar.hidden = YES;
    }
    self.tableView.backgroundColor = [UIColor clearColor];
    [self.tableView reloadData];
    
    self.navigationController.navigationBar.tintColor = self._tintColor;
    //selectorView.tintColor = self._tintColor;
}

- (IBAction)CancelButtonPressed:(id)sender {
    [delegate viewControllerWillBeDismissed:self.mode];
    [self dismissViewControllerAnimated:YES completion:nil ];
}
- (IBAction)clearAllButtonPressed:(id)sender {
    // Delete the row from the data source
    if (dataToLoad.count > 0) {
        NSString * message;
        if (mode == 0) {
            message  = @"Are you sure you want to delete all your bookmarks? This action cannot  be undone";
        }else{
            message  = @"Are you sure you want to delete all your history? This action cannot  be undone";
        }
        
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:message delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Delete" otherButtonTitles:nil];
        
        [actionSheet showInView:self.view];
    }    
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSLog(@"You have pressed the %@ button", [actionSheet buttonTitleAtIndex:buttonIndex]);
    
    if (buttonIndex == 0) {
        if (mode == 0) {
//            [delegate deletedAllSavedStops];
            [self.reittiDataManager deleteAllSavedStop];
            [self.reittiDataManager deleteAllSavedroutes];
            self.navigationController.toolbar.hidden = YES;
        }else{
//            [delegate deletedAllHistoryStops];
            [self.reittiDataManager deleteAllHistoryStop];
            [self.reittiDataManager deleteAllHistoryRoutes];
        }
        
        [dataToLoad removeAllObjects];
        [self.tableView reloadData];
    }   
    
}

- (IBAction)segmentControlValueChanged:(id)sender {
    
    [self setUpViewForTheSelectedMode];
    
    self.mode = listSegmentControl.selectedSegmentIndex;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    NSLog(@"%@",self.dataToLoad);
    return self.dataToLoad.count + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"emptyCell"];;
    if (indexPath.row < self.dataToLoad.count) {
        if ([[self.dataToLoad objectAtIndex:indexPath.row] isKindOfClass:[StopEntity class]] || [[self.dataToLoad objectAtIndex:indexPath.row] isKindOfClass:[HistoryEntity class]]) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"savedStopCell"];
        }else if ([[self.dataToLoad objectAtIndex:indexPath.row] isKindOfClass:[RouteHistoryEntity class]]  || [[self.dataToLoad objectAtIndex:indexPath.row] isKindOfClass:[RouteEntity class]]){
            cell = [tableView dequeueReusableCellWithIdentifier:@"savedRouteCell"];
        }
    }
    @try {
        if ([[self.dataToLoad objectAtIndex:indexPath.row] isKindOfClass:[StopEntity class]] || [[self.dataToLoad objectAtIndex:indexPath.row] isKindOfClass:[HistoryEntity class]]) {
            StopEntity *stopEntity = [StopEntity alloc];
            if (indexPath.row < self.dataToLoad.count) {
                stopEntity = [self.dataToLoad objectAtIndex:indexPath.row];
            }
            
            UILabel *title = (UILabel *)[cell viewWithTag:2002];
            UILabel *subTitle = (UILabel *)[cell viewWithTag:2003];
            cell.selectionStyle = UITableViewCellSelectionStyleDefault;
            
            title.text = stopEntity.busStopName;
            //stopName.font = CUSTOME_FONT_BOLD(23.0f);
            
            subTitle.text = [NSString stringWithFormat:@"%@ - %@", stopEntity.busStopShortCode, stopEntity.busStopCity];
            //cityName.font = CUSTOME_FONT_BOLD(19.0f);
        }
        else{
            RouteEntity *routeEntity = [RouteEntity alloc];
            if (indexPath.row < self.dataToLoad.count) {
                routeEntity = [self.dataToLoad objectAtIndex:indexPath.row];
            }
            
            UILabel *title = (UILabel *)[cell viewWithTag:2002];
            UILabel *subTitle = (UILabel *)[cell viewWithTag:2003];
            cell.selectionStyle = UITableViewCellSelectionStyleDefault;
            
            title.text = routeEntity.toLocationName;
            //stopName.font = CUSTOME_FONT_BOLD(23.0f);
            
            subTitle.text = [NSString stringWithFormat:@"%@", routeEntity.fromLocationName];
        }
        
    }
    @catch (NSException *exception) {
        NSLog(@"Exception when displaying table: %@", [exception description]);
        //This is to leave on extra empty row
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    @finally {
    }
    cell.backgroundColor = [UIColor clearColor];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    if (indexPath.row < self.dataToLoad.count) {
        return YES;
    }else{
        return NO;
    }
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        StopEntity *deletedStop;
        RouteEntity *deletedRoute;
        if ([[self.dataToLoad objectAtIndex:indexPath.row] isKindOfClass:[StopEntity class]] || [[self.dataToLoad objectAtIndex:indexPath.row] isKindOfClass:[HistoryEntity class]]) {
            deletedStop = [dataToLoad objectAtIndex:indexPath.row];
            [dataToLoad removeObject:deletedStop];
        }else if ([[self.dataToLoad objectAtIndex:indexPath.row] isKindOfClass:[RouteHistoryEntity class]]  || [[self.dataToLoad objectAtIndex:indexPath.row] isKindOfClass:[RouteEntity class]]){
            deletedRoute = [dataToLoad objectAtIndex:indexPath.row];
            [dataToLoad removeObject:deletedRoute];
        }
        // Delete the row from the data source
        
        if (mode == 0) {
            if (deletedRoute != nil) {
//                [delegate deletedSavedRouteForCode:deletedRoute.routeUniqueName];
                [self.reittiDataManager deleteSavedRouteForCode:deletedRoute.routeUniqueName];
                [savedRoutes removeObject:deletedRoute];
            }else{
//                [delegate deletedSavedStopForCode:deletedStop.busStopCode];
                [self.reittiDataManager deleteSavedStopForCode:deletedStop.busStopCode];
                [savedStops removeObject:deletedStop];
            }
        }else{
            if (deletedRoute != nil) {
//                [delegate deletedHistoryRouteForCode:deletedRoute.routeUniqueName];
                [self.reittiDataManager deleteHistoryRouteForCode:deletedRoute.routeUniqueName];
                [recentRoutes removeObject:deletedRoute];
            }else{
//                [delegate deletedHistoryStopForCode:deletedStop.busStopCode];
                [self.reittiDataManager deleteHistoryStopForCode:deletedStop.busStopCode];
                [recentStops removeObject:deletedStop];
            }
        }
        
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        if (![self.reittiDataManager fetchAllSavedStopsFromCoreData]) {
            self.navigationController.toolbar.hidden = YES;
        }else{
            self.navigationController.toolbar.hidden = NO;
        }
        
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Delegates

- (void)savedStop:(BusStop *)busStop{
    if (mode == 0) {
        [dataToLoad addObject:busStop];
        [savedStops addObject:busStop];
        [self.tableView reloadData];
    }else{
        [savedStops addObject:busStop];
    }
    
}
- (void)deletedSavedStop:(BusStop *)busStop{
    if (mode == 0) {
        [dataToLoad removeObject:busStop];
        [savedStops removeObject:busStop];
        [self.tableView reloadData];
    }else{
        [savedStops removeObject:busStop];
    }
    
}
- (void)routeModified{
    //Fetch saved route list again
    savedRoutes = [NSMutableArray arrayWithArray:[self.reittiDataManager fetchAllSavedRoutesFromCoreData]];
    
    recentRoutes = [NSMutableArray arrayWithArray:[self.reittiDataManager fetchAllSavedRouteHistoryFromCoreData]];
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row < self.dataToLoad.count) {
        //StopEntity * selected = [self.dataToLoad objectAtIndex:indexPath.row];
        //[delegate savedStopSelected:selected.busStopCode fromMode:self.mode];
        //[self dismissViewControllerAnimated:YES completion:nil ];
    }
}

#pragma mark - Seague
- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender{
    NSIndexPath *selectedRowIndexPath = [self.tableView indexPathForSelectedRow];
    if (selectedRowIndexPath.row < self.dataToLoad.count)
        return YES;
    return NO;
}
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSIndexPath *selectedRowIndexPath = [self.tableView indexPathForSelectedRow];
    
    if ([segue.identifier isEqualToString:@"bookmarkSelected"]) {
        if (selectedRowIndexPath.row < self.dataToLoad.count) {
            if ([[self.dataToLoad objectAtIndex:selectedRowIndexPath.row] isKindOfClass:[StopEntity class]] || [[self.dataToLoad objectAtIndex:selectedRowIndexPath.row] isKindOfClass:[HistoryEntity class]]) {
                
                StopEntity * selected = [self.dataToLoad objectAtIndex:selectedRowIndexPath.row];
                
                UINavigationController *navigationController = (UINavigationController *)segue.destinationViewController;
                //NSLog(@"%@", [navigationController viewControllers]);
                //NSLog(@"%d", [[navigationController viewControllers] count]);
                StopViewController *stopViewController =[[navigationController viewControllers] lastObject];
                stopViewController.stopCode = [NSString stringWithFormat:@"%d", [selected.busStopCode intValue]];
                stopViewController.stopEntity = selected;
                stopViewController.darkMode = self.darkMode;
                stopViewController.reittiDataManager = self.reittiDataManager;
                stopViewController.backButtonText = self.title;
                stopViewController.delegate = self;
            }
        }
    }else if ([segue.identifier isEqualToString:@"routeSelected"]){
        if (selectedRowIndexPath.row < self.dataToLoad.count){
            if ([[self.dataToLoad objectAtIndex:selectedRowIndexPath.row] isKindOfClass:[RouteHistoryEntity class]]  || [[self.dataToLoad objectAtIndex:selectedRowIndexPath.row] isKindOfClass:[RouteEntity class]]){
                
                RouteEntity * selected = [self.dataToLoad objectAtIndex:selectedRowIndexPath.row];
                
                UINavigationController *navigationController = (UINavigationController *)segue.destinationViewController;
                RouteSearchViewController *routeSearchViewController = [[navigationController viewControllers] lastObject];
                
                routeSearchViewController.savedStops = [NSMutableArray arrayWithArray:self.savedStops];
                routeSearchViewController.recentStops = [NSMutableArray arrayWithArray:self.recentStops];
                routeSearchViewController.darkMode = self.darkMode;
                routeSearchViewController.prevToLocation = selected.toLocationName;
                routeSearchViewController.prevToCoords = selected.toLocationCoordsString;
                routeSearchViewController.prevFromLocation = selected.fromLocationName;
                routeSearchViewController.prevFromCoords = selected.fromLocationCoordsString;
                
                routeSearchViewController.delegate = self;
                routeSearchViewController.reittiDataManager = self.reittiDataManager;
            }
        }
    }else if([segue.identifier isEqualToString:@"editSelectionForWidget"]){
        UINavigationController *navigationController = (UINavigationController *)segue.destinationViewController;
        WidgetSettingsViewController *controller = (WidgetSettingsViewController *)[[navigationController viewControllers] lastObject];
        
        controller.savedStops = self.savedStops;
        
    }
}

- (void)dealloc
{
    NSLog(@"BookmarksController:This bitchass ARC deleted my UIView.");
}

@end
