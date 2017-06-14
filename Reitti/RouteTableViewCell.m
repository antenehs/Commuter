//
//  RouteTableViewCell.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 20/3/16.
//  Copyright © 2016 Anteneh Sahledengel. All rights reserved.
//

#import "RouteTableViewCell.h"
#import "ReittiStringFormatter.h"
#import "ASA_Helpers.h"

@interface RouteTableViewCell ()

@property (weak, nonatomic)id iCloudDownloadButtonTarget;
@property (nonatomic)SEL iCloudDownloadButtonSelector;

@end

@implementation RouteTableViewCell

#pragma mark - view Settup
-(void)setupFromICloudRecord:(CKRecord *)record{
    self.iCloudRecord = record;
    self.dateLabel.hidden = YES;
    
    self.toLabel.text = record[kRouteToLocation];
    self.fromLabel.text = record[kRouteFromLocaiton];
}

-(void)setupFromRouteEntity:(RouteEntity *)stopEntity{
    if (!stopEntity) return;
    
    self.routeEntity = stopEntity;
    
    self.iCloudDownloadButton.hidden = YES;
    
    self.toLabel.text = stopEntity.toLocationName;
    self.fromLabel.text = stopEntity.fromLocationName;
    
    self.dateLabel.hidden = !stopEntity.isHistoryRoute;
    if(stopEntity.isHistoryRoute)
        self.dateLabel.text = [[ReittiDateHelper sharedFormatter] formatPrittyDate:stopEntity.dateModified];
}

-(void)setupFromRoute:(Route *)route{
    
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
