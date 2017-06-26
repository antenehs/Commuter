//
//  NearbyInfoTableViewCell.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 6/24/17.
//  Copyright © 2017 Anteneh Sahledengel. All rights reserved.
//

#import "NearbyInfoTableViewCell.h"
#import "JTMaterialSpinner.h"

@interface NearbyInfoTableViewCell ()

@property (strong, nonatomic) IBOutlet JTMaterialSpinner *activityIndicator;
@property (strong, nonatomic) IBOutlet UIImageView *infoImageView;
@property (strong, nonatomic) IBOutlet UILabel *infoLabel;


@end

@implementation NearbyInfoTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    self.activityIndicator.backgroundColor = [UIColor clearColor];
    self.infoImageView.tintColor = [UIColor grayColor];
    
    self.contentView.backgroundColor = [UIColor clearColor];
    self.backgroundColor = [UIColor clearColor];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

-(void)setupForInfoType:(NearbyListInfoType)infoType specialErrorMessage:(NSString *)errorMessage {
    self.activityIndicator.hidden = infoType != NearbyListInfoTypeLoading;
    self.infoImageView.hidden = infoType == NearbyListInfoTypeLoading;
    
    if (infoType == NearbyListInfoTypeLoading) {
        [self.activityIndicator beginRefreshing];
    } else {
        self.infoImageView.image = [self imageForType:infoType];
    }
    
    self.infoLabel.text = infoType == NearbyListInfoTypeError && errorMessage ? errorMessage : [self textForInfoType:infoType];
}

-(NSString *)textForInfoType:(NearbyListInfoType)infoType {
    switch (infoType) {
        case NearbyListInfoTypeLoading:
            return @"Loading...";
        case NearbyListInfoTypeNothingNearby:
            return @"No departures nearby soon.";
        case NearbyListInfoTypeEverythingFiltered:
            return @"No departures nearby. They might be filtered away.";
        case NearbyListInfoTypeZoomedOut:
            return @"Zoom in to see nearby departures.";
        case NearbyListInfoTypeError:
            return @"Error occured fetching departures";
        case NearbyListInfoTypeUnsupportedRegion:
            return @"Commuter is not supported in this region";
        default:
            return @"Nothing to see here.";
    }
}

-(UIImage *)imageForType:(NearbyListInfoType)infoType {
    UIImage *image = nil;
    switch (infoType) {
        case NearbyListInfoTypeLoading:
            image = nil;
            break;
        case NearbyListInfoTypeNothingNearby:
            image = [UIImage imageNamed:@"noDepartures"];
            break;
        case NearbyListInfoTypeEverythingFiltered:
            image = [UIImage imageNamed:@"noDepartures"];
            break;
        case NearbyListInfoTypeZoomedOut:
            image = [UIImage imageNamed:@"zoomIn"];
            break;
        case NearbyListInfoTypeError:
            image = [UIImage imageNamed:@"ErrorFilled"];
            break;
        case NearbyListInfoTypeUnsupportedRegion:
            image = [UIImage imageNamed:@"ErrorFilled"];
            break;
        default:
            image = nil;
            break;
    }
    
    image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    
    return image;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
