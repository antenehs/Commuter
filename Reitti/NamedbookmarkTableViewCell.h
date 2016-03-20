//
//  NamedBookmarkTableViewCell.h
//  Reitti
//
//  Created by Anteneh Sahledengel on 20/3/16.
//  Copyright © 2016 Anteneh Sahledengel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ReittiModels.h"

@interface NamedBookmarkTableViewCell : UITableViewCell

-(void)setupFromICloudRecord:(CKRecord *)record;
-(void)setupFromNamedBookmark:(NamedBookmark *)bookmark;

-(void)startDownloadActivity;
-(void)stopDownloadActivity;

-(void)addTargetForICloudDownloadButton:(id)target selector:(SEL)selector;

@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UILabel *addressLabel;
@property (strong, nonatomic) IBOutlet UIImageView *bookmarkImageView;
@property (strong, nonatomic) IBOutlet UIButton *iCloudDownloadButton;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

//Data sources
@property (strong, nonatomic)CKRecord *iCloudRecord;

@end
