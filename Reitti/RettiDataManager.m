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
#import "SettingsEntity.h"
#import "ReittiManagedObjectBase.h"
#import "LiveTrafficManager.h"

@implementation RettiDataManager

@synthesize managedObjectContext;

@synthesize delegate;
@synthesize geocodeSearchdelegate;
@synthesize reverseGeocodeSearchdelegate;
@synthesize routeSearchdelegate;
@synthesize disruptionFetchDelegate;
@synthesize hslCommunication, treCommunication;
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
@synthesize settingsEntity;
@synthesize allNamedBookmarkNames;
@synthesize namedBookmark;
@synthesize helsinkiRegion, tampereRegion, userLocation;

-(id)init{
    [self initElements];
    return self;
    
}

-(id)initWithManagedObjectContext:(NSManagedObjectContext *)context{
    self.managedObjectContext = context;
    
    [self initElements];
    
    [self fetchSystemCookie];
    nextObjectLID = [cookieEntity.objectLID intValue];
    
    [self fetchAllHistoryStopCodesFromCoreData];
    [self fetchAllSavedStopCodesFromCoreData];
    [self fetchAllSavedRouteCodesFromCoreData];
    [self fetchAllRouteHistoryCodesFromCoreData];
    [self fetchAllNamedBookmarkNamesFromCoreData];

    liveManager = [[LiveTrafficManager alloc] init];
    [liveManager fetchAllLiveVehicles];
    
    return self;
    
}

- (void)initElements {
    HSLCommunication *hCommunicator = [[HSLCommunication alloc] init];
    hCommunicator.delegate = self;
    
    self.hslCommunication = hCommunicator;
    
    TRECommunication *tCommunicator = [[TRECommunication alloc] init];
    tCommunicator.delegate = self;
    
    self.treCommunication = tCommunicator;
    
    numberOfApis = 2;
    stopFetchFailedCount = 0;
    geocodeFetchResponseCount = 0;
    geocodeFetchFailedCount = 0;
    
    HSLGeocodeResposeQueue = [@[] mutableCopy];
    TREGeocodeResponseQueue = [@[] mutableCopy];
    
    [self initRegionCoordinates];
    
    userLocation = HSLandTRERegion;
}

-(void)setUserLocationToCoords:(CLLocationCoordinate2D)coords{
    userLocation = [self identifyRegionOfCoordinate:coords];
}

-(Region)getRegionForCoords:(CLLocationCoordinate2D)coords{
    return [self identifyRegionOfCoordinate:coords];
}

-(void)setUserLocationToRegion:(Region)region{
    userLocation = region;
}

-(NSString *)getNameOfRegion:(Region)region{
    if (region == HSLRegion) {
        return @"Helsinki region";
    }else if (region == TRERegion) {
        return @"Tampere region";
    }else{
        return @"";
    }
}

-(void)resetResponseQueues{
    [HSLGeocodeResposeQueue removeAllObjects];
    [TREGeocodeResponseQueue removeAllObjects];
}

+(CLLocationCoordinate2D)getCoordinateForRegion:(Region)region{
    if (region == TRERegion) {
        //lat="61.4981508" lon="23.7610254"
        CLLocationCoordinate2D coord = {.latitude = 61.4981508 , .longitude = 23.7610254 };
        return coord;
    }else{
        //lat="60.168959" lon="24.924714"
        CLLocationCoordinate2D coord = {.latitude = 60.168959 , .longitude = 24.924714 };
        return coord;
    }
}

- (void)initRegionCoordinates {
    CLLocationCoordinate2D coord1 = {.latitude = 60.765052 , .longitude = 23.742929 };
    CLLocationCoordinate2D coord2 = {.latitude = 59.928294 , .longitude = 25.786386};
    RTCoordinateRegion helsinkiRegionCoords = { coord1,coord2 };
    self.helsinkiRegion = helsinkiRegionCoords;
    
    CLLocationCoordinate2D coord3 = {.latitude = 61.892057 , .longitude = 22.781625 };
    CLLocationCoordinate2D coord4 = {.latitude = 61.092114 , .longitude = 24.716342};
    RTCoordinateRegion tampereRegionCoords = { coord3,coord4 };
    self.tampereRegion = tampereRegionCoords;
}

