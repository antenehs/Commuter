//
//  RettiDataManager.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 23/2/14.
//  Copyright (c) 2014 Anteneh Sahledengel. All rights reserved.
//

#import "RettiDataManager.h"
#import <MapKit/MapKit.h>
#import "StopEntity.h"
#import "HistoryEntity.h"
#import "RouteEntity.h"
#import "RouteHistoryEntity.h"
#import "CookieEntity.h"

@implementation RettiDataManager

@synthesize managedObjectContext;

@synthesize delegate;
@synthesize geocodeSearchdelegate;
@synthesize routeSearchdelegate;
@synthesize disruptionFetchDelegate;
@synthesize hslCommunication;
@synthesize detailLineInfo;
@synthesize stopLinesInfo;
@synthesize allHistoryStopCodes;
@synthesize allSavedStopCodes;
@synthesize allRouteHistoryCodes, allSavedRouteCodes;
@synthesize stopEntity;
@synthesize historyEntity;
@synthesize routeEntity;
@synthesize routeHistoryEntity;
@synthesize cookieEntity;

-(id)init{
    HSLCommunication *communicator = [[HSLCommunication alloc] init];
    communicator.delegate = self;
    
    self.hslCommunication = communicator;
    
    return self;
    
}

-(id)initWithManagedObjectContext:(NSManagedObjectContext *)context{
    self.managedObjectContext = context;
    HSLCommunication *communicator = [[HSLCommunication alloc] init];
    communicator.delegate = self;
    
    self.hslCommunication = communicator;
    [self fetchSystemCookie];
    nextObjectLID = [cookieEntity.objectLID intValue];
    
    [self fetchAllHistoryStopCodesFromCoreData];
    [self fetchAllSavedStopCodesFromCoreData];
    [self fetchAllSavedRouteCodesFromCoreData];
    [self fetchAllRouteHistoryCodesFromCoreData];
    
    return self;
    
}

-(void)searchRouteForFromCoords:(NSString *)fromCoords andToCoords:(NSString *)toCoords  time:(NSString *)time andDate:(NSString *)date andTimeType:(NSString *)timeType andSearchOption:(RouteSearchOption)searchOption{
    NSString *optimizeString;
    if (searchOption == RouteSearchOptionFastest) {
        optimizeString = @"fastest";
    }else if (searchOption == RouteSearchOptionLeastTransfer) {
        optimizeString = @"least_transfers";
    }else if (searchOption == RouteSearchOptionLeastWalking) {
        optimizeString = @"least_walking";
    }else{
        optimizeString = @"default";
    }
    
    [self.hslCommunication searchRouteForCoordinates:fromCoords andToCoordinate:toCoords time:time andDate:date andTimeType:timeType andOptimize:optimizeString numberOfResults:5];
}

-(void)getFirstRouteForFromCoords:(NSString *)fromCoords andToCoords:(NSString *)toCoords{
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"HHmm"];
    NSString *time = [dateFormat stringFromDate:[NSDate date]];
    
    NSDateFormatter *dateFormat2 = [[NSDateFormatter alloc] init];
    [dateFormat2 setDateFormat:@"YYYYMMdd"];
    NSString *date = [dateFormat2 stringFromDate:[NSDate date]];
    
    [self.hslCommunication searchRouteForCoordinates:fromCoords andToCoordinate:toCoords time:time andDate:date andTimeType:@"departure" andOptimize:@"fastest" numberOfResults:1];
}

-(void)searchAddressesForKey:(NSString *)key{
    [self.hslCommunication searchGeocodeForKey:key];
}

-(void)fetchStopsForCode:(NSString *)code{    
    
    [self.hslCommunication getStopInfoForCode:code];
    //[self.delegate stopFetchDidComplete:nil];
}

-(void)fetchStopsInAreaForRegion:(MKCoordinateRegion)mapRegion{
    [self.hslCommunication getStopsInArea:mapRegion.center forDiameter:(mapRegion.span.longitudeDelta * 111000)];
}

-(void)fetchDisruptions{
    [self.hslCommunication getDisruptions];
}

-(void)fetchLineInfoForCodeList:(NSString *)codeList{
    [self.hslCommunication getLineInformation:codeList];
}

-(NSDictionary *)convertListInfoArrayToDictionary:(NSArray *)infoListArray{
    
    NSMutableArray *codesList;
    
    for (LineInfo * line in infoListArray) {
        [codesList addObject:[NSString stringWithFormat:@"%@", line.code]];
    }
    
    
    NSDictionary *convertedSet = [NSDictionary dictionaryWithObjects:infoListArray forKeys:codesList];
    
    return convertedSet;
}

-(NSDictionary *)convertBusStopToDictionary:(BusStop *)stop{
    
    NSMutableDictionary *stopDictionary = [[NSMutableDictionary alloc] init];
    [stopDictionary setObject:stop forKey:stop.code];
    
    return stopDictionary;
}

