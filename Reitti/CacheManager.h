//
//  CacheManager.h
//  Reitti
//
//  Created by Anteneh Sahledengel on 6/6/15.
//  Copyright (c) 2015 Anteneh Sahledengel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RouteCacheEntity.h"
#import "StaticStop.h"

@interface CacheManager : NSObject

+ (id)sharedManager;

-(id)init;
-(id)initFromFile;
-(id)initWithManagedObjectContext:(NSManagedObjectContext *)context;

-(NSString *)getRouteNameForCode:(NSString *)code;
-(StaticStop *)getStopForCode:(NSString *)code;

@property (strong, nonatomic) NSMutableDictionary *allSavedRouteCache;
@property (strong, nonatomic) NSMutableDictionary *allInMemoryRouteCache;
@property (strong, nonatomic) NSMutableDictionary *allInMemoryStopCache;

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end
