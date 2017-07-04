//
//  ReittiRemindersManager.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 4/4/15.
//  Copyright (c) 2015 Anteneh Sahledengel. All rights reserved.
//

#import "ReittiRemindersManager.h"
#import "ReittiStringFormatter.h"
#import "ReittiNotificationHelper.h"
#import "CoreDataManager.h"
#import <EventKit/EventKit.h>
#import "SettingsManager.h"
#import "RettiDataManager.h"
#import "AppManager.h"
#import "ASA_Helpers.h"

@import UserNotifications;

@interface ReittiRemindersManager ()

@property (nonatomic, strong)EKEventStore * eventStore;
@property (nonatomic, strong)SettingsManager *settingsManager;

@end

@implementation ReittiRemindersManager

@synthesize allRoutines,allSavedRoutineIds;
@synthesize managedObjectContext;

+(id)sharedManger{
    static ReittiRemindersManager *remindersManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        remindersManager = [[self alloc] init];
    });
    
    return remindersManager;
}

-(id)init{
    self.managedObjectContext = [[CoreDataManager sharedManager] managedObjectContext];
    self.settingsManager = [SettingsManager sharedManager];
    
    self.allRoutines = [[self fetchAllSavedRoutinesFromCoreData] mutableCopy];
    
    //Do some sanity check
    [self checkIfRoutineNotificationsAreValid:self.allRoutines];
    
    if ([AppManager isProVersion])
        [self registerCategoriesAndActions];
    
    //TODO:
    [[UIApplication sharedApplication] registerForRemoteNotifications];
    
    return self;
}

#pragma mark - Departure notif methods
-(void)setNotificationForDeparture:(StopDeparture *)departure inStop:(BusStop *)stop offset:(int)minute showNotifInController:(UIViewController *)controller {
    DepartureNotification *notification = [DepartureNotification notificationForDeparture:departure stop:stop offsetMin:minute];
    
    [self scheduleNotification:[notification notificationRequest] forDate:notification.fireDate showNotifInController:controller];
}

-(void)getAllDepartureNotificationsWithCompletion:(ActionBlock)completion {
    [[UNUserNotificationCenter currentNotificationCenter] getPendingNotificationRequestsWithCompletionHandler:^(NSArray<UNNotificationRequest *> * _Nonnull requests) {
        [self asa_ExecuteBlockInUIThread:^{
            NSMutableArray *departureNotifications = [@[] mutableCopy];
            for (UNNotificationRequest *request in requests) {
                if ([request.content.categoryIdentifier isEqualToString:kNotificationTypeDeparture]) {
                    DepartureNotification *notif = [[DepartureNotification alloc] initFromDictionary:request.content.userInfo];
                    if (notif) {
                        notif.relatedNotification = request;
                        [departureNotifications addObject:notif];
                    }
                }
            }
            
            completion([NSArray arrayWithArray:departureNotifications]);
        }];
    }];
}

-(void)getDepartureNotificationsForStop:(BusStop *)stop withCompletion:(ActionBlock)completion {
    [self getAllDepartureNotificationsWithCompletion:^(NSArray *notifs){
        NSArray *notifsForStop = [notifs filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"stopName == %@", [DepartureNotification notificationStopNameForStop:stop]]];
        
        completion(notifsForStop);
    }];
}

#pragma mark - Route notification methods
-(void)setNotificationForRoute:(Route *)route withMinOffset:(int)minute showNotifInController:(UIViewController *)controller {
    RouteNotification *routeNotif = [RouteNotification notificationForRoute:route offsetMn:minute];

    [self scheduleNotification:[routeNotif notificationRequest] forDate:routeNotif.fireDate showNotifInController:controller];
}

-(void)getAllRouteNotificationsWithCompletion:(ActionBlock)completion {
    [[UNUserNotificationCenter currentNotificationCenter] getPendingNotificationRequestsWithCompletionHandler:^(NSArray<UNNotificationRequest *> * _Nonnull requests) {
        [self asa_ExecuteBlockInUIThread:^{
            NSMutableArray *departureNotifications = [@[] mutableCopy];
            for (UNNotificationRequest *request in requests) {
                if ([request.content.categoryIdentifier isEqualToString:kNotificationTypeRoute]) {
                    RouteNotification *notif = [[RouteNotification alloc] initFromDictionary:request.content.userInfo];
                    if (notif) {
                        notif.relatedNotification = request;
                        [departureNotifications addObject:notif];
                    }
                }
            }
            
            completion([NSArray arrayWithArray:departureNotifications]);
        }];
    }];
}

