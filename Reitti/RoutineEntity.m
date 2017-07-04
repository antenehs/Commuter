//
//  RoutineEntity.m
//  
//
//  Created by Anteneh Sahledengel on 11/7/15.
//
//

#import "RoutineEntity.h"

NSString *kNotificationTypeRoutine = @"kNotificationTypeRoutine";

NSString *kRoutineNotificationFromName = @"kRoutineNotificationFromName";
NSString *kRoutineNotificationFromCoords = @"kRoutineNotificationFromCoords";
NSString *kRoutineNotificationToName = @"kRoutineNotificationToName";
NSString *kRoutineNotificationToCoords = @"kRoutineNotificationToCoords";
NSString *kRoutineNotificationUniqueName = @"kRoutineNotificationUniqueName";


@implementation RoutineEntity

@dynamic dateModified;
@dynamic toLocationCoords;
@dynamic toLocationName;
@dynamic toDisplayName;
@dynamic fromLocationCoords;
@dynamic fromLocationName;
@dynamic fromDisplayName;
@dynamic routeDate;
@dynamic isEnabled;
@dynamic dayNames;
@dynamic repeatDays;
@dynamic toneName;



-(NSDictionary *)dictionaryRepresentation {
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setObject:self.fromDisplayName forKey:kRoutineNotificationFromName];
    [dict setObject:self.fromLocationName forKey:@"fromLocationName"];
    [dict setObject:self.fromLocationCoords forKey:kRoutineNotificationFromCoords];
    [dict setObject:self.toDisplayName forKey:kRoutineNotificationToName];
    [dict setObject:self.toLocationName forKey:@"toLocationName"];
    [dict setObject:self.toLocationCoords forKey:kRoutineNotificationToCoords];
    [dict setObject:self.routeDate forKey:@"routeDate"];
    [dict setObject:[NSNumber numberWithBool:self.isEnabled] forKey:@"isEnabled"];
    [dict setObject:self.dayNames forKey:@"dayNames"];
    [dict setObject:self.repeatDays forKey:@"repeatDays"];
    [dict setObject:self.toneName forKey:@"toneName"];
    [dict setObject:[self uniqueName] forKey:kRoutineNotificationUniqueName];
    
    return dict;
}

-(NSString *)uniqueName {
    return [self.objectID description];
}

-(NSArray *)dailyUniqueNames {
    return @[self.uniqueName,
             [NSString stringWithFormat:@"%@-1", self.uniqueName],
             [NSString stringWithFormat:@"%@-2", self.uniqueName],
             [NSString stringWithFormat:@"%@-3", self.uniqueName],
             [NSString stringWithFormat:@"%@-4", self.uniqueName],
             [NSString stringWithFormat:@"%@-5", self.uniqueName],
             [NSString stringWithFormat:@"%@-6", self.uniqueName],
             [NSString stringWithFormat:@"%@-7", self.uniqueName]];
}

@end
