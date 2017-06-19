//
//  ReittiDateHelper.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 17/4/16.
//  Copyright © 2016 Anteneh Sahledengel. All rights reserved.
//

#import "ReittiDateHelper.h"
#import "ReittiStringFormatter.h"

@interface ReittiDateHelper ()

@end

@implementation ReittiDateHelper

+(id)sharedFormatter {
    static ReittiDateHelper *dateFormatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dateFormatter = [[ReittiDateHelper alloc] init];
    });
    
    return dateFormatter;
}

#pragma mark - Date formatters
- (NSDateFormatter *)apiHourFormatter{
    if (!_apiHourFormatter) {
        _apiHourFormatter = [[NSDateFormatter alloc] init];
        [_apiHourFormatter setDateFormat:@"HHmm"];
        [_apiHourFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"fi_FI"]];
    }
    
    return _apiHourFormatter;
}

- (NSDateFormatter *)apiDateFormatter{
    if (!_apiDateFormatter) {
        
        _apiDateFormatter = [[NSDateFormatter alloc] init];
        [_apiDateFormatter setDateFormat:@"yyyyMMdd"];
        [_apiDateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"fi_FI"]];
    }
    
    return _apiDateFormatter;
}

- (NSDateFormatter *)apiFullDateFormatter{
    if (!_apiFullDateFormatter) {
        
        _apiFullDateFormatter = [[NSDateFormatter alloc] init];
        [_apiFullDateFormatter setDateFormat:@"yyyyMMddHHmm"];
        [_apiFullDateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"fi_FI"]];
    }
    
    return _apiFullDateFormatter;
}

-(NSDateFormatter *)hourAndMinFormatter {
    if (!_hourAndMinFormatter) {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"HH:mm"];
        [formatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"fi_FI"]];
        _hourAndMinFormatter = formatter;
    }
    
    return _hourAndMinFormatter;
}

-(NSDateFormatter *)dateFormatter {
    if (!_dateFormatter) {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"d.MM.yy"];
        [formatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"fi_FI"]];
        _dateFormatter = formatter;
    }
    
    return _dateFormatter;
}

-(NSDateFormatter *)fullDateFormatter {
    if (!_fullDateFormatter) {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"d.MM.yy HH:mm"];
        [formatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"fi_FI"]];
        _fullDateFormatter = formatter;
    }
    
    return _fullDateFormatter;
}

-(NSDateFormatter *)digiTransitDateFormatter {
    if (!_digiTransitDateFormatter) {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd"];
        [formatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"fi_FI"]];
        _digiTransitDateFormatter = formatter;
    }
    
    return _digiTransitDateFormatter;
}

-(NSDateFormatter *)digiTransitTimeFormatter {
    if (!_digiTransitTimeFormatter) {
        _digiTransitTimeFormatter = self.hourAndMinFormatter;
    }
    
    return _digiTransitTimeFormatter;
}

-(NSCalendar *)currentCalendar {
    if (!_currentCalendar) {
        _currentCalendar = [NSCalendar currentCalendar];
    }
    
    return _currentCalendar;
}

#pragma mark - Public methods
/**
Expected format @"YYYYMMdd" and @"HHmm"
*/
- (NSDate *)dateFromApiDateString:(NSString *)dateString andHourString:(NSString *)hourString{
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
            NSString *fullDateString = [NSString stringWithFormat:@"%@%@", dateString, timeString];
            parsedDate = [self.apiFullDateFormatter dateFromString:fullDateString];
        }else{
            parsedDate = [self.apiHourFormatter dateFromString:timeString];
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

-(NSDate *)dateFromFullApiDateString:(NSString *)fullDateString {
    return [self.apiFullDateFormatter dateFromString:fullDateString];
}

-(NSString *)formatHourStringFromDate:(NSDate *)date{
    return [self.hourAndMinFormatter stringFromDate:date];
}

-(NSString *)formatHourRangeStringFrom:(NSDate *)fromTime toDate:(NSDate *)toTime{
    return [NSString stringWithFormat:@"%@ - %@", [self.hourAndMinFormatter stringFromDate:fromTime], [self.hourAndMinFormatter stringFromDate:toTime]];
}

-(NSString *)formatDate:(NSDate *)date{
    return [self.dateFormatter stringFromDate:date];
}

-(NSString *)formatFullDateString:(NSDate *)date {
    NSDateFormatter *formatter = self.fullDateFormatter;
    [formatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"fi_FI"]];
    return [formatter stringFromDate:date];
}

