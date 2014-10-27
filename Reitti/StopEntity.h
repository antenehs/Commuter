//
//  StopEntity.h
//  Reitti
//
//  Created by Anteneh Sahledengel on 25/3/14.
//  Copyright (c) 2014 Anteneh Sahledengel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface StopEntity : NSManagedObject

@property (nonatomic, retain) NSNumber * busStopCode;
@property (nonatomic, retain) NSDictionary * stopLines;
@property (nonatomic, retain) NSString * busStopShortCode;
@property (nonatomic, retain) NSString * busStopName;
@property (nonatomic, retain) NSString * busStopCity;
@property (nonatomic, retain) NSString * busStopURL;
@property (nonatomic, retain) NSString * busStopCoords;

@end
