//
//  StopTableViewCell.h
//  Reitti
//
//  Created by Anteneh Sahledengel on 20/3/16.
//  Copyright © 2016 Anteneh Sahledengel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ReittiModels.h"

@interface StopTableViewCell : UITableViewCell

-(void)setupFromICloudRecord:(CKRecord *)record;
-(void)setupFromStopEntity:(StopEntity *)stopEntity;
-(void)setupFromHistoryEntity:(HistoryEntity *)historyEntity;
-(void)setupFromStopGeocode:(GeoCode *)stopGeocode;
-(void)setupFromBusStop:(BusStop *)busTop;

- (void)startDownloadActivity;
- (void)stopDownloadActivity;

-(void)addTargetForICloudDownloadButton:(id)target selector:(SEL)selector;

@property (weak, nonatomic) IBOutlet UIImageView *stopImageView;
@property (weak, nonatomic) IBOutlet UILabel *stopNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *stopSubtitleLabel;
@property (weak, nonatomic) IBOutlet UIButton *iCloudDownloadButton;
@property (strong, nonatomic) IBOutlet UILabel *dateLabel;

//Data sources
@property (strong, nonatomic)CKRecord *iCloudRecord;
@property (strong, nonatomic)StopEntity *stopEntity;
@property (strong, nonatomic)HistoryEntity *historyEntity;
@property (strong, nonatomic)BusStop *busStop;
@property (strong, nonatomic)GeoCode *stopGeocode;

@end
