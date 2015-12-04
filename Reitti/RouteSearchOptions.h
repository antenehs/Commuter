//
//  RouteSearchOptions.h
//  Reitti
//
//  Created by Anteneh Sahledengel on 29/3/15.
//  Copyright (c) 2015 Anteneh Sahledengel. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum
{
    RouteTimeNow = 0,
    RouteTimeDeparture = 1,
    RouteTimeArrival = 2
} RouteTimeType;

typedef enum
{
    RouteSearchOptionFastest = 0,
    RouteSearchOptionLeastTransfer = 1,
    RouteSearchOptionLeastWalking = 2
} RouteSearchOptimization;

extern NSString * displayTextOptionKey;
extern NSString * detailOptionKey;
extern NSString * valueOptionKey;
extern NSString * pictureOptionKey;
extern NSString * defaultOptionKey;

extern NSInteger kDefaultNumberOfResults;

@interface RouteSearchOptions : NSObject <NSCoding>

+(id)defaultOptions;
-(id)init;

-(id)copy;

-(NSArray *)allTrasportTypeNames;

-(NSArray *)getTransportTypeOptions;
-(NSArray *)getTicketZoneOptions;
-(NSArray *)getChangeMargineOptions;
-(NSArray *)getWalkingSpeedOptions;

-(NSInteger)getDefaultValueIndexForTicketZoneOptions;
-(NSInteger)getDefaultValueIndexForChangeMargineOptions;
-(NSInteger)getDefaultValueIndexForWalkingSpeedOptions;

-(NSInteger)getSelectedTicketZoneIndex;
-(NSInteger)getSelectedChangeMargineIndex;
-(NSInteger)getSelectedWalkingSpeedIndex;

-(BOOL)isAllTrasportTypesSelected;
-(BOOL)isAllTrasportTypesExcluded;
-(NSArray *)listOfExcludedtransportTypes;

@property(nonatomic,strong) NSDate *date;
@property(nonatomic)RouteTimeType selectedTimeType;
@property(nonatomic)RouteSearchOptimization selectedRouteSearchOptimization;
@property NSArray *selectedRouteTrasportTypes;
@property NSString *selectedTicketZone;
@property NSString *selectedChangeMargine;
@property NSString *selectedWalkingSpeed;

@property(nonatomic)NSInteger numberOfResults;

//@property NSString *selectedChangeCost;
//@property NSString *selectedWaitingCost;
//@property NSString *selectedWalkingCost;

@end
