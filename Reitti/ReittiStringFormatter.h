//
//  ReittiStringFormatter.h
//  Reitti
//
//  Created by Anteneh Sahledengel on 27/2/14.
//  Copyright (c) 2014 Anteneh Sahledengel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

#if !(APPLE_WATCH) && !(DEPARTURES_WIDGET)
#import <ArcGIS/ArcGIS.h>
#endif

@interface ReittiStringFormatter : NSObject

+(NSString *)formatHSLAPITimeWithColon:(NSString *)hslTime;
+(NSString *)formatHSLAPITimeToHumanTime:(NSString *)hslTime;
//+(NSString *)formatHourRangeStringFrom:(NSDate *)fromTime toDate:(NSDate *)toTime;
//+(NSString *)formatPrittyDate:(NSDate *)date;
//+(NSString *)formatFullDate:(NSDate *)date;
//+(NSString *)formatHourStringFromDate:(NSDate *)date;
+(NSString *)formatDurationString:(NSInteger)seconds;
+(NSString *)formatFullDurationString:(NSInteger)seconds;

+(NSString *)formatHSLDateWithDots:(NSString *)hslData;
+(NSString *)commaSepStringFromArray:(NSArray *)array withSeparator:(NSString *)separator;
+(CLLocationCoordinate2D)convertStringTo2DCoord:(NSString *)coordString;
+(NSString *)convert2DCoordToString:(CLLocationCoordinate2D)coord;
//+(NSDate *)createDateFromString:(NSString *)timeString withMinOffset:(int)offset;
+(NSString *)formatRoundedNumberFromDouble:(double)doubleVal roundDigits:(int)roundPoints androundUp:(BOOL)roundUp;

#ifndef APPLE_WATCH
+(NSAttributedString *)formatAttributedDurationString:(NSInteger)seconds withFont:(UIFont *)font;
+(NSAttributedString *)formatAttributedString:(NSString *)numberString withUnit:(NSString *)unitString withFont:(UIFont *)font andUnitFontSize:(NSInteger)smallFontSize;
+(NSAttributedString *)highlightSubstringInString:(NSString *)text substring:(NSString *)substring withNormalFont:(UIFont *)font;
+(NSAttributedString *)highlightSubstringInString:(NSString *)text substrings:(NSArray *)substring withNormalFont:(UIFont *)font highlightedFont:(UIFont *)highlightedFont andHighlightColor:(UIColor *)highlightedColor;

#endif

#if !(APPLE_WATCH) && !(DEPARTURES_WIDGET)
+(NSString *)coordStringFromKkj3CoorsWithX:(NSNumber *)xCoord andY:(NSNumber *)yCoord;
+(AGSPoint *)convertCoordsToKkj3Point:(CLLocationCoordinate2D)coords;
#endif

@end
