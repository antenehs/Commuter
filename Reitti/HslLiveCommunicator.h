//
//  HslLiveCommunicator.h
//  Reitti
//
//  Created by Anteneh Sahledengel on 19/5/15.
//  Copyright (c) 2015 Anteneh Sahledengel. All rights reserved.
//

#import "APIClient.h"

@protocol HslLiveCommunicatorDelegate <NSObject>
- (void)receivedVehiclesCSV:(NSData *)objectNotation;
- (void)fetchingVehiclesFromHSLLiveFailedWithError:(NSError *)error;
@end

@interface HslLiveCommunicator : APIClient

@property (weak, nonatomic) id <HslLiveCommunicatorDelegate> delegate;

@end
