//
//  ReittiStringFormatter.h
//  Reitti
//
//  Created by Anteneh Sahledengel on 27/2/14.
//  Copyright (c) 2014 Anteneh Sahledengel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface ReittiStringFormatterE : NSObject

+(NSString *)formatHSLAPITimeWithColon:(NSString *)hslTime;
+(NSString *)formatHSLAPITimeToHumanTime:(NSString *)hslTime;
+(NSString *)formatHourRangeStringFrom:(NSDate *)fromTime toDate:(NSDate *)toTime;
+(NSString *)formatHourStringFromDate:(NSDate *)date;
+(NSString *)formatHSLHourFromDate:(NSDate *)date;
+(NSString *)formatHSLDateFromDate:(NSDate *)date;
+(NSString *)formatHSLDateWithDots:(NSString *)hslData;
+(NSString *)parseBusNumFromLineCode:(NSString *)lineCode;
+(NSString *)parseLineCodeFromLineInfoString:(NSString *)lineInfoString;
+(CLLocationCoordinate2D)convertStringTo2DCoord:(NSString *)coordString;
+(NSString *)convert2DCoordToString:(CLLocationCoordinate2D)coord;
+(NSDate *)createDateFromString:(NSString *)timeString withMinOffset:(int)offset;
+(NSString *)formatRoundedNumberFromDouble:(double)doubleVal roundDigits:(int)roundPoints androundUp:(BOOL)roundUp;
+(NSString *)commaSepStringFromArray:(NSArray *)array withSeparator:(NSString *)separator;

@end
