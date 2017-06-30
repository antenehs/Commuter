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

@interface ReittiRemindersManager ()

@property (nonatomic, strong)EKEventStore * eventStore;
@property (nonatomic, strong)SettingsManager *settingsManager;

@end

NSString *kNotificationTypeUserInfoKey = @"kNotificationTypeUserInfoKey";
NSString *kNotificationTypeRoutine = @"kNotificationTypeRoutine";
NSString *kNotificationTypeDeparture = @"kNotificationTypeDeparture";
NSString *kNotificationTypeRoute = @"kNotificationTypeRoute";

NSString *kRoutineNotificationFromName = @"kRoutineNotificationFromName";
NSString *kRoutineNotificationFromCoords = @"kRoutineNotificationFromCoords";
NSString *kRoutineNotificationToName = @"kRoutineNotificationToName";
NSString *kRoutineNotificationToCoords = @"kRoutineNotificationToCoords";
NSString *kRoutineNotificationUniqueName = @"kRoutineNotificationUniqueName";

@implementation ReittiRemindersManager

@synthesize allRoutines,allSavedRoutineIds;
@synthesize reminderMessageFormater, managedObjectContext;

+(id)sharedManger{
    static ReittiRemindersManager *remindersManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        remindersManager = [[self alloc] init];
    });
    
    return remindersManager;
}

-(id)init{
    reminderMessageFormater = @"Your ride will leave in %d minutes.";
    
    self.managedObjectContext = [[CoreDataManager sharedManager] managedObjectContext];
    self.settingsManager = [SettingsManager sharedManager];
    
    self.allRoutines = [[self fetchAllSavedRoutinesFromCoreData] mutableCopy];
    
    //Do some sanity check
    [self checkIfNotificationsAreValid:self.allRoutines];
    
    [[UIApplication sharedApplication] registerForRemoteNotifications];
    
    return self;
}

-(void)setNotificationForDate:(NSDate *)date message:(NSString *)message userInfo:(NSDictionary *)userInfo showNotifInController:(UIViewController *)viewController {
    //If it is first time, just create it becuase the user will be asked to enable it anyways.
    if ([self isLocalNotificationEnabled] || ![ReittiRemindersManager notificationAccessRequested]) {
        BOOL showConfirmation = [ReittiRemindersManager notificationAccessRequested];
        
        [self registerNotification];
        if (date == nil) {
            [ReittiNotificationHelper showSimpleMessageWithTitle:@"Uh-oh"
                                                      andContent:@"Setting reminder failed."
                                                    inController:viewController];
            
            return;
        }
    
        if ([[NSDate date] compare:date] == NSOrderedDescending ) {
            [ReittiNotificationHelper showSimpleMessageWithTitle:@"You might wanna hurry up!"
                                                      andContent:@"The alarm time you selected has already passed."
                                                    inController:viewController];
        } else {
            if (showConfirmation)
                [ReittiNotificationHelper showSimpleMessageWithTitle:@"Got it!"
                                                          andContent:@"You will be reminded."
                                                        inController:viewController];
            [self scheduleOneTimeNotificationForDate:date message:message userInfo:userInfo];
        }
        
    }else{
        UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"No Access to Notifications Granted"
                                                                            message:@"Please grant access to Notifications from Settings to use this feature."
                                                                     preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) { }];
        [controller addAction:okAction];
        
        UIAlertAction *settingAction = [UIAlertAction actionWithTitle:@"Settings" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self openAppSettings];
        }];
        [controller addAction:settingAction];
        
        [viewController presentViewController:controller animated:YES completion:nil];
    }
    
}

