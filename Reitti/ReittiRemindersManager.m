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

@interface ReittiRemindersManager ()

@property (nonatomic, strong)EKEventStore * eventStore;

@end

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
    
    self.allRoutines = [[self fetchAllSavedRoutinesFromCoreData] mutableCopy];
    
    //Do some sanity check
    [self checkIfNotificationsAreValid:self.allRoutines];
    
    return self;
}


-(void)setNotificationWithMinOffset:(int)minute andTime:(NSDate *)date andToneName:(NSString *)toneName{
    if ([self isLocalNotificationEnabled]) {
        if (date == nil) {
            [ReittiNotificationHelper showSimpleMessageWithTitle:@"Uh-oh"  andContent:@"Setting notifications failed."];
            
            return;
        }
        
        NSTimeInterval seconds = (minute * -60);
        
        date = [date dateByAddingTimeInterval:seconds];
        
        if ([[NSDate date] compare:date] == NSOrderedDescending ) {
            [ReittiNotificationHelper showSimpleMessageWithTitle:@"You might wanna hurry up!"   andContent:@"The alarm time you selected has already past."];
        }else{
            [ReittiNotificationHelper showSimpleMessageWithTitle:@"Got it!"   andContent:@"You will be reminded."];
            [self scheduleOneTimeNotificationForDate:date andMessage:[NSString stringWithFormat:reminderMessageFormater, minute] andToneName:toneName];
        }
        
    }else{
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"No Access to Notifications Granted"                                                                                      message:@"Please grant access to Notifications from Settings to use this feature."
                                                           delegate:self
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:@"Settings",nil];
        [alertView show];
    }
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 1) {
        [self openAppSettings];
    }
}

#pragma mark - Local 
+(BOOL)isFirstRequest{
    NSString *isAlradyRequested = [[NSUserDefaults standardUserDefaults] objectForKey:@"PreviousBundleVersion"];
    
    return isAlradyRequested == nil;
}

-(void)setIsFirstRequest{
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    
    if (standardUserDefaults) {
        [standardUserDefaults setObject:@"YES" forKey:@"ISFirstTimeRequestForNotification"];
        [standardUserDefaults synchronize];
    }
}

