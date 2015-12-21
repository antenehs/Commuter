//
//  ReittiRemindersManager.h
//  Reitti
//
//  Created by Anteneh Sahledengel on 4/4/15.
//  Copyright (c) 2015 Anteneh Sahledengel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RoutineEntity.h"
#import "EnumManager.h"

extern NSString *kRoutineNotificationFromName;
extern NSString *kRoutineNotificationFromCoords;
extern NSString *kRoutineNotificationToName;
extern NSString *kRoutineNotificationToCoords;
extern NSString *kRoutineNotificationUniqueName;

@interface ReittiRemindersManager : NSObject<UIAlertViewDelegate>

+(id)sharedManger;


/*Uncomment the following to have reminders*/
//-(BOOL)isAppAutorizedForReminders;
//-(void)setReminderWithMinOffset:(int)minute andHourString:(NSString *)timeString;

-(void)setNotificationWithMinOffset:(int)minute andHourString:(NSString *)timeString;
-(void)setNotificationWithMinOffset:(int)minute andTime:(NSDate *)date;

+(BOOL)isFirstRequest;
-(BOOL)isLocalNotificationEnabled;
-(void)registerNotification;

+(NSString *)displayStringForSeletedDays:(NSArray *)daysList;
+(NSArray *)allDayNamesArray;
+(NSArray *)allDayNumbersArray;

-(void)saveRoutineToCoreData:(RoutineEntity *)routine;
-(void)deleteSavedRoutineForObjectId:(NSNumber *)objectId;
-(void)deleteSavedRoutine:(RoutineEntity *)routineToDelete;
-(void)deleteAllSavedRoutines;
-(NSArray *)fetchAllSavedRoutinesFromCoreData;
-(void)fetchAllSavedRoutineIdsFromCoreData;
-(RoutineEntity *)fetchSavedRoutineFromCoreDataForId:(NSNumber *)code;

@property(nonatomic, strong)NSMutableArray *allRoutines;
@property(nonatomic, strong)NSMutableArray *allSavedRoutineIds;

@property(nonatomic, strong)NSString *reminderMessageFormater;
@property(nonatomic, strong)NSManagedObjectContext *managedObjectContext;

@end
