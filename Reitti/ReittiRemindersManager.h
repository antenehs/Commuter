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

extern NSString *kRoutineNotificationFromName;
extern NSString *kRoutineNotificationFromCoords;
extern NSString *kRoutineNotificationToName;
extern NSString *kRoutineNotificationToCoords;
extern NSString *kRoutineNotificationUniqueName;

@interface ReittiRemindersManager : NSObject<UIAlertViewDelegate>

+(id)sharedManger;

-(void)setNotificationForDeparture:(StopDeparture *)departure inStop:(BusStop *)stop offset:(int)minute;
-(NSArray *)getAllDepartureNotifications;
-(NSArray *)getDepartureNotificationsForStop:(BusStop *)stop;

-(void)setNotificationForRoute:(Route *)route withMinOffset:(int)minute;
-(NSArray *)getAllRouteNotifications;
-(NSArray *)getRouteNotificationsForRoute:(Route *)route;

-(void)cancelNotifications:(NSArray *)notification;

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

-(void)updateRoutineForDeletedBookmarkNamed:(NSString *)bookmarkName;

@property(nonatomic, strong)NSMutableArray *allRoutines;
@property(nonatomic, strong)NSMutableArray *allSavedRoutineIds;

@property(nonatomic, strong)NSString *reminderMessageFormater;
@property(nonatomic, strong)NSManagedObjectContext *managedObjectContext;

@end