-(void)getRouteNotificationsForRoute:(Route *)route withCompletion:(ActionBlock)completion {
    [self getAllRouteNotificationsWithCompletion:^(NSArray *notifs){
        NSArray *notifsForRoute = [notifs filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"routeUniqueIdentifier == %@", route.routeUniqueName]];
        
        completion(notifsForRoute);
    }];
}

#pragma mark - Routine notification methods
-(void)checkIfRoutineNotificationsAreValid:(NSArray *)routines {
    NSArray *localNotifications = [[UIApplication sharedApplication] scheduledLocalNotifications];
    
    int enabledRoutines = 0;
    
    for (RoutineEntity *routine in routines) {
        if (routine.isEnabled) {
            enabledRoutines++;
        }
    }
    
    if (localNotifications.count != enabledRoutines || ![SettingsManager migratedRoutines]) {
        //Cancel all notification
        [self recreateAllNotificationsForRoutines:routines];
        
        [SettingsManager setMigratedRoutines:YES];
    }
}

-(void)recreateAllNotificationsForRoutines:(NSArray *)routines {
    [self registerNotificationWithCompletion:^(BOOL granted) {
        if (granted) {
            for (RoutineEntity *routine in routines) {
                [self cancelUserNotificationsForRoutine:routine];
                if (routine.isEnabled) {
                    [self scheduleLocalNotificationForRoutine:routine];
                }
            }
        }
    }];
}

-(void)scheduleLocalNotificationForRoutine:(RoutineEntity *)routine {
    [self cancelUserNotificationsForRoutine:routine];

    UNMutableNotificationContent *notificationContent = [self notificationContentForRoutine:routine];
    
    UNCalendarNotificationTrigger *trigger;
    
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    [gregorian setLocale:[NSLocale currentLocale]];
    
    if (routine.repeatDays.count == 0) {
        return;
    }else if (routine.repeatDays.count == 7){
//        NSDateComponents *dailyComponents = [gregorian components:NSCalendarUnitHour|NSCalendarUnitMinute|NSCalendarUnitSecond fromDate:[NSDate dateWithTimeIntervalSinceNow:10]];
        NSDateComponents *dailyComponents = [gregorian components:NSCalendarUnitHour|NSCalendarUnitMinute fromDate:routine.routeDate];
        trigger = [UNCalendarNotificationTrigger triggerWithDateMatchingComponents:dailyComponents  repeats:YES];
        UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:routine.uniqueName content:notificationContent trigger:trigger];
        [self scheduleNotification:request];
    }else{
        NSDateComponents *weaklyComponents = [gregorian components:NSCalendarUnitWeekday|NSCalendarUnitHour|NSCalendarUnitMinute fromDate:routine.routeDate];
        
        //Schedule notifications for each day separately
        for (NSNumber *weekDay in routine.repeatDays) {
            //In geregorian calendar, Sunday == 1
            int dayNumber = [weekDay intValue];
            
            if (dayNumber == 7) dayNumber = 1;
            else dayNumber++;
            
            [weaklyComponents setWeekday:dayNumber];
            
            trigger = [UNCalendarNotificationTrigger triggerWithDateMatchingComponents:weaklyComponents  repeats:YES];
            
            UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:[NSString stringWithFormat:@"%@-%d", routine.uniqueName, dayNumber]
                                                                                  content:notificationContent
                                                                                  trigger:trigger];
            [self scheduleNotification:request];
        }
    }
}

-(UNMutableNotificationContent *)notificationContentForRoutine:(RoutineEntity *)routine {
    UNMutableNotificationContent *content = [UNMutableNotificationContent new];
    content.title = @"Routine reminder";
    content.body = [NSString stringWithFormat:@"Time to go to %@", routine.toDisplayName];
    if (routine.toneName == KNotificationDefaultSoundName) {
        content.sound = [UNNotificationSound defaultSound];
    }else{
        NSString *fullToneName = [NSString stringWithFormat:@"%@.mp3",routine.toneName];
        content.sound = [UNNotificationSound soundNamed:fullToneName];
    }
    content.userInfo = [routine dictionaryRepresentation];
    content.categoryIdentifier = kNotificationTypeRoutine;
    
    return content;
}

-(void)cancelUserNotificationsForRoutine:(RoutineEntity *)routine {
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    [center removePendingNotificationRequestsWithIdentifiers:routine.dailyUniqueNames];
}

