//
//  StopTableViewCell.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 20/3/16.
//  Copyright © 2016 Anteneh Sahledengel. All rights reserved.
//

#import "StopTableViewCell.h"
#import "AppManager.h"
#import "ReittiStringFormatter.h"
#import "ASA_Helpers.h"

@interface StopTableViewCell ()

@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@property (weak, nonatomic)id iCloudDownloadButtonTarget;
@property (nonatomic)SEL iCloudDownloadButtonSelector;

@end

@implementation StopTableViewCell

#pragma mark - view Settup
-(void)setupFromICloudRecord:(CKRecord *)record{
    self.iCloudRecord = record;
    
    self.dateLabel.hidden = YES;
    
    self.stopImageView.image = [AppManager stopIconForStopType:(StopType)[record[kStopType] intValue]];
    self.stopNameLabel.text = record[kStopName];
    if (record[kStopCity] && ![record[kStopCity] isEqualToString:@""]) {
        self.stopSubtitleLabel.text = [NSString stringWithFormat:@"%@ - %@", record[kStopShortCode], record[kStopCity]];
    } else {
        self.stopSubtitleLabel.text = [NSString stringWithFormat:@"%@", record[kStopShortCode]];
    }
//    self.stopSubtitleLabel.text = [NSString stringWithFormat:@"%@ - %@", record[kStopShortCode], record[kStopCity]];
}

-(void)setupFromStopEntity:(StopEntity *)stopEntity{
    self.stopEntity = stopEntity;
    self.dateLabel.hidden = YES;
    self.iCloudDownloadButton.hidden = YES;
    
    self.stopImageView.image = [AppManager stopIconForStopType:stopEntity.stopType];
    self.stopNameLabel.text = stopEntity.busStopName;
    if (stopEntity.busStopCity && ![stopEntity.busStopCity isEqualToString:@""]) {
        self.stopSubtitleLabel.text = [NSString stringWithFormat:@"%@ - %@", stopEntity.busStopShortCode, stopEntity.busStopCity];
    } else {
        self.stopSubtitleLabel.text = [NSString stringWithFormat:@"%@", stopEntity.busStopShortCode];
    }
}

-(void)setupFromHistoryEntity:(StopEntity *)historyEntity{
    self.historyEntity = historyEntity;
    self.dateLabel.hidden = NO;
    self.iCloudDownloadButton.hidden = YES;
    
    self.stopImageView.image = [AppManager stopIconForStopType:historyEntity.stopType];
    self.stopNameLabel.text = historyEntity.busStopName;
    
    if (historyEntity.busStopCity && ![historyEntity.busStopCity isEqualToString:@""]) {
        self.stopSubtitleLabel.text = [NSString stringWithFormat:@"%@ - %@", historyEntity.busStopShortCode, historyEntity.busStopCity];
    } else {
        self.stopSubtitleLabel.text = [NSString stringWithFormat:@"%@", historyEntity.busStopShortCode];
    }
    
    self.dateLabel.text = [[ReittiDateHelper sharedFormatter] formatPrittyDate:historyEntity.dateModified];
}

-(void)setupFromStopGeocode:(GeoCode *)stopGeocode{
    self.stopGeocode = stopGeocode;
    self.dateLabel.hidden = YES;
    self.iCloudDownloadButton.hidden = YES;
    
    self.stopImageView.image = [AppManager stopIconForStopType:stopGeocode.stopType];
    self.stopNameLabel.text = [NSString stringWithFormat:@"%@ (%@)", stopGeocode.name, stopGeocode.getStopShortCode];
    if (stopGeocode.city && ![stopGeocode.city isEqualToString:@""]) {
        self.stopSubtitleLabel.text = [NSString stringWithFormat:@"%@ - %@", stopGeocode.getAddress, stopGeocode.city];
    } else {
        self.stopSubtitleLabel.text = [NSString stringWithFormat:@"%@", stopGeocode.getAddress];
    }
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
