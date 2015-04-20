//
//  ReittiStringFormatter.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 27/2/14.
//  Copyright (c) 2014 Anteneh Sahledengel. All rights reserved.
//

#import "ReittiStringFormatter.h"

@implementation ReittiStringFormatter

//Expected format is either XXXX or XXX or numbers
+(NSString *)formatHSLAPITimeWithColon:(NSString *)hslTime{
    if ([hslTime intValue] == 0 && (![hslTime isEqualToString:@"0000"] && ![hslTime isEqualToString:@"000"])){
        return hslTime;
    }
    
    NSRange hourRange, minuteRange;
    
    if (hslTime.length == 3) {
        hourRange = NSMakeRange(0, 1);
        minuteRange = NSMakeRange(1, 2);
    }else if (hslTime.length == 4){
        hourRange = NSMakeRange(0, 2);
        minuteRange = NSMakeRange(2, 2);
    }else{
        return hslTime;
    }
    
    NSString * hour = [hslTime substringWithRange:hourRange];
    NSString * minute = [hslTime substringWithRange:minuteRange];
    
    return [NSString stringWithFormat:@"%@:%@", hour, minute];
    
}

+(NSString *)formatHSLAPITimeToHumanTime:(NSString *)hslTime{
    if ([hslTime intValue] == 0 && (![hslTime isEqualToString:@"0000"] && ![hslTime isEqualToString:@"000"])){
        return hslTime;
    }
    
    NSRange hourRange, minuteRange;
    
    if (hslTime.length == 3) {
        hourRange = NSMakeRange(0, 1);
        minuteRange = NSMakeRange(1, 2);
    }else if (hslTime.length == 4){
        hourRange = NSMakeRange(0, 2);
        minuteRange = NSMakeRange(2, 2);
    }else{
        return hslTime;
    }
    
    NSString * hour = [hslTime substringWithRange:hourRange];
    NSString * minute = [hslTime substringWithRange:minuteRange];
    
    @try {
        if ([hour intValue] > 23) {
            int diff = [hour intValue] - 24;
            hour = [NSString stringWithFormat:@"%d", diff];
        }
    }
    @catch (NSException *exception) {
        //do nothing
    }
    
    return [NSString stringWithFormat:@"%@:%@", hour, minute];
    
}

+(NSString *)formatHourRangeStringFrom:(NSDate *)fromTime toDate:(NSDate *)toTime{
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"HH:mm"];
    
    return [NSString stringWithFormat:@"%@ - %@", [formatter stringFromDate:fromTime], [formatter stringFromDate:toTime]];
}

+(NSString *)formatPrittyDate:(NSDate *)date{
    NSDateFormatter *formatter;
    
    NSDateComponents *otherDay = [[NSCalendar currentCalendar] components:NSEraCalendarUnit|NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:date];
    
    NSDateComponents *today = [[NSCalendar currentCalendar] components:NSEraCalendarUnit|NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:[NSDate date]];
    //If date is today
    if([today day] == [otherDay day] &&
       [today month] == [otherDay month] &&
       [today year] == [otherDay year] &&
       [today era] == [otherDay era]) {
       
        formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"HH:mm"];
        
        return [formatter stringFromDate:date];
    }else if([today day] == [otherDay day] + 1 &&
             [today month] == [otherDay month] &&
             [today year] == [otherDay year] &&
             [today era] == [otherDay era]) {
        
        formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"HH:mm"];
        
        return @"Yesterday";
    }else if([today day] == [otherDay day] + 2 &&
             [today month] == [otherDay month] &&
             [today year] == [otherDay year] &&
             [today era] == [otherDay era]) {
        
        formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"HH:mm"];
        
        return @"2 days ago";
    }else{
        formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"d.MM.yy"];
        
        return [formatter stringFromDate:date];;
    }
    
}

+(NSString *)formatHourStringFromDate:(NSDate *)date{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"HH:mm"];
    
    return [formatter stringFromDate:date];
}

+(NSString *)formatDurationString:(NSInteger)seconds{
    int minutes = (int)(seconds/60);
    
    if (minutes > 59) {
        return [NSString stringWithFormat:@"%dh %dmin", (int)(minutes/60), minutes % 60];
    }else{
        return [NSString stringWithFormat:@"%dmin", minutes];
    }
    
}

//Expected format is XXXXXXXX of numbers
+(NSString *)formatHSLDateWithDots:(NSString *)hslData{
    if (hslData.length != 8 || [hslData intValue] == 0) {
        return hslData;
    }
    
    NSRange yearRange = NSMakeRange(0, 4);
    NSRange monthRange = NSMakeRange(4, 2);
    NSRange dateRange = NSMakeRange(6, 2);
    
    NSString * year = [hslData substringWithRange:yearRange];
    NSString * month = [hslData substringWithRange:monthRange];
    NSString * date = [hslData substringWithRange:dateRange];

    return [NSString stringWithFormat:@"%@.%@.%@", date, month, year];
}

