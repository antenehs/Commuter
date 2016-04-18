//
//  ReittiDateFormatter.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 17/4/16.
//  Copyright © 2016 Anteneh Sahledengel. All rights reserved.
//

#import "ReittiDateFormatter.h"
#import "ReittiStringFormatter.h"

@interface ReittiDateFormatter ()

@property (nonatomic, strong) NSDateFormatter *hourFormatter;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@property (nonatomic, strong) NSDateFormatter *fullDateFormatter;

@end

@implementation ReittiDateFormatter

+(id)sharedFormatter {
    static ReittiDateFormatter *dateFormatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dateFormatter = [[ReittiDateFormatter alloc] init];
    });
    
    return dateFormatter;
}

#pragma mark - Date formatters
- (NSDateFormatter *)hourFormatter{
    if (!_hourFormatter) {
        _hourFormatter = [[NSDateFormatter alloc] init];
        [_hourFormatter setDateFormat:@"HHmm"];
    }
    
    return _hourFormatter;
}

- (NSDateFormatter *)dateFormatter{
    if (!_dateFormatter) {
        
        _dateFormatter = [[NSDateFormatter alloc] init];
        [_dateFormatter setDateFormat:@"yyyyMMdd"];
    }
    
    return _dateFormatter;
}

- (NSDateFormatter *)fullDateFormatter{
    if (!_fullDateFormatter) {
        
        _fullDateFormatter = [[NSDateFormatter alloc] init];
        [_fullDateFormatter setDateFormat:@"yyyyMMdd HHmm"];
    }
    
    return _fullDateFormatter;
}

#pragma mark - Public methods
/**
Expected format @"YYYYMMdd" and @"HHmm"
*/
- (NSDate *)dateFromMatkaDateString:(NSString *)dateString andHourString:(NSString *)hourString{
    @try {
        NSString *notFormattedTime = hourString;
        NSString *timeString = [ReittiStringFormatter formatHSLAPITimeWithColon:notFormattedTime];
        
        BOOL istommorrow = NO;
        
        NSArray *comp = [timeString componentsSeparatedByString:@":"];
        int hourVal = [[comp objectAtIndex:0] intValue];
        
        //The api time could be greater than 24( like 2643 )
        if (hourVal > 23) {
            timeString = [NSString stringWithFormat:@"0%d%@", hourVal - 24, [comp objectAtIndex:1] ];
            istommorrow = YES;
        }else{
            timeString = [NSString stringWithFormat:@"%d%@", hourVal, [comp objectAtIndex:1] ];
        }
        
        if (timeString.length == 3)
            timeString = [NSString stringWithFormat:@"0%@", timeString];
        
        NSDate *parsedDate = nil;
        if (dateString) {
            NSString *fullDateString = [NSString stringWithFormat:@"%@ %@", dateString, timeString];
            parsedDate = [self.fullDateFormatter dateFromString:fullDateString];
        }else{
            parsedDate = [self.hourFormatter dateFromString:timeString];
        }
        
        NSTimeInterval seconds;
        if (istommorrow) {
            seconds = (24 * 60 * 60);
            parsedDate = [parsedDate dateByAddingTimeInterval:seconds];
        }
        
        return parsedDate;
    }
    @catch (NSException *exception) {
        return nil;
    }
}

@end