-(BOOL)isLocalNotificationEnabled{
    BOOL toReturn = NO;
    UIUserNotificationSettings *grantedSettings = [[UIApplication sharedApplication] currentUserNotificationSettings];
    
    if (grantedSettings.types == UIUserNotificationTypeNone) {
        NSLog(@"No permiossion granted");
        toReturn = NO;
    }
    else if (grantedSettings.types & UIUserNotificationTypeSound & UIUserNotificationTypeAlert ){
        NSLog(@"Sound and alert permissions ");
        toReturn = YES;
    }
    else if (grantedSettings.types  & UIUserNotificationTypeAlert){
        NSLog(@"Alert Permission Granted");
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
    
    [self setIsFirstRequest];
    
    //If notifications is not enabled at this point, must be the user disagreed.
    
}

-(void)checkIfNotificationsAreValid:(NSArray *)routines{
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
//    }else if (routine.repeatDays.count == 5 &&
//              ![routine.repeatDays containsObject:@6] &&
//              ![routine.repeatDays containsObject:@7]){
//        NSDate *date = [[NSCalendar currentCalendar] dateFromComponents:timeComponents];
//        [self scheduleLocalNotification:localNotification forDate:date withRepeat:NSCalendarUnitWeekday];
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
    localNotification.alertBody = [NSString stringWithFormat:@"Time to go to %@", routine.toDisplayName];
    localNotification.alertAction = @"Get route info";
    if (routine.toneName == UILocalNotificationDefaultSoundName) {
        localNotification.soundName = UILocalNotificationDefaultSoundName;
    }else{
        localNotification.soundName = [NSString stringWithFormat:@"%@.mp3",routine.toneName];
    }
    
    localNotification.userInfo = [self dictionaryDateFromRoutine:routine];
    localNotification.timeZone = [NSTimeZone defaultTimeZone];
    //    localNotification.applicationIconBadgeNumber = [[UIApplication sharedApplication] applicationIconBadgeNumber] + 1;
    
    return localNotification;
}

-(void)scheduleLocalNotification:(UILocalNotification *)notification forDate:(NSDate *)date withRepeat:(NSCalendarUnit)repeat{
    notification.repeatInterval = repeat;
    notification.fireDate = date;
    
    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
    //    [[UIApplication sharedApplication] presentLocalNotificationNow:localNotification];
}

-(void)scheduleOneTimeNotificationForDate:(NSDate *)date andMessage:(NSString *)body andToneName:(NSString *)toneName{
    UILocalNotification* localNotification = [[UILocalNotification alloc] init];
    localNotification.alertBody = body;
    if (toneName == UILocalNotificationDefaultSoundName) {
        localNotification.soundName = UILocalNotificationDefaultSoundName;
    }else{
        localNotification.soundName = [toneName containsString:@".mp3"] ? toneName : [NSString stringWithFormat:@"%@.mp3",toneName];
    }
    
    localNotification.userInfo = nil;
    localNotification.timeZone = [NSTimeZone defaultTimeZone];
    localNotification.fireDate = date;
    
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
}

-(void)cancelAllRoutineLocalNotification{
    NSArray *allNotifications = [[UIApplication sharedApplication] scheduledLocalNotifications];
    for (UILocalNotification *notification in allNotifications) {
        if ([self isRoutineNotification:notification]) {
            [[UIApplication sharedApplication] cancelLocalNotification:notification];
        }
    }
}

-(NSString *)uniqueNameForRoutine:(RoutineEntity *)routine{
//    return [NSString stringWithFormat:@"%@-%@-%@",routine.fromDisplayName, routine.toDisplayName, [ReittiStringFormatter formatFullDate:routine.routeDate]];
    return [routine.objectID description];
}

-(NSDictionary *)dictionaryDateFromRoutine:(RoutineEntity *)routine{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setObject:routine.fromDisplayName forKey:kRoutineNotificationFromName];
    [dict setObject:routine.fromLocationCoords forKey:kRoutineNotificationFromCoords];
    [dict setObject:routine.toDisplayName forKey:kRoutineNotificationToName];
    [dict setObject:routine.toLocationCoords forKey:kRoutineNotificationToCoords];
    [dict setObject:[self uniqueNameForRoutine:routine] forKey:kRoutineNotificationUniqueName];
    
    return dict;
}

#pragma mark - Static Helpers
-(BOOL)isRoutineNotification:(UILocalNotification *)notification{
    return notification.userInfo != nil;
}

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
    NSLog(@"ReittiRemindersManager: Saving routine to core data!");
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
        
        NSLog(@"RemindersManager: Fetched local routines values is NOT null");
        return savedRoutines;
        
    }
    else {
        NSLog(@"RemindersManager: Fetched local routines values is null");
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
        
        NSLog(@"RemindersManager: Fetched routine values is NOT null");
        allSavedRoutineIds = [self simplifyCoreDataDictionaryArray:routineCodes withKey:@"objectLID"] ;
    }
    else {
        NSLog(@"RemindersManager: Fetched routine values is null");
        allSavedRoutineIds = [[NSMutableArray alloc] init];
    }
}

-(RoutineEntity *)fetchSavedRoutineFromCoreDataForId:(NSNumber *)code{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity =
    
    [NSEntityDescription entityForName:@"RoutineEntity" inManagedObjectContext:self.managedObjectContext];
    
    [request setEntity:entity];
    
    NSString *predString = [NSString stringWithFormat:
                            @"objectLID == %@", code];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:predString];
    [request setPredicate:predicate];
    
    NSError *error = nil;
    
    NSArray *savedRoutines = [self.managedObjectContext executeFetchRequest:request error:&error];
    
    if ([savedRoutines count] != 0) {
        
        NSLog(@"RemindersManager: Fetched saved routine values is NOT null");
        return [savedRoutines objectAtIndex:0];
        
    }
    else {
        NSLog(@"RemindersManager: Fetched saved routine values is null");
    }
    
    return nil;
}

-(NSMutableArray *)simplifyCoreDataDictionaryArray:(NSArray *)array withKey:(NSString *)key{
    NSMutableArray *retArray = [[NSMutableArray alloc] init];
    for (NSDictionary * dict in array) {
        [retArray addObject:[dict objectForKey:key]];
    }
    return retArray;
}


@end
