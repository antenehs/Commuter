//
//  LiveTrafficManager.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 14/5/15.
//  Copyright (c) 2015 Anteneh Sahledengel. All rights reserved.
//

#import "LiveTrafficManager.h"
#import "Vehicle.h"
#import "ReittiStringFormatter.h"
#import "ReittiAnalyticsManager.h"

NSString *kLineCodesKey = @"lineCodes";
NSString *kTrainCodesKey = @"trainCodes";

@implementation LiveTrafficManager

@synthesize delegate;

@synthesize pubTransAPI, hslLiveAPI,totalVehicleList;

- (instancetype)init {
    pubTransAPI = [[PubTransCommunicator alloc] init];
    pubTransAPI.delegate = self;
    
    hslLiveAPI = [[HslLiveCommunicator alloc] init];
//    hslLiveAPI.delegate = self;
    
    totalVehicleList = [[NSMutableArray alloc] init];
    
    allVehiclesAreBeingFetch = NO;
    vehiclesAreBeingFetchFromHSL = NO;
    vehiclesAreBeingFetchFromPubTrans = NO;
    vehicleFetchFromPubtransComplete = NO;
    vehicleFetchFromHSLLiveComplete = NO;

    return self;
}

//- (void)formatAndStartFetchingVehiclesFromHslLive:(NSArray *)lineCodes {
//    if (lineCodes == nil)
//        return;
//    
//    [self fetchLiveVehiclesFromHSLLiveForLineCodes:lineCodes];
//    pubTransRefreshTimer = [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(updateLiveVehiclesFromHSL:) userInfo:lineCodes repeats:YES];
//}

- (void)fetchLiveVehiclesFromHSLLiveForLineCodes:(NSArray *)lineCodes andTrainCodes:(NSArray *)trainCodes{
    //Check for straight three times fail and cancel automatically updating.
    
    __block NSMutableArray *allVehicles = [@[] mutableCopy];
    __block NSInteger reqestCount = 0;
    reqestCount += lineCodes && lineCodes.count > 0 ? 1 : 0;
    reqestCount += trainCodes && trainCodes.count > 0 ? 1 : 0;
    
    if (trainCodes && trainCodes.count > 0 && hslDevApiFetchFailCount < 10) {
        [hslLiveAPI getAllLiveVehiclesFromHSLDev:trainCodes withCompletionBlock:^(NSArray *vehicles, NSString *errorString){
            reqestCount--;
            if (!errorString) {
                [allVehicles addObjectsFromArray:vehicles];
                
                hslDevApiFetchFailCount = 0;
            }else{
                if (reqestCount == 0) {
                    [self.delegate fetchingVehiclesFromHSLFailedWithError:nil];
                    return;
                }
                
                hslDevApiFetchFailCount++;
                
                [[ReittiAnalyticsManager sharedManager] trackErrorEventForAction:kActionApiSearchFailed label:[NSString stringWithFormat:@"Live vehicle fetch from HSL Dev failed. Error: %@", errorString] value:nil];
            }
            
            if (reqestCount == 0) {
                [self.delegate didReceiveVehiclesFromHSlLive:allVehicles];
            }
        }];
    }
    
    if (lineCodes && lineCodes.count > 0 && hslLiveApiFetchFailCount < 10) {
        [hslLiveAPI getAllLiveVehiclesFromHSLLive:lineCodes withCompletionBlock:^(NSArray *vehicles, NSString *errorString){
            reqestCount--;
            if (!errorString) {
                [allVehicles addObjectsFromArray:vehicles];
                
                hslLiveApiFetchFailCount = 0;
            }else{
                if (reqestCount == 0) {
                    [self.delegate fetchingVehiclesFromHSLFailedWithError:nil];
                    return;
                }
                
                hslLiveApiFetchFailCount++;
                
                [[ReittiAnalyticsManager sharedManager] trackErrorEventForAction:kActionApiSearchFailed label:[NSString stringWithFormat:@"Live vehicle fetch from HSL Live failed. Error: %@", errorString] value:nil];
            }
            
            if (reqestCount == 0) {
                [self.delegate didReceiveVehiclesFromHSlLive:allVehicles];
            }
        }];
    }
}