#pragma mark - API fetch methods

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
    
    Region fromRegion = [self identifyRegionOfCoordinate:[ReittiStringFormatter convertStringTo2DCoord:fromCoords]];
    Region toRegion = [self identifyRegionOfCoordinate:[ReittiStringFormatter convertStringTo2DCoord:toCoords]];
    
    if (fromRegion == toRegion) {
        if (fromRegion == TRERegion) {
            [self.treCommunication searchRouteForCoordinates:fromCoords andToCoordinate:toCoords time:time andDate:date andTimeType:timeType andOptimize:optimizeString numberOfResults:5];
        }else{
            [self.hslCommunication searchRouteForCoordinates:fromCoords andToCoordinate:toCoords time:time andDate:date andTimeType:timeType andOptimize:optimizeString numberOfResults:5];
        }
    }else{
//        [routeSearchdelegate routeSearchDidFail:@"No route information available for the selected addresses."];
        [self.hslCommunication searchRouteForCoordinates:fromCoords andToCoordinate:toCoords time:time andDate:date andTimeType:timeType andOptimize:optimizeString numberOfResults:5];
    }
}

-(void)getFirstRouteForFromCoords:(NSString *)fromCoords andToCoords:(NSString *)toCoords{
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"HHmm"];
    NSString *time = [dateFormat stringFromDate:[NSDate date]];
    
    NSDateFormatter *dateFormat2 = [[NSDateFormatter alloc] init];
    [dateFormat2 setDateFormat:@"YYYYMMdd"];
    NSString *date = [dateFormat2 stringFromDate:[NSDate date]];
    
    Region fromRegion = [self identifyRegionOfCoordinate:[ReittiStringFormatter convertStringTo2DCoord:fromCoords]];
    Region toRegion = [self identifyRegionOfCoordinate:[ReittiStringFormatter convertStringTo2DCoord:toCoords]];
    
    if (fromRegion == toRegion) {
        if (fromRegion == TRERegion) {
            [self.treCommunication searchRouteForCoordinates:fromCoords andToCoordinate:toCoords time:time andDate:date andTimeType:@"departure" andOptimize:@"fastest" numberOfResults:1];
        }else{
            [self.hslCommunication searchRouteForCoordinates:fromCoords andToCoordinate:toCoords time:time andDate:date andTimeType:@"departure" andOptimize:@"fastest" numberOfResults:1];
        }
    }else{
        [routeSearchdelegate routeSearchDidFail:@"No route information available for the selected addresses."];
    }
    
    
}

-(void)searchAddressesForKey:(NSString *)key{
    geoCodeRequestedFor = userLocation;
    if (userLocation == HSLRegion) {
        [self.hslCommunication searchGeocodeForKey:key];
    }else if (userLocation == TRERegion) {
        [self.treCommunication searchGeocodeForKey:key];
    }else{
        geoCodeRequestPrioritizedFor = HSLandTRERegion;
        [self.hslCommunication searchGeocodeForKey:key];
        [self.treCommunication searchGeocodeForKey:key];
    }
    
}

-(void)searchAddresseForCoordinate:(CLLocationCoordinate2D)coords{
    Region region = [self identifyRegionOfCoordinate:coords];
    NSString *coordStrings = [NSString stringWithFormat:@"%f,%f", coords.longitude, coords.latitude];
    if (region == HSLRegion) {
        [self.hslCommunication searchAddressForCoordinate:coordStrings];
    }else if (region == TRERegion){
        [self.treCommunication searchAddressForCoordinate:coordStrings];
    }else{
        [self.hslCommunication searchAddressForCoordinate:coordStrings];
    }
}

-(void)fetchStopsForCode:(NSString *)code andCoords:(CLLocationCoordinate2D)coords{
    
    Region region = [self identifyRegionOfCoordinate:coords];
    if (region == HSLRegion) {
        [self.hslCommunication getStopInfoForCode:code];
        stopInfoRequestedFor = HSLRegion;
    }else if (region == TRERegion){
        [self.treCommunication getStopInfoForCode:code];
        stopInfoRequestedFor = TRERegion;
    }else{
        [self.hslCommunication getStopInfoForCode:code];
        [self.treCommunication getStopInfoForCode:code];
        stopFetchFailedCount = 0;
        stopInfoRequestedFor = HSLandTRERegion;
    }
    
    //[self.delegate stopFetchDidComplete:nil];
}

-(void)fetchStopsInAreaForRegion:(MKCoordinateRegion)mapRegion{
    Region region = [self identifyRegionOfCoordinate:mapRegion.center];
    if (region == HSLRegion) {
        [self.hslCommunication getStopsInArea:mapRegion.center forDiameter:(mapRegion.span.longitudeDelta * 111000)];
        stopInAreaRequestedFor = HSLRegion;
    }else if (region == TRERegion){
        [self.treCommunication getStopsInArea:mapRegion.center forDiameter:(mapRegion.span.longitudeDelta * 111000)];
        stopInAreaRequestedFor = TRERegion;
    }else{
        [self.hslCommunication getStopsInArea:mapRegion.center forDiameter:(mapRegion.span.longitudeDelta * 111000)];
        stopInAreaRequestedFor = HSLRegion;
    }
}

