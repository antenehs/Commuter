//
//  RoutineEntity.h
//  
//
//  Created by Anteneh Sahledengel on 11/7/15.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "ReittiManagedObjectBase.h"

extern NSString *kNotificationTypeRoutine;

extern NSString *kRoutineNotificationFromName;
extern NSString *kRoutineNotificationFromCoords;
extern NSString *kRoutineNotificationToName;
extern NSString *kRoutineNotificationToCoords;
extern NSString *kRoutineNotificationUniqueName;

@interface RoutineEntity : ReittiManagedObjectBase

@property (nonatomic, retain) NSDate * dateModified;
@property (nonatomic, retain) NSString * toLocationCoords;
@property (nonatomic, retain) NSString * toLocationName;
@property (nonatomic, retain) NSString * toDisplayName;
@property (nonatomic, retain) NSString * fromLocationCoords;
@property (nonatomic, retain) NSString * fromLocationName;
@property (nonatomic, retain) NSString * fromDisplayName;
@property (nonatomic, retain) NSDate * routeDate;
@property (nonatomic) BOOL isEnabled;
@property (nonatomic, retain) NSString * dayNames;
@property (nonatomic, retain) NSArray * repeatDays;
@property (nonatomic, retain) NSString * toneName;


-(NSDictionary *)dictionaryRepresentation;
-(NSString *)uniqueName;
-(NSArray *)dailyUniqueNames;

@end