+(NSDictionary *)convertStopLinesArrayToDictionary:(NSArray *)lineList{
    
    NSMutableDictionary *lineListDict = [[NSMutableDictionary alloc] init];
    
    for (NSString *line in lineList) {
        NSArray *info = [line componentsSeparatedByString:@":"];
        [lineListDict setObject:[info objectAtIndex:1] forKey:[info objectAtIndex:0]];
    }
    
    return lineListDict;
}

-(StopEntity *)castHistoryEntityToStopEntity:(HistoryEntity *)historyEntityToCast{
  
    return (StopEntity *)historyEntityToCast;
}

-(BusStopShort *)castStopGeoCodeToBusStopShort:(GeoCode *)geoCode{
    if (geoCode.getLocationType != LocationTypeStop)
        return nil;
    
    BusStopShort *castedBSS = [[BusStopShort alloc] init];
    castedBSS.code = geoCode.getStopCode;
    castedBSS.codeShort = geoCode.getStopShortCode;
    castedBSS.coords = geoCode.coords;
    castedBSS.name = geoCode.name;
    castedBSS.city = geoCode.city;
    castedBSS.address = geoCode.getAddress;
    castedBSS.distance = [NSNumber numberWithInt:0];
    
    return castedBSS;
}

-(BusStopShort *)castStopEntityToBusStopShort:(StopEntity *)stopEntityToCast{
    BusStopShort *castedBSS = [[BusStopShort alloc] init];
    castedBSS.code = stopEntityToCast.busStopCode;
    castedBSS.codeShort = stopEntityToCast.busStopShortCode;
    castedBSS.coords = stopEntityToCast.busStopCoords;
    castedBSS.name = stopEntityToCast.busStopName;
    castedBSS.city = stopEntityToCast.busStopCity;
    castedBSS.address = nil;
    castedBSS.distance = [NSNumber numberWithInt:0];
    
    return castedBSS;
}

-(NSString *)constructListOfLineCodesFromStopsArray:(NSArray *)stopsListArray{
    
    NSString *codeListString;
    
    for (BusStop * stop in stopsListArray) {
        
        for (NSString *line in stop.lines) {
            NSString *lineCode = [ReittiStringFormatter parseLineCodeFromLineInfoString:line];
            if (codeListString == nil) {
                codeListString = lineCode;
            }else{
                codeListString = [NSString stringWithFormat:@"%@|%@", codeListString, lineCode];
            }
        }
    }
    
    return codeListString;
}

-(BOOL)isBusStopSaved:(BusStop *)stop{
    return [allSavedStopCodes containsObject:stop.code];
}

-(void)updateSavedStopsDefaultValueForStops:(NSArray *)savedStops{

    NSString *codes = [[NSString alloc] init];
    
    BOOL firstElement = YES;
    for (StopEntity *stop in savedStops) {
        if (firstElement) {
            codes = [NSString stringWithFormat:@"%d",[stop.busStopCode intValue]];
            firstElement = NO;
        }else{
            codes = [NSString stringWithFormat:@"%@,%d",codes, [stop.busStopCode intValue]];
        }
    }
    
    NSUserDefaults *sharedDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.ewketApps.commuterDepartures"];
    
//    NSDictionary *defaults = @{@"StopCodes" : codes, };
    
    [sharedDefaults setObject:codes forKey:@"StopCodes"];
    [sharedDefaults synchronize];
}

-(void)updateSelectedStopListForDeletedStop:(int)stopCode andAllStops:(NSArray *)allStops{
    NSUserDefaults *sharedDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.ewketApps.commuterDepartures"];
    NSString *selectedCodes = [sharedDefaults objectForKey:@"SelectedStopCodes"];
    
    if (allStops == nil) {
        [sharedDefaults setObject:@"" forKey:@"SelectedStopCodes"];
        return;
    }
    
    if (stopCode == 0) {
        return;
    }
    
    NSRange strRange = [selectedCodes rangeOfString:[NSString stringWithFormat:@"%d", stopCode]];
    if (strRange.location != NSNotFound) {
        StopEntity *new;
        for (StopEntity *stop in allStops) {
            
            if ([stop.busStopCode intValue] != stopCode) {
                NSRange range = [selectedCodes rangeOfString:[NSString stringWithFormat:@"%d", [stop.busStopCode intValue]]];
                if (range.location == NSNotFound) {
                    new = stop;
                }
            }
        }
        
        if (allStops != nil && new != nil) {
            
            NSString *newEntry = [NSString stringWithFormat:@"%@", [new busStopCode]];
            NSString *newStr = [selectedCodes stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%d", stopCode] withString:newEntry ];
            [sharedDefaults setObject:newStr forKey:@"SelectedStopCodes"];
            [sharedDefaults synchronize];
        }else{
            NSString *newStr = [selectedCodes stringByReplacingCharactersInRange:strRange withString:@""];
            newStr = [newStr stringByReplacingOccurrencesOfString:@",," withString:@","];
            newStr = [newStr stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@","]];
            [sharedDefaults setObject:newStr forKey:@"SelectedStopCodes"];
            [sharedDefaults synchronize];
        }
    }
}

