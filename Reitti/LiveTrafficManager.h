//
//  LiveTrafficManager.h
//  Reitti
//
//  Created by Anteneh Sahledengel on 14/5/15.
//  Copyright (c) 2015 Anteneh Sahledengel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PubTransCommunicator.h"
#import "HslLiveCommunicator.h"

@protocol LiveTraficManagerDelegate
- (void)didReceiveVehiclesFromHSlLive:(NSArray *)vehicleList;
- (void)fetchingVehiclesFromHSLFailedWithError:(NSError *)error;
- (void)didReceiveVehiclesFromPubTrans:(NSArray *)vehicleList;
- (void)fetchingVehiclesFromPubTransFailedWithError:(NSError *)error;
@end

@interface LiveTrafficManager : NSObject<PubTransCommunicatorDelegate> {
    PubTransCommunicator *pubTransAPI;
//    HslLiveCommunicator *hslLiveAPI;
    
    BOOL allVehiclesAreBeingFetch;
    BOOL vehiclesAreBeingFetchFromHSL;
    BOOL vehiclesAreBeingFetchFromPubTrans;
    
    NSTimer *refreshTimer;
    NSTimer *hslRefreshTimer;
    NSTimer *pubTransRefreshTimer;
    
    bool vehicleFetchFromPubtransComplete;
    bool vehicleFetchFromHSLLiveComplete;
    
    NSInteger hslDevApiFetchFailCount;
    NSInteger hslLiveApiFetchFailCount;
}

- (instancetype)init;
- (void)fetchAllLiveVehiclesWithCodesFromHSLLive:(NSArray *)lineCodes andTrainCodes:(NSArray *)trainCodes;
- (void)fetchAllLiveVehiclesWithCodesFromPubTrans:(NSArray *)lineCodes;
- (void)fetchAllLiveVehicles;
- (void)stopFetchingVehicles;

+ (NSArray *)vehiclesFromJSON:(NSData *)objectNotation error:(NSError **)error;

@property (weak, nonatomic) id<LiveTraficManagerDelegate> delegate;

@property(nonatomic, strong) PubTransCommunicator *pubTransAPI;
@property(nonatomic, strong) HslLiveCommunicator *hslLiveAPI;

@property(nonatomic, strong) NSMutableArray *totalVehicleList;

@end
