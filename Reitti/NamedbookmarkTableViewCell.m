//
//  NamedBookmarkTableViewCell.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 20/3/16.
//  Copyright © 2016 Anteneh Sahledengel. All rights reserved.
//

#import "NamedBookmarkTableViewCell.h"

@interface NamedBookmarkTableViewCell ()

@property (weak, nonatomic)id iCloudDownloadButtonTarget;
@property (nonatomic)SEL iCloudDownloadButtonSelector;

@end

@implementation NamedBookmarkTableViewCell

#pragma mark - view Settup
-(void)setupFromICloudRecord:(CKRecord *)record{
    self.iCloudRecord = record;
    
    self.nameLabel.text = record[kNamedBookmarkName];
    self.addressLabel.text = record[kNamedBookmarkFullAddress];
    
    if ([UIImage imageNamed:record[@"iconPictureName"]])
        [self.bookmarkImageView setImage:[UIImage imageNamed:record[@"iconPictureName"]]];
    else
        [self.bookmarkImageView setImage:[UIImage imageNamed:record[@"location-75-red.png"]]];
}

-(void)setupFromNamedBookmark:(NamedBookmark *)bookmark{
    self.namedBookmark = bookmark;
    self.iCloudDownloadButton.hidden = YES;
    
    self.nameLabel.text = bookmark.name;
    self.addressLabel.text = [bookmark getFullAddress];
    
    if ([UIImage imageNamed:bookmark.iconPictureName])
        [self.bookmarkImageView setImage:[UIImage imageNamed:bookmark.iconPictureName]];
    else
        [self.bookmarkImageView setImage:[UIImage imageNamed:bookmark.iconPictureName]];
}

-(void)addTargetForICloudDownloadButton:(id)target selector:(SEL)selector{
    self.iCloudDownloadButtonTarget = target;
    self.iCloudDownloadButtonSelector = selector;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (void)startDownloadActivity {
    self.iCloudDownloadButton.hidden = YES;
    [self.activityIndicator startAnimating];
}

- (void)stopDownloadActivity {
    [self.activityIndicator stopAnimating];
    self.iCloudDownloadButton.hidden = NO;
}

#pragma mark - IbActions
- (IBAction)iCloudDownloadButtonPressed:(id)sender {
    if (self.iCloudDownloadButtonSelector) {
        [self.iCloudDownloadButtonTarget performSelector:self.iCloudDownloadButtonSelector withObject:self afterDelay:0 ];
    }
}

@end