#pragma mark - Departure notif methods
-(void)setNotificationForDeparture:(StopDeparture *)departure inStop:(BusStop *)stop offset:(int)minute showNotifInController:(UIViewController *)controller {
    DepartureNotification *notification = [DepartureNotification notificationForDeparture:departure stop:stop offsetMin:minute];
    
    NSTimeInterval seconds = (minute * -60);
    NSDate *fireDate = [departure.departureTime dateByAddingTimeInterval:seconds];
    
    //For debug
//    NSTimeInterval seconds = 10;
//    NSDate *fireDate = [[NSDate date] dateByAddingTimeInterval:seconds];
    
    notification.fireDate = fireDate;
    notification.toneName = [self.settingsManager toneName];
    
    NSMutableDictionary *userInfo = [[notification dictionaryRepresentation] mutableCopy];
    if (userInfo)
        userInfo[kNotificationTypeUserInfoKey] = kNotificationTypeDeparture;
    
    
    
    [self setNotificationForDate:fireDate message:notification.body userInfo:userInfo showNotifInController:controller];
}

-(NSArray *)getAllDepartureNotifications {
    NSArray *allNotifications = [[UIApplication sharedApplication] scheduledLocalNotifications];
    NSMutableArray *departureNotifications = [@[] mutableCopy];
    
    for (UILocalNotification *notification in allNotifications) {
        if ([[self notificationTypeOf:notification] isEqualToString:kNotificationTypeDeparture]) {
            DepartureNotification *notif = [[DepartureNotification alloc] initFromDictionary:notification.userInfo];
            if (notif) {
                notif.relatedNotification = notification;
                [departureNotifications addObject:notif];
            }
        }
    }
    
    return departureNotifications;
}

-(NSArray *)getDepartureNotificationsForStop:(BusStop *)stop {
    NSArray *allDepartureNotifications = [self getAllDepartureNotifications];
    return [allDepartureNotifications filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"stopName == %@", [DepartureNotification notificationStopNameForStop:stop]]];
}

#pragma mark - Route notification methods
-(void)setNotificationForRoute:(Route *)route withMinOffset:(int)minute showNotifInController:(UIViewController *)controller {
    RouteNotification *routeNotif = [RouteNotification notificationForRoute:route offsetMn:minute];
    
    NSTimeInterval seconds = (minute * -60);
    NSDate *fireDate = [route.startingTimeOfRoute dateByAddingTimeInterval:seconds];
    
    routeNotif.fireDate = fireDate;
    routeNotif.toneName = [self.settingsManager toneName];
    
    NSMutableDictionary *userInfo = [[routeNotif dictionaryRepresentation] mutableCopy];
    if (userInfo)
        userInfo[kNotificationTypeUserInfoKey] = kNotificationTypeRoute;
    
    
    [self setNotificationForDate:fireDate message:routeNotif.body userInfo:userInfo showNotifInController:controller];
}

-(NSArray *)getAllRouteNotifications {
    NSArray *allNotifications = [[UIApplication sharedApplication] scheduledLocalNotifications];
    NSMutableArray *routeNotifications = [@[] mutableCopy];
    
    for (UILocalNotification *notification in allNotifications) {
        if ([[self notificationTypeOf:notification] isEqualToString:kNotificationTypeRoute]) {
            RouteNotification *notif = [[RouteNotification alloc] initFromDictionary:notification.userInfo];
            if (notif) {
                notif.relatedNotification = notification;
                [routeNotifications addObject:notif];
            }
        }
    }
    
    return routeNotifications;
}

-(NSArray *)getRouteNotificationsForRoute:(Route *)route {
    NSArray *allRouteNotifications = [self getAllRouteNotifications];
    return [allRouteNotifications filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"routeUniqueIdentifier == %@", route.routeUniqueName]];
}

-(void)cancelNotifications:(NSArray *)notifications {
    for (NotificationBase *notification in notifications) {
        if (notification.relatedNotification) {
            [[UIApplication sharedApplication] cancelLocalNotification:notification.relatedNotification];
        }
    }
}

#pragma mark - Local 
+(BOOL)notificationAccessRequested {
    NSString *isAlradyRequested = [[NSUserDefaults standardUserDefaults] objectForKey:@"NotificationAccessRequested"];
    
    return isAlradyRequested != nil;
}

