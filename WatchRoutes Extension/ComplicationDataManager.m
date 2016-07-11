//
//  ComplecationDataManager.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 9/7/16.
//  Copyright © 2016 Anteneh Sahledengel. All rights reserved.
//

#import "ComplicationDataManager.h"
#import <ClockKit/ClockKit.h>

NSString* ComplicationCurrentEntry = @"ComplicationCurrentEntry";
NSString* ComplicationTextData = @"ComplicationTextData";
NSString* ComplicationShortTextData = @"ComplicationShortTextData";

@implementation ComplicationDataManager

+(instancetype)sharedManager {
    static ComplicationDataManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedInstance = [ComplicationDataManager new];
    });
    
    return sharedInstance;
}

-(void)setDepartureTime:(NSDate *)date {
    [self saveDateToDefaults:date];
    [self refreshComplications];
}

-(void)setRoute:(Route *)route {
    self.routeForComplication = route;
    if (route) {
        [self saveDateToDefaults:route.timeAtTheFirstStop];
    } else {
        [self saveDateToDefaults:nil];
    }
    [self refreshComplications];
}

-(NSDate *)getDepartureTime {
    return [self getDateFromDefaults];
}

- (void)refreshComplications {
    CLKComplicationServer *server = [CLKComplicationServer sharedInstance];
    for(CLKComplication *complication in server.activeComplications) {
        [server reloadTimelineForComplication:complication];
    }
}

#pragma mark - Helper methods
-(void)saveDateToDefaults:(NSDate *)date {
    [[NSUserDefaults standardUserDefaults] setObject:date forKey:@"stopDepartureTime"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(NSDate *)getDateFromDefaults {
     NSDate * savedDate = [[NSUserDefaults standardUserDefaults] objectForKey:@"stopDepartureTime"];
    return savedDate;
}

@end
