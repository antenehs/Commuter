//
//  ICloudBookmarksViewController.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 13/3/16.
//  Copyright © 2016 Anteneh Sahledengel. All rights reserved.
//

#import "ICloudBookmarksViewController.h"
#import "RettiDataManager.h"
#import "ICloudManager.h"
#import "AppManager.h"
#import "JTMaterialSpinner.h"
#import "ApiProtocols.h"

#import "TableViewCells.h"

@interface ICloudBookmarksViewController ()

@property (nonatomic, strong)RettiDataManager *reittiDataManager;
@property (nonatomic, strong)NSDictionary *dataToLoad;

@property (nonatomic, strong)NSMutableArray *alreadySavedRecords;

@property (strong, nonatomic) IBOutlet UIView *infoView;
@property (strong, nonatomic) IBOutlet UIImageView *infoViewImageView;
@property (strong, nonatomic) IBOutlet UILabel *infoTitleLabel;
@property (strong, nonatomic) IBOutlet UILabel *infoDetailLabel;
@property (strong, nonatomic) IBOutlet JTMaterialSpinner *activityIndicator;

@end


@implementation ICloudBookmarksViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    markAllAsDownloaded = NO;
    self.alreadySavedRecords = [@[] mutableCopy];
    
    [self.tableView setBlurredBackgroundWithImageNamed:nil];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.navigationItem.rightBarButtonItem = nil;
    
    [self.tableView registerNib:[UINib nibWithNibName:@"StopTableViewCell" bundle:nil] forCellReuseIdentifier:@"savedStopCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"RouteTableViewCell" bundle:nil] forCellReuseIdentifier:@"savedRouteCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"NamedBookmarkTableViewCell" bundle:nil] forCellReuseIdentifier:@"namedBookmarkCell"];

    self.infoView.layer.cornerRadius = 10.0;
    
    self.dataToLoad = @{};
    self.reittiDataManager = [[RettiDataManager alloc] init];
    
    if (![ICloudManager isICloudContainerAvailable]) {
        [self showNoOtherDeviceMessage];
    } else {
        [self fetchBookmarks];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[ReittiAnalyticsManager sharedManager] trackScreenViewForScreenName:NSStringFromClass([self class])];
}

-(void)fetchBookmarks {
    [self showLoading];
    [self.reittiDataManager fetchallBookmarksFromICloudWithCompletionHandler:^(ICloudBookmarks *result, NSString *errorString){
        if (!errorString) {
            self.dataToLoad = [result getBookmarksExcludingNamedBookmarks:[self.reittiDataManager fetchAllSavedNamedBookmarksFromCoreData]
                                                               savedStops:[self.reittiDataManager fetchAllSavedStopsFromCoreData]
                                                              savedRoutes:[self.reittiDataManager fetchAllSavedRoutesFromCoreData]];
            
            BOOL thereAreOtherDevices = [[[result allBookmarksGrouped] allKeys] count] > 1;
            if (self.dataToLoad.allKeys.count == 0 && thereAreOtherDevices) {
                [self showSynchedMessage];
            }else if (self.dataToLoad.allKeys.count == 0) {
                [self showNoOtherDeviceMessage];
            }else{
                [self.tableView reloadData];
                self.tableView.hidden = NO;
            }
        } else {
            [self showErrorWithMessage:errorString];
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - tableview datasource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.dataToLoad.allKeys.count;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSString *deviceName = self.dataToLoad.allKeys[section];
    NSArray *records = self.dataToLoad[deviceName];
    
    return records ? records.count : 0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *deviceName = self.dataToLoad.allKeys[indexPath.section];
    NSArray *recordsForSection = self.dataToLoad[deviceName];
    
    CKRecord *record = [recordsForSection objectAtIndex:indexPath.row];
    
    if ([record.recordType isEqualToString:NamedBookmarkType]) {
        NamedBookmarkTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"namedBookmarkCell"];
        
        [cell setupFromICloudRecord:record];
        [cell addTargetForICloudDownloadButton:self selector:@selector(downloadNamedBookmarkButtonTapped:)];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }else if ([record.recordType isEqualToString:SavedStopType]) {
        StopTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"savedStopCell"];
        
        [cell setupFromICloudRecord:record];
        [cell addTargetForICloudDownloadButton:self selector:@selector(downloadStopButtonTapped:)];
     
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }else{
        RouteTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"savedRouteCell"];
        
        [cell setupFromICloudRecord:record];
        [cell addTargetForICloudDownloadButton:self selector:@selector(downloadRouteButtonTapped:)];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    
    return nil;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *deviceId = self.dataToLoad.allKeys[section];
    NSArray *bookmarksInSection = self.dataToLoad[deviceId];
    
    if (bookmarksInSection.count > 0) {
        CKRecord *record = bookmarksInSection[0];
        return record[kRecordDeviceName];
    }
    
    return @"Other device";
}

#pragma mark - IBActions

- (IBAction)closeButtonTapped:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

//- (IBAction)downloadAllButtonTapped:(id)sender {
//    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Are you sure you want to import all bookmarks?"
//                                                                   message:@"Duplicate bookmarks will be replaced by the one from your other devices."
//                                                            preferredStyle:UIAlertControllerStyleAlert];
//    
//    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"YES" style:UIAlertActionStyleDefault
//                                                          handler:^(UIAlertAction * action) {
//                                                              [self downloadAllBookmarks];
//                                                          }];
//    
//    UIAlertAction* laterAction = [UIAlertAction actionWithTitle:@"Nope" style:UIAlertActionStyleCancel
//                                                        handler:^(UIAlertAction * action) {}];
//
//    [alert addAction:defaultAction];
//    [alert addAction:laterAction];
//    
//    [self presentViewController:alert animated:YES completion:nil];
//}

- (IBAction)downloadNamedBookmarkButtonTapped:(NamedBookmarkTableViewCell *)bookmarkCell {
    CKRecord *record = bookmarkCell.iCloudRecord;
    if (!record) return;
    
    if ([self.reittiDataManager doesNamedBookmarkExistWithName:record[kNamedBookmarkName]]) {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Replace existing bookmark."
                                                                       message:@"Another bookmark exists already with the same name. Would you like to replace it?"
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"Replace" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {
                                                                  if ([self saveNamedBookmarkFromRecord:record])
                                                                      [self fakeActivityForButton:bookmarkCell.iCloudDownloadButton andCell:bookmarkCell];
                                                              }];
        
        UIAlertAction* laterAction = [UIAlertAction actionWithTitle:@"Nope" style:UIAlertActionStyleCancel
                                                            handler:^(UIAlertAction * action) {}];
        
        [alert addAction:defaultAction];
        [alert addAction:laterAction];
        
        [self presentViewController:alert animated:YES completion:nil];
    } else {
        if ([self saveNamedBookmarkFromRecord:record])
            [self fakeActivityForButton:bookmarkCell.iCloudDownloadButton andCell:bookmarkCell];
    }
    
    [[ReittiAnalyticsManager sharedManager] trackFeatureUseEventForAction:kActionDownloadedICloudBookmark label:@"Named bookmark" value:nil];
}