-(void)setNotificationAccessRequested{
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    
    if (standardUserDefaults) {
        [standardUserDefaults setObject:@"YES" forKey:@"NotificationAccessRequested"];
        [standardUserDefaults synchronize];
    }
}

-(BOOL)isLocalNotificationEnabled{
    BOOL toReturn = NO;
    UIUserNotificationSettings *grantedSettings = [[UIApplication sharedApplication] currentUserNotificationSettings];
    
    if (grantedSettings.types == UIUserNotificationTypeNone) {
        toReturn = NO;
    }
    else if (grantedSettings.types & UIUserNotificationTypeSound & UIUserNotificationTypeAlert ){
        toReturn = YES;
    }
    else if (grantedSettings.types  & UIUserNotificationTypeAlert){
        toReturn = YES;
    }
    
    return toReturn;
}

-(void)registerNotification{
    
    UIUserNotificationType types = UIUserNotificationTypeBadge |
    UIUserNotificationTypeSound | UIUserNotificationTypeAlert;
    
    UIUserNotificationSettings *mySettings =
    [UIUserNotificationSettings settingsForTypes:types categories:nil];
    
    [[UIApplication sharedApplication] registerUserNotificationSettings:mySettings];
    [[UIApplication sharedApplication] registerForRemoteNotifications];
    
    [self setNotificationAccessRequested];
    
    //If notifications is not enabled at this point, must be the user disagreed.
    
}

-(void)checkIfNotificationsAreValid:(NSArray *)routines {
    NSArray *localNotifications = [[UIApplication sharedApplication] scheduledLocalNotifications];
    
    int enabledRoutines = 0;
    
    for (RoutineEntity *routine in routines) {
        if (routine.isEnabled) {
            enabledRoutines++;
        }
    }
    
    if (localNotifications.count != enabledRoutines) {
        //Cancel all notification
        [self recreateAllNotificationsForRoutines:routines];
    }
}

-(void)recreateAllNotificationsForRoutines:(NSArray *)routines{
    [self cancelAllRoutineLocalNotification];
    
    for (RoutineEntity *routine in routines) {
        if (routine.isEnabled) {
            [self scheduleLocalNotificationForRoutine:routine];
        }
    }
}

-(void)scheduleLocalNotificationForRoutine:(RoutineEntity *)routine{
    [self registerNotification];
    
    //Check if NSNotification exist already
    NSArray *localNotifications = [[UIApplication sharedApplication] scheduledLocalNotifications];
    
    for (UILocalNotification *notification in localNotifications) {
        if ([notification.userInfo[kRoutineNotificationUniqueName] isEqualToString:[self uniqueNameForRoutine:routine]]) {
            [[UIApplication sharedApplication] cancelLocalNotification:notification];
        }
    }
    
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    [gregorian setLocale:[NSLocale currentLocale]];
    
    NSDateComponents *timeComponents = [gregorian components:NSCalendarUnitYear | NSCalendarUnitWeekOfYear |NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond fromDate:routine.routeDate];
    
    [timeComponents setSecond:0];
    
    UILocalNotification *localNotification = [self createNotificationForRoutine:routine];
    
    if (routine.repeatDays.count == 0) {
        return;
    }else if (routine.repeatDays.count == 7){
        NSDate *date = [[NSCalendar currentCalendar] dateFromComponents:timeComponents];
        [self scheduleLocalNotification:localNotification forDate:date withRepeat:NSCalendarUnitDay];
    }else{
        //Schedule notifications for each day separately
        for (NSNumber *weekDay in routine.repeatDays) {
            //In geregorian calendar, Sunday == 1
            int dayNumber = [weekDay intValue];
            if (dayNumber == 7) {
                dayNumber = 1;
            }else{
                dayNumber++;
            }
            
            [timeComponents setWeekday:dayNumber];
            [timeComponents setWeekOfYear: [timeComponents weekOfYear]];
            [timeComponents setHour: [timeComponents hour]];
            [timeComponents setMinute:[timeComponents minute]];
            
            NSDate *date = [[NSCalendar currentCalendar] dateFromComponents:timeComponents];
            [self scheduleLocalNotification:localNotification forDate:date withRepeat:NSCalendarUnitWeekOfYear];
        }
    }
}