- (void)fetchAllLiveVehiclesFromHSLLive{
    
    __block NSMutableArray *allVehicles = [@[] mutableCopy];
    __block NSInteger reqestCount = 2;
    
    [hslLiveAPI getAllLiveVehiclesFromHSLDev:nil withCompletionBlock:^(NSArray *vehicles, NSString *errorString){
        reqestCount--;
        if (!errorString) {
            [self.totalVehicleList addObjectsFromArray:vehicles];
            [allVehicles addObjectsFromArray:vehicles];
        }else{
            if (reqestCount == 0) {
                [self.delegate fetchingVehiclesFromHSLFailedWithError:nil];
                return;
            }
            
            [[ReittiAnalyticsManager sharedManager] trackErrorEventForAction:kActionApiSearchFailed label:[NSString stringWithFormat:@"Live vehicle fetch from HSL Dev failed. Error: %@", errorString] value:nil];
        }
        
        if (reqestCount == 0) {
            [self.delegate didReceiveVehiclesFromHSlLive:allVehicles];
        }
    }];
    
    [hslLiveAPI getAllLiveVehiclesFromHSLLive:nil withCompletionBlock:^(NSArray *vehicles, NSString *errorString){
        reqestCount--;
        if (!errorString) {
            [self.totalVehicleList addObjectsFromArray:vehicles];
            [allVehicles addObjectsFromArray:vehicles];
        }else{
            if (reqestCount == 0) {
                [self.delegate fetchingVehiclesFromHSLFailedWithError:nil];
                return;
            }
            
            [[ReittiAnalyticsManager sharedManager] trackErrorEventForAction:kActionApiSearchFailed label:[NSString stringWithFormat:@"Live vehicle fetch from HSL Live failed. Error: %@", errorString] value:nil];
        }
        
        if (reqestCount == 0) {
            [self.delegate didReceiveVehiclesFromHSlLive:allVehicles];
        }
    }];
}

- (void)fetchAllLiveVehiclesWithCodesFromHSLLive:(NSArray *)lineCodes andTrainCodes:(NSArray *)trainCodes{
    //Format line codes
    @try {
        [self fetchLiveVehiclesFromHSLLiveForLineCodes:lineCodes andTrainCodes:trainCodes];
        
        hslDevApiFetchFailCount = 0;
        hslLiveApiFetchFailCount = 0;
        
        NSDictionary *userInfo = @{kLineCodesKey : lineCodes ? lineCodes : @[] , kTrainCodesKey : trainCodes ? trainCodes : @[]};
        hslRefreshTimer = [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(updateLiveVehiclesWithCodeFromHSL:) userInfo:userInfo repeats:YES];
    }
    @catch (NSException *exception) {
        [self.delegate fetchingVehiclesFromHSLFailedWithError:nil];
    }
   
}

- (void)formatAndStartFetchingVehiclesFromPubTrans:(NSArray *)lineCodes {
    if (lineCodes == nil)
        return;
    
    if (lineCodes.count > 0) {
        NSString *codesString = [ReittiStringFormatter commaSepStringFromArray:lineCodes withSeparator:@"|"];
        [pubTransAPI getAllLiveVehiclesFromPubTrans:codesString];
        pubTransRefreshTimer = [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(updateLiveVehiclesFromPubTrans:) userInfo:codesString repeats:YES];
    }else{
        [self.delegate fetchingVehiclesFromPubTransFailedWithError:nil];
    }
}

- (void)fetchAllLiveVehiclesWithCodesFromPubTrans:(NSArray *)lineCodes{
    //Format line codes
    @try {
        if (!vehiclesAreBeingFetchFromPubTrans) {
            [self formatAndStartFetchingVehiclesFromPubTrans:lineCodes];
            vehiclesAreBeingFetchFromPubTrans = YES;
        }
    }
    @catch (NSException *exception) {
        [self.delegate fetchingVehiclesFromPubTransFailedWithError:nil];
    }
    
}

- (void)fetchAllLiveVehicles{
    if (!allVehiclesAreBeingFetch) {
        [self.totalVehicleList removeAllObjects];
        [self fetchAllLiveVehiclesFromHSLLive];
//        [pubTransAPI getAllLiveVehiclesFromPubTrans:nil];
        refreshTimer = [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(updateAllLiveVehiclesFromHSL:) userInfo:nil repeats:YES];
        allVehiclesAreBeingFetch = YES;
        vehicleFetchFromPubtransComplete = YES;
        vehicleFetchFromHSLLiveComplete = NO;
    }
}

-(void)stopFetchingVehicles{
    [refreshTimer invalidate];
    [hslRefreshTimer invalidate];
    [pubTransRefreshTimer invalidate];
    allVehiclesAreBeingFetch = NO;
    vehiclesAreBeingFetchFromPubTrans = NO;
    vehiclesAreBeingFetchFromHSL = NO;
}

