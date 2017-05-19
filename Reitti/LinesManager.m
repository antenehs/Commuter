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
#import "SettingsManager.h"
#import "StopCoreDataManager.h"

NSString *kRecentLinesNsDefaultsKey = @"recentLinesNsDefaultsKey";
NSString *kRecentLinesPatternCodeKey = @"recentLinesPatternCodeKey";
NSString *kStopLineCodesKey = @"stopLineCodes";
NSString *kStopLinePatternCodesKey = @"stopLinePatternCodesKey";

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
        return @[];
    
    return recentLineCodes;
}

-(NSArray *)getRecentLinePatternCodes{
    NSArray *recentLinePatternCodes = [[NSUserDefaults standardUserDefaults] objectForKey:kRecentLinesPatternCodeKey];
    
    if (!recentLinePatternCodes || recentLinePatternCodes.count < 1)
        return @[];
    
    return recentLinePatternCodes;
}

-(void)saveRecentLine:(Line *)line{
    if (!line)
        return;
    
    [self saveRecentLineCodesForLine:line];
    [self saveRecentLinePatternCodesForLine:line];
}

-(void)saveRecentLineCodesForLine:(Line *)line {
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    
    if (standardUserDefaults) {
        NSArray *recentLineCodes = [[NSUserDefaults standardUserDefaults] objectForKey:kRecentLinesNsDefaultsKey];
        
        if (!recentLineCodes)
            recentLineCodes = @[];
        
        NSMutableArray *mutableLinesCopy = [recentLineCodes mutableCopy];
        if (mutableLinesCopy.count > 3) {
            [mutableLinesCopy removeObjectsInRange:NSMakeRange(3, mutableLinesCopy.count - 3)];
        }
        if ([mutableLinesCopy containsObject:line.code]) {
            [mutableLinesCopy removeObject:line.code];
        }
        
        [mutableLinesCopy insertObject:line.code atIndex:0];
        
        [standardUserDefaults setObject:mutableLinesCopy forKey:kRecentLinesNsDefaultsKey];
        [standardUserDefaults synchronize];
    }
}

-(void)saveRecentLinePatternCodesForLine:(Line *)line {
    if (!line.patternCode) return;
    
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    
    if (standardUserDefaults) {
        NSArray *recentLinePatternCodes = [[NSUserDefaults standardUserDefaults] objectForKey:kRecentLinesPatternCodeKey];
        
        if (!recentLinePatternCodes)
            recentLinePatternCodes = @[];
        
        NSMutableArray *mutableLinePatterns = [recentLinePatternCodes mutableCopy];
        if (mutableLinePatterns.count > 3) {
            [mutableLinePatterns removeObjectsInRange:NSMakeRange(3, mutableLinePatterns.count - 3)];
        }
        if ([mutableLinePatterns containsObject:line.patternCode]) {
            [mutableLinePatterns removeObject:line.patternCode];
        }
        
        [mutableLinePatterns insertObject:line.patternCode atIndex:0];
        
        [standardUserDefaults setObject:mutableLinePatterns forKey:kRecentLinesPatternCodeKey];
        [standardUserDefaults synchronize];
    }
}

#pragma mark - line fetching

-(void)getLinesForRecentLineCodesWithCompletionBlock:(ActionBlock)completionBlock {
    NSArray *lineCodes = [self getRecentLineCodes];
    NSArray *linePatternCodes = [self getRecentLinePatternCodes];
    if (lineCodes && lineCodes > 0 && linePatternCodes.count > 0) {
        [[LinesManager sharedManager] fetchLinesForCodes:lineCodes withCompletionBlock:^(NSArray *lines){
            lines = [self filterLines:lines forPatternCodes:linePatternCodes];
            completionBlock([self sortRecentLines:lines]); //Order is not garantied so needs to be sorted.
        }];
    } else {
        completionBlock(nil);
    }
}

- (NSMutableArray *)sortRecentLines:(NSArray *)recentLines{
    NSArray *linesCodes = [self getRecentLineCodes];
    NSArray *sortedArray = [recentLines sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
        //We can cast all types to ReittiManagedObjectBase since we are only interested in the date modified property
        NSInteger first = [linesCodes indexOfObject:[(Line *)a code]];
        NSInteger second = [linesCodes indexOfObject:[(Line *)b code]];
        
        if (first == NSNotFound)
            return NSOrderedDescending;
        
        //Decending by date - latest to earliest
        if (second > first)
            return NSOrderedAscending;
        else if (first > second)
            return NSOrderedDescending;
        else
            return NSOrderedSame;
    }];
    
    return [NSMutableArray arrayWithArray:sortedArray];
}

-(void)getLinesFromSavedStopsWithCompletionBlock:(ActionBlock)completionBlock {
    NSDictionary *lineCodesAndPatterns = [self getLineCodesAndLinesFromSavedStops];
    if (lineCodesAndPatterns && [lineCodesAndPatterns[kStopLineCodesKey] count] > 0) {

        NSArray *lineCodes = lineCodesAndPatterns[kStopLineCodesKey];
        NSArray *stopLinePatterns = lineCodesAndPatterns[kStopLinePatternCodesKey];
        [self fetchLinesForCodes:lineCodes withCompletionBlock:^(NSArray *lines){
            completionBlock([self filterLines:lines forPatternCodes:stopLinePatterns]);
        }];
    } else {
        completionBlock(nil);
    }
}