-(BOOL)isRouteSaved:(NSString *)fromString andTo:(NSString *)toString{
    return [allSavedRouteCodes containsObject:[RettiDataManager generateUniqueRouteNameFor:fromString andToLoc:toString]];
}

#pragma mark - Core data methods
-(CookieEntity *)fetchSystemCookie{
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity =[NSEntityDescription entityForName:@"CookieEntity" inManagedObjectContext:self.managedObjectContext];
    
    [request setEntity:entity];
    
    
    NSError *error = nil;
    
    NSArray *tempSystemCookie = [self.managedObjectContext executeFetchRequest:request error:&error];
    
    if (tempSystemCookie.count > 0) {
        
        NSLog(@"CardsSetManager: (fetchLocalSets)Fetched local settings value is not null");
        cookieEntity = [tempSystemCookie objectAtIndex:0];
    }
    else {
        NSLog(@"CardsSetManager: (fetchLocalSets)Fetched local settings values is null");
        [self initializeSystemCookie];
    }
    
    return cookieEntity;
    
}

-(void)initializeSystemCookie{
    cookieEntity = (CookieEntity *)[NSEntityDescription insertNewObjectForEntityForName:@"CookieEntity" inManagedObjectContext:self.managedObjectContext];
    //set default values
    [cookieEntity setObjectLID:[NSNumber numberWithInt:100]];
    [cookieEntity setAppOpenCount:[NSNumber numberWithInt:0]];
    
    NSError *error = nil;
    
    if (![cookieEntity.managedObjectContext save:&error]) {
        // Handle error
        NSLog(@"Unresolved error %@, %@: Error when saving the Managed systemCookie!!", error, [error userInfo]);
        exit(-1);  // Fail
    }
}

-(int)getAppOpenCountAndIncreament{
    
    if ([cookieEntity.appOpenCount intValue] < 15) {
        [self increamentAppOpenCounter];
    }
    
    return [cookieEntity.appOpenCount intValue];
    
}

-(void)setAppOpenCountValue:(int)value{
    [cookieEntity setAppOpenCount:[NSNumber numberWithInt:value]];
    NSError *error = nil;
    
    if (![cookieEntity.managedObjectContext save:&error]) {
        // Handle error
        NSLog(@"Unresolved error %@, %@: Error when saving the Managed object:!!", error, [error userInfo]);
        exit(-1);  // Fail
    }

}

-(void)increamentObjectLID{
    [self fetchSystemCookie];
    
    [cookieEntity setObjectLID:[NSNumber numberWithInt:(nextObjectLID + 1)]];
    nextObjectLID++;
    NSError *error = nil;
    
    if (![cookieEntity.managedObjectContext save:&error]) {
        // Handle error
        NSLog(@"Unresolved error %@, %@: Error when saving the Managed object:!!", error, [error userInfo]);
        exit(-1);  // Fail
    }
}

-(void)increamentAppOpenCounter{
    [cookieEntity setAppOpenCount:[NSNumber numberWithInt:([cookieEntity.appOpenCount intValue] + 1)]];
    NSError *error = nil;
    
    if (![cookieEntity.managedObjectContext save:&error]) {
        // Handle error
        NSLog(@"Unresolved error %@, %@: Error when saving the Managed object:!!", error, [error userInfo]);
        exit(-1);  // Fail
    }
}

#pragma mark - stop core data methods
-(void)saveToCoreDataStop:(BusStop *)stop withLines:(NSDictionary *)lines{
    NSLog(@"RettiDataManager: Saving Stop to core data!");
    self.stopEntity= (StopEntity *)[NSEntityDescription insertNewObjectForEntityForName:@"StopEntity" inManagedObjectContext:self.managedObjectContext];
    //set default values
    [self.stopEntity setBusStopCode:stop.code];
    [self.stopEntity setBusStopShortCode:stop.code_short];
    [self.stopEntity setBusStopName:stop.name_fi];
    [self.stopEntity setBusStopCity:stop.city_fi];
    [self.stopEntity setBusStopURL:stop.timetable_link];
    [self.stopEntity setBusStopCoords:stop.coords];
    [self.stopEntity setStopLines:lines];
    
    NSError *error = nil;
    
    if (![stopEntity.managedObjectContext save:&error]) {
        // Handle error
        NSLog(@"Unresolved error %@, %@: Error when saving the Managed object!!", error, [error userInfo]);
        exit(-1);  // Fail
    }
    
    [allSavedStopCodes addObject:stop.code];
    [self updateSavedStopsDefaultValueForStops:[self fetchAllSavedStopsFromCoreData]];
}

-(void)deleteSavedStopForCode:(NSNumber *)code{
    StopEntity *stopToDelete = [self fetchSavedStopFromCoreDataForCode:code];
    
    [self.managedObjectContext deleteObject:stopToDelete];
    
    NSError *error = nil;
    if (![self.managedObjectContext save:&error]) {
        // Handle error
        NSLog(@"Unresolved error %@, %@: Error when saving the Managed object:MainMenu!!", error, [error userInfo]);
        exit(-1);  // Fail
    }
    
    [allSavedStopCodes removeObject:code];
    NSArray *savedSt = [self fetchAllSavedStopsFromCoreData];
    [self updateSavedStopsDefaultValueForStops:savedSt];
    [self updateSelectedStopListForDeletedStop:[code intValue] andAllStops:savedSt];
}

