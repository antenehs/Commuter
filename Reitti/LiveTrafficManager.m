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

@interface LiveTrafficManager ()

@property (nonatomic, copy) ActionBlock fetchAllFromHSLHandler;
@property (nonatomic, copy) ActionBlock fetchLinesFromHSLHandler;

@end

@implementation LiveTrafficManager

@synthesize hslLiveAPI;

- (instancetype)init {
    hslLiveAPI = [[HslLiveCommunicator alloc] init];
    
    allVehiclesAreBeingFetch = NO;

    return self;
}

#pragma mark - HSL live vehicle methods

- (void)fetchLiveVehiclesFromHSLLiveForLineCodes:(NSArray *)lineCodes andTrainCodes:(NSArray *)trainCodes withCompletionHandler:(ActionBlock)completionHandler{
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
//                    [self.delegate fetchingVehiclesFromHSLFailedWithError:nil];
                    if (completionHandler)
                        completionHandler(nil, errorString);
                    return;
                }
                
                hslDevApiFetchFailCount++;
                
                [[ReittiAnalyticsManager sharedManager] trackErrorEventForAction:kActionApiSearchFailed label:[NSString stringWithFormat:@"Live vehicle fetch from HSL Dev failed. Error: %@", errorString] value:nil];
            }
            
            if (reqestCount == 0) {
//                [self.delegate didReceiveVehiclesFromHSlLive:allVehicles];
                if (completionHandler)
                    completionHandler(allVehicles, nil);
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
//                    [self.delegate fetchingVehiclesFromHSLFailedWithError:nil];
                    if (completionHandler)
                        completionHandler(nil, errorString);
                    return;
                }
                
                hslLiveApiFetchFailCount++;
                
                [[ReittiAnalyticsManager sharedManager] trackErrorEventForAction:kActionApiSearchFailed label:[NSString stringWithFormat:@"Live vehicle fetch from HSL Live failed. Error: %@", errorString] value:nil];
            }
            
            if (reqestCount == 0) {
//                [self.delegate didReceiveVehiclesFromHSlLive:allVehicles];
                if (completionHandler)
                    completionHandler(allVehicles, nil);
            }
        }];
    }
}

- (void)fetchAllLiveVehiclesFromHSLLiveWithCompletionHandler:(ActionBlock)completionHandler{
    
    __block NSMutableArray *allVehicles = [@[] mutableCopy];
    __block NSInteger reqestCount = 2;
    
    [hslLiveAPI getAllLiveVehiclesFromHSLDev:nil withCompletionBlock:^(NSArray *vehicles, NSString *errorString){
        reqestCount--;
        if (!errorString) {
            [allVehicles addObjectsFromArray:vehicles];
        }else{
            if (reqestCount == 0) {
//                [self.delegate fetchingVehiclesFromHSLFailedWithError:nil];
                if (completionHandler)
                    completionHandler(nil, errorString);
                return;
            }
            
            [[ReittiAnalyticsManager sharedManager] trackErrorEventForAction:kActionApiSearchFailed label:[NSString stringWithFormat:@"Live vehicle fetch from HSL Dev failed. Error: %@", errorString] value:nil];
        }
        
        if (reqestCount == 0) {
//            [self.delegate didReceiveVehiclesFromHSlLive:allVehicles];
            if (completionHandler)
                completionHandler(allVehicles, nil);
        }
    }];
    
    [hslLiveAPI getAllLiveVehiclesFromHSLLive:nil withCompletionBlock:^(NSArray *vehicles, NSString *errorString){
        reqestCount--;
        if (!errorString) {
            [allVehicles addObjectsFromArray:vehicles];
        }else{
            if (reqestCount == 0) {
//                [self.delegate fetchingVehiclesFromHSLFailedWithError:nil];
                if (completionHandler)
                    completionHandler(nil, errorString);
                return;
            }
            
            [[ReittiAnalyticsManager sharedManager] trackErrorEventForAction:kActionApiSearchFailed label:[NSString stringWithFormat:@"Live vehicle fetch from HSL Live failed. Error: %@", errorString] value:nil];
        }
        
        if (reqestCount == 0) {
//            [self.delegate didReceiveVehiclesFromHSlLive:allVehicles];
            if (completionHandler)
                completionHandler(allVehicles, nil);
        }
    }];
}

- (void)startFetchingAllLiveVehiclesWithCodesFromHSLLive:(NSArray *)lineCodes andTrainCodes:(NSArray *)trainCodes withCompletionHandler:(ActionBlock)completionHandler{
    @try {
        self.fetchLinesFromHSLHandler = completionHandler;
        [self fetchLiveVehiclesFromHSLLiveForLineCodes:lineCodes andTrainCodes:trainCodes withCompletionHandler:completionHandler];
        
        hslDevApiFetchFailCount = 0;
        hslLiveApiFetchFailCount = 0;
        
        NSDictionary *userInfo = @{kLineCodesKey : lineCodes ? lineCodes : @[] , kTrainCodesKey : trainCodes ? trainCodes : @[]};
        hslRefreshTimer = [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(updateLiveVehiclesWithCodeFromHSL:) userInfo:userInfo repeats:YES];
    }
    @catch (NSException *exception) {
        completionHandler(nil, exception.reason);
    }
}

- (void)startFetchingAllLiveVehiclesWithCompletionHandler:(ActionBlock)completionHandler{
    if (!allVehiclesAreBeingFetch) {
        self.fetchAllFromHSLHandler = completionHandler;
        [self fetchAllLiveVehiclesFromHSLLiveWithCompletionHandler:completionHandler];
        refreshTimer = [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(updateAllLiveVehiclesFromHSL:) userInfo:nil repeats:YES];
        allVehiclesAreBeingFetch = YES;
    }
}

-(void)stopFetchingVehicles{
    [refreshTimer invalidate];
    [hslRefreshTimer invalidate];
    allVehiclesAreBeingFetch = NO;
    
    self.fetchAllFromHSLHandler = nil;
    self.fetchLinesFromHSLHandler = nil;
}

- (void)updateAllLiveVehiclesFromHSL:(NSTimer *)sender {
    [self fetchAllLiveVehiclesFromHSLLiveWithCompletionHandler:self.fetchAllFromHSLHandler];
    
}

- (void)updateLiveVehiclesWithCodeFromHSL:(NSTimer *)sender {
    NSDictionary *userInfo = [sender userInfo] ? [sender userInfo] : @{};
    [self fetchLiveVehiclesFromHSLLiveForLineCodes:userInfo[kLineCodesKey] andTrainCodes:userInfo[kTrainCodesKey] withCompletionHandler:self.fetchLinesFromHSLHandler];
}

@end
