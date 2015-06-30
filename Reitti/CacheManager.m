//
//  CacheManager.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 6/6/15.
//  Copyright (c) 2015 Anteneh Sahledengel. All rights reserved.
//

#import "CacheManager.h"
#import "StaticRoute.h"

@implementation CacheManager

@synthesize allSavedRouteCache, allInMemoryRouteCache, allInMemoryRouteList, allInMemoryUniqueRouteList, allInMemoryStopCache;
@synthesize managedObjectContext;

#pragma mark Singleton Methods

+ (id)sharedManager {
    static CacheManager *sharedCacheManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedCacheManager = [[self alloc] init];
    });
    return sharedCacheManager;
}

-(id)init{
    return [self initFromFile];
}

-(id)initFromFile{
    self.allInMemoryRouteList = [self readRoutesFromFile:@"routes.json"];
    self.allInMemoryUniqueRouteList = [self readRoutesFromFile:@"routesFiltered.json"];
    
    self.allInMemoryRouteCache = [self convertRoutesArrayToDictionary:self.allInMemoryRouteList];
    self.allInMemoryStopCache = [self readStopsFromFile];
    
    return self;
}

-(id)initWithManagedObjectContext:(NSManagedObjectContext *)context{
    self.managedObjectContext = context;
    
    [self fetchRouteCache];
    
    return self;
}

#pragma mark - accessor methods
-(NSString *)getRouteNameForCode:(NSString *)code{
    
    if (allSavedRouteCache.count != 0) {
        RouteCacheEntity *route = [allSavedRouteCache objectForKey:code];
        if (route != nil) {
            if ([route.routeType isEqualToString:@"6"]) {
                //Metro
                return @"Metro";
            }
            return route.shortName;
        }
    }else if (allInMemoryRouteCache.count != 0) {
        StaticRoute *route = [allInMemoryRouteCache objectForKey:code];
        if (route != nil) {
            if ([route.routeType isEqualToString:@"6"]) {
                //Metro
                return @"Metro";
            }
            return route.shortName;
        }
    }
    
    return nil;
}

-(NSString *)getRouteDestinationForCode:(NSString *)code{
    
    if (allSavedRouteCache.count != 0) {
//        RouteCacheEntity *route = [allSavedRouteCache objectForKey:code];
        //TODO: Implement this case
    }else if (allInMemoryRouteCache.count != 0) {
        StaticRoute *route = [allInMemoryRouteCache objectForKey:code];
        if (route != nil) {
            if ([route.routeType isEqualToString:@"6"]) {
                //Metro
                return @"Metro";
            }
            return route.lineEnd;
        }
    }
    
    return nil;
}

-(StaticStop *)getStopForCode:(NSString *)code{
    if (allInMemoryStopCache.count != 0) {
        StaticStop *stop = [allInMemoryStopCache objectForKey:code];
        if (stop != nil) {
            if ([stop.stopType isEqualToString:@"6"]) {
                //Metro
                stop.lineNames = @[@"Metro"];
                return stop;
            }
            return stop;
        }
    }
    
    return nil;
}

#pragma mark - Core data methods
-(NSMutableDictionary *)fetchRouteCache{
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity =[NSEntityDescription entityForName:@"RouteCacheEntity" inManagedObjectContext:self.managedObjectContext];
    
    [request setEntity:entity];
    
    
    NSError *error = nil;
    
    NSArray *routeCaches = [self.managedObjectContext executeFetchRequest:request error:&error];
    
    if (routeCaches.count > 0) {
        
        NSLog(@"CardsSetManager: (fetchLocalSets)Fetched local settings value is not null");
        for (RouteCacheEntity *routeCahce in routeCaches) {
            [allSavedRouteCache setValue:routeCahce forKey:routeCahce.code];
        }
    }
    else {
        NSLog(@"CardsSetManager: (fetchLocalSets)Fetched local settings values is null");
        [self initializeRouteCachesFromJson];
    }
    
    return allSavedRouteCache;
}

