//
//  Notifications.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 5/9/16.
//  Copyright © 2016 Anteneh Sahledengel. All rights reserved.
//

#import "Notifications.h"
#import "EnumManager.h"
#import "SettingsManager.h"
#import "ReittiDateHelper.h"

NSString *kNotificationStopCode = @"stopCode";

NSString *KNotificationDefaultSoundName = @"KNotificationDefaultSoundName";

NSString *kNotificationTypeUserInfoKey = @"type";
NSString *kNotificationTypeDeparture = @"kNotificationTypeDeparture";
NSString *kNotificationTypeRoute = @"kNotificationTypeRoute";

NSString *kNotificationActionSnooze = @"SNOOZE_ACTION";
NSString *kNotificationActionSeeDepartures = @"DEPARTURES_ACTION";
NSString *kNotificationActionGetRoutesForRoutine = @"ROUTINE_ROUTES_ACTION";
NSString *kNotificationActionSeeRoutes = @"VIEW_ROUTES_ACTION";

@implementation NotificationBase

-(UNNotificationSound *)notificationSound {
    if (self.toneName == KNotificationDefaultSoundName)
        return [UNNotificationSound defaultSound];
    else {
        NSString *fullToneName = [self.toneName containsString:@".mp3"] ? self.toneName : [NSString stringWithFormat:@"%@.mp3",self.toneName];
        return [UNNotificationSound soundNamed:fullToneName];
    }
}

-(UNMutableNotificationContent *)notificationContent {
    UNMutableNotificationContent *content = [UNMutableNotificationContent new];
    content.title = self.title;
    content.body = self.body;
    content.sound = self.notificationSound;
    content.categoryIdentifier = self.type;
    
    return content;
}

-(NSDictionary *)dictionaryRepresentation {
    NSMutableDictionary *dict = [@{} mutableCopy];
    
    [dict setValue:self.type forKey:kNotificationTypeUserInfoKey];
    [dict setValue:self.title forKey:@"title"];
    [dict setValue:self.fireDate forKey:@"fireDate"];
    [dict setValue:self.body forKey:@"body"];
    [dict setValue:self.toneName forKey:@"toneName"];
    
    return dict;
}

-(instancetype)initFromDictionary:(NSDictionary *)dict {
    if (!dict) return nil;
    
    self.type = dict[kNotificationTypeUserInfoKey];
    self.title = dict[@"title"];
    self.fireDate = dict[@"fireDate"];
    self.body = dict[@"body"];
    self.toneName = dict[@"toneName"];
    
    return self;
}

@end

@implementation DepartureNotification

+(instancetype)notificationForDeparture:(StopDeparture *)departure stop:(BusStop *)stop offsetMin:(int)minute {
    DepartureNotification *notif = [DepartureNotification new];
    notif.title = @"Departure Reminder";
    notif.body = [NSString stringWithFormat:@"Your ride will leave in %d minutes.", minute];
    notif.stopName = [DepartureNotification notificationStopNameForStop:stop];
    notif.stopCode = stop.gtfsId;
    notif.stopIconName = stop.stopIconName;
    
    LineType lineType = [EnumManager lineTypeForStopType:stop.stopType];
    LegTransportType legType = [EnumManager legTrasportTypeForLineType:lineType];
    notif.departureLine = [EnumManager lineDisplayName:legType forLineCode:departure.code];
    notif.departureTime = departure.departureTime;
    
    NSTimeInterval seconds = (minute * -60);
    NSDate *fireDate = [departure.departureTime dateByAddingTimeInterval:seconds];
    
//    NSTimeInterval seconds = 10;
//    NSDate *fireDate = [[NSDate date] dateByAddingTimeInterval:seconds];
    
    notif.fireDate = fireDate;
    notif.toneName = [[SettingsManager sharedManager] toneName];
    notif.type = kNotificationTypeDeparture;
    
    return notif;
}

-(UNNotificationRequest *)notificationRequest {
    UNMutableNotificationContent *content = [super notificationContent];
    content.userInfo = [self dictionaryRepresentation];
    
    NSTimeInterval timeInterval = [self.fireDate timeIntervalSinceNow];
    if (timeInterval < 1) return  nil;
    
    UNTimeIntervalNotificationTrigger *trigger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:timeInterval
                                                                                                    repeats:NO];
    
    UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:self.uniqueIdentifier
                                                                          content:content
                                                                          trigger:trigger];
    
    return request;
}

