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

NSString *kNotificationStopCode = @"stopCode";

@implementation NotificationBase

-(NSDictionary *)dictionaryRepresentation {
    NSMutableDictionary *dict = [@{} mutableCopy];
    
    [dict setValue:self.title forKey:@"title"];
    [dict setValue:self.fireDate forKey:@"fireDate"];
    [dict setValue:self.body forKey:@"body"];
    [dict setValue:self.toneName forKey:@"toneName"];
    
    return dict;
}

-(instancetype)initFromDictionary:(NSDictionary *)dict {
    if (!dict) return nil;
    
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
    notif.title = @"";
    notif.body = [NSString stringWithFormat:@"Your ride will leave in %d minutes.", minute];
    notif.stopName = [DepartureNotification notificationStopNameForStop:stop];
    notif.stopCode = stop.gtfsId;
    notif.stopIconName = stop.stopIconName;
    
    LineType lineType = [EnumManager lineTypeForStopType:stop.stopType];
    LegTransportType legType = [EnumManager legTrasportTypeForLineType:lineType];
    notif.departureLine = [EnumManager lineDisplayName:legType forLineCode:departure.code];
    notif.departureTime = departure.parsedScheduledDate;
    
    return notif;
}

+(NSString *)notificationStopNameForStop:(BusStop *)stop {
    return [NSString stringWithFormat:@"%@ (%@)", stop.name, stop.codeShort];
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
    notif.title = [NSString stringWithFormat:@"Leave %@", route.fromLocationName];;
    notif.body = [NSString stringWithFormat:@"Get ready to leave %@ in %d minutes", route.fromLocationName, minute];
    notif.routeUniqueIdentifier = route.routeUniqueName;
    notif.routeToLocation = route.toLocationName;
    notif.routeFromLocation = route.fromLocationName;
    notif.routeStartTime = route.startingTimeOfRoute;
    
    return notif;
}

-(NSDictionary *)dictionaryRepresentation {
    NSMutableDictionary *dict = [[super dictionaryRepresentation] mutableCopy];
    
    [dict setValue:self.routeUniqueIdentifier forKey:@"routeUniqueIdentifier"];
    [dict setValue:self.routeFromLocation forKey:@"routeFromLocation"];
    [dict setValue:self.routeToLocation forKey:@"routeToLocation"];
    [dict setValue:self.routeStartTime forKey:@"routeStartTime"];
    
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