-(void)downloadStopButtonTapped:(StopTableViewCell *)stopCell {
    CKRecord *record = stopCell.iCloudRecord;
    if (!record) return;
    
    [stopCell startDownloadActivity];
    [self saveStopFromRecord:record withCompletionHandler:^(BOOL *success){
        [stopCell stopDownloadActivity];
        if (success) {
            [self animateDownloadButtonChange:stopCell.iCloudDownloadButton];
        }
    }];
    
    [[ReittiAnalyticsManager sharedManager] trackFeatureUseEventForAction:kActionDownloadedICloudBookmark label:@"Stop" value:nil];
}

-(void)downloadRouteButtonTapped:(RouteTableViewCell *)routeCell {
    CKRecord *record = routeCell.iCloudRecord;
    if (!record) return;
    
    [self saveRouteFromRecord:record];
    [self fakeActivityForButton:routeCell.iCloudDownloadButton andCell:routeCell];
    
    [[ReittiAnalyticsManager sharedManager] trackFeatureUseEventForAction:kActionDownloadedICloudBookmark label:@"Route" value:nil];
}

- (BOOL)saveNamedBookmarkFromRecord:(CKRecord *)record {
    if ([self.reittiDataManager createOrUpdateNamedBookmarkFromICLoudRecord:record]) {
        [self.alreadySavedRecords addObject:record];
        return YES;
    }
    
    return NO;
}

- (void)saveStopFromRecord:(CKRecord *)record withCompletionHandler:(ActionBlock)completionHandler {
    if (!record || !record[kStopNumber]) return;
    
    NSNumber *stopCode = record[kStopNumber];
    CLLocation *locaiton = record[kStopCoordinate];
    NSNumber *fetchedFromNumber = record[kStopFetchedFrom];
    
    RTStopSearchParam *searchParam = [RTStopSearchParam new];
    searchParam.longCode = [NSString stringWithFormat:@"%d", [stopCode intValue]];
    
    if (fetchedFromNumber) {
        ReittiApi fetchedFrom = (ReittiApi)[fetchedFromNumber intValue];
        
        [self.reittiDataManager fetchStopsForSearchParams:searchParam fetchFromApi:fetchedFrom withCompletionBlock:^(BusStop * response, NSString *error){
            [self stopFetchCompleted:response andError:error withCompletionHandler:completionHandler];
        }];
    } else {
        [self.reittiDataManager fetchStopsForSearchParams:searchParam andCoords:locaiton.coordinate withCompletionBlock:^(BusStop * response, NSString *error){
            [self stopFetchCompleted:response andError:error withCompletionHandler:completionHandler];
        }];
    }
}