//Expected format is XXXX(X) X 
+(NSString *)parseBusNumFromLineCode:(NSString *)lineCode{
    
    NSArray *codes = [lineCode componentsSeparatedByString:@" "];
    NSString *code = [codes objectAtIndex:0];
    
    if (code.length < 4) {
        return code;
    }
    
    //Can be assumed a train line
    if (([code hasPrefix:@"3001"] || [code hasPrefix:@"3002"]) && code.length > 4) {
        NSString * trainLineCode = [code substringWithRange:NSMakeRange(4, code.length - 4)];
        if (trainLineCode != nil && trainLineCode.length > 0) {
            return trainLineCode;
        }
    }
    
    NSRange second = NSMakeRange(1, 1);
    
    NSString *checkString = [code substringWithRange:second];
    
    if([checkString isEqualToString:@"0"]){
        return [code substringWithRange:NSMakeRange(2, code.length - 2)];
    }else{
        return [code substringWithRange:NSMakeRange(1, code.length - 1)];
    }
}

//Expected format is XXXX(X) X:YYYYYYY
+(NSString *)parseLineCodeFromLineInfoString:(NSString *)lineInfoString{
    NSArray *segments = [lineInfoString componentsSeparatedByString:@":"];
    
    return [segments objectAtIndex:0];
}

+(NSAttributedString *)highlightSubstringInString:(NSString *)text substring:(NSString *)substring withNormalFont:(UIFont *)font{
//    [UIColor colorWithRed:51.0/255.0 green:153.0/255.0 blue:102/255.0 alpha:1.0]
    NSMutableDictionary *subStringDict = [NSMutableDictionary dictionaryWithObject:[UIColor colorWithRed:244.0f/255 green:107.0f/255 blue:0 alpha:1] forKey:NSForegroundColorAttributeName];
    [subStringDict setObject:font forKey:NSFontAttributeName];
    
    NSMutableDictionary *restStringDict = [NSMutableDictionary dictionaryWithObject:font forKey:NSFontAttributeName];
    
    if (text == nil || substring == nil)
        return [[NSMutableAttributedString alloc] initWithString:text attributes:restStringDict];
    
    if ([text rangeOfString:substring options:NSCaseInsensitiveSearch].location == NSNotFound)
        return [[NSMutableAttributedString alloc] initWithString:text attributes:restStringDict];
    
    NSRange location = [text rangeOfString:substring options:NSCaseInsensitiveSearch];
    
    NSMutableAttributedString *highlighted = [[NSMutableAttributedString alloc] initWithString:[text substringWithRange:location] attributes:subStringDict];
    
    NSMutableAttributedString *notHightlighted1 = [[NSMutableAttributedString alloc] initWithString:[text substringToIndex:location.location] attributes:restStringDict];
    
    NSMutableAttributedString *notHightlighted2 = [[NSMutableAttributedString alloc] initWithString:[text substringFromIndex:location.location + location.length ] attributes:restStringDict];
    
    [notHightlighted1 appendAttributedString:highlighted];
    [notHightlighted1 appendAttributedString:notHightlighted2];
    
    return notHightlighted1;
    
}

//Expected format longitude,latitude
+(CLLocationCoordinate2D)convertStringTo2DCoord:(NSString *)coordString{
    NSArray *coords = [coordString componentsSeparatedByString:@","];
    
    CLLocationCoordinate2D coord = {.latitude =  [[coords objectAtIndex:1] floatValue], .longitude =  [[coords objectAtIndex:0] floatValue]};
    
    return coord;
}

+(NSDate *)createDateFromString:(NSString *)timeString withMinOffset:(int)offset{
    BOOL istommorrow = NO;
    NSDate *offsettedDate;
    
    @try {
        NSArray *comp = [timeString componentsSeparatedByString:@":"];
        int hourVal = [[comp objectAtIndex:0] intValue];
        
        if (hourVal > 23) {
            timeString = [NSString stringWithFormat:@"%d:%@", hourVal - 24, [comp objectAtIndex:1] ];
            istommorrow = YES;
        }
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
        [dateFormatter setDateFormat:@"HH:mm"];
        
        NSDate *time = [dateFormatter dateFromString:timeString];
        
        if (time == nil) {
            return nil;
        }
        
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSDateComponents *components = [calendar components:(NSHourCalendarUnit | NSMinuteCalendarUnit) fromDate:time];
        NSInteger hour = [components hour];
        NSInteger minute = [components minute];
        
        NSDate *today = [NSDate date];
        NSDateComponents *component = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:today];
        [component setHour:hour];
        [component setMinute:minute];
        
        NSDate *date = [calendar dateFromComponents:component];
        
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

@end