-(void)deleteAllSavedStop{
    NSArray *stopsToDelete = [self fetchAllSavedStopsFromCoreData];
    
    for (StopEntity *stop in stopsToDelete) {
        [self.managedObjectContext deleteObject:stop];
    }
    
    NSError *error = nil;
    if (![self.managedObjectContext save:&error]) {
        // Handle error
        NSLog(@"Unresolved error %@, %@: Error when saving the Managed object:MainMenu!!", error, [error userInfo]);
        exit(-1);  // Fail
    }
    
    [allSavedStopCodes removeAllObjects];
    NSArray *savedSt = [self fetchAllSavedStopsFromCoreData];
    [self updateSavedStopsDefaultValueForStops:savedSt];
    [self updateSelectedStopListForDeletedStop:0 andAllStops:savedSt];
}

//Return array of set dictionaries
-(NSArray *)fetchAllSavedStopsFromCoreData{
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity =
    
    [NSEntityDescription entityForName:@"StopEntity" inManagedObjectContext:self.managedObjectContext];
    
    [request setEntity:entity];
    
    //[request setResultType:NSDictionaryResultType];
    [request setReturnsDistinctResults:YES];
    //[request setPropertiesToFetch :[NSArray arrayWithObjects: @"set_id",  @"title",  @"subject",  @"url",  @"score",  @"views",  @"created",  @"last_modified",  @"card_count",  @"access", nil]];
    
    NSError *error = nil;
    
    NSArray *savedStops = [self.managedObjectContext executeFetchRequest:request error:&error];
    
    if ([savedStops count] != 0) {
        
        NSLog(@"ReittiManager: Fetched local stops values is NOT null");
        return savedStops;
        
    }
    else {
        NSLog(@"ReittiManager: Fetched local stops values is null");
    }
    
    return nil;
}

-(void)fetchAllSavedStopCodesFromCoreData{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity =
    
    [NSEntityDescription entityForName:@"StopEntity" inManagedObjectContext:self.managedObjectContext];
    
    [request setEntity:entity];
    
    [request setResultType:NSDictionaryResultType];
    
    [request setReturnsDistinctResults:YES];
    [request setPropertiesToFetch :[NSArray arrayWithObject: @"busStopCode"]];
    
    NSError *error = nil;
    
    NSArray *recentStopsCodes = [self.managedObjectContext executeFetchRequest:request error:&error];
    
    if ([recentStopsCodes count] != 0) {
        
        NSLog(@"ReittiManager: Fetched history stops values is NOT null");
        allSavedStopCodes = [self simplifyCoreDataDictionaryArray:recentStopsCodes withKey:@"busStopCode"] ;
    }
    else {
        NSLog(@"ReittiManager: Fetched history stops values is null");
        allSavedStopCodes = [[NSMutableArray alloc] init];
    }
}

-(StopEntity *)fetchSavedStopFromCoreDataForCode:(NSNumber *)code{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity =
    
    [NSEntityDescription entityForName:@"StopEntity" inManagedObjectContext:self.managedObjectContext];
    
    [request setEntity:entity];
    
    NSString *predString = [NSString stringWithFormat:
                            @"busStopCode == %@", code];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:predString];
    [request setPredicate:predicate];
    
    NSError *error = nil;
    
    NSArray *savedStops = [self.managedObjectContext executeFetchRequest:request error:&error];
    
    if ([savedStops count] != 0) {
        
        NSLog(@"ReittiManager: Fetched saved stops values is NOT null");
        return [savedStops objectAtIndex:0];
        
    }
    else {
        NSLog(@"ReittiManager: Fetched saved stops values is null");
    }
    
    return nil;
}

#pragma mark - Stop history core data methods
-(BOOL)saveHistoryToCoreDataStop:(BusStop *)stop{
    NSLog(@"RettiDataManager: Saving Stop history to core data!");
    //Check for existence here first
    if(![allHistoryStopCodes containsObject:stop.code] && stop != nil){
        self.historyEntity= (HistoryEntity *)[NSEntityDescription insertNewObjectForEntityForName:@"HistoryEntity" inManagedObjectContext:self.managedObjectContext];
        //set default values
        [self.historyEntity setObjectLID:[NSNumber numberWithInt:nextObjectLID]];
        [self.historyEntity setBusStopCode:stop.code];
        [self.historyEntity setBusStopShortCode:stop.code_short];
        [self.historyEntity setBusStopName:stop.name_fi];
        [self.historyEntity setBusStopCity:stop.city_fi];
        [self.historyEntity setBusStopURL:stop.timetable_link];
        [self.historyEntity setBusStopCoords:stop.coords];
        
        NSError *error = nil;
        
        if (![historyEntity.managedObjectContext save:&error]) {
            // Handle error
            NSLog(@"Unresolved error %@, %@: Error when saving the Managed object!!", error, [error userInfo]);
            exit(-1);  // Fail
        }
        
        [self increamentObjectLID];
        [allHistoryStopCodes addObject:stop.code];
        return YES;
    }else if (stop == nil){
        return NO;
    }else{
        self.historyEntity = [self fetchStopHistoryFromCoreDataForCode:stop.code];
        
        [self.historyEntity setObjectLID:[NSNumber numberWithInt:nextObjectLID]];
        
        NSError *error = nil;
        
        if (![historyEntity.managedObjectContext save:&error]) {
            // Handle error
            NSLog(@"Unresolved error %@, %@: Error when saving the Managed object!!", error, [error userInfo]);
            exit(-1);  // Fail
        }
        
        [self increamentObjectLID];
        return YES;
    }
}