- (void)stopFetchCompleted:(BusStop *)stop andError:(NSString *)error withCompletionHandler:(ActionBlock)completionHandler {
    BOOL success = NO;
    if (!error) {
        [self.reittiDataManager saveToCoreDataStop:stop];
        success = YES;
    } else {
        success = NO;
    }
    
    if (completionHandler) {
        completionHandler(success);
    }
}

- (void)saveRouteFromRecord:(CKRecord *)record {
    if (!record || !record[kRouteUniqueName]) return;
    
    [self.reittiDataManager saveRouteToCoreData:record[kRouteFromLocaiton] fromCoords:record[kRouteFromCoords] andToLocation:record[kRouteToLocation] andToCoords:record[kRouteToCoords]];
}

- (void)animateDownloadButtonChange:(UIButton *)button {
//    UIEdgeInsets originalInset = button.imageEdgeInsets;
    
    [UIView animateWithDuration:0.2 animations:^(){
//        CGFloat xInset = button.frame.size.width/2;
//        CGFloat yInset = button.frame.size.height/2;
//        [button setImageEdgeInsets:UIEdgeInsetsMake(yInset, xInset, yInset, xInset)];
//        //This should be called for the inset to be animated
//        [button layoutSubviews];
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.2 animations:^(){
            [button setImage:[UIImage imageNamed:@"doneImageGreen"] forState:UIControlStateNormal];
            [button setImage:[UIImage imageNamed:@"doneImageGreen"] forState:UIControlStateDisabled];
            [button setImageEdgeInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
            button.layer.masksToBounds = YES;
            //This should be called for the inset to be animated
            [button layoutSubviews];
        } completion:^(BOOL finished) {
            button.enabled = NO;
        }];
    }];
}

- (void)fakeActivityForButton:(UIButton *)button andCell:(UITableViewCell *)cell {
    [(NamedBookmarkTableViewCell *)cell startDownloadActivity];
    
    [(NamedBookmarkTableViewCell *)cell performSelector:@selector(stopDownloadActivity) withObject:nil afterDelay:0.3];
    [self performSelector:@selector(animateDownloadButtonChange:) withObject:button afterDelay:0.3];
}

#pragma mark - info view methods
-(void)showLoading {
    self.tableView.hidden = YES;
    self.infoViewImageView.image = [UIImage imageNamed:@"iCloudIcon"];
    self.activityIndicator.hidden = NO;
    [self.activityIndicator beginRefreshing];
    self.activityIndicator.circleLayer.lineWidth = 2;
    self.activityIndicator.circleLayer.strokeColor = [AppManager systemGreenColor].CGColor;
    self.activityIndicator.alternatingColors = nil;
    
    self.infoTitleLabel.hidden = YES;
    self.infoDetailLabel.hidden = YES;
}

-(void)showNoOtherDeviceMessage {
    self.tableView.hidden = YES;
    self.infoViewImageView.image = [UIImage imageNamed:@"iCloudIcon"];
    self.activityIndicator.hidden = YES;
    
    self.infoTitleLabel.hidden = NO;
    self.infoTitleLabel.text = @"No iCloud Bookmarks Found";
    self.infoTitleLabel.textColor = [UIColor grayColor];
    self.infoDetailLabel.hidden = NO;
    self.infoDetailLabel.text = @"To use bookmark sync feature, log in with the same iCloud account on all your devices.";
}

-(void)showSynchedMessage {
    self.tableView.hidden = YES;
    self.infoViewImageView.image = [UIImage imageNamed:@"iCloudSynched"];
    self.activityIndicator.hidden = YES;
    
    self.infoTitleLabel.hidden = NO;
    self.infoTitleLabel.text = @"All Devices In Sync";
    self.infoTitleLabel.textColor = [UIColor grayColor];
    self.infoDetailLabel.hidden = NO;
    self.infoDetailLabel.text = @"";
}

-(void)showErrorWithMessage:(NSString *)errorMessage {
    self.tableView.hidden = YES;
    self.infoViewImageView.image = [UIImage imageNamed:@"iCloudError"];
    self.activityIndicator.hidden = YES;
    
    self.infoTitleLabel.hidden = NO;
    self.infoTitleLabel.text = @"Sync Failed";
    self.infoTitleLabel.textColor = [UIColor grayColor];
    self.infoDetailLabel.hidden = NO;
    self.infoDetailLabel.text = errorMessage;
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
