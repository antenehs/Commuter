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
#import "BusStop.h"
#import "StopDeparture.h"
#import "Notifications.h"
#import "Route.h"

typedef void (^NotifRegistrationBlock)(BOOL granted);

@interface ReittiRemindersManager : NSObject

+(id)sharedManger;

-(void)setNotificationForDeparture:(StopDeparture *)departure inStop:(BusStop *)stop offset:(int)minute showNotifInController:(UIViewController *)controller;

-(void)getAllDepartureNotificationsWithCompletion:(ActionBlock)completion;
-(void)getDepartureNotificationsForStop:(BusStop *)stop withCompletion:(ActionBlock)completion;

-(void)setNotificationForRoute:(Route *)route withMinOffset:(int)minute showNotifInController:(UIViewController *)controller;

-(void)getAllRouteNotificationsWithCompletion:(ActionBlock)completion;
-(void)getRouteNotificationsForRoute:(Route *)route withCompletion:(ActionBlock)completion;

-(void)cancelUserNotifications:(NSArray *)notifications;
-(void)snoozeNotification:(UNNotificationRequest *)notifRequest;

-(void)isUserNotificationEnabledWithCompletion:(NotifRegistrationBlock)completion;

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

-(void)updateRoutineForDeletedBookmarkNamed:(NSString *)bookmarkName;

@property(nonatomic, strong)NSMutableArray *allRoutines;
@property(nonatomic, strong)NSMutableArray *allSavedRoutineIds;

@property(nonatomic, strong)NSString *reminderMessageFormater;
@property(nonatomic, strong)NSManagedObjectContext *managedObjectContext;

@end
