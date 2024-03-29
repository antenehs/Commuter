//
//  HistoryEntity.h
//  Reitti
//
//  Created by Anteneh Sahledengel on 25/3/14.
//  Copyright (c) 2014 Anteneh Sahledengel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "ReittiManagedObjectBase.h"
#import "EnumManager.h"
#import "ApiProtocols.h"

@interface HistoryEntity : ReittiManagedObjectBase

@property (nonatomic, retain) NSString * busStopURL;
@property (nonatomic, retain) NSString * busStopCity;
@property (nonatomic, retain) NSNumber * busStopCode;
@property (nonatomic, retain) NSString * busStopName;
@property (nonatomic, retain) NSString * busStopShortCode;
@property (nonatomic, retain) NSString * busStopCoords;
@property (nonatomic, retain) NSString * busStopWgsCoords;
@property (nonatomic, retain) NSNumber * fetchedFrom;

@property (nonatomic, retain) NSNumber * stopTypeNumber;
@property (nonatomic, retain) NSNumber * isHistory;
@property (nonatomic, retain) NSString * stopGtfsId;

@property (nonatomic) StopType stopType;
-(ReittiApi)fetchedFromApi;

@end
