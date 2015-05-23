//
//  PubTransAPI.h
//  Reitti
//
//  Created by Anteneh Sahledengel on 14/5/15.
//  Copyright (c) 2015 Anteneh Sahledengel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "APIClient.h"

@protocol PubTransCommunicatorDelegate <NSObject>
- (void)receivedGeoJSON:(NSData *)objectNotation;
- (void)fetchingVehiclesFromPubTransFailedWithError:(NSError *)error;
@end

@interface PubTransCommunicator : APIClient

@property (weak, nonatomic) id <PubTransCommunicatorDelegate> delegate;

@end
