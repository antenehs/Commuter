//
//  HslLiveCommunicator.h
//  Reitti
//
//  Created by Anteneh Sahledengel on 19/5/15.
//  Copyright (c) 2015 Anteneh Sahledengel. All rights reserved.
//

#import "APIClient.h"

@interface HslLiveCommunicator : NSObject

- (void)getAllLiveVehiclesFromHSLLive:(NSArray *)lineCodes withCompletionBlock:(ActionBlock)completionBlock;
- (void)getAllLiveVehiclesFromHSLDev:(NSArray *)lineCodes withCompletionBlock:(ActionBlock)completionBlock;

@end
