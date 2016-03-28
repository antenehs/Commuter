//
//  LiveTrafficManager.h
//  Reitti
//
//  Created by Anteneh Sahledengel on 14/5/15.
//  Copyright (c) 2015 Anteneh Sahledengel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HslLiveCommunicator.h"
#import "ApiProtocols.h"

@interface HSLLiveTrafficManager : NSObject <LiveTrafficFetchProtocol> {
    BOOL allVehiclesAreBeingFetch;
    
    NSTimer *refreshTimer;
    NSTimer *hslRefreshTimer;
    
    NSInteger hslDevApiFetchFailCount;
    NSInteger hslLiveApiFetchFailCount;
}

- (instancetype)init;
//- (void)startFetchingAllLiveVehiclesWithCodes:(NSArray *)lineCodes andTrainCodes:(NSArray *)trainCodes withCompletionHandler:(ActionBlock)completionHandler;
//- (void)startFetchingAllLiveVehiclesWithCompletionHandler:(ActionBlock)completionHandler;
//- (void)stopFetchingVehicles;

@property(nonatomic, strong) HslLiveCommunicator *hslLiveAPI;

@end
