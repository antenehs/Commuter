//
//  ReittiRemindersManager.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 4/4/15.
//  Copyright (c) 2015 Anteneh Sahledengel. All rights reserved.
//

#import "ReittiRemindersManager.h"
#import "ReittiStringFormatter.h"
#import <EventKit/EventKit.h>

@interface ReittiRemindersManager ()

@property (nonatomic, strong)EKEventStore * eventStore;

@end

@implementation ReittiRemindersManager

@synthesize reminderMessageFormater;

-(id)init{
    _eventStore = [[EKEventStore alloc] init];
    
    [_eventStore requestAccessToEntityType:EKEntityTypeReminder
                                completion:^(BOOL granted, NSError *error) {
                                    if (!granted){
                                        NSLog(@"Access to store not granted");
                                    }
                                }];
    reminderMessageFormater = @"Your ride will leave in %d minutes.";
    return self;
}

-(BOOL)isAppAutorizedForReminders{
    EKAuthorizationStatus status = [EKEventStore authorizationStatusForEntityType:EKEntityTypeReminder];
    
    if (status != EKAuthorizationStatusAuthorized) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"No Access to Reminders app"                                                                                      message:@"Please grant access to the Reminders app from Settings/Privacy/Reminders to use this feature."
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        [alertView show];
        return NO;
    }else{
        return YES;
    }
}

-(void)setReminderWithMinOffset:(int)minute andHourString:(NSString *)timeString{
    EKAuthorizationStatus status = [EKEventStore authorizationStatusForEntityType:EKEntityTypeReminder];
    
    if (status == EKAuthorizationStatusAuthorized) {
        if ([self createEKReminderWithMinOffset:minute andHourString:timeString]) {
            //[self showNotificationWithMessage:@"Reminder set successfully!" messageType:RNotificationTypeConfirmation forSeconds:5 keppingSearchView:YES];
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Got it!"
                                                                message:@"You will be reminded."
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
            [alertView show];
        }
        
    }else{
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"No Access to Reminders app"                                                                                      message:@"Please grant access to the Reminders app from Settings/Privacy/Reminders to use this feature."
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        [alertView show];
    }
}

-(BOOL)createEKReminderWithMinOffset:(int)minutes andHourString:(NSString *)timeString{
    NSDate *date = [ReittiStringFormatter createDateFromString:timeString withMinOffset:minutes];
    
    if (date == nil) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Uh-oh"                                                                                      message:@"Setting reminder failed."
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        [alertView show];
        return NO;
    }
    
    if ([[NSDate date] compare:date] == NSOrderedDescending ) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Just so you know"                                                                                      message:@"The alarm time you set has already past."
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        [alertView show];
    }
    
    EKReminder *reminder = [EKReminder reminderWithEventStore:_eventStore];
    
    reminder.title = [NSString stringWithFormat:reminderMessageFormater, minutes];
    
    reminder.calendar = [_eventStore defaultCalendarForNewReminders];
    
    EKAlarm *alarm = [EKAlarm alarmWithAbsoluteDate:date];
    
    [reminder addAlarm:alarm];
    
    NSError *error = nil;
    
    [_eventStore saveReminder:reminder commit:YES error:&error];
    
    return YES;
}

@end