#pragma mark - Generic notification helpers
-(void)scheduleNotification:(UNNotificationRequest *)notifRequest forDate:(NSDate *)date showNotifInController:(UIViewController *)viewController {
    ActionBlock scheduleNotif = ^{
        if (date == nil) {
            [ReittiNotificationHelper showSimpleMessageWithTitle:@"Uh-oh"
                                                      andContent:@"Setting reminder failed."inController:viewController];
            
            return;
        }
        
        if ([[NSDate date] compare:date] == NSOrderedDescending ) {
            [ReittiNotificationHelper showSimpleMessageWithTitle:@"You might wanna hurry up!"
                                                      andContent:@"The alarm time you selected has already passed."
                                                    inController:viewController];
        } else {
            
            [ReittiNotificationHelper showSimpleMessageWithTitle:@"Got it!"
                                                      andContent:@"You will be reminded."
                                                    inController:viewController];
            
            [self scheduleNotification:notifRequest];
        }
        
    };
    
    [self isUserNotificationEnabledWithCompletion:^(BOOL enabled) {
        if (enabled)
            scheduleNotif();
        else {
            [self registerNotificationWithCompletion:^(BOOL granted) {
                if (granted)
                    scheduleNotif();
                else
                    [self showAccessNotGrantedMessageInController:viewController];
            }];
        }
        
    }];
}

-(void)scheduleNotification:(UNNotificationRequest *)notifRequest {
    if (!notifRequest)
        return;
    
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    [center addNotificationRequest:notifRequest withCompletionHandler:^(NSError * _Nullable error) {
        if (error != nil) {
            NSLog(@"Something went wrong adding notification: %@",error);
        }
    }];
}

-(void)cancelUserNotifications:(NSArray *)notifications {
    if (!notifications) return;
    
    NSArray *identifiers = [notifications asa_mapWith:^NSString * (NotificationBase *element) {
        return element.relatedNotification.identifier;
    }];
    
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    
    [center removePendingNotificationRequestsWithIdentifiers:identifiers];
}

-(void)snoozeNotification:(UNNotificationRequest *)notifRequest {
    if (!notifRequest) return;
    
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    
    UNTimeIntervalNotificationTrigger *newTrigger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:300 repeats:NO];
    
    UNMutableNotificationContent *newContent = [notifRequest.content mutableCopy];
    
    if (notifRequest.content.userInfo[kNotificationSnoozedBodyUserInfoKey]) {
        newContent.body = notifRequest.content.userInfo[kNotificationSnoozedBodyUserInfoKey];
    }
    
    UNNotificationRequest *newRequest = [UNNotificationRequest requestWithIdentifier:notifRequest.identifier
                                                                             content:newContent
                                                                             trigger:newTrigger];
    
    [center removePendingNotificationRequestsWithIdentifiers:@[notifRequest.identifier]];
    
    [self scheduleNotification:newRequest];
}

-(void)isUserNotificationEnabledWithCompletion:(NotifRegistrationBlock)completion {
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    [center getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * _Nonnull settings) {
        [self asa_ExecuteBlockInUIThread:^{
            completion(settings.authorizationStatus == UNAuthorizationStatusAuthorized);
            
            NSString *value = settings.authorizationStatus == UNAuthorizationStatusAuthorized ? @"true" : @"false";
            [[ReittiAnalyticsManager sharedManager] trackUserProperty:kUserAllowedReminders value:value];
        }];
    }];
}

-(void)registerNotificationWithCompletion:(NotifRegistrationBlock)completion {
    UNAuthorizationOptions options = UNAuthorizationOptionAlert + UNAuthorizationOptionSound;
    
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    [center requestAuthorizationWithOptions:options
                          completionHandler:^(BOOL granted, NSError * _Nullable error) {
                              [self asa_ExecuteBlockInUIThread:^{
                                  if (completion)
                                      completion(granted);
                                  
                                  if (!granted) NSLog(@"Something went wrong registering notifs.");
                              }];
                          }];
}