- (IBAction) updateAllLiveVehiclesFromHSL:(NSTimer *)sender {
    [self fetchAllLiveVehiclesFromHSLLive];
//    [pubTransAPI getAllLiveVehiclesFromPubTrans:nil];
    
    vehicleFetchFromPubtransComplete = YES;
    vehicleFetchFromHSLLiveComplete = NO;
    [self.totalVehicleList removeAllObjects];
}

- (IBAction)updateLiveVehiclesWithCodeFromHSL:(NSTimer *)sender {
    NSDictionary *userInfo = [sender userInfo] ? [sender userInfo] : @{};
    [self fetchLiveVehiclesFromHSLLiveForLineCodes:userInfo[kLineCodesKey] andTrainCodes:userInfo[kTrainCodesKey]];
}

- (IBAction)updateLiveVehiclesFromPubTrans:(NSTimer *)sender {
    [pubTransAPI getAllLiveVehiclesFromPubTrans:[sender userInfo]];
}

#pragma mark - vehicle fetch delegate
- (void)receivedGeoJSON:(NSData *)objectNotation{
    vehicleFetchFromPubtransComplete = YES;
    NSError *error = nil;
    NSArray *vehicles = [LiveTrafficManager vehiclesFromJSON:objectNotation error:&error];

    [self.totalVehicleList addObjectsFromArray:vehicles];
    if (error != nil) {
        [self.delegate fetchingVehiclesFromPubTransFailedWithError:error];
        
    } else {
        [self.delegate didReceiveVehiclesFromPubTrans:vehicles];
    }
}
- (void)fetchingVehiclesFromPubTransFailedWithError:(NSError *)error{
    vehicleFetchFromPubtransComplete = YES;
    [self.delegate fetchingVehiclesFromPubTransFailedWithError:error];
}

//- (void)receivedVehiclesCSV:(NSData *)objectNotation{
//    vehicleFetchFromHSLLiveComplete = YES;
//    NSString *error = nil;
//    NSArray *vehicles = [LiveTrafficManager vehiclesFromCSV:objectNotation error:&error];
//    
//    [self.totalVehicleList addObjectsFromArray:vehicles];
//    if (error != nil) {
//        [self.delegate fetchingVehiclesFromHSLFailedWithError:nil];
//    } else {
//        [self.delegate didReceiveVehiclesFromHSlLive:vehicles];
//    }
//    
//}
//- (void)fetchingVehiclesFromHSLLiveFailedWithError:(NSError *)error{
//    vehicleFetchFromHSLLiveComplete = YES;
//    if (vehicleFetchFromPubtransComplete) {
//        [self.delegate fetchingVehiclesFromHSLFailedWithError:error];
//    }
//}

#pragma stop fetchDelegate
- (void)receivedStopsFromPubTrans:(NSArray *)stops{}
- (void)fetchingStopsFromPubTransFailedWithError:(NSError *)error{}


#pragma mark - Helper methods
+ (NSArray *)vehiclesFromJSON:(NSData *)objectNotation error:(NSError **)error{
    NSError *localError = nil;
    NSDictionary *parsedObject = [NSJSONSerialization JSONObjectWithData:objectNotation options:0 error:&localError];
    
    if (localError != nil) {
        *error = localError;
        return nil;
    }
    
    NSMutableArray *vehicles = [[NSMutableArray alloc] init];
    
    NSArray *results = [parsedObject valueForKey:@"features"];
    
    for (NSDictionary *featureDict in results) {
        Vehicle *vehicle = [[Vehicle alloc] initWithDictionary:featureDict];
        
        [vehicles addObject:vehicle];
    }
    
    return vehicles;
}

+ (NSArray *)vehiclesFromCSV:(NSData *)objectNotation error:(NSString **)error{
    NSString* vehiclesString =  [[NSString alloc] initWithData:objectNotation encoding:NSUTF8StringEncoding];
    
    if (vehiclesString == nil) {
        *error = @"csv string is empty.";
        return nil;
    }
    
    NSMutableArray *vehicles = [[NSMutableArray alloc] init];
    
    NSArray *allLines = [vehiclesString componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    
    for (NSString *csvLine in allLines) {
        Vehicle *vehicle = [[Vehicle alloc] initWithCSV:csvLine];
//        NSLog(@"CSV line: %@", csvLine);
        if (vehicle != nil) {
            [vehicles addObject:vehicle];
        }
    }
    
    return vehicles;
}


@end
