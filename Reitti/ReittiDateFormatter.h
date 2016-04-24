//
//  ReittiDateFormatter.h
//  Reitti
//
//  Created by Anteneh Sahledengel on 17/4/16.
//  Copyright © 2016 Anteneh Sahledengel. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ReittiDateFormatter : NSObject

+(id)sharedFormatter;

- (NSDate *)dateFromMatkaDateString:(NSString *)dateString andHourString:(NSString *)hourString;
-(NSString *)formatHourStringFromDate:(NSDate *)date;
-(NSString *)formatHourRangeStringFrom:(NSDate *)fromTime toDate:(NSDate *)toTime;
-(NSString *)formatFullDate:(NSDate *)date;
-(NSString *)formatPrittyDate:(NSDate *)date;
-(NSDate *)createDateFromString:(NSString *)timeString withMinOffset:(int)offset;

@end