-(void)deleteHistoryStopForCode:(NSNumber *)code{
    HistoryEntity *historyToDelete = [self fetchStopHistoryFromCoreDataForCode:code];
    
    [self.managedObjectContext deleteObject:historyToDelete];
    
    NSError *error = nil;
    if (![historyToDelete.managedObjectContext save:&error]) {
        // Handle error
        NSLog(@"Unresolved error %@, %@: Error when saving the Managed object:MainMenu!!", error, [error userInfo]);
        exit(-1);  // Fail
    }
    
    [allHistoryStopCodes removeObject:code];
}

-(void)deleteAllHistoryStop{
    NSArray *historyToDelete = [self fetchAllSavedStopHistoryFromCoreData];
    
    for (HistoryEntity *stop in historyToDelete) {
        [self.managedObjectContext deleteObject:stop];
    }
    
    NSError *error = nil;
    if (![self.managedObjectContext save:&error]) {
        // Handle error
        NSLog(@"Unresolved error %@, %@: Error when saving the Managed object:MainMenu!!", error, [error userInfo]);
        exit(-1);  // Fail
    }
    
    [allHistoryStopCodes removeAllObjects];
}

-(NSArray *)fetchAllSavedStopHistoryFromCoreData{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity =
    
    [NSEntityDescription entityForName:@"HistoryEntity" inManagedObjectContext:self.managedObjectContext];
    
    [request setEntity:entity];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc]
                                        initWithKey:@"objectLID" ascending:NO];
    [request setSortDescriptors:@[sortDescriptor]];
    
    [request setReturnsDistinctResults:YES];
    
    NSError *error = nil;
    
    NSArray *recentStops = [self.managedObjectContext executeFetchRequest:request error:&error];
    
    if ([recentStops count] != 0) {
        
        NSLog(@"ReittiManager: Fetched history stops values is NOT null");
        return recentStops;
        
    }
    else {
        NSLog(@"ReittiManager: Fetched history stops values is null");
    }
    
    return nil;
}

-(HistoryEntity *)fetchStopHistoryFromCoreDataForCode:(NSNumber *)code{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity =
    
    [NSEntityDescription entityForName:@"HistoryEntity" inManagedObjectContext:self.managedObjectContext];
    
    [request setEntity:entity];
    
    NSString *predString = [NSString stringWithFormat:
                            @"busStopCode == %@", code];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:predString];
    [request setPredicate:predicate];
    
    NSError *error = nil;
    
    NSArray *recentStops = [self.managedObjectContext executeFetchRequest:request error:&error];
    
    if ([recentStops count] != 0) {
        
        NSLog(@"ReittiManager: Fetched history stops values is NOT null");
        return [recentStops objectAtIndex:0];
        
    }
    else {
        NSLog(@"ReittiManager: Fetched history stops values is null");
    }
    
    return nil;
}

-(void)fetchAllHistoryStopCodesFromCoreData{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity =
    
    [NSEntityDescription entityForName:@"HistoryEntity" inManagedObjectContext:self.managedObjectContext];
    
    [request setEntity:entity];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc]
                                        initWithKey:@"objectLID" ascending:NO];
    [request setSortDescriptors:@[sortDescriptor]];
    [request setResultType:NSDictionaryResultType];
    
    [request setReturnsDistinctResults:YES];
    [request setPropertiesToFetch :[NSArray arrayWithObject: @"busStopCode"]];
    
    NSError *error = nil;
    
    NSArray *recentStopsCodes = [self.managedObjectContext executeFetchRequest:request error:&error];
    
    if ([recentStopsCodes count] != 0) {
        
        NSLog(@"ReittiManager: Fetched history stops values is NOT null");
        allHistoryStopCodes = [self simplifyCoreDataDictionaryArray:recentStopsCodes withKey:@"busStopCode"] ;
    }
    else {
        NSLog(@"ReittiManager: Fetched history stops values is null");
        allHistoryStopCodes = [[NSMutableArray alloc] init];
    }
}