-(void)registerCategoriesAndActions {
    UNUserNotificationCenter* center = [UNUserNotificationCenter currentNotificationCenter];
    
    UNNotificationAction* snoozeAction = [UNNotificationAction
                                          actionWithIdentifier:@"SNOOZE_ACTION"
                                          title:@"Snooze"
                                          options:UNNotificationActionOptionNone];
    
    UNNotificationAction* stopDeparturesAction = [UNNotificationAction
                                        actionWithIdentifier:@"DEPARTURES_ACTION"
                                        title:@"View Stop"
                                        options:UNNotificationActionOptionForeground|UNNotificationActionOptionAuthenticationRequired];
    
    UNNotificationAction* routineRoutesAction = [UNNotificationAction
                                                  actionWithIdentifier:@"ROUTINE_ROUTES_ACTION"
                                                  title:@"Get Routes"
                                                  options:UNNotificationActionOptionForeground|UNNotificationActionOptionAuthenticationRequired];
    
    UNNotificationCategory* departureCategory = [UNNotificationCategory
                                               categoryWithIdentifier:kNotificationTypeDeparture
                                               actions:@[stopDeparturesAction, snoozeAction]
                                               intentIdentifiers:@[]
                                               options:UNNotificationCategoryOptionCustomDismissAction];
    
    UNNotificationCategory* routeCategory = [UNNotificationCategory
                                                 categoryWithIdentifier:kNotificationTypeRoute
                                                 actions:@[snoozeAction]
                                                 intentIdentifiers:@[]
                                                 options:UNNotificationCategoryOptionCustomDismissAction];
    
    UNNotificationCategory* routineCategory = [UNNotificationCategory
                                                 categoryWithIdentifier:kNotificationTypeRoutine
                                                 actions:@[routineRoutesAction, snoozeAction]
                                                 intentIdentifiers:@[]
                                                 options:UNNotificationCategoryOptionCustomDismissAction];
    
    [center setNotificationCategories:[NSSet setWithObjects:departureCategory, routeCategory, routineCategory, nil]];
}

//-(void)scheduleOneTimeNotificationForDate:(NSDate *)date message:(NSString *)message userInfo:(NSDictionary *)userInfo {
//    UILocalNotification* localNotification = [[UILocalNotification alloc] init];
//    localNotification.alertTitle = @"Time to go";
//    localNotification.alertBody = message;
//    NSString *toneName = [self.settingsManager toneName];
//    if (toneName == UILocalNotificationDefaultSoundName) {
//        localNotification.soundName = UILocalNotificationDefaultSoundName;
//    }else{
//        localNotification.soundName = [toneName containsString:@".mp3"] ? toneName : [NSString stringWithFormat:@"%@.mp3",toneName];
//    }
//
//    localNotification.userInfo = userInfo;
//    localNotification.timeZone = [NSTimeZone defaultTimeZone];
//    localNotification.fireDate = date;
//
//    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
//}

//-(BOOL)isLocalNotificationEnabled {
//    BOOL toReturn = NO;
//    UIUserNotificationSettings *grantedSettings = [[UIApplication sharedApplication] currentUserNotificationSettings];
//
//    if (grantedSettings.types == UIUserNotificationTypeNone) {
//        toReturn = NO;
//    }
//    else if (grantedSettings.types & UIUserNotificationTypeSound & UIUserNotificationTypeAlert ){
//        toReturn = YES;
//    }
//    else if (grantedSettings.types  & UIUserNotificationTypeAlert){
//        toReturn = YES;
//    }
//
//    return toReturn;
//}

/*
 
 +(BOOL)notificationAccessRequested {
 NSString *isAlradyRequested = [[NSUserDefaults standardUserDefaults] objectForKey:@"NotificationAccessRequested"];
 
 return isAlradyRequested != nil;
 }
 
 -(void)setNotificationAccessRequested {
 NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
 
 if (standardUserDefaults) {
 [standardUserDefaults setObject:@"YES" forKey:@"NotificationAccessRequested"];
 [standardUserDefaults synchronize];
 }
 }
 */

/*
 -(void)registerNotification {
 
 UIUserNotificationType types = UIUserNotificationTypeBadge |
 UIUserNotificationTypeSound | UIUserNotificationTypeAlert;
 
 UIUserNotificationSettings *mySettings =
 [UIUserNotificationSettings settingsForTypes:types categories:nil];
 
 [[UIApplication sharedApplication] registerUserNotificationSettings:mySettings];
 [[UIApplication sharedApplication] registerForRemoteNotifications];
 
 [self setNotificationAccessRequested];
 
 //If notifications is not enabled at this point, must be the user disagreed.
 }
 */

#pragma mark - Generic helpers
-(void)showAccessNotGrantedMessageInController:(UIViewController *)viewController {
    UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"No Access to Notifications Granted"
                                                                        message:@"Please grant access to Notifications from Settings to use this feature."
                                                                 preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) { }];
    [controller addAction:okAction];
    
    UIAlertAction *settingAction = [UIAlertAction actionWithTitle:@"Settings" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [ReittiRemindersManager openAppSettings];
    }];
    
    [controller addAction:settingAction];
    
    [viewController presentViewController:controller animated:YES completion:nil];
}