-(NSString *)uniqueIdentifier {
    NSString *dateString = [[ReittiDateHelper sharedFormatter] formatFullDateString:self.departureTime];
    return [NSString stringWithFormat:@"%@-%@-%@", self.stopName, self.departureLine, dateString];
}

+(NSString *)notificationStopNameForStop:(BusStop *)stop {
    return stop.displayName;
}

-(NSDictionary *)dictionaryRepresentation {
    NSMutableDictionary *dict = [[super dictionaryRepresentation] mutableCopy];
    
    [dict setValue:self.stopName forKey:@"stopName"];
    [dict setValue:self.stopCode forKey:kNotificationStopCode];
    [dict setValue:self.stopIconName forKey:@"stopIconName"];
    [dict setValue:self.departureLine forKey:@"departureLine"];
    [dict setValue:self.departureTime forKey:@"departureTime"];
    
    return dict;
}

-(instancetype)initFromDictionary:(NSDictionary *)dict {
    if (!dict) return nil;
    
    self = [super initFromDictionary:dict];
    if (self) {
        self.stopName = dict[@"stopName"];
        self.stopCode = dict[kNotificationStopCode];
        self.stopIconName = dict[@"stopIconName"];
        self.departureLine = dict[@"departureLine"];
        self.departureTime = dict[@"departureTime"];
    }
    
    return self;
}

@end

@implementation RouteNotification

+(instancetype)notificationForRoute:(Route *)route offsetMn:(int)minute {
    RouteNotification *notif = [RouteNotification new];
    notif.title = @"Route Reminder";
    notif.body = [NSString stringWithFormat:@"Get ready to leave %@ in %d minutes", route.fromLocationName, minute];
    notif.routeUniqueIdentifier = route.routeUniqueName;
    notif.routeToLocation = route.toLocationName;
    notif.routeFromLocation = route.fromLocationName;
    notif.routeStartTime = route.startingTimeOfRoute;
    
    NSTimeInterval seconds = (minute * -60);
    NSDate *fireDate = [route.startingTimeOfRoute dateByAddingTimeInterval:seconds];
    
    notif.fireDate = fireDate;
    notif.toneName = [[SettingsManager sharedManager] toneName];
    
    notif.type = kNotificationTypeRoute;
    
    return notif;
}

-(UNNotificationRequest *)notificationRequest {
    UNMutableNotificationContent *content = [super notificationContent];
    content.userInfo = [self dictionaryRepresentation];
    
    NSTimeInterval timeInterval = [self.fireDate timeIntervalSinceNow];
    if (timeInterval < 1) return  nil;
    
    UNTimeIntervalNotificationTrigger *trigger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:timeInterval
                                                                                                    repeats:NO];
    
    
    UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:self.uniqueIdentifier
                                                                          content:content
                                                                          trigger:trigger];
    
    return request;
}

-(NSString *)uniqueIdentifier {
    NSString *dateString = [[ReittiDateHelper sharedFormatter] formatFullDateString:self.fireDate];
    return [NSString stringWithFormat:@"%@-%@", self.routeUniqueIdentifier, dateString];
}

-(NSDictionary *)dictionaryRepresentation {
    NSMutableDictionary *dict = [[super dictionaryRepresentation] mutableCopy];
    
    [dict setValue:self.routeUniqueIdentifier forKey:@"routeUniqueIdentifier"];
    [dict setValue:self.routeFromLocation forKey:@"routeFromLocation"];
    [dict setValue:self.routeToLocation forKey:@"routeToLocation"];
    [dict setValue:self.routeStartTime forKey:@"routeStartTime"];
    [dict setValue:kNotificationTypeRoute forKey:kNotificationTypeUserInfoKey];
    
    return dict;
}

-(instancetype)initFromDictionary:(NSDictionary *)dict {
    if (!dict) return nil;
    
    self = [super initFromDictionary:dict];
    if (self) {
        self.routeUniqueIdentifier = dict[@"routeUniqueIdentifier"];
        self.routeFromLocation = dict[@"routeFromLocation"];
        self.routeToLocation = dict[@"routeToLocation"];
        self.routeStartTime = dict[@"routeStartTime"];
    }
    
    return self;
}

@end
