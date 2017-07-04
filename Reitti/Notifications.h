//
//  Notifications.h
//  Reitti
//
//  Created by Anteneh Sahledengel on 5/9/16.
//  Copyright © 2016 Anteneh Sahledengel. All rights reserved.
//

#import <Foundation/Foundation.h>

#if MAIN_APP
#import "StopDeparture.h"
#import "BusStop.h"
#import "Route.h"
#endif

@import UserNotifications;

extern NSString *kNotificationStopCode;

extern NSString *KNotificationDefaultSoundName;

extern NSString *kNotificationSnoozedBodyUserInfoKey;

extern NSString *kNotificationTypeUserInfoKey;
extern NSString *kNotificationTypeDeparture;
extern NSString *kNotificationTypeRoute;

extern NSString *kNotificationActionSnooze;
extern NSString *kNotificationActionSeeDepartures;
extern NSString *kNotificationActionGetRoutesForRoutine;
extern NSString *kNotificationActionSeeRoutes;

@interface NotificationBase : NSObject

-(NSDictionary *)dictionaryRepresentation;
-(instancetype)initFromDictionary:(NSDictionary *)dict;

@property (nonatomic, strong)NSString *type;
@property (nonatomic, strong)NSDate *fireDate;
@property (nonatomic, strong)NSString *title;
@property (nonatomic, strong)NSString *body;
@property (nonatomic, strong)NSString *snoozedBody;
@property (nonatomic, strong)NSString *toneName;
@property (nonatomic, strong)UNNotificationRequest *relatedNotification;

@end



@interface DepartureNotification : NotificationBase

-(NSDictionary *)dictionaryRepresentation;
-(instancetype)initFromDictionary:(NSDictionary *)dict;

#if MAIN_APP
+(instancetype)notificationForDeparture:(StopDeparture *)departure stop:(BusStop *)stop offsetMin:(int)minute;
+(NSString *)notificationStopNameForStop:(BusStop *)stop;

-(UNNotificationRequest *)notificationRequest;
#endif

@property (nonatomic, strong)NSString *stopName;
@property (nonatomic, strong)NSString *stopCode;
@property (nonatomic, strong)NSString *stopCoordString;
@property (nonatomic, strong)NSString *stopIconName;
@property (nonatomic, strong)NSString *stopAnnotationImageName;
@property (nonatomic, strong)NSString *departureLine;
@property (nonatomic, strong)NSString *departureLineDestination;
@property (nonatomic, strong)NSDate *departureTime;
@property (nonatomic, strong)NSArray *laterDepartureTimes;

@end



@interface RouteNotification : NotificationBase

-(NSDictionary *)dictionaryRepresentation;
-(instancetype)initFromDictionary:(NSDictionary *)dict;

#if MAIN_APP
+(instancetype)notificationForRoute:(Route *)route offsetMn:(int)minute;

-(UNNotificationRequest *)notificationRequest;
#endif

@property (nonatomic, strong)NSString *routeUniqueIdentifier;
@property (nonatomic, strong)NSString *routeFromLocation;
@property (nonatomic, strong)NSString *routeToLocation;
@property (nonatomic, strong)NSDate *routeStartTime;

@end
