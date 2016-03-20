//
//  StopTableViewCell.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 20/3/16.
//  Copyright © 2016 Anteneh Sahledengel. All rights reserved.
//

#import "StopTableViewCell.h"
#import "AppManager.h"

@interface StopTableViewCell ()

@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@property (weak, nonatomic)id iCloudDownloadButtonTarget;
@property (nonatomic)SEL iCloudDownloadButtonSelector;

@end

@implementation StopTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

#pragma mark - view Settup
-(void)setupFromICloudRecord:(CKRecord *)record{
    self.iCloudRecord = record;
    
    self.stopImageView.image = [AppManager stopAnnotationImageForStopType:(StopType)[record[kStopType] intValue]];
    self.stopNameLabel.text = record[kStopName];
    self.stopSubtitleLabel.text = [NSString stringWithFormat:@"%@ - %@", record[kStopShortCode], record[kStopCity]];
}

-(void)setupFromStopEntity:(StopEntity *)stopEntity{
    
}

-(void)setupFromHistoryEntity:(HistoryEntity *)historyEntity{
    
}

-(void)setupFromBusStop:(BusStop *)busTop{
    
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