#pragma mark - route core data methods
+(NSString *)generateUniqueRouteNameFor:(NSString *)fromLoc andToLoc:(NSString *)toLoc{
    return [NSString stringWithFormat:@"%@ - %@",fromLoc, toLoc];
}
-(void)saveRouteToCoreData:(NSString *)fromLocation fromCoords:(NSString *)fromCoords andToLocation:(NSString *)toLocation andToCoords:(NSString *)toCoords{
    NSLog(@"RettiDataManager: Saving Route to core data!");
    self.routeEntity= (RouteEntity *)[NSEntityDescription insertNewObjectForEntityForName:@"RouteEntity" inManagedObjectContext:self.managedObjectContext];
    //set default values
    [self.routeEntity setFromLocationName:fromLocation];
    [self.routeEntity setFromLocationCoordsString:fromCoords];
    [self.routeEntity setToLocationName:toLocation];
    [self.routeEntity setToLocationCoordsString:toCoords];
    [self.routeEntity setRouteUniqueName:[RettiDataManager generateUniqueRouteNameFor:fromLocation andToLoc:toLocation]];
    
    NSError *error = nil;
    
    if (![routeEntity.managedObjectContext save:&error]) {
        // Handle error
        NSLog(@"Unresolved error %@, %@: Error when saving the Managed object!!", error, [error userInfo]);
        exit(-1);  // Fail
    }
    
    [allSavedRouteCodes addObject:self.routeEntity.routeUniqueName];
}

-(void)deleteSavedRouteForCode:(NSString *)code{
    RouteEntity *routeToDelete = [self fetchSavedRouteFromCoreDataForCode:code];
    
    [self.managedObjectContext deleteObject:routeToDelete];
    
    NSError *error = nil;
    if (![self.managedObjectContext save:&error]) {
        // Handle error
        NSLog(@"Unresolved error %@, %@: Error when saving the Managed object:MainMenu!!", error, [error userInfo]);
        exit(-1);  // Fail
    }
    
    [allSavedRouteCodes removeObject:code];
}

-(void)deleteAllSavedroutes{
    NSArray *routesToDelete = [self fetchAllSavedRoutesFromCoreData];
    
    for (RouteEntity *route in routesToDelete) {
        [self.managedObjectContext deleteObject:route];
    }
    
    NSError *error = nil;
    if (![self.managedObjectContext save:&error]) {
        // Handle error
        NSLog(@"Unresolved error %@, %@: Error when saving the Managed object:MainMenu!!", error, [error userInfo]);
        exit(-1);  // Fail
    }
    
    [allSavedRouteCodes removeAllObjects];
}

-(NSArray *)fetchAllSavedRoutesFromCoreData{
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity =
    
    [NSEntityDescription entityForName:@"RouteEntity" inManagedObjectContext:self.managedObjectContext];
    
    [request setEntity:entity];
    
    //[request setResultType:NSDictionaryResultType];
    [request setReturnsDistinctResults:YES];
    //[request setPropertiesToFetch :[NSArray arrayWithObjects: @"set_id",  @"title",  @"subject",  @"url",  @"score",  @"views",  @"created",  @"last_modified",  @"card_count",  @"access", nil]];
    
    NSError *error = nil;
    
    NSArray *savedRoutes = [self.managedObjectContext executeFetchRequest:request error:&error];
    
    if ([savedRoutes count] != 0) {
        
        NSLog(@"ReittiManager: Fetched local routes values is NOT null");
        return savedRoutes;
        
    }
    else {
        NSLog(@"ReittiManager: Fetched local routes values is null");
    }
    
    return nil;
}

-(void)fetchAllSavedRouteCodesFromCoreData{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity =
    
    [NSEntityDescription entityForName:@"RouteEntity" inManagedObjectContext:self.managedObjectContext];
    
    [request setEntity:entity];
    
    [request setResultType:NSDictionaryResultType];
    
    [request setReturnsDistinctResults:YES];
    [request setPropertiesToFetch :[NSArray arrayWithObject: @"routeUniqueName"]];
    
    NSError *error = nil;
    
    NSArray *savedRouteCodes = [self.managedObjectContext executeFetchRequest:request error:&error];
    
    if ([savedRouteCodes count] != 0) {
        
        NSLog(@"ReittiManager: Fetched saved route values is NOT null");
        allSavedRouteCodes = [self simplifyCoreDataDictionaryArray:savedRouteCodes withKey:@"routeUniqueName"] ;
    }
    else {
        NSLog(@"ReittiManager: Fetched route values is null");
        allSavedRouteCodes = [[NSMutableArray alloc] init];
    }
}

-(RouteEntity *)fetchSavedRouteFromCoreDataForCode:(NSString *)code{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity =
    
    [NSEntityDescription entityForName:@"RouteEntity" inManagedObjectContext:self.managedObjectContext];
    
    [request setEntity:entity];
    
    NSString *predString = [NSString stringWithFormat:
                            @"routeUniqueName == '%@'", code];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:predString];
    [request setPredicate:predicate];
    
    NSError *error = nil;
    
    NSArray *savedRoutes = [self.managedObjectContext executeFetchRequest:request error:&error];
    
    if ([savedRoutes count] != 0) {
        
        NSLog(@"ReittiManager: Fetched saved routes values is NOT null");
        return [savedRoutes objectAtIndex:0];
        
    }
    else {
        NSLog(@"ReittiManager: Fetched saved routes values is null");
    }
    
    return nil;
}

