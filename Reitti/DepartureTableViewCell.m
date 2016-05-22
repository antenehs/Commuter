//
//  DepartureTableViewCell.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 21/5/16.
//  Copyright © 2016 Anteneh Sahledengel. All rights reserved.
//

#import "DepartureTableViewCell.h"
#import "ReittiDateFormatter.h"
#import "ReittiStringFormatter.h"
#import "AppManager.h"
#import "ASA_Helpers.h"

@interface DepartureTableViewCell ()

@property (nonatomic,  strong) NSTimer *timer;
@property (nonatomic, strong) NSArray *realtimeImages;

@end

@implementation DepartureTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.realtimeImages = @[[UIImage imageNamed:@"realtime1"], [UIImage imageNamed:@"realtime2"]];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.backgroundColor = [UIColor whiteColor];
    self.compactMode = NO;
}

-(void)setupFromStopDeparture:(StopDeparture *)departure compactMode:(BOOL)compact{
    self.departure = departure;
    self.compactMode = compact;
    
    [self setupForCompactMode:compact];
    
    NSDate *departureTime = departure.parsedScheduledDate;
    
    if (departure.isRealTime) {
        self.timer = [NSTimer scheduledTimerWithTimeInterval: 1.0
                                                      target: self
                                                    selector: @selector(changeRealtimeImage)
                                                    userInfo: nil
                                                     repeats: YES];
        self.realtimeIndicatorImageView.hidden = NO;
        self.timeLabel.textColor = [AppManager systemGreenColor];
        if (departure.parsedRealtimeDate) {
            departureTime = departure.parsedRealtimeDate;
        }
        
        if (!compact && ![departure.parsedScheduledDate asa_IsEqualToDateIgnoringSeconds:departure.parsedRealtimeDate]) {
            self.strikeThroughView.hidden = NO;
            self.cancelledDepartureTimeLabel.hidden = NO;
            
            NSString *formattedHour = [[ReittiDateFormatter sharedFormatter] formatHourStringFromDate:departure.parsedScheduledDate];
            self.cancelledDepartureTimeLabel.text = formattedHour;
        } else {
            self.strikeThroughView.hidden = YES;
            self.cancelledDepartureTimeLabel.hidden = YES;
        }
    } else {
        [self.timer invalidate];
        self.realtimeIndicatorImageView.hidden = YES;
        self.timeLabel.textColor = [UIColor darkGrayColor];
        self.strikeThroughView.hidden = YES;
        self.cancelledDepartureTimeLabel.hidden = YES;
    }
    
    NSString *formattedHour = [[ReittiDateFormatter sharedFormatter] formatHourStringFromDate:departureTime];
    if (!formattedHour || formattedHour.length < 1 ) {
        NSString *notFormattedTime = departure.time ;
        formattedHour = [ReittiStringFormatter formatHSLAPITimeWithColon:notFormattedTime];
        self.timeLabel.text = formattedHour;
    } else {
        if ([departure.parsedScheduledDate timeIntervalSinceNow] < 300) {
            self.timeLabel.attributedText = [ReittiStringFormatter highlightSubstringInString:formattedHour
                                                                               substring:formattedHour
                                                                          withNormalFont:self.timeLabel.font];
            ;
        }else{
            self.timeLabel.text = formattedHour;
        }
    }
    
    self.codeLabel.text = departure.code;
    self.codeLabel.backgroundColor = [UIColor whiteColor];
    self.codeLabel.hidden = NO;
    self.destinationLabel.text = departure.destination;
}

- (void)setupForCompactMode:(BOOL)compact {
    if (compact) {
        self.strikeThroughView.hidden = YES;
        self.cancelledDepartureTimeLabel.hidden = YES;
        
        self.codeLabel.font = [self.codeLabel.font fontWithSize:16];
        self.destinationLabel.font = [self.destinationLabel.font fontWithSize:14];
        self.timeLabel.font = [self.timeLabel.font fontWithSize:16];
    } else {
        self.strikeThroughView.hidden = NO;
        self.cancelledDepartureTimeLabel.hidden = NO;
        
        self.codeLabel.font = [self.codeLabel.font fontWithSize:20];
        self.destinationLabel.font = [self.destinationLabel.font fontWithSize:14];
        self.timeLabel.font = [self.timeLabel.font fontWithSize:20];
    }
}

- (void)changeRealtimeImage {
    if ( [self.realtimeIndicatorImageView.image isEqual: _realtimeImages[0]]){
        self.realtimeIndicatorImageView.image = _realtimeImages[1];
    } else {
        self.realtimeIndicatorImageView.image = _realtimeImages[0];
    }
}

-(void)prepareForReuse {
    [self.timer invalidate];
    self.realtimeIndicatorImageView.image = _realtimeImages[0];
    self.realtimeIndicatorImageView.hidden = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
