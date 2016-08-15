//
//  StopEntity.h
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
#import "OrderedManagedObject.h"

@interface StopEntity : OrderedManagedObject

@property (nonatomic, retain) NSNumber * busStopCode;
@property (nonatomic, retain) NSArray  * stopLines;
@property (nonatomic, retain) NSString * busStopShortCode;
@property (nonatomic, retain) NSString * busStopName;
@property (nonatomic, retain) NSString * busStopCity;
@property (nonatomic, retain) NSString * busStopURL;
@property (nonatomic, retain) NSString * busStopCoords;
@property (nonatomic, retain) NSString * busStopWgsCoords;
@property (nonatomic, retain) NSNumber *fetchedFrom;

@property (nonatomic) StopType stopType;
@property (nonatomic, retain, readonly) NSArray * lineCodes;
@property (nonatomic, strong, readonly) NSArray * fullLineCodes;
@property (nonatomic, retain, readonly) NSString * linesString;

-(ReittiApi)fetchedFromApi;

@end
