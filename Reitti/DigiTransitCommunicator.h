//
//  DigiTransitCommunicator.h
//  Reitti
//
//  Created by Anteneh Sahledengel on 19/5/16.
//  Copyright © 2016 Anteneh Sahledengel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "APIClient.h"

@interface DigiTransitCommunicator : APIClient

+(id)hslDigiTransitCommunicator;
+(id)treDigiTransitCommunicator;
+(id)finlandDigiTransitCommunicator;

-(void)fetchStopDetailForCode:(NSString *)stopCode name:(NSString *)stopName withCompletionBlock:(ActionBlock)completionBlock;

@end
