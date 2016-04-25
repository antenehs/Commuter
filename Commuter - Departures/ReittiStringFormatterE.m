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
    [formatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"fi_FI"]];
    [formatter setDateFormat:@"HH:mm"];
    
    return [NSString stringWithFormat:@"%@ - %@", [formatter stringFromDate:fromTime], [formatter stringFromDate:toTime]];
}

+(NSString *)formatHourStringFromDate:(NSDate *)date{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"HH:mm"];
    [formatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"fi_FI"]];
    
    return [formatter stringFromDate:date];
}

+(NSString *)formatHSLHourFromDate:(NSDate *)date{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"HHmm"];
    
    return [formatter stringFromDate:date];
}

+(NSString *)formatHSLDateFromDate:(NSDate *)date{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyyMMdd"];
    [formatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"fi_FI"]];
    
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
    
    @try {
        //Line codes from HSL live could be only 4 characters
        if (lineCode.length < 4)
            return lineCode;
        
        //Can be assumed a metro
        if ([lineCode hasPrefix:@"1300"])
            return @"Metro";
        
        //Can be assumed a ferry
        if ([lineCode hasPrefix:@"1019"])
            return @"Ferry";
        
        //Can be assumed a train line
        if (([lineCode hasPrefix:@"3001"] || [lineCode hasPrefix:@"3002"]) && lineCode.length > 4) {
            NSString * trainLineCode = [lineCode substringWithRange:NSMakeRange(4, 1)];
            if (trainLineCode != nil && trainLineCode.length > 0)
                return trainLineCode;
        }
        
        //2-4. character = line code (e.g. 102)
        NSString *codePart = [lineCode substringWithRange:NSMakeRange(1, 3)];
        while ([codePart hasPrefix:@"0"]) {
            codePart = [codePart substringWithRange:NSMakeRange(1, codePart.length - 1)];
        }
        
        if (lineCode.length <= 4)
            return codePart;
        
        //5 character = letter variant (e.g. T)
        NSString *firstLetterVariant = [lineCode substringWithRange:NSMakeRange(4, 1)];
        if ([firstLetterVariant isEqualToString:@" "])
            return codePart;
        
        if (lineCode.length <= 5)
            return [NSString stringWithFormat:@"%@%@", codePart, firstLetterVariant];
        
        //6 character = letter variant or numeric variant (ignore number variant)
        NSString *secondLetterVariant = [lineCode substringWithRange:NSMakeRange(5, 1)];
        if ([secondLetterVariant isEqualToString:@" "] || [secondLetterVariant intValue])
            return [NSString stringWithFormat:@"%@%@", codePart, firstLetterVariant];
        
        return [NSString stringWithFormat:@"%@%@%@", codePart, firstLetterVariant, secondLetterVariant];
    }
    @catch (NSException *exception) {
        return lineCode;
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
        [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"fi_FI"]];
        
        NSDate *time = [dateFormatter dateFromString:timeString];
        
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

+(NSString *)formatRoundedNumberFromDouble:(double)doubleVal roundDigits:(int)roundPoints androundUp:(BOOL)roundUp{
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    
    [formatter setMaximumFractionDigits:roundPoints];
    
    [formatter setRoundingMode: roundUp? NSNumberFormatterRoundUp : NSNumberFormatterRoundDown];
    
    NSString *numberString = [formatter stringFromNumber:[NSNumber numberWithFloat:doubleVal]];
    
    return numberString;
}

+(NSString *)commaSepStringFromArray:(NSArray *)array withSeparator:(NSString *)separator{
    NSMutableArray *tempArray = [[NSMutableArray alloc] init];
    if (array != nil && ![[array firstObject] isKindOfClass:[NSString class]]) {
        return nil;
    }
    
    for (NSString *line in array) {
        if (![tempArray containsObject:line]) {
            [tempArray addObject:line];
        }
    }
    
    separator = separator != nil ? separator : @",";
    
    if (tempArray.count > 0) {
        return [[tempArray valueForKey:@"description"] componentsJoinedByString:separator];
    }else{
        return @"";
    }
}

@end