- (UILocalNotification *)createNotificationForRoutine:(RoutineEntity *)routine {
    UILocalNotification* localNotification = [[UILocalNotification alloc] init];
    localNotification.alertTitle = @"Routine reminder";
    localNotification.alertBody = [NSString stringWithFormat:@"Time to go to %@", routine.toDisplayName];
    localNotification.alertAction = @"Get route info";
    if (routine.toneName == UILocalNotificationDefaultSoundName) {
        localNotification.soundName = UILocalNotificationDefaultSoundName;
    }else{
        localNotification.soundName = [NSString stringWithFormat:@"%@.mp3",routine.toneName];
    }
    
    localNotification.userInfo = [self dictionaryDataFromRoutine:routine];
    localNotification.timeZone = [NSTimeZone defaultTimeZone];
    //    localNotification.applicationIconBadgeNumber = [[UIApplication sharedApplication] applicationIconBadgeNumber] + 1;
    
    return localNotification;
}

-(void)scheduleLocalNotification:(UILocalNotification *)notification forDate:(NSDate *)date withRepeat:(NSCalendarUnit)repeat {
    notification.repeatInterval = repeat;
    notification.fireDate = date;
    
    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
}

-(void)scheduleOneTimeNotificationForDate:(NSDate *)date message:(NSString *)message userInfo:(NSDictionary *)userInfo {
    UILocalNotification* localNotification = [[UILocalNotification alloc] init];
    localNotification.alertTitle = @"Time to go";
    localNotification.alertBody = message;
    NSString *toneName = [self.settingsManager toneName];
    if (toneName == UILocalNotificationDefaultSoundName) {
        localNotification.soundName = UILocalNotificationDefaultSoundName;
    }else{
        localNotification.soundName = [toneName containsString:@".mp3"] ? toneName : [NSString stringWithFormat:@"%@.mp3",toneName];
    }
    
    localNotification.userInfo = userInfo;
    localNotification.timeZone = [NSTimeZone defaultTimeZone];
    localNotification.fireDate = date;
    
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
}

-(void)cancelAllRoutineLocalNotification{
    NSArray *allNotifications = [[UIApplication sharedApplication] scheduledLocalNotifications];
    for (UILocalNotification *notification in allNotifications) {
        if ([[self notificationTypeOf:notification] isEqualToString:kNotificationTypeRoutine]) {
            [[UIApplication sharedApplication] cancelLocalNotification:notification];
        }
    }
}

-(NSString *)uniqueNameForRoutine:(RoutineEntity *)routine{
    return [routine.objectID description];
}

-(NSDictionary *)dictionaryDataFromRoutine:(RoutineEntity *)routine{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setObject:routine.fromDisplayName forKey:kRoutineNotificationFromName];
    [dict setObject:routine.fromLocationCoords forKey:kRoutineNotificationFromCoords];
    [dict setObject:routine.toDisplayName forKey:kRoutineNotificationToName];
    [dict setObject:routine.toLocationCoords forKey:kRoutineNotificationToCoords];
    [dict setObject:[self uniqueNameForRoutine:routine] forKey:kRoutineNotificationUniqueName];
    [dict setObject:kNotificationTypeRoutine forKey:kNotificationTypeUserInfoKey];
    
    return dict;
}

-(NSString *)notificationTypeOf:(UILocalNotification *)notification {
    if (!notification.userInfo) return @"UNKNOWN";
    
    return notification.userInfo[kNotificationTypeUserInfoKey];
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

- (void)openAppSettings{
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
