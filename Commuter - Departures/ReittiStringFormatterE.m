//
//  ReittiStringFormatter.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 27/2/14.
//  Copyright (c) 2014 Anteneh Sahledengel. All rights reserved.
//

#import "ReittiStringFormatterE.h"

@implementation ReittiStringFormatterE

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

+(NSString *)formatHourStringFromDate:(NSDate *)date{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"HH:mm"];
    
    return [formatter stringFromDate:date];
}

+(NSString *)formatHSLHourFromDate:(NSDate *)date{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"HHmm"];
    
    return [formatter stringFromDate:date];
}

+(NSString *)formatHSLDateFromDate:(NSDate *)date{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"YYYYMMdd"];
    
    return [formatter stringFromDate:date];
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