#pragma mark - Static Helpers
+(NSString *)displayStringForSeletedDays:(NSArray *)daysList{
    if (daysList.count == 0) {
        return @"Never";
    }else if (daysList.count == 7){
        return @"Everyday";
    }else if (daysList.count == 5 &&
              ![daysList containsObject:@6] &&
              ![daysList containsObject:@7]){
        return @"Weekdays";
    }else{
        //Sort day list
        NSSortDescriptor *highestToLowest = [NSSortDescriptor sortDescriptorWithKey:@"self" ascending:YES];
        daysList = [daysList sortedArrayUsingDescriptors:[NSArray arrayWithObject:highestToLowest]];
        NSMutableArray *tempArray = [@[] mutableCopy];
        for (NSNumber *number in daysList) {
            [tempArray addObject:[EnumManager shortDayNameForWeekDay:(WeekDay)[number intValue]]];
        }
        
        return [ReittiStringFormatter commaSepStringFromArray:tempArray withSeparator:@" · "];;
    }
}

+(NSArray *)allDayNamesArray{
    return @[[EnumManager dayNameForWeekDay:WeekDayMonday],
             [EnumManager dayNameForWeekDay:WeekDayTuesday],
             [EnumManager dayNameForWeekDay:WeekDayWedensday],
             [EnumManager dayNameForWeekDay:WeekDayThursday],
             [EnumManager dayNameForWeekDay:WeekDayFriday],
             [EnumManager dayNameForWeekDay:WeekDaySaturday],
             [EnumManager dayNameForWeekDay:WeekDaySunday]];
}

+(NSArray *)allDayNumbersArray{
    return @[[NSNumber numberWithInt:WeekDayMonday],
             [NSNumber numberWithInt:WeekDayTuesday],
             [NSNumber numberWithInt:WeekDayWedensday],
             [NSNumber numberWithInt:WeekDayThursday],
             [NSNumber numberWithInt:WeekDayFriday],
             [NSNumber numberWithInt:WeekDaySaturday],
             [NSNumber numberWithInt:WeekDaySunday]];
}

+(void)openAppSettings{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
}

#pragma mark - Core data Methods
-(void)saveRoutineToCoreData:(RoutineEntity *)routine{
    //Set objectId
    
    //Set modification date
    routine.dateModified = [NSDate date];
    
    NSError *error = nil;
    
    if (![routine.managedObjectContext save:&error]) {
        // Handle error
        NSLog(@"Unresolved error %@, %@: Error when saving the Managed object!!", error, [error userInfo]);
        exit(-1);  // Fail
    }
    
    [self fetchAllSavedRoutineIdsFromCoreData];
    self.allRoutines = [[self fetchAllSavedRoutinesFromCoreData] mutableCopy];
    
    [self recreateAllNotificationsForRoutines:self.allRoutines];
}

-(void)deleteSavedRoutineForObjectId:(NSNumber *)objectId{
    RoutineEntity *routineToDelete = [self fetchSavedRoutineFromCoreDataForId:objectId];
    
    [self.managedObjectContext deleteObject:routineToDelete];
    
    NSError *error = nil;
    if (![self.managedObjectContext save:&error]) {
        // Handle error
        NSLog(@"Unresolved error %@, %@: Error when saving the Managed object:MainMenu!!", error, [error userInfo]);
        exit(-1);  // Fail
    }
    
    [self fetchAllSavedRoutineIdsFromCoreData];
    [self fetchAllSavedRoutinesFromCoreData];
    
    self.allRoutines = [[self fetchAllSavedRoutinesFromCoreData] mutableCopy];
    [self recreateAllNotificationsForRoutines:self.allRoutines];
}

-(void)deleteSavedRoutine:(RoutineEntity *)routineToDelete{
    
    [self.managedObjectContext deleteObject:routineToDelete];
    
    NSError *error = nil;
    if (![self.managedObjectContext save:&error]) {
        // Handle error
        NSLog(@"Unresolved error %@, %@: Error when saving the Managed object:MainMenu!!", error, [error userInfo]);
        exit(-1);  // Fail
    }
    
    [self fetchAllSavedRoutineIdsFromCoreData];
    [self fetchAllSavedRoutinesFromCoreData];
    
    self.allRoutines = [[self fetchAllSavedRoutinesFromCoreData] mutableCopy];
    [self recreateAllNotificationsForRoutines:self.allRoutines];
}

