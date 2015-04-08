//
//  ReittiRemindersManager.h
//  Reitti
//
//  Created by Anteneh Sahledengel on 4/4/15.
//  Copyright (c) 2015 Anteneh Sahledengel. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ReittiRemindersManager : NSObject

-(BOOL)isAppAutorizedForReminders;
-(void)setReminderWithMinOffset:(int)minute andHourString:(NSString *)timeString;

@property(nonatomic, strong)NSString *reminderMessageFormater;

@end
