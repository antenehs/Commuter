//
//  RouteTableViewCell.h
//  Reitti
//
//  Created by Anteneh Sahledengel on 20/3/16.
//  Copyright © 2016 Anteneh Sahledengel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ReittiModels.h"

@interface RouteTableViewCell : UITableViewCell

-(void)setupFromICloudRecord:(CKRecord *)record;
-(void)setupFromRouteEntity:(RouteEntity *)stopEntity;
-(void)setupFromHistoryEntity:(RouteHistoryEntity *)historyEntity;
-(void)setupFromRoute:(Route *)route;

-(void)startDownloadActivity;
-(void)stopDownloadActivity;

-(void)addTargetForICloudDownloadButton:(id)target selector:(SEL)selector;

@property (weak, nonatomic) IBOutlet UILabel *fromLabel;
@property (weak, nonatomic) IBOutlet UILabel *toLabel;
@property (weak, nonatomic) IBOutlet UIImageView *routeImageView;
@property (weak, nonatomic) IBOutlet UIButton *iCloudDownloadButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

//Data sources
@property (strong, nonatomic)CKRecord *iCloudRecord;

@end
