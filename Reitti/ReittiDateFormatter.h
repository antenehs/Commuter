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

-(NSDate *)dateFromApiDateString:(NSString *)dateString andHourString:(NSString *)hourString;
-(NSDate *)dateFromFullApiDateString:(NSString *)fullDateString;
-(NSString *)formatHourStringFromDate:(NSDate *)date;
-(NSString *)formatHourRangeStringFrom:(NSDate *)fromTime toDate:(NSDate *)toTime;
-(NSString *)formatDate:(NSDate *)date;
-(NSString *)formatHoursOrFullDateIfNotToday:(NSDate *)date;
-(NSString *)formatPrittyDate:(NSDate *)date;
-(NSDate *)createDateFromString:(NSString *)timeString withMinOffset:(int)offset;

+(BOOL)isSameDateAsToday:(NSDate *)date1;

@property (nonatomic, strong) NSDateFormatter *apiHourFormatter;
@property (nonatomic, strong) NSDateFormatter *apiDateFormatter;
@property (nonatomic, strong) NSDateFormatter *apiFullDateFormatter;

@property (nonatomic, strong) NSDateFormatter *hourAndMinFormatter;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@property (nonatomic, strong) NSDateFormatter *fullDateFormatter;

@end
