//
//  StopCoreDataManager.h
//  Reitti
//
//  Created by Anteneh Sahledengel on 5/13/17.
//  Copyright © 2017 Anteneh Sahledengel. All rights reserved.
//

#import "CoreDataManager.h"
#import "BusStop.h"
#import "StopEntity.h"

@interface StopCoreDataManager : CoreDataManager

+(id)sharedManager;

//Saved Stop
-(void)saveToCoreDataStop:(BusStop *)stop;
-(BOOL)isBusStopSaved:(BusStop *)stop;
-(BOOL)isBusStopSavedWithCode:(NSString *)stopCode;

-(void)deleteSavedStopForCode:(NSString *)code;
-(void)deleteSavedStop:(StopEntity *)savedStop;
-(void)deleteSavedStops:(NSArray *)stops;
-(void)deleteAllSavedStop;

-(NSArray *)fetchAllSavedStopsFromCoreData;
-(StopEntity *)fetchSavedStopFromCoreDataForCode:(NSString *)code;

//Stop history
-(void)saveHistoryToCoreDataStop:(BusStop *)stop;

-(void)deleteHistoryStopForCode:(NSString *)code;
-(void)deleteAllHistoryStop;

-(NSArray *)fetchAllSavedStopHistoryFromCoreData;

//Comon
-(void)updateStopsOrderTo:(NSArray *)orderedObjects;

@end
