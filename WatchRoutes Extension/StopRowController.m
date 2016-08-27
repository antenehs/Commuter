//
//  StopRowController.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 27/8/16.
//  Copyright © 2016 Anteneh Sahledengel. All rights reserved.
//

#import "StopRowController.h"

@implementation StopRowController

-(void)setUpWithStop:(StopEntity *)stop {
    self.stop = stop;
    
    UIImage *iconImage = [UIImage imageNamed:stop.iconName != nil ? stop.iconName : @"busStopIcon"];
    [self.stopimage setImage:iconImage != nil ? iconImage : [UIImage imageNamed:@"busStopIcon"]];
    
    [self.stopNameLabel setText:stop.busStopName];
    if (stop.busStopCity && ![stop.busStopCity isEqualToString:@""]) {
        self.stopDetailLabel.text = [NSString stringWithFormat:@"%@ - %@", stop.busStopShortCode, stop.busStopCity];
    } else {
        self.stopDetailLabel.text = [NSString stringWithFormat:@"%@", stop.busStopShortCode];
    }
}

@end
