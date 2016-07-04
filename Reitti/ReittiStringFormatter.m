//
//  ReittiStringFormatter.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 27/2/14.
//  Copyright (c) 2014 Anteneh Sahledengel. All rights reserved.
//

#import "ReittiStringFormatter.h"
#import "AppManagerBase.h"

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

+(NSString *)formatDurationString:(NSInteger)seconds{
    int minutes = (int)(seconds/60);
    
    if (minutes > 59) {
        return [NSString stringWithFormat:@"%dh %d min", (int)(minutes/60), minutes % 60];
    }else{
        return [NSString stringWithFormat:@"%d min", minutes];
    }
    
}

+(NSString *)formatFullDurationString:(NSInteger)seconds{
    int minutes = (int)(seconds/60);
    
    if (minutes > 59) {
        return [NSString stringWithFormat:@"%dhour %d minutes", (int)(minutes/60), minutes % 60];
    }else{
        return [NSString stringWithFormat:@"%d minutes", minutes];
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

//Expected format is XXXX(X) X:YYYYYYY
+(NSString *)parseLineCodeFromLineInfoString:(NSString *)lineInfoString{
    NSArray *segments = [lineInfoString componentsSeparatedByString:@":"];
    
    return [segments objectAtIndex:0];
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

//Expected format longitude,latitude
+(CLLocationCoordinate2D)convertStringTo2DCoord:(NSString *)coordString{
    NSArray *coords = [coordString componentsSeparatedByString:@","];
    if (!coords || coords.count < 2)
        return CLLocationCoordinate2DMake(0, 0);
    
    CLLocationCoordinate2D coord = {.latitude =  [[coords objectAtIndex:1] floatValue], .longitude =  [[coords objectAtIndex:0] floatValue]};
    
    return coord;
}

+(NSString *)convert2DCoordToString:(CLLocationCoordinate2D)coord{
    return [NSString stringWithFormat:@"%f,%f", coord.longitude, coord.latitude];
}

+(NSString *)formatRoundedNumberFromDouble:(double)doubleVal roundDigits:(int)roundPoints androundUp:(BOOL)roundUp{
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    
    [formatter setMaximumFractionDigits:roundPoints];
    
    [formatter setRoundingMode: roundUp? NSNumberFormatterRoundUp : NSNumberFormatterRoundDown];
    
    NSString *numberString = [formatter stringFromNumber:[NSNumber numberWithFloat:doubleVal]];
    
    return numberString;
}

#ifndef APPLE_WATCH
+(NSString *)coordStringFromKkj3CoorsWithX:(NSNumber *)xCoord andY:(NSNumber *)yCoord {
    if (!xCoord || !yCoord)
        return @"0,0";
    
    double x = [xCoord doubleValue], y = [yCoord doubleValue];
    
    AGSGeometryEngine* engine    = [AGSGeometryEngine defaultGeometryEngine];
    AGSSpatialReference* kkj3 = [AGSSpatialReference spatialReferenceWithWKID: 2393];
    AGSPoint* kkj3Point         = [AGSPoint pointWithX:x y:y spatialReference:kkj3];
    AGSSpatialReference* wgs = [AGSSpatialReference spatialReferenceWithWKID: 4326];
    AGSPoint* wgsPoint         = (AGSPoint*) [engine projectGeometry:kkj3Point toSpatialReference :wgs];
    
    return [NSString stringWithFormat:@"%f,%f", wgsPoint.x, wgsPoint.y];
}

+(AGSPoint *)convertCoordsToKkj3Point:(CLLocationCoordinate2D)coords {
    AGSGeometryEngine* engine    = [AGSGeometryEngine defaultGeometryEngine];
    
    CLLocation *location = [[CLLocation alloc] initWithLatitude:coords.latitude longitude:coords.longitude];
    
    AGSPoint* wgsPoint         = [AGSPoint pointWithLocation:location];
    AGSSpatialReference* kkj3 = [AGSSpatialReference spatialReferenceWithWKID: 2393];
    AGSPoint* kkj3Point         = (AGSPoint*) [engine projectGeometry:wgsPoint toSpatialReference :kkj3];
    
    return kkj3Point;
}

+(NSAttributedString *)formatAttributedDurationString:(NSInteger)seconds withFont:(UIFont *)font{
    
    UIFont *smallerFont = [font fontWithSize:16.0];
    
    NSMutableDictionary *numbersDict = [NSMutableDictionary dictionaryWithObject:[UIColor blackColor] forKey:NSForegroundColorAttributeName];
    [numbersDict setObject:font forKey:NSFontAttributeName];
    
    NSMutableDictionary *stringsDict = [NSMutableDictionary dictionaryWithObject:[UIColor grayColor] forKey:NSForegroundColorAttributeName];
    [stringsDict setObject:smallerFont forKey:NSFontAttributeName];
    
    
    int minutes = (int)(seconds/60);
    if (minutes > 59) {
        NSMutableAttributedString *formattedString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%d", (int)(minutes/60)] attributes:numbersDict];
        [formattedString appendAttributedString:[[NSMutableAttributedString alloc] initWithString:@"h " attributes:stringsDict]];
        
        [formattedString appendAttributedString:[[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%d", minutes % 60] attributes:numbersDict]];
        
        [formattedString appendAttributedString:[[NSMutableAttributedString alloc] initWithString:@"min" attributes:stringsDict]];
        
        return formattedString;
    }else{
        NSMutableAttributedString *formattedString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%d", minutes] attributes:numbersDict];
        [formattedString appendAttributedString:[[NSMutableAttributedString alloc] initWithString:@"min" attributes:stringsDict]];
        
        return formattedString;
    }
    
}

+(NSAttributedString *)formatAttributedString:(NSString *)numberString withUnit:(NSString *)unitString withFont:(UIFont *)font andUnitFontSize:(NSInteger)smallFontSize{
    
    UIFont *smallerFont = [font fontWithSize:smallFontSize];
    
    //    NSMutableDictionary *numbersDict = [NSMutableDictionary dictionaryWithObject:[UIColor blackColor] forKey:NSForegroundColorAttributeName];
    NSMutableDictionary *numbersDict = [NSMutableDictionary dictionaryWithObject:font forKey:NSFontAttributeName];
    //    [numbersDict setObject:font forKey:NSFontAttributeName];
    
    NSMutableDictionary *stringsDict = [NSMutableDictionary dictionaryWithObject:[UIColor grayColor] forKey:NSForegroundColorAttributeName];
    [stringsDict setObject:smallerFont forKey:NSFontAttributeName];
    
    
    NSMutableAttributedString *formattedString = [[NSMutableAttributedString alloc] initWithString:numberString attributes:numbersDict];
    [formattedString appendAttributedString:[[NSMutableAttributedString alloc] initWithString:unitString attributes:stringsDict]];
    
    return formattedString;
}

+(NSAttributedString *)highlightSubstringInString:(NSString *)text substring:(NSString *)substring withNormalFont:(UIFont *)font{
    //    [UIColor colorWithRed:51.0/255.0 green:153.0/255.0 blue:102/255.0 alpha:1.0]
    NSMutableDictionary *subStringDict = [NSMutableDictionary dictionaryWithObject:[AppManagerBase systemOrangeColor] forKey:NSForegroundColorAttributeName];
    [subStringDict setObject:font forKey:NSFontAttributeName];
    
    NSMutableDictionary *restStringDict = [NSMutableDictionary dictionaryWithObject:font forKey:NSFontAttributeName];
    
    if (text == nil)
        return nil;
    
    if (substring == nil)
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

#endif

@end
