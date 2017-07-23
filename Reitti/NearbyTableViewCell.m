//
//  NearbyTableViewCell.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 6/22/17.
//  Copyright © 2017 Anteneh Sahledengel. All rights reserved.
//

#import "NearbyTableViewCell.h"
#import "AppManager.h"
#import "ASA_Helpers.h"
#import "SwiftHeaders.h"
#import "AppFeatureManager.h"

@interface NearbyTableViewCell ()

@property (strong, nonatomic) IBOutlet UIImageView *iconImageView;
@property (strong, nonatomic) IBOutlet UILabel *mainTitleLabel;
@property (strong, nonatomic) IBOutlet UILabel *mainSubtitleLabel;
@property (strong, nonatomic) IBOutlet UILabel *detailSubtitleLabel;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *detailSubtitleBottomSpaceConstraint;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *valueLabelTopSpaceConstraint;
@property (strong, nonatomic) IBOutlet UILabel *primaryValueLabel;
@property (strong, nonatomic) IBOutlet UIView *primaryValueRealtimeIndicator;
@property (strong, nonatomic) IBOutlet UILabel *secondaryValueLabel;
@property (strong, nonatomic) IBOutlet UIView *secondaryValueRealtimeIndicator;


@end

@implementation NearbyTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    self.primaryValueRealtimeIndicator.backgroundColor = [UIColor clearColor];
    
    self.secondaryValueRealtimeIndicator.backgroundColor = [UIColor clearColor];
}

- (void)setupFromNearByRowObject:(id)nearByRow {
    if ([nearByRow isKindOfClass:GroupedDepartures.class]) {
        [self setupFromGroupedDepartures:(GroupedDepartures *)nearByRow];
        return;
    }
    
    if ([nearByRow isKindOfClass:BikeStation.class]) {
        
        [self setupFromBikeStation:(BikeStation *)nearByRow];
        return;
    }
    
    NSAssert(false, @"Unknown type");
}

-(void)setupFromGroupedDepartures:(GroupedDepartures *)groupedDepartures {
    self.groupedDepartures = groupedDepartures;
    
    [self setIconImage:[AppManager lightColorImageForLegTransportType:[EnumManager legTrasportTypeForLineType:groupedDepartures.line.lineType]]];
    
    self.mainTitleLabel.text = groupedDepartures.line.code;
    self.mainTitleLabel.font = [self.mainTitleLabel.font fontWithSize:31];
    self.mainSubtitleLabel.text = [NSString stringWithFormat:@"➞ %@", groupedDepartures.line.destination.uppercaseString];
    self.detailSubtitleLabel.text = [NSString stringWithFormat:@"%@ (%@) • %@m", groupedDepartures.stop.name, groupedDepartures.stop.codeShort, groupedDepartures.distance];
    
    NSArray *validDepartues = [groupedDepartures getValidDepartures];
    
    self.secondaryValueLabel.hidden = YES;
    self.valueLabelTopSpaceConstraint.active = NO;
    if (!validDepartues || validDepartues.count == 0) {
        self.primaryValueLabel.text = @"-";
    } else if (validDepartues.count > 0) {
        [self setupValueLabel:self.primaryValueLabel withDeparture:validDepartues[0] attributeText:YES];
        if (validDepartues.count > 1) {
            self.secondaryValueLabel.hidden = NO;
            [self setupValueLabel:self.secondaryValueLabel withDeparture:validDepartues[1] attributeText:NO];
            self.valueLabelTopSpaceConstraint.active = YES;
        }
    }
    
    self.contentView.backgroundColor = [AppManager colorForLineType:groupedDepartures.line.lineType];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

-(void)setupValueLabel:(UILabel *)label withDeparture:(StopDeparture *)departure attributeText:(BOOL)attribute {
    NSDate *departureDate = departure.departureTime;
    if (!departureDate) {
        label.text = @"-";
        return;
    }
    
    NSTimeInterval timeFromNow = [departureDate timeIntervalSinceNow];
    if (timeFromNow <= 60) {
        label.text = @"NOW";
        NSAssert(timeFromNow > 0, @"Time remaining should not be less than zero");
    } else if (attribute && timeFromNow < 3600 ){
        NSString *numString = [NSString stringWithFormat:@"%d", (int)timeFromNow/60];
        NSAttributedString *timeString = [ReittiStringFormatter formatAttributedString:numString withUnit:@" min" withFont:self.primaryValueLabel.font andUnitFontSize:14];
        label.attributedText = timeString;
    } else {
        NSString *timeString = [[ReittiDateHelper sharedFormatter] formatHourStringFromDate:departureDate];
        label.text = timeString;
    }
    
    if (departure.isRealTime && [AppFeatureManager proFeaturesAvailable]) {
        if ([label isEqual:self.primaryValueLabel]) {
            RealtimeIndicatorView *indicatorView = [[RealtimeIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 14, 14)];
            indicatorView.color = [UIColor whiteColor];
            
            [self.primaryValueRealtimeIndicator addSubview:indicatorView];
        } else {
            RealtimeIndicatorView *indicatorView = [[RealtimeIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 12, 12)];
            indicatorView.color = [UIColor whiteColor];
            
            [self.secondaryValueRealtimeIndicator addSubview:indicatorView];
        }
    }
}

-(void)setupFromBikeStation:(BikeStation *)bikeStation {
    self.bikeStation = bikeStation;
    
    [self setIconImage:[AppManager lightColorImageForLegTransportType:LegTypeBicycle]];
    self.mainTitleLabel.text = bikeStation.name;
    self.mainTitleLabel.font = [self.mainTitleLabel.font fontWithSize:26];
    self.mainSubtitleLabel.text = [NSString stringWithFormat:@"%@ • %@m", bikeStation.stationId, bikeStation.distance];
    
    self.detailSubtitleLabel.hidden = YES;
    self.detailSubtitleBottomSpaceConstraint.active = NO;
    
    NSAttributedString *availabilityString = [ReittiStringFormatter formatAttributedString:[bikeStation.bikesAvailable stringValue] withUnit:[NSString stringWithFormat:@" %@/%@", bikeStation.bikesUnitString, bikeStation.totalSpaces] withFont:self.primaryValueLabel.font andUnitFontSize:14];
    self.primaryValueLabel.attributedText = availabilityString;
    
    self.secondaryValueLabel.hidden = YES;
    self.valueLabelTopSpaceConstraint.active = NO;
    
    
    self.contentView.backgroundColor = [AppManager systemYellowColor];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

-(void)setIconImage:(UIImage *)image {
    image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    self.iconImageView.image = image;
    self.iconImageView.tintColor = [UIColor whiteColor];
}

-(void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)prepareForReuse {
    for (UIView *view in self.primaryValueRealtimeIndicator.subviews) {
        [view removeFromSuperview];
    }
    
    for (UIView *view in self.secondaryValueRealtimeIndicator.subviews) {
        [view removeFromSuperview];
    }
    
    self.detailSubtitleLabel.hidden = NO;
    self.secondaryValueLabel.hidden = NO;
    
    self.detailSubtitleBottomSpaceConstraint.active = YES;
    self.valueLabelTopSpaceConstraint.active = YES;
    
    self.groupedDepartures = nil;
    self.bikeStation = nil;
}

@end
