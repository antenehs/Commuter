//
//  DepartureTableViewCell.h
//  Reitti
//
//  Created by Anteneh Sahledengel on 21/5/16.
//  Copyright © 2016 Anteneh Sahledengel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StopDeparture.h"
#import "CustomeTableViewCell.h"

@interface DepartureTableViewCell : CustomeTableViewCell

-(void)setupFromStopDeparture:(StopDeparture *)departure compactMode:(BOOL)compact;

@property (strong, nonatomic) IBOutlet UILabel *codeLabel;
@property (strong, nonatomic) IBOutlet UILabel *destinationLabel;
@property (strong, nonatomic) IBOutlet UILabel *timeLabel;
@property (strong, nonatomic) IBOutlet UILabel *cancelledDepartureTimeLabel;
@property (strong, nonatomic) IBOutlet UIView *strikeThroughView;
@property (strong, nonatomic) IBOutlet UIImageView *realtimeIndicatorImageView;

@property (nonatomic, strong)StopDeparture *departure;
@property (nonatomic) BOOL compactMode;

@end