-(void)fetchDisruptions{
    if (userLocation == HSLRegion) {
        [self.hslCommunication getDisruptions];
    }else{
        [self.disruptionFetchDelegate disruptionFetchDidFail:nil];
    }
}

-(void)fetchLineInfoForCodeList:(NSString *)codeList{
    [self.hslCommunication getLineInformation:codeList];
}

#pragma mark - helper methods
- (void)saveManagedObject:(NSManagedObject *)object {
    ReittiManagedObjectBase *managedObject = (ReittiManagedObjectBase *)object;
    managedObject.objectLID = [NSNumber numberWithInt:nextObjectLID];
    managedObject.dateModified = [NSDate date];
    
    NSError *error = nil;
    
    if (![object.managedObjectContext save:&error]) {
        // Handle error
        NSLog(@"Unresolved error %@, %@: Error when saving the Managed object!!", error, [error userInfo]);
        exit(-1);  // Fail
    }
    
    [self increamentObjectLID];
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
    castedBSS.coords = stopEntityToCast.busStopWgsCoords;
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

-(Region)identifyRegionOfCoordinate:(CLLocationCoordinate2D)coords{
    
    if ([self isCoordinateInRegion:self.helsinkiRegion coordinate:coords]) {
        return HSLRegion;
    }
    
    if ([self isCoordinateInRegion:self.tampereRegion coordinate:coords]) {
        return TRERegion;
    }
    
    return OtherRegion;
}

-(BOOL)isCoordinateInRegion:(RTCoordinateRegion)region coordinate:(CLLocationCoordinate2D)coords{
    if (coords.latitude < region.topLeftCorner.latitude &&
        coords.latitude > region.bottomRightCorner.latitude &&
        coords.longitude > region.topLeftCorner.longitude &&
        coords.longitude < region.bottomRightCorner.longitude) {
        return YES;
    }else
        return NO;
}

#pragma mark - Settings Methods
-(SettingsEntity *)fetchSettings{
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity =[NSEntityDescription entityForName:@"SettingsEntity" inManagedObjectContext:self.managedObjectContext];
    
    [request setEntity:entity];
    
    
    NSError *error = nil;
    
    NSArray *tempSystemSettings = [self.managedObjectContext executeFetchRequest:request error:&error];
    
    if (tempSystemSettings.count > 0) {
        
        NSLog(@"ReittiDataManger: (fetchLocalSets)Fetched local settings value is not null");
        settingsEntity = [tempSystemSettings objectAtIndex:0];
    }
    else {
        NSLog(@"ReittiDataManger: (fetchLocalSets)Fetched local settings values is null");
        [self initializeSettings];
    }
    
    return settingsEntity;
    
}

-(void)initializeSettings{
    settingsEntity = (SettingsEntity *)[NSEntityDescription insertNewObjectForEntityForName:@"SettingsEntity" inManagedObjectContext:self.managedObjectContext];
    //set default values
    [settingsEntity setMapMode:[NSNumber numberWithInt:0]];
    [settingsEntity setUserLocation:[NSNumber numberWithInt:0]];
    [settingsEntity setClearOldHistory:[NSNumber numberWithBool:YES]];
    [settingsEntity setNumberOfDaysToKeepHistory:[NSNumber numberWithInt:90]];
    [settingsEntity setSettingsStartDate:[NSDate date]];
    
    NSError *error = nil;
    
    if (![settingsEntity.managedObjectContext save:&error]) {
        // Handle error
        NSLog(@"Unresolved error %@, %@: Error when saving the Managed settings!!", error, [error userInfo]);
        exit(-1);  // Fail
    }
}

-(void)resetSettings{
    if (settingsEntity == nil) {
        settingsEntity = (SettingsEntity *)[NSEntityDescription insertNewObjectForEntityForName:@"SettingsEntity" inManagedObjectContext:self.managedObjectContext];
    }
    
    //set default values
    [settingsEntity setMapMode:[NSNumber numberWithInt:0]];
    [settingsEntity setUserLocation:[NSNumber numberWithInt:0]];
    [settingsEntity setClearOldHistory:[NSNumber numberWithBool:YES]];
    [settingsEntity setNumberOfDaysToKeepHistory:[NSNumber numberWithInt:90]];
    [settingsEntity setSettingsStartDate:[NSDate date]];
    
    NSError *error = nil;
    
    if (![settingsEntity.managedObjectContext save:&error]) {
        // Handle error
        NSLog(@"Unresolved error %@, %@: Error when saving the Managed settings!!", error, [error userInfo]);
        exit(-1);  // Fail
    }
}

-(void)saveSettings{
    NSError *error = nil;
    
    if (![settingsEntity.managedObjectContext save:&error]) {
        // Handle error
        NSLog(@"Unresolved error %@, %@: Error when saving the Managed object:!!", error, [error userInfo]);
        exit(-1);  // Fail
    }
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
    [self.stopEntity setBusStopWgsCoords:stop.wgs_coords];
    [self.stopEntity setStopLines:lines];
    
    [self saveManagedObject:stopEntity];
    
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
        [self.historyEntity setBusStopCode:stop.code];
        [self.historyEntity setBusStopShortCode:stop.code_short];
        [self.historyEntity setBusStopName:stop.name_fi];
        [self.historyEntity setBusStopCity:stop.city_fi];
        [self.historyEntity setBusStopURL:stop.timetable_link];
        [self.historyEntity setBusStopCoords:stop.coords];
        [self.historyEntity setBusStopWgsCoords:stop.wgs_coords];
        
        [self saveManagedObject:historyEntity];
        
        [allHistoryStopCodes addObject:stop.code];
        return YES;
    }else if (stop == nil){
        return NO;
    }else{
        self.historyEntity = [self fetchStopHistoryFromCoreDataForCode:stop.code];
        
        [self saveManagedObject:historyEntity];
        
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

-(void)clearHistoryOlderThanDays:(int)numOfDays{
//    numOfDays = 1;
    BOOL modified = NO;
    NSArray *allStopHistory = [self fetchAllSavedStopHistoryFromCoreData];
    for (HistoryEntity *stop in allStopHistory) {
        if (stop.dateModified != nil) {
            if ([stop.dateModified timeIntervalSinceNow] < -(numOfDays * 24 * 60 * 60)) {
                [self.managedObjectContext deleteObject:stop];
                modified = YES;
                [allHistoryStopCodes removeObject:stop.busStopCode];
            }
        }else{
            if ([settingsEntity.settingsStartDate timeIntervalSinceNow] > (numOfDays * 24 * 60 * 60)) {
                [self.managedObjectContext deleteObject:stop];
                modified = YES;
                [allHistoryStopCodes removeObject:stop.busStopCode];
            }
        }
    }
    
    NSArray *allRouteHistory = [self fetchAllSavedRouteHistoryFromCoreData];
    for (RouteHistoryEntity *route in allRouteHistory) {
        if (route.dateModified != nil) {
            if ([route.dateModified timeIntervalSinceNow] < -(numOfDays * 24 * 60 * 60)) {
                [self.managedObjectContext deleteObject:route];
                modified = YES;
                [allRouteHistoryCodes removeObject:route.routeUniqueName];
            }
        }else{
            if ([settingsEntity.settingsStartDate timeIntervalSinceNow] > (numOfDays * 24 * 60 * 60)) {
                [self.managedObjectContext deleteObject:route];
                modified = YES;
                [allRouteHistoryCodes removeObject:route.routeUniqueName];
            }
        }
    }
    
    if (modified) {
        NSError *error = nil;
        if (![self.managedObjectContext save:&error]) {
            // Handle error
            NSLog(@"Unresolved error %@, %@: Error when saving the Managed object:MainMenu!!", error, [error userInfo]);
            exit(-1);  // Fail
        }
    }
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
    
    [self saveManagedObject:self.routeEntity];
    
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

#pragma mark - named bookmark methods
-(NamedBookmark *)saveNamedBookmarkToCoreData:(NamedBookmark *)ndBookmark{
    NSLog(@"RettiDataManager: Saving named bookmark to core data!");
    //Check for existence here first
    if (ndBookmark == nil)
        return nil;
    
    if(![self doesNamedBookmarkExistWithName:ndBookmark.name]){
        self.namedBookmark = (NamedBookmark *)[NSEntityDescription insertNewObjectForEntityForName:@"NamedBookmark" inManagedObjectContext:self.managedObjectContext];
        //set default values
        [self.namedBookmark setName:ndBookmark.name];
        [self.namedBookmark setStreetAddress:ndBookmark.streetAddress];
        [self.namedBookmark setCity:ndBookmark.city];
        [self.namedBookmark setSearchedName:ndBookmark.searchedName];
        [self.namedBookmark setCoords:ndBookmark.coords];
        [self.namedBookmark setIconPictureName:ndBookmark.iconPictureName];
        
        [self saveManagedObject:namedBookmark];
        
        [allNamedBookmarkNames addObject:ndBookmark.name];
        return self.namedBookmark;
    }else{
        self.namedBookmark = [self fetchSavedNamedBookmarkFromCoreDataForName:ndBookmark.name];
        
        [self.namedBookmark setName:ndBookmark.name];
        [self.namedBookmark setStreetAddress:ndBookmark.streetAddress];
        [self.namedBookmark setCity:ndBookmark.city];
        [self.namedBookmark setSearchedName:ndBookmark.searchedName];
        [self.namedBookmark setCoords:ndBookmark.coords];
        [self.namedBookmark setIconPictureName:ndBookmark.iconPictureName];
        
        [self saveManagedObject:namedBookmark];
        
        return self.namedBookmark;
    }
}

-(NamedBookmark *)updateNamedBookmarkToCoreDataWithID:(NSNumber *)objectLid withNamedBookmark:(NamedBookmark *)ndBookmark{
    NSLog(@"RettiDataManager: Saving named bookmark to core data!");
    //Check for existence here first
    if (ndBookmark == nil)
        return nil;
    
    self.namedBookmark = [self fetchSavedNamedBookmarkFromCoreDataForObjectLid:objectLid];
    
    if(self.namedBookmark != nil){
        
        [self.namedBookmark setName:ndBookmark.name];
        [self.namedBookmark setStreetAddress:ndBookmark.streetAddress];
        [self.namedBookmark setCity:ndBookmark.city];
        [self.namedBookmark setSearchedName:ndBookmark.searchedName];
        [self.namedBookmark setCoords:ndBookmark.coords];
        [self.namedBookmark setIconPictureName:ndBookmark.iconPictureName];
        
        NSError *error = nil;
        
        if (![namedBookmark.managedObjectContext save:&error]) {
            // Handle error
            NSLog(@"Unresolved error %@, %@: Error when saving the Managed object!!", error, [error userInfo]);
            exit(-1);  // Fail
        }
        
        return self.namedBookmark;
    }else{
        return nil;
    }
}


-(void)deleteNamedBookmarkForName:(NSString *)name{
    NamedBookmark *bookmarkToDelete = [self fetchSavedNamedBookmarkFromCoreDataForName:name];
    
    [self.managedObjectContext deleteObject:bookmarkToDelete];
    
    NSError *error = nil;
    if (![self.managedObjectContext save:&error]) {
        // Handle error
        NSLog(@"Unresolved error %@, %@: Error when saving the Managed object:MainMenu!!", error, [error userInfo]);
        exit(-1);  // Fail
    }
    
    [allNamedBookmarkNames removeObject:name];
}
-(void)deleteAllNamedBookmarks{
    NSArray *bookmarksToDelete = [self fetchAllSavedNamedBookmarksFromCoreData];
    
    for (NamedBookmark *bookmark in bookmarksToDelete) {
        [self.managedObjectContext deleteObject:bookmark];
    }
    
    NSError *error = nil;
    if (![self.managedObjectContext save:&error]) {
        // Handle error
        NSLog(@"Unresolved error %@, %@: Error when saving the Managed object.", error, [error userInfo]);
        exit(-1);  // Fail
    }
    
    [allNamedBookmarkNames removeAllObjects];
}
-(NSArray *)fetchAllSavedNamedBookmarksFromCoreData{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity =
    
    [NSEntityDescription entityForName:@"NamedBookmark" inManagedObjectContext:self.managedObjectContext];
    
    [request setEntity:entity];
    
    //[request setResultType:NSDictionaryResultType];
    [request setReturnsDistinctResults:YES];
    //[request setPropertiesToFetch :[NSArray arrayWithObjects: @"set_id",  @"title",  @"subject",  @"url",  @"score",  @"views",  @"created",  @"last_modified",  @"card_count",  @"access", nil]];
    
    NSError *error = nil;
    
    NSArray *savedBookmarks = [self.managedObjectContext executeFetchRequest:request error:&error];
    
    if ([savedBookmarks count] != 0) {
        
        NSLog(@"ReittiManager: Fetched local named bookmark values is NOT null");
        return savedBookmarks;
        
    }
    else {
        NSLog(@"ReittiManager: Fetched local named bookmark values is null");
    }
    
    return nil;
}

-(BOOL)doesNamedBookmarkExistWithName:(NSString *)name{
    return [allNamedBookmarkNames containsObject:name];
}

-(NamedBookmark *)fetchSavedNamedBookmarkFromCoreDataForName:(NSString *)name{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity =
    
    [NSEntityDescription entityForName:@"NamedBookmark" inManagedObjectContext:self.managedObjectContext];
    
    [request setEntity:entity];
    
    NSString *predString = [NSString stringWithFormat:
                            @"name == '%@'", name];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:predString];
    [request setPredicate:predicate];
    
    NSError *error = nil;
    
    NSArray *savedBookmarks = [self.managedObjectContext executeFetchRequest:request error:&error];
    
    if ([savedBookmarks count] != 0) {
        
        NSLog(@"ReittiManager: Fetched named bookmarks values is NOT null");
        return [savedBookmarks objectAtIndex:0];
        
    }
    else {
        NSLog(@"ReittiManager: Fetched saved named bookmark values is null");
    }
    
    return nil;
}

-(NamedBookmark *)fetchSavedNamedBookmarkFromCoreDataForCoords:(NSString *)coords{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity =
    
    [NSEntityDescription entityForName:@"NamedBookmark" inManagedObjectContext:self.managedObjectContext];
    
    [request setEntity:entity];
    
    NSString *predString = [NSString stringWithFormat:
                            @"coords == '%@'", coords];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:predString];
    [request setPredicate:predicate];
    
    NSError *error = nil;
    
    NSArray *savedBookmarks = [self.managedObjectContext executeFetchRequest:request error:&error];
    
    if ([savedBookmarks count] != 0) {
        
        NSLog(@"ReittiManager: Fetched named bookmarks values is NOT null");
        return [savedBookmarks objectAtIndex:0];
        
    }
    else {
        NSLog(@"ReittiManager: Fetched saved named bookmark values is null");
    }
    
    return nil;
}

-(NamedBookmark *)fetchSavedNamedBookmarkFromCoreDataForObjectLid:(NSNumber *)objectLid{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity =
    
    [NSEntityDescription entityForName:@"NamedBookmark" inManagedObjectContext:self.managedObjectContext];
    
    [request setEntity:entity];
    
    NSString *predString = [NSString stringWithFormat:
                            @"objectLID == %@", objectLid];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:predString];
    [request setPredicate:predicate];
    
    NSError *error = nil;
    
    NSArray *savedBookmarks = [self.managedObjectContext executeFetchRequest:request error:&error];
    
    if ([savedBookmarks count] != 0) {
        
        NSLog(@"ReittiManager: Fetched named bookmarks values is NOT null");
        return [savedBookmarks objectAtIndex:0];
        
    }
    else {
        NSLog(@"ReittiManager: Fetched saved named bookmark values is null");
    }
    
    return nil;
}