-(NSString *)formatHoursOrFullDateIfNotToday:(NSDate *)date {
    NSDateFormatter *formatter = [ReittiDateHelper isSameDateAsToday:date] ? self.hourAndMinFormatter : self.fullDateFormatter;
    [formatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"fi_FI"]];
    return [formatter stringFromDate:date];
}

-(NSString *)formatPrittyDate:(NSDate *)date{
    NSDateComponents *otherDay = [[NSCalendar currentCalendar] components:NSCalendarUnitEra|NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:date];
    
    NSDateComponents *today = [[NSCalendar currentCalendar] components:NSCalendarUnitEra|NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:[NSDate date]];
    //If date is today
    if([today day] == [otherDay day] &&
       [today month] == [otherDay month] &&
       [today year] == [otherDay year] &&
       [today era] == [otherDay era]) {
        
        return [self.hourAndMinFormatter stringFromDate:date];
    }else if([today day] == [otherDay day] + 1 &&
             [today month] == [otherDay month] &&
             [today year] == [otherDay year] &&
             [today era] == [otherDay era]) {
        
        return @"Yesterday";
    }else if([today day] == [otherDay day] + 2 &&
             [today month] == [otherDay month] &&
             [today year] == [otherDay year] &&
             [today era] == [otherDay era]) {
        
        return @"2 days ago";
    }else{
        
        return [self.dateFormatter stringFromDate:date];;
    }
}

-(NSDate *)createDateFromString:(NSString *)timeString withMinOffset:(int)offset{
    BOOL istommorrow = NO;
    NSDate *offsettedDate;
    
    @try {
        NSArray *comp = [timeString componentsSeparatedByString:@":"];
        int hourVal = [[comp objectAtIndex:0] intValue];
        
        if (hourVal > 23) {
            timeString = [NSString stringWithFormat:@"%d:%@", hourVal - 24, [comp objectAtIndex:1] ];
            istommorrow = YES;
        }
        
        NSDate *time = [self.hourAndMinFormatter dateFromString:timeString];
        
        if (time == nil) {
            return nil;
        }
        
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSDateComponents *components = [calendar components:(NSCalendarUnitHour | NSCalendarUnitMinute) fromDate:time];
        NSInteger hour = [components hour];
        NSInteger minute = [components minute];
        
        NSDate *today = [NSDate date];
        NSDateComponents *component = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:today];
        [component setHour:hour];
        [component setMinute:minute];
        
        NSDate *date = [calendar dateFromComponents:component];
        
        if ([date timeIntervalSinceNow] < 0) { //Must be tomorrow
            istommorrow = YES;
        }
        
        NSTimeInterval seconds;
        if (istommorrow) {
            seconds = (offset * -60) + (24 * 60 * 60);
        }else{
            seconds = (offset * -60);
        }
        
        offsettedDate = [date dateByAddingTimeInterval:seconds];
        
    }
    @catch (NSException *exception) {
        return nil;
    }
    
    return offsettedDate;
}

+(BOOL)isSameDateAsToday:(NSDate *)date1{
    NSDateComponents *otherDay = [[NSCalendar currentCalendar] components:NSCalendarUnitEra|NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:date1];
    NSDateComponents *today = [[NSCalendar currentCalendar] components:NSCalendarUnitEra|NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:[NSDate date]];
    return ([today day] == [otherDay day] &&
            [today month] == [otherDay month] &&
            [today year] == [otherDay year] &&
            [today era] == [otherDay era]);
}

+(NSInteger)daysBetweenDate:(NSDate*)fromDateTime andDate:(NSDate*)toDateTime {
    NSDate *fromDate;
    NSDate *toDate;
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    [calendar rangeOfUnit:NSCalendarUnitDay startDate:&fromDate
                 interval:NULL forDate:fromDateTime];
    [calendar rangeOfUnit:NSCalendarUnitDay startDate:&toDate
                 interval:NULL forDate:toDateTime];
    
    NSDateComponents *difference = [calendar components:NSCalendarUnitDay
                                               fromDate:fromDate toDate:toDate options:0];
    
    return [difference day];
}

-(NSString *)digitransitQueryDateStringFromDate:(NSDate *)date {
    return [self.digiTransitDateFormatter stringFromDate:date];
}

-(NSString *)digitransitQueryTimeStringFromDate:(NSDate *)date {
    return [self.digiTransitTimeFormatter stringFromDate:date];
}

-(NSDate *)dateIgnoringTime {
    NSDateComponents *components = [self.currentCalendar
                                    components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay
                                    fromDate:[NSDate date]];
    return [self.currentCalendar dateFromComponents:components];
}

@end
