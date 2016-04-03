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
    
    self.dateLabel.hidden = YES;
    
    self.stopImageView.image = [AppManager stopAnnotationImageForStopType:(StopType)[record[kStopType] intValue]];
    self.stopNameLabel.text = record[kStopName];
    self.stopSubtitleLabel.text = [NSString stringWithFormat:@"%@ - %@", record[kStopShortCode], record[kStopCity]];
}

-(void)setupFromStopEntity:(StopEntity *)stopEntity{
    self.stopEntity = stopEntity;
    self.dateLabel.hidden = YES;
    self.iCloudDownloadButton.hidden = YES;
    
    self.stopImageView.image = [AppManager stopAnnotationImageForStopType:stopEntity.stopType];
    self.stopNameLabel.text = stopEntity.busStopName;
    self.stopSubtitleLabel.text = [NSString stringWithFormat:@"%@ - %@", stopEntity.busStopShortCode, stopEntity.busStopCity];
}

-(void)setupFromHistoryEntity:(HistoryEntity *)historyEntity{
    self.historyEntity = historyEntity;
    self.dateLabel.hidden = NO;
    self.iCloudDownloadButton.hidden = YES;
    
    self.stopImageView.image = [AppManager stopAnnotationImageForStopType:historyEntity.stopType];
    self.stopNameLabel.text = historyEntity.busStopName;
    self.stopSubtitleLabel.text = [NSString stringWithFormat:@"%@ - %@", historyEntity.busStopShortCode, historyEntity.busStopCity];
    
    self.dateLabel.text = [ReittiStringFormatter formatPrittyDate:historyEntity.dateModified];
}

-(void)setupFromStopGeocode:(GeoCode *)stopGeocode{
    self.stopGeocode = stopGeocode;
    self.dateLabel.hidden = YES;
    self.iCloudDownloadButton.hidden = YES;
    
    self.stopImageView.image = [AppManager stopAnnotationImageForStopType:[stopGeocode getStopType]];
    self.stopNameLabel.text = [NSString stringWithFormat:@"%@ (%@)", stopGeocode.name, stopGeocode.getStopShortCode];
    self.stopSubtitleLabel.text = [NSString stringWithFormat:@"%@ - %@", stopGeocode.getAddress, stopGeocode.city];
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