#pragma mark - route history core data methods
-(BOOL)saveRouteHistoryToCoreData:(NSString *)fromLocation fromCoords:(NSString *)fromCoords andToLocation:(NSString *)toLocation toCoords:(NSString *)toCoords{
    NSLog(@"RettiDataManager: Saving route history to core data!");
    //Check for existence here first
    
    if (fromLocation == nil || fromCoords == nil || toLocation == nil || toCoords == nil) {
        return NO;
    }
    
    NSString *uniqueCode = [RettiDataManager generateUniqueRouteNameFor:fromLocation andToLoc:toLocation];
    if(![allRouteHistoryCodes containsObject:uniqueCode] && uniqueCode != nil){
        self.routeHistoryEntity= (RouteHistoryEntity *)[NSEntityDescription insertNewObjectForEntityForName:@"RouteHistoryEntity" inManagedObjectContext:self.managedObjectContext];
        //set default values
        [self.routeHistoryEntity setObjectLID:[NSNumber numberWithInt:nextObjectLID]];
        [self.routeHistoryEntity setRouteUniqueName:uniqueCode];
        [self.routeHistoryEntity setFromLocationName:fromLocation];
        [self.routeHistoryEntity setFromLocationCoordsString:fromCoords];
        [self.routeHistoryEntity setToLocationName:toLocation];
        [self.routeHistoryEntity setToLocationCoordsString:toCoords];
        
        NSError *error = nil;
        
        if (![routeHistoryEntity.managedObjectContext save:&error]) {
            // Handle error
            NSLog(@"Unresolved error %@, %@: Error when saving the Managed object!!", error, [error userInfo]);
            exit(-1);  // Fail
        }
        
        [self increamentObjectLID];
        [allRouteHistoryCodes addObject:uniqueCode];
        return YES;
    }else if (uniqueCode == nil){
        return NO;
    }else{
        self.routeHistoryEntity = [self fetchRouteHistoryFromCoreDataForCode:uniqueCode];
        
        [self.routeHistoryEntity setObjectLID:[NSNumber numberWithInt:nextObjectLID]];
        
        NSError *error = nil;
        
        if (![routeHistoryEntity.managedObjectContext save:&error]) {
            // Handle error
            NSLog(@"Unresolved error %@, %@: Error when saving the Managed object!!", error, [error userInfo]);
            exit(-1);  // Fail
        }
        
        [self increamentObjectLID];
        return YES;
    }
}

-(void)deleteHistoryRouteForCode:(NSString *)code{
    RouteHistoryEntity *historyToDelete = [self fetchRouteHistoryFromCoreDataForCode:code];
    
    [self.managedObjectContext deleteObject:historyToDelete];
    
    NSError *error = nil;
    if (![historyToDelete.managedObjectContext save:&error]) {
        // Handle error
        NSLog(@"Unresolved error %@, %@: Error when saving the Managed object:MainMenu!!", error, [error userInfo]);
        exit(-1);  // Fail
    }
    
    [allRouteHistoryCodes removeObject:code];
}

-(void)deleteAllHistoryRoutes{
    NSArray *historyToDelete = [self fetchAllSavedRouteHistoryFromCoreData];
    
    for (RouteHistoryEntity *route in historyToDelete) {
        [self.managedObjectContext deleteObject:route];
    }
    
    NSError *error = nil;
    if (![self.managedObjectContext save:&error]) {
        // Handle error
        NSLog(@"Unresolved error %@, %@: Error when saving the Managed object:MainMenu!!", error, [error userInfo]);
        exit(-1);  // Fail
    }
    
    [allRouteHistoryCodes removeAllObjects];
}

-(NSArray *)fetchAllSavedRouteHistoryFromCoreData{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity =
    
    [NSEntityDescription entityForName:@"RouteHistoryEntity" inManagedObjectContext:self.managedObjectContext];
    
    [request setEntity:entity];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc]
                                        initWithKey:@"objectLID" ascending:NO];
    [request setSortDescriptors:@[sortDescriptor]];
    
    [request setReturnsDistinctResults:YES];
    
    NSError *error = nil;
    
    NSArray *recentRoutes = [self.managedObjectContext executeFetchRequest:request error:&error];
    
    if ([recentRoutes count] != 0) {
        
        NSLog(@"ReittiManager: Fetched history routes values is NOT null");
        return recentRoutes;
        
    }
    else {
        NSLog(@"ReittiManager: Fetched history route values is null");
    }
    
    return nil;
}

-(RouteHistoryEntity *)fetchRouteHistoryFromCoreDataForCode:(NSString *)code{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity =
    
    [NSEntityDescription entityForName:@"RouteHistoryEntity" inManagedObjectContext:self.managedObjectContext];
    
    [request setEntity:entity];
    
    NSString *predString = [NSString stringWithFormat:
                            @"routeUniqueName == '%@'", code];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:predString];
    [request setPredicate:predicate];
    
    NSError *error = nil;
    
    NSArray *recentRoutes = [self.managedObjectContext executeFetchRequest:request error:&error];
    
    if ([recentRoutes count] != 0) {
        
        NSLog(@"ReittiManager: Fetched history routes values is NOT null");
        return [recentRoutes objectAtIndex:0];
        
    }
    else {
        NSLog(@"ReittiManager: Fetched history route values is null");
    }
    
    return nil;
}