-(NSDictionary *)getLineCodesAndLinesFromSavedStops {
    NSArray *savedStops = [[StopCoreDataManager sharedManager] fetchAllSavedStopsFromCoreData];
    
    NSMutableArray *lineCodes = [@[] mutableCopy];
    NSMutableArray *linePatternCodes = [@[] mutableCopy];
    for (StopEntity *stop in savedStops) {
        if (stop.fullLineCodes) {
            for (StopLine *line in stop.stopLines) {
                [linePatternCodes addObject:line.pattern.code ? line.pattern.code : @""];
                if (![lineCodes containsObject:line.fullCode]) {
                    [lineCodes addObject:line.fullCode];
                }
            }
        }
    }
    
    return @{kStopLineCodesKey : lineCodes, kStopLinePatternCodesKey : linePatternCodes};
}

-(void)getLinesFromNearByStopsWithCompletionBlock:(ActionBlock)completionBlock  {
    [self getLineCodesFromNearByStopsWithCompletionBlock:^(NSArray *lineCodes, NSArray *stopLinePatterns){
        if (lineCodes.count > 0) {
            [self fetchLinesForCodes:lineCodes withCompletionBlock:^(NSArray *lines){
                completionBlock([self filterLines:lines forPatternCodes:stopLinePatterns]);
            }];
        }
    }];
}

-(void)fetchLinesForCodes:(NSArray *)lineCodes withCompletionBlock:(ActionBlock)completionBlock{
    [self.reittiDataManager fetchLinesForLineCodes:lineCodes withCompletionBlock:^(NSArray *lines, NSString *searchTerm, NSString *errorString){
        if (!errorString) {
            completionBlock([[self filterInvalidLines:lines] mutableCopy]);
        }else{
            completionBlock([@[] mutableCopy]);
        }
    }];
}

-(NSArray *)filterLines:(NSArray *)lines forPatternCodes:(NSArray *)patternCodes {
    return [lines filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id object, NSDictionary *bindings) {
        Line *line = (Line *)object;
        return [patternCodes containsObject:line.patternCode];
    }]];
}

-(NSArray *)filterInvalidLines:(NSArray *)lines {
    return [lines filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id object, NSDictionary *bindings) {
        Line *line = (Line *)object;
        return line.codeShort && line.code && line.isValidNow;
    }]];
}

-(void)getLineCodesFromNearByStopsWithCompletionBlock:(ActionBlock)completionBlock{
    if (!self.currentUserLocation)
        completionBlock(@[], nil);
    
    MKCoordinateSpan span = {.latitudeDelta =  0.01, .longitudeDelta =  0.01};
    MKCoordinateRegion region = {self.currentUserLocation.coordinate, span};
    
    //always search from current user api since line searches are done from current user location
    [self.reittiDataManager fetchStopsInAreaForRegion:region fetchFromApi:ReittiCurrentRegionApi withCompletionBlock:^(NSArray *stopsList, NSString *errorMessage, ReittiApi usedApi){
        if (!errorMessage) {
            if ([SettingsManager useDigiTransit]) {
                if (stopsList.count > 0) {
                    NSMutableArray *lineCodes = [@[] mutableCopy];
                    NSMutableArray *linePatterns = [@[] mutableCopy];
                    for (BusStop *stop in stopsList) {
                        for (StopLine *line in stop.lines) {
                            if (line.fullCode) {
                                if (![lineCodes containsObject:lineCodes]) {
                                    [lineCodes addObject:line.fullCode];
                                    [linePatterns addObject:line.pattern ? line.pattern.code : @""];
                                }
                            }
                        }
                    }
                    
                    completionBlock(lineCodes, linePatterns);
                }else{
                    completionBlock(@[], @[]);
                }
            } else {
                [self fetchStopsDetailsForBusStopShorts:stopsList withCompletionBlock:^(NSArray *detailStops){
                    if (detailStops.count > 0) {
                        NSMutableArray *lineCodes = [@[] mutableCopy];
                        NSMutableArray *linePatterns = [@[] mutableCopy];
                        for (BusStop *stop in detailStops) {
                            for (StopLine *line in stop.lines) {
                                if (line.fullCode) {
                                    if (![lineCodes containsObject:lineCodes]) {
                                        [lineCodes addObject:line.fullCode];
                                        [linePatterns addObject:line.pattern ? line.pattern.code : @""];
                                    }
                                }
                            }
                        }
                        
                        completionBlock(lineCodes, linePatterns);
                    }else{
                        completionBlock(@[], @[]);
                    }
                }];
            }
            
        }else{
            completionBlock(@[], @[]);
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
        
        RTStopSearchParam *searchParam = [RTStopSearchParam new];
        searchParam.longCode = busStopShort.gtfsId;
        
        //Fetch from current region since lines will be fetching from current region
        [self.reittiDataManager fetchStopsForSearchParams:searchParam fetchFromApi:ReittiCurrentRegionApi withCompletionBlock:^(BusStop *stop, NSString *errorString){
            if (!errorString && stop) {
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
