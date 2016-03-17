//
//  ICloudBookmarksViewController.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 13/3/16.
//  Copyright © 2016 Anteneh Sahledengel. All rights reserved.
//

#import "ICloudBookmarksViewController.h"
#import "NamedBookmark.h"
#import "RettiDataManager.h"
#import "ICloudManager.h"
#import "AppManager.h"

@interface ICloudBookmarksViewController ()

@property (nonatomic, strong)RettiDataManager *reittiDataManager;
@property (nonatomic, strong)NSDictionary *dataToLoad;

@property (nonatomic, strong)NSMutableArray *alreadySavedRecords;

@end

//TODO: handle when there is nothing to display
//TODO: Handle case of replacing bookmark by the same name
//TODO: Confirmation when downloading all
//TODO: Show and hide cloud icon in bookmarks when there are other devices.

@implementation ICloudBookmarksViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    markAllAsDownloaded = NO;
    self.alreadySavedRecords = [@[] mutableCopy];
    
    [self.tableView setBlurredBackgroundWithImageNamed:nil];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.dataToLoad = @{};
    self.reittiDataManager = [[RettiDataManager alloc] init];
    
    [self.reittiDataManager fetchallBookmarksFromICloudWithCompletionHandler:^(ICloudBookmarks *result, NSString *errorString){
        if (!errorString) {
            self.dataToLoad = [result getBookmarksExcludingNamedBookmarks:[self.reittiDataManager fetchAllSavedNamedBookmarksFromCoreData]
                                                               savedStops:[self.reittiDataManager fetchAllSavedStopsFromCoreData]
                                                               savedRoutes:nil];
            [self.tableView reloadData];
        } else {
            //TODO: handle error
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
    UITableViewCell *cell;
    NSString *deviceName = self.dataToLoad.allKeys[indexPath.section];
    NSArray *recordsForSection = self.dataToLoad[deviceName];
    
    CKRecord *record = [recordsForSection objectAtIndex:indexPath.row];
    
    if ([record.recordType isEqualToString:NamedBookmarkType]) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"namedBookmarkCell"];
        
        UIImageView *imageView = (UIImageView *)[cell viewWithTag:2001];
        UILabel *title = (UILabel *)[cell viewWithTag:2002];
        UILabel *subTitle = (UILabel *)[cell viewWithTag:2003];
        UIButton *downloadButton = (UIButton *)[cell viewWithTag:2004];
        
        [imageView setImage:[UIImage imageNamed:record[@"iconPictureName"]]];
        
        title.text = record[kNamedBookmarkName];
        subTitle.text = record[kNamedBookmarkFullAddress];
        
        if (markAllAsDownloaded)
            [self animateDownloadButtonChange:downloadButton];
    }else if ([record.recordType isEqualToString:SavedStopType]) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"savedStopCell"];
        
        UILabel *title = (UILabel *)[cell viewWithTag:2002];
        UILabel *subTitle = (UILabel *)[cell viewWithTag:2003];
        UIImageView *imageView = (UIImageView *)[cell viewWithTag:2005];
        UIButton *downloadButton = (UIButton *)[cell viewWithTag:2004];
        
        imageView.image = [AppManager stopAnnotationImageForStopType:(StopType)[record[kStopType] intValue]];
        title.text = record[kStopName];
        subTitle.text = [NSString stringWithFormat:@"%@ - %@", record[kStopShortCode], record[kStopCity]];
        
        if (markAllAsDownloaded)
            [self animateDownloadButtonChange:downloadButton];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return self.dataToLoad.allKeys[section];
}

#pragma mark - IBActions

- (IBAction)closeButtonTapped:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)downloadAllButtonTapped:(id)sender {
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Are you sure you want to import all bookmarks?"
                                                                   message:@"Duplicate bookmarks will be replaced by the one from your other devices."
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"YES" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {
                                                              [self downloadAllBookmarks];
                                                          }];
    
    UIAlertAction* laterAction = [UIAlertAction actionWithTitle:@"Nope" style:UIAlertActionStyleCancel
                                                        handler:^(UIAlertAction * action) {}];

    [alert addAction:defaultAction];
    [alert addAction:laterAction];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (IBAction)downloadSingleButtonTapped:(id)sender {
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:buttonPosition];
    //TODO: Check type to save
    if (indexPath != nil)
    {
        NSString *deviceName = self.dataToLoad.allKeys[indexPath.section];
        NSArray *recordsForSection = self.dataToLoad[deviceName];
        CKRecord *record = recordsForSection[indexPath.row];
        
        if ([self.reittiDataManager doesNamedBookmarkExistWithName:record[kNamedBookmarkName]]) {
            UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Replace existing bookmark."
                                                                           message:@"Another bookmark exists already with the same name. Would you like to replace it?"
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"Replace" style:UIAlertActionStyleDefault
                                                                  handler:^(UIAlertAction * action) {
                                                                      if ([self saveSingleBookmarkFromRecord:record])
                                                                          [self animateDownloadButtonChange:sender];
                                                                  }];
            
            UIAlertAction* laterAction = [UIAlertAction actionWithTitle:@"Nope" style:UIAlertActionStyleCancel
                                                                handler:^(UIAlertAction * action) {}];
            
            [alert addAction:defaultAction];
            [alert addAction:laterAction];
            
            [self presentViewController:alert animated:YES completion:nil];
        } else {
            if ([self saveSingleBookmarkFromRecord:record])
                [self animateDownloadButtonChange:sender];
        }
        
    }
}

- (BOOL)downloadAllBookmarks {
    for (NSArray *recordArray in self.dataToLoad.allValues) {
        for (CKRecord *record in recordArray) {
            if (![self.alreadySavedRecords containsObject:record]) {
                [self saveSingleBookmarkFromRecord:record];
            }
        }
    }
    
    markAllAsDownloaded = YES;
    [self.tableView reloadData];
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
    return YES;
}

- (BOOL)saveSingleBookmarkFromRecord:(CKRecord *)record {
    if ([self.reittiDataManager createOrUpdateNamedBookmarkFromICLoudRecord:record]) {
        [self.alreadySavedRecords addObject:record];
        return YES;
    }
    
    return NO;
}

- (void)animateDownloadButtonChange:(UIButton *)button {
//    UIEdgeInsets originalInset = button.imageEdgeInsets;
    
    [UIView animateWithDuration:0.2 animations:^(){
        CGFloat xInset = button.frame.size.width/2;
        CGFloat yInset = button.frame.size.height/2;
        [button setImageEdgeInsets:UIEdgeInsetsMake(yInset, xInset, yInset, xInset)];
        //This should be called for the inset to be animated
        [button layoutSubviews];
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


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