-(void)fetchAllNamedBookmarkNamesFromCoreData{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity =
    
    [NSEntityDescription entityForName:@"NamedBookmark" inManagedObjectContext:self.managedObjectContext];
    
    [request setEntity:entity];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc]
                                        initWithKey:@"name" ascending:NO];
    [request setSortDescriptors:@[sortDescriptor]];
    [request setResultType:NSDictionaryResultType];
    
    [request setReturnsDistinctResults:YES];
    [request setPropertiesToFetch :[NSArray arrayWithObject: @"name"]];
    
    NSError *error = nil;
    
    NSArray *bookmarkNames = [self.managedObjectContext executeFetchRequest:request error:&error];
    
    if ([bookmarkNames count] != 0) {
        
        NSLog(@"ReittiManager: Fetched named Bookmarks values is NOT null");
        allNamedBookmarkNames = [self simplifyCoreDataDictionaryArray:bookmarkNames withKey:@"name"] ;
    }
    else {
        NSLog(@"ReittiManager: Fetched named Bookmarks values is null");
        allNamedBookmarkNames = [[NSMutableArray alloc] init];
    }
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
        [self.routeHistoryEntity setRouteUniqueName:uniqueCode];
        [self.routeHistoryEntity setFromLocationName:fromLocation];
        [self.routeHistoryEntity setFromLocationCoordsString:fromCoords];
        [self.routeHistoryEntity setToLocationName:toLocation];
        [self.routeHistoryEntity setToLocationCoordsString:toCoords];
        
        [self saveManagedObject:routeHistoryEntity];
        
        [allRouteHistoryCodes addObject:uniqueCode];
        return YES;
    }else if (uniqueCode == nil){
        return NO;
    }else{
        self.routeHistoryEntity = [self fetchRouteHistoryFromCoreDataForCode:uniqueCode];
        
        [self saveManagedObject:routeHistoryEntity];
        
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
#pragma mark - merged delegate methods
- (void)checkForGeoCodeFetchCompletionAndReturn{
    
    if (HSLGeocodeResposeQueue.count > 0 && TREGeocodeResponseQueue.count > 0) {
        NSMutableArray *respose = [@[] mutableCopy];
        if (geoCodeRequestPrioritizedFor == TRERegion) {
            if (![[TREGeocodeResponseQueue firstObject] isKindOfClass:[FailedGeoCodeFetch class]]) {
                [respose addObjectsFromArray:[TREGeocodeResponseQueue firstObject]];
            }
            
            if (![[HSLGeocodeResposeQueue firstObject] isKindOfClass:[FailedGeoCodeFetch class]]) {
                [respose addObjectsFromArray:[HSLGeocodeResposeQueue firstObject]];
            }
        }else{
            if (![[HSLGeocodeResposeQueue firstObject] isKindOfClass:[FailedGeoCodeFetch class]]) {
                [respose addObjectsFromArray:[HSLGeocodeResposeQueue firstObject]];
            }
            
            if (![[TREGeocodeResponseQueue firstObject] isKindOfClass:[FailedGeoCodeFetch class]]) {
                [respose addObjectsFromArray:[TREGeocodeResponseQueue firstObject]];
            }
        }
        
        if (respose.count == 0){
            //Failed case. Respond the error
            FailedGeoCodeFetch *failedObject;
            if (geoCodeRequestPrioritizedFor == TRERegion)
                failedObject = [TREGeocodeResponseQueue firstObject];
            else
                failedObject = [HSLGeocodeResposeQueue firstObject];
            
            [geocodeSearchdelegate geocodeSearchDidFail:failedObject.textForError forRequest:nil];
            
        }else{
            [geocodeSearchdelegate geocodeSearchDidComplete:respose  isFinalResult:YES];
        }
        
        [TREGeocodeResponseQueue removeObjectAtIndex:0];
        [HSLGeocodeResposeQueue removeObjectAtIndex:0];
    }
    
}

#pragma mark - HSLCommunication delegate methods
- (void)hslRouteSearchDidComplete:(HSLCommunication *)communicator{
    [routeSearchdelegate routeSearchDidComplete:communicator.routeList];
}
- (void)hslRouteSearchFailed:(int)errorCode{
    if (errorCode == -1009) {
        [routeSearchdelegate routeSearchDidFail:@"Internet connection appears to be offline."];
    }else if (errorCode == -1016) {
        [routeSearchdelegate routeSearchDidFail:@"No route information available for the selected addresses."];
    }else{
        [routeSearchdelegate routeSearchDidFail:nil];
    }
}
- (void)hslGeocodeSearchDidComplete:(HSLCommunication *)communicator{
    if (geoCodeRequestedFor == HSLRegion) {
        [geocodeSearchdelegate geocodeSearchDidComplete:communicator.geoCodeList  isFinalResult:YES];
    }else if(geoCodeRequestedFor == HSLandTRERegion){
        [HSLGeocodeResposeQueue addObject:communicator.geoCodeList];
        
        [self checkForGeoCodeFetchCompletionAndReturn];
    }
    
}

- (void)hslGeocodeSearchFailed:(int)errorCode{
    //The last one to fail sends the message
    NSString *errorMessage = nil;
    if (errorCode == -1009) {
        errorMessage = @"Internet connection appears to be offline.";
    }
    
    if (geoCodeRequestedFor == HSLRegion) {
        [geocodeSearchdelegate geocodeSearchDidFail:errorMessage forRequest:nil];
    }else if (geoCodeRequestedFor == HSLandTRERegion){
        FailedGeoCodeFetch *failed = [[FailedGeoCodeFetch alloc] init];
        failed.errorCode = errorCode;
        failed.textForError = errorMessage;
        
        [HSLGeocodeResposeQueue addObject:failed];
        [self checkForGeoCodeFetchCompletionAndReturn];
    }
    
    
}

-(void)hslReverseGeocodeSearchDidComplete:(HSLCommunication *)communicator{
    if (communicator.reverseGeoCodeList.count > 0) {
        [self.reverseGeocodeSearchdelegate reverseGeocodeSearchDidComplete:(GeoCode *)[communicator.reverseGeoCodeList objectAtIndex:0]];
    }else{
        [self.reverseGeocodeSearchdelegate reverseGeocodeSearchDidFail:@"No address was found for the coordinates."];
    }
}

-(void)hslReverseGeocodeSearchFailed:(int)errorCode{
    NSString *errorString = @"";
    switch (errorCode) {
        case -1009:
            errorString = @"Internet connection appears to be offline.";
            break;
        default:
            errorString = @"No address was found for the coordinates";
            break;
    }
    
    [self.reverseGeocodeSearchdelegate reverseGeocodeSearchDidFail:errorString];
}

-(void)hslStopFetchDidComplete:(HSLCommunication *)communicator{
    [self.delegate stopFetchDidComplete:communicator.stopList];
//    [self fetchLineInfoForCodeList:[self constructListOfLineCodesFromStopsArray:communicator.stopList]];
    
}

-(void)hslStopFetchFailed:(int)errorCode{
    if (stopInfoRequestedFor != HSLandTRERegion || stopFetchFailedCount == numberOfApis - 1) {
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
        stopFetchFailedCount = 0;
    }
    
    stopFetchFailedCount ++;
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
            errorString = @"Nearby stops service not available in this area.";
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

#pragma mark - TRECommunication delegate methods
- (void)treStopFetchDidComplete:(TRECommunication *)communicator{
    [self.delegate stopFetchDidComplete:communicator.stopList];
}
- (void)treStopFetchFailed:(int)errorCode{
    if (stopInfoRequestedFor != HSLandTRERegion || stopFetchFailedCount == numberOfApis - 1) {
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
        stopFetchFailedCount = 0;
    }
    
    stopFetchFailedCount ++;
}
- (void)treStopInAreaFetchDidComplete:(TRECommunication *)communicator{
    [self.delegate nearByStopFetchDidComplete:communicator.nearByStopList];
}
- (void)treStopInAreaFetchFailed:(int)errorCode{
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
- (void)treLineInfoFetchDidComplete:(TRECommunication *)communicator{
    //not needed yet
}
- (void)treLineInfoFetchFailed:(TRECommunication *)communicator{
    //not needed yet
}
- (void)treGeocodeSearchDidComplete:(TRECommunication *)communicator{
    if (geoCodeRequestedFor == TRERegion) {
        [geocodeSearchdelegate geocodeSearchDidComplete:communicator.geoCodeList  isFinalResult:YES];
    }else if(geoCodeRequestedFor == HSLandTRERegion){
        [TREGeocodeResponseQueue addObject:communicator.geoCodeList];
    
        [self checkForGeoCodeFetchCompletionAndReturn];
    }
}
- (void)treGeocodeSearchFailed:(int)errorCode{
    //The last one to fail sends the message
    NSString *errorMessage = nil;
    if (errorCode == -1009) {
        errorMessage = @"Internet connection appears to be offline.";
    }
    
    if (geoCodeRequestedFor == TRERegion) {
        [geocodeSearchdelegate geocodeSearchDidFail:errorMessage forRequest:nil];
    }else if (geoCodeRequestedFor == HSLandTRERegion){
        FailedGeoCodeFetch *failed = [[FailedGeoCodeFetch alloc] init];
        failed.errorCode = errorCode;
        failed.textForError = errorMessage;
        
        [TREGeocodeResponseQueue addObject:failed];
        [self checkForGeoCodeFetchCompletionAndReturn];
    }
}

-(void)treReverseGeocodeSearchDidComplete:(TRECommunication *)communicator{
    if (communicator.reverseGeoCodeList.count > 0) {
        [self.reverseGeocodeSearchdelegate reverseGeocodeSearchDidComplete:(GeoCode *)[communicator.reverseGeoCodeList objectAtIndex:0]];
    }else{
        [self.reverseGeocodeSearchdelegate reverseGeocodeSearchDidFail:@"No address was found for the coordinates."];
    }
}

-(void)treReverseGeocodeSearchFailed:(int)errorCode{
    NSString *errorString = @"";
    switch (errorCode) {
        case -1009:
            errorString = @"Internet connection appears to be offline.";
            break;
        default:
            errorString = @"No address was found for the coordinates";
            break;
    }
    
    [self.reverseGeocodeSearchdelegate reverseGeocodeSearchDidFail:errorString];
}

- (void)treRouteSearchDidComplete:(TRECommunication *)communicator{
    [routeSearchdelegate routeSearchDidComplete:communicator.routeList];
}
- (void)treRouteSearchFailed:(int)errorCode{
    if (errorCode == -1009) {
        [routeSearchdelegate routeSearchDidFail:@"Internet connection appears to be offline."];
    }else if (errorCode == -1016) {
        [routeSearchdelegate routeSearchDidFail:@"No route information available for the selected addresses."];
    }else{
        [routeSearchdelegate routeSearchDidFail:nil];
    }
}
- (void)treDisruptionFetchComplete:(TRECommunication *)communicator{
    
}
- (void)treDisruptionFetchFailed:(int)errorCode{
    
}

- (void)dealloc
{
    NSLog(@"RettiManager:Dealloc:Saved cooki data");
}

@end
