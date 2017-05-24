//
//  RouteSearchOptions.h
//  Reitti
//
//  Created by Anteneh Sahledengel on 29/3/15.
//  Copyright (c) 2015 Anteneh Sahledengel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RouteOptionManagerBase.h"

@interface RouteSearchOptions : NSObject <NSCoding>

+(id)defaultOptions;
-(id)init;

-(id)copy;

+(instancetype)modelObjectFromDictionary:(NSDictionary *)dict;
-(NSDictionary *)dictionaryRepresentation;

#if MAIN_APP
-(NSArray *)allTrasportTypeNames;

-(NSArray *)getTransportTypeOptions;
-(NSArray *)getTicketZoneOptions;
-(NSArray *)getChangeMargineOptions;
-(NSArray *)getWalkingSpeedOptions;

-(NSArray *)getDefaultTransportTypeNames;
-(NSInteger)getDefaultValueIndexForTicketZoneOptions;
-(NSInteger)getDefaultValueIndexForChangeMargineOptions;
-(NSInteger)getDefaultValueIndexForWalkingSpeedOptions;

-(NSInteger)getSelectedTicketZoneIndex;
-(NSInteger)getSelectedChangeMargineIndex;
-(NSInteger)getSelectedWalkingSpeedIndex;

-(BOOL)isAllTrasportTypesSelected;
-(BOOL)isAllTrasportTypesExcluded;
-(NSArray *)listOfExcludedtransportTypes;
#endif

@property(nonatomic,strong) NSDate *date;
@property(nonatomic)RouteTimeType selectedTimeType;
@property(nonatomic)RouteSearchOptimization selectedRouteSearchOptimization;
@property NSArray *selectedRouteTrasportTypes;
@property NSString *selectedTicketZone;
@property NSString *selectedChangeMargine;
@property NSString *selectedWalkingSpeed;

@property(nonatomic)NSInteger numberOfResults;

@end