-(void)deleteAllSavedRoutines{
    NSArray *routinesToDelete = [self fetchAllSavedRoutinesFromCoreData];
    
    for (RoutineEntity *routine in routinesToDelete) {
        [self.managedObjectContext deleteObject:routine];
    }
    
    NSError *error = nil;
    if (![self.managedObjectContext save:&error]) {
        // Handle error
        NSLog(@"Unresolved error %@, %@: Error when saving the Managed object!!", error, [error userInfo]);
        exit(-1);  // Fail
    }
    
    [self fetchAllSavedRoutineIdsFromCoreData];
    [self fetchAllSavedRoutinesFromCoreData];
    
    self.allRoutines = [[self fetchAllSavedRoutinesFromCoreData] mutableCopy];
    [self recreateAllNotificationsForRoutines:self.allRoutines];
}

//Return array of set dictionaries
-(NSArray *)fetchAllSavedRoutinesFromCoreData{
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity =
    
    [NSEntityDescription entityForName:@"RoutineEntity" inManagedObjectContext:self.managedObjectContext];
    
    [request setEntity:entity];
    
    [request setReturnsDistinctResults:YES];
    
    NSError *error = nil;
    
    NSArray *savedRoutines = [self.managedObjectContext executeFetchRequest:request error:&error];
    
    if ([savedRoutines count] != 0) {
        return savedRoutines;
    }
    
    return nil;
}

-(void)fetchAllSavedRoutineIdsFromCoreData{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity =
    
    [NSEntityDescription entityForName:@"RoutineEntity" inManagedObjectContext:self.managedObjectContext];
    
    [request setEntity:entity];
    
    [request setResultType:NSDictionaryResultType];
    
    [request setReturnsDistinctResults:YES];
    [request setPropertiesToFetch :[NSArray arrayWithObject: @"objectLID"]];
    
    NSError *error = nil;
    
    NSArray *routineCodes = [self.managedObjectContext executeFetchRequest:request error:&error];
    
    if ([routineCodes count] != 0) {
        allSavedRoutineIds = [self simplifyCoreDataDictionaryArray:routineCodes withKey:@"objectLID"] ;
    }
    else {
        allSavedRoutineIds = [[NSMutableArray alloc] init];
    }
}

-(RoutineEntity *)fetchSavedRoutineFromCoreDataForId:(NSNumber *)code{
    
    NSString *predString = [NSString stringWithFormat:@"objectLID == %@", code];
    
    NSArray *routines = [self fetchAllSavedRoutinesFromCoreDataForPredicateString:predString];
    
    if (routines && routines.count > 0)
        return routines[0];
    
    return nil;
}

-(NSArray *)fetchAllSavedRoutinesFromCoreDataForFromOrToName:(NSString *)displayName{
    NSString *predString = [NSString stringWithFormat:@"toDisplayName == '%@' || fromDisplayName == '%@'", displayName, displayName];
    
    return [self fetchAllSavedRoutinesFromCoreDataForPredicateString:predString];
}

-(NSArray *)fetchAllSavedRoutinesFromCoreDataForPredicateString:(NSString *)predString{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity =
    
    [NSEntityDescription entityForName:@"RoutineEntity" inManagedObjectContext:self.managedObjectContext];
    
    [request setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:predString];
    [request setPredicate:predicate];
    
    NSError *error = nil;
    
    NSArray *savedRoutines = [self.managedObjectContext executeFetchRequest:request error:&error];
    
    return savedRoutines;
}

-(void)updateRoutineForDeletedBookmarkNamed:(NSString *)bookmarkName{
    if (!bookmarkName)
        return;
    
    NSArray *routines = [self fetchAllSavedRoutinesFromCoreDataForFromOrToName:bookmarkName];
    
    for (RoutineEntity *routine in routines) {
        if ([routine.toDisplayName isEqualToString:bookmarkName])
            routine.toDisplayName = routine.toLocationName;
        
        if ([routine.fromDisplayName isEqualToString:bookmarkName])
            routine.fromDisplayName = routine.fromLocationName;
        
        [self saveRoutineToCoreData:routine];
    }
}

-(NSMutableArray *)simplifyCoreDataDictionaryArray:(NSArray *)array withKey:(NSString *)key{
    NSMutableArray *retArray = [[NSMutableArray alloc] init];
    for (NSDictionary * dict in array) {
        [retArray addObject:[dict objectForKey:key]];
    }
    return retArray;
}


@end
