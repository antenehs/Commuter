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
-(void)setupFromRoute:(Route *)route;

-(void)startDownloadActivity;
-(void)stopDownloadActivity;

-(void)addTargetForICloudDownloadButton:(id)target selector:(SEL)selector;

@property (weak, nonatomic) IBOutlet UILabel *fromLabel;
@property (weak, nonatomic) IBOutlet UILabel *toLabel;
@property (weak, nonatomic) IBOutlet UIImageView *routeImageView;
@property (weak, nonatomic) IBOutlet UIButton *iCloudDownloadButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (strong, nonatomic) IBOutlet UILabel *dateLabel;


//Data sources
@property (strong, nonatomic)CKRecord *iCloudRecord;
@property (strong, nonatomic)RouteEntity *routeEntity;

@end