-(RouteCacheEntity *)fetchRouteCacheForCode:(NSString *)code{
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity =[NSEntityDescription entityForName:@"RouteCacheEntity" inManagedObjectContext:self.managedObjectContext];
    
    [request setEntity:entity];
    
    NSString *predString = [NSString stringWithFormat:
                            @"code == %@", code];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:predString];
    [request setPredicate:predicate];
    
    NSError *error = nil;
    
    NSArray *routeCaches = [self.managedObjectContext executeFetchRequest:request error:&error];
    
    if (routeCaches.count > 0) {
        
        NSLog(@"CacheManger: Fetched routes value is not null");
        return [routeCaches objectAtIndex:0];
    }
    else {
        NSLog(@"CacheManger: Fetched routes values is null");
    }
    
    return nil;
}

-(void)initializeRouteCachesFromJson{
    NSMutableArray *routeList = [self readRoutesFromFile:@"routes.json"];
    NSMutableDictionary *routes = [self convertRoutesArrayToDictionary:routeList];
    allSavedRouteCache = [[NSMutableDictionary alloc] init];
    
    if (routes.count > 0) {
        
        for (StaticRoute *route in routes) {
            RouteCacheEntity * routeCache = (RouteCacheEntity *)[NSEntityDescription insertNewObjectForEntityForName:@"RouteCacheEntity" inManagedObjectContext:self.managedObjectContext];
            //set values
            routeCache.code = route.code;
            routeCache.shortName = route.shortName;
            routeCache.longName = route.longName;
            routeCache.routeOperator = route.operator;
            routeCache.routeType = route.routeType;
            routeCache.routeUrl = route.routeUrl;
            
            [allSavedRouteCache setValue:routeCache forKey:routeCache.code];
        }
        
        NSError *error = nil;
        
        if (![self.managedObjectContext save:&error]) {
            // Handle error
            NSLog(@"Unresolved error %@, %@: Error when saving the Managed RouteCaches!!", error, [error userInfo]);
            exit(-1);  // Fail
        }
    }
}

-(NSMutableArray *)readRoutesFromFile:(NSString *)fileName{
    NSMutableArray *routes = [[NSMutableArray alloc] init];
    
    NSError *localError = nil;
    
    NSString *path = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:fileName];
    if ([[NSFileManager defaultManager] fileExistsAtPath:path])
    {
        NSArray *parsedObject = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:path]
                                                                options:kNilOptions
                                                                  error:&localError];
        
        if (localError != nil) {
            return routes;
        }
        
        NSArray *results = parsedObject;
        
        for (NSDictionary *routeDict in results) {
            StaticRoute *route = [[StaticRoute alloc] initWithDictionary:routeDict];
            [routes addObject:route];
        }
    }
    
    return routes;
}

-(NSMutableDictionary *)convertRoutesArrayToDictionary:(NSArray *)array{
    NSMutableDictionary *routes = [[NSMutableDictionary alloc] init];
    
    if (array == nil) {
        return routes;
    }
    
    for (StaticRoute *route in array) {
        
        [routes setValue:route forKey:route.code];
    }
    
    return routes;
}


-(NSMutableDictionary *)readStopsFromFile{
    NSMutableDictionary *stops = [[NSMutableDictionary alloc] init];
    
    NSError *localError = nil;
    
    NSString *path = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"stops.json"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:path])
    {
        NSArray *parsedObject = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:path]
                                                                options:kNilOptions
                                                                  error:&localError];
        
        if (localError != nil) {
            return stops;
        }
        
        NSArray *results = parsedObject;
        
        for (NSDictionary *stopDict in results) {
            StaticStop *stop = [[StaticStop alloc] initWithDictionary:stopDict];
            
            [stops setValue:stop forKey:stop.code];
        }
    }
    
    return stops;
}

@end
