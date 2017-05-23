//
//  NSDate+Helper.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 1/12/15.
//  Copyright © 2015 Anteneh Sahledengel. All rights reserved.
//

#import "NSDate+Helper.h"

@implementation NSDate (Helper)

-(BOOL)asa_IsEqualToDateIgnoringSeconds:(NSDate *)otherDate {
    NSTimeInterval difference = [self timeIntervalSinceDate:otherDate];
    
    return difference < 0 ? difference > -60 : difference < 60;
}

-(NSDate *)asa_dateIgnoringTime {
    NSDateComponents *components = [[NSCalendar currentCalendar]
                                    components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit
                                    fromDate:[NSDate date]];
    return [[NSCalendar currentCalendar] dateFromComponents:components];
}

@end
