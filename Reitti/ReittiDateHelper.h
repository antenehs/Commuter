//
//  ReittiDateHelper.h
//  Reitti
//
//  Created by Anteneh Sahledengel on 17/4/16.
//  Copyright © 2016 Anteneh Sahledengel. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ReittiDateHelper : NSObject

+(id)sharedFormatter;

-(NSDate *)dateFromApiDateString:(NSString *)dateString andHourString:(NSString *)hourString;
-(NSDate *)dateFromFullApiDateString:(NSString *)fullDateString;
-(NSString *)formatHourStringFromDate:(NSDate *)date;
-(NSString *)formatHourRangeStringFrom:(NSDate *)fromTime toDate:(NSDate *)toTime;
-(NSString *)formatDate:(NSDate *)date;
-(NSString *)formatHoursOrFullDateIfNotToday:(NSDate *)date;
-(NSString *)formatPrittyDate:(NSDate *)date;
-(NSDate *)createDateFromString:(NSString *)timeString withMinOffset:(int)offset;

-(NSString *)digitransitQueryDateStringFromDate:(NSDate *)date;
-(NSString *)digitransitQueryTimeStringFromDate:(NSDate *)date;

+(BOOL)isSameDateAsToday:(NSDate *)date1;
+(NSInteger)daysBetweenDate:(NSDate*)fromDateTime andDate:(NSDate*)toDateTime;

@property (nonatomic, strong) NSDateFormatter *apiHourFormatter;
@property (nonatomic, strong) NSDateFormatter *apiDateFormatter;
@property (nonatomic, strong) NSDateFormatter *apiFullDateFormatter;

@property (nonatomic, strong) NSDateFormatter *hourAndMinFormatter;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@property (nonatomic, strong) NSDateFormatter *fullDateFormatter;

@property (nonatomic, strong) NSDateFormatter *digiTransitDateFormatter;
@property (nonatomic, strong) NSDateFormatter *digiTransitTimeFormatter;

@end
