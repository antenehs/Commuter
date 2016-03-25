//
//  LinesManager.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 30/12/15.
//  Copyright © 2015 Anteneh Sahledengel. All rights reserved.
//

#import "LinesManager.h"
#import <MapKit/MapKit.h>
#import "SettingsManager.h"
#import "StopEntity.h"

NSString *kRecentLinesNsDefaultsKey = @"recentLinesNsDefaultsKey";

@interface LinesManager ()<CLLocationManagerDelegate>

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CLLocation * currentUserLocation;

@property (strong, nonatomic) RettiDataManager *reittiDataManager;

@end

@implementation LinesManager

@synthesize locationManager, currentUserLocation;

+(id)sharedManager{
    static LinesManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedManager = [[LinesManager alloc] init];
    });
    
    return sharedManager;
}

-(id)init{
    self = [super init];
    if (self) {
        [self initLocationManager];
        self.reittiDataManager = [[RettiDataManager alloc] init];
        
        SettingsManager *settingsManager = [[SettingsManager alloc] initWithDataManager:self.reittiDataManager];
        
        [self.reittiDataManager setUserLocationToRegion:[settingsManager userLocation]];
    }
    
    return self;
}

#pragma mark - location services
- (void)initLocationManager{
    if (locationManager == nil) {
        locationManager = [[CLLocationManager alloc] init];
        locationManager.distanceFilter = kCLDistanceFilterNone;
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
    }
    
    [locationManager startUpdatingLocation];
    locationManager.delegate = self;
}

-(BOOL)isLocationServiceAvailable{
    BOOL accessGranted = [CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse;
//    NSLog(@"%d",[CLLocationManager authorizationStatus]);
    BOOL locationServicesEnabled = [CLLocationManager locationServicesEnabled];
    
    if (!locationServicesEnabled) {
        return NO;
    }
    
    if (!accessGranted) {
        return NO;
    }
    
    return YES;
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    self.currentUserLocation = [locations lastObject];
}

#pragma mark - get lines methods
-(NSArray *)getRecentLineCodes{
    NSArray *recentLineCodes = [[NSUserDefaults standardUserDefaults] objectForKey:kRecentLinesNsDefaultsKey];
    
    if (!recentLineCodes || recentLineCodes.count < 1)
        return nil;
    
    return recentLineCodes;
}

-(void)saveRecentLine:(Line *)line{
    if (!line)
        return;

    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    
    if (standardUserDefaults) {
        NSArray *recentLineCodes = [[NSUserDefaults standardUserDefaults] objectForKey:kRecentLinesNsDefaultsKey];
        
        if (!recentLineCodes)
            recentLineCodes = @[];
        
        NSMutableArray *mutableLinesCopy = [recentLineCodes mutableCopy];
        if (mutableLinesCopy.count > 3) {
            [mutableLinesCopy removeObjectsInRange:NSMakeRange(3, mutableLinesCopy.count - 3)];
        }
        
        [mutableLinesCopy insertObject:line.code atIndex:0];
        
        [standardUserDefaults setObject:mutableLinesCopy forKey:kRecentLinesNsDefaultsKey];
        [standardUserDefaults synchronize];
    }
}

-(void)removeRecentLine:(Line *)line{
    
}

-(NSArray *)getLineCodesFromSavedStops{
    NSArray *savedStops = [self.reittiDataManager fetchAllSavedStopsFromCoreData];
    
    NSMutableArray *lineCodes = [@[] mutableCopy];
    for (StopEntity *stop in savedStops) {
        for (NSString *lineCode in stop.fullLineCodes) {
            if (![lineCodes containsObject:lineCodes]) {
                [lineCodes addObject:lineCode];
            }
        }
    }
    
    return lineCodes;
}

-(void)getLineCodesFromNearByStopsWithCompletionBlock:(ActionBlock)completionBlock{
    if (!self.currentUserLocation)
        completionBlock(@[], nil);
    
    MKCoordinateSpan span = {.latitudeDelta =  0.01, .longitudeDelta =  0.01};
    MKCoordinateRegion region = {self.currentUserLocation.coordinate, span};
    
    
    [self.reittiDataManager fetchStopsInAreaForRegion:region withCompletionBlock:^(NSArray *stopsList, NSString *errorMessage){
        if (!errorMessage) {
            [self fetchStopsDetailsForBusStopShorts:stopsList withCompletionBlock:^(NSArray *detailStops){
                if (detailStops.count > 0) {
                    NSMutableArray *lineCodes = [@[] mutableCopy];
                    for (BusStop *stop in detailStops) {
                        for (NSString *lineCode in stop.lineFullCodes) {
                            if (![lineCodes containsObject:lineCodes]) {
                                [lineCodes addObject:lineCode];
                            }
                        }
                    }
                    
                    completionBlock(lineCodes);
                }else{
                    completionBlock(@[]);
                }
            }];
            
        }else{
            completionBlock(nil, errorMessage);
        }
    }];
}

- (void)fetchStopsDetailsForBusStopShorts:(NSArray *)busStopShorts withCompletionBlock:(ActionBlock)completionBlock{
    if (!busStopShorts || busStopShorts.count < 1)
        completionBlock(@[]);
    
    __block NSMutableArray *fetchedStops = [@[] mutableCopy];
    NSArray *stopsToUse = nil;
    
    if (busStopShorts.count > 3) {
        stopsToUse = [busStopShorts objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 3)]];
    }else{
        stopsToUse = [NSArray arrayWithArray:busStopShorts];
    }
    
    __block NSInteger numberOfStops = 0;
    
    for (BusStopShort *busStopShort in stopsToUse) {
        numberOfStops ++;
        
        [self.reittiDataManager fetchStopsForCode:[busStopShort.code stringValue] andCoords:[ReittiStringFormatter convertStringTo2DCoord:busStopShort.coords] withCompletionBlock:^(BusStop *stop, NSString *errorString){
            if (!errorString) {
                [fetchedStops addObject:stop];
            }
            
            numberOfStops--;
            if (numberOfStops == 0){
                completionBlock(fetchedStops);
            }
        }];
    }
}

@end