-(void)fetchAllRouteHistoryCodesFromCoreData{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity =
    
    [NSEntityDescription entityForName:@"RouteHistoryEntity" inManagedObjectContext:self.managedObjectContext];
    
    [request setEntity:entity];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc]
                                        initWithKey:@"objectLID" ascending:NO];
    [request setSortDescriptors:@[sortDescriptor]];
    [request setResultType:NSDictionaryResultType];
    
    [request setReturnsDistinctResults:YES];
    [request setPropertiesToFetch :[NSArray arrayWithObject: @"routeUniqueName"]];
    
    NSError *error = nil;
    
    NSArray *recentRouteCodes = [self.managedObjectContext executeFetchRequest:request error:&error];
    
    if ([recentRouteCodes count] != 0) {
        
        NSLog(@"ReittiManager: Fetched history routes values is NOT null");
        allRouteHistoryCodes = [self simplifyCoreDataDictionaryArray:recentRouteCodes withKey:@"routeUniqueName"] ;
    }
    else {
        NSLog(@"ReittiManager: Fetched history routes values is null");
        allRouteHistoryCodes = [[NSMutableArray alloc] init];
    }
}



-(NSMutableArray *)simplifyCoreDataDictionaryArray:(NSArray *)array withKey:(NSString *)key{
    NSMutableArray *retArray = [[NSMutableArray alloc] init];
    for (NSDictionary * dict in array) {
        [retArray addObject:[dict objectForKey:key]];
    }
    return retArray;
}

#pragma mark - HSLCommunication delegate methods
- (void)hslRouteSearchDidComplete:(HSLCommunication *)communicator{
    [routeSearchdelegate routeSearchDidComplete:communicator.routeList];
}
- (void)hslRouteSearchFailed:(int)errorCode{
    if (errorCode == -1009) {
        [routeSearchdelegate routeSearchDidFail:@"Internet connection appears to be offline."];
    }else{
        [routeSearchdelegate routeSearchDidFail:nil];
    }
    
}
- (void)hslGeocodeSearchDidComplete:(HSLCommunication *)communicator{
    [geocodeSearchdelegate geocodeSearchDidComplete:communicator.geoCodeList forRequest:communicator.requestedKey];
}
- (void)hslGeocodeSearchFailed:(int)errorCode{
    if (errorCode == -1009) {
        [geocodeSearchdelegate geocodeSearchDidFail:@"Internet connection appears to be offline." forRequest:nil];
    }else{
        [geocodeSearchdelegate geocodeSearchDidFail:nil forRequest:nil];
    }
}

-(void)hslStopFetchDidComplete:(HSLCommunication *)communicator{
    [self.delegate stopFetchDidComplete:communicator.stopList];
//    [self fetchLineInfoForCodeList:[self constructListOfLineCodesFromStopsArray:communicator.stopList]];
    
}

-(void)hslStopFetchFailed:(int)errorCode{
    NSString *errorString = @"";
    switch (errorCode) {
        case -1016:
            errorString = @"The remote server returned nothing. Try again.";
            break;
        case -1009:
            errorString = @"Internet connection appears to be offline.";
            break;
        default:
            errorString = @"Uh-oh. Fetching stop info failed. Please try again.";
            break;
    }
    [self.delegate stopFetchDidFail:errorString];
}
-(void)hslStopInAreaFetchDidComplete:(HSLCommunication *)communicator{
    [self.delegate nearByStopFetchDidComplete:communicator.nearByStopList];
}
-(void)hslStopInAreaFetchFailed:(int)errorCode{
    NSString *errorString = @"";
    switch (errorCode) {
        case -1009:
            errorString = @"Internet connection appears to be offline.";
            break;
        case -1011:
            errorString = @"Service not available in this area.";
            break;
        case -1001:
            errorString = @"Request timed out.";
            break;
        default:
            break;
    }
    [self.delegate nearByStopFetchDidFail:errorString];
}

-(void)hslDisruptionFetchComplete:(HSLCommunication *)communicator{
    [self.disruptionFetchDelegate disruptionFetchDidComplete:communicator.disruptionList];
}

-(void)hslDisruptionFetchFailed:(int)errorCode{
    [self.disruptionFetchDelegate disruptionFetchDidFail:nil];
}

-(void)hslLineInfoFetchDidComplete:(HSLCommunication *)communicator{
    self.detailLineInfo = [self convertListInfoArrayToDictionary:communicator.lineInfoList];
    //[self.delegate stopFetchDidComplete:communicator.stopList];
}

-(void)hslLineInfoFetchFailed:(HSLCommunication *)communicator{
    //[self.delegate stopFetchDidFail:nil];
}

- (void)dealloc
{
    NSLog(@"RettiManager:Dealloc:Saved cooki data");
}

@end
