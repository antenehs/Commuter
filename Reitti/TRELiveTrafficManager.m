//
//  TRELiveTrafficManager.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 26/3/16.
//  Copyright © 2016 Anteneh Sahledengel. All rights reserved.
//

#import "TRELiveTrafficManager.h"
#import "APIClient.h"

NSString *kTRELineCodesKey = @"lineCodes";

@interface TRELiveTrafficManager ()

@property (nonatomic, strong)APIClient *itsfApiClient;

@property (nonatomic, copy) ActionBlock fetchAllFromHSLHandler;
@property (nonatomic, copy) ActionBlock fetchLinesFromHSLHandler;

@end

@implementation TRELiveTrafficManager

-(id)init{
    self = [super init];
    
    if (self) {
        self.itsfApiClient = [[APIClient alloc] init];
        self.itsfApiClient.apiBaseUrl = @"http://data.itsfactory.fi/journeys/api/1/vehicle-activity/";
    }
    
    return self;
}

- (void)fetchLiveVehiclesFromHSLLiveForLineCodes:(NSArray *)lineCodes andTrainCodes:(NSArray *)trainCodes withCompletionHandler:(ActionBlock)completionHandler{
    //Check for straight three times fail and cancel automatically updating.
    
//    [hslLiveAPI getAllLiveVehiclesFromHSLDev:trainCodes withCompletionBlock:^(NSArray *vehicles, NSString *errorString){
//        reqestCount--;
//        if (!errorString) {
//            [allVehicles addObjectsFromArray:vehicles];
//            
//            hslDevApiFetchFailCount = 0;
//        }else{
//            if (reqestCount == 0) {
//                //                    [self.delegate fetchingVehiclesFromHSLFailedWithError:nil];
//                if (completionHandler)
//                    completionHandler(nil, errorString);
//                return;
//            }
//            
//            hslDevApiFetchFailCount++;
//            
//            [[ReittiAnalyticsManager sharedManager] trackErrorEventForAction:kActionApiSearchFailed label:[NSString stringWithFormat:@"Live vehicle fetch from HSL Dev failed. Error: %@", errorString] value:nil];
//        }
//        
//        if (reqestCount == 0) {
//            //                [self.delegate didReceiveVehiclesFromHSlLive:allVehicles];
//            if (completionHandler)
//                completionHandler(allVehicles, nil);
//        }
//    }];
    
    NSMutableDictionary *optionsDict = [@{} mutableCopy];
    
    [optionsDict setValue:@"HSL" forKey:@"OperatorRef"];
    
//    [self.itsfApiClient doApiFetchWithOutMappingWithParams:optionsDict andCompletionBlock:^(NSData *response, NSError *error){
//        if (!error) {
//            //Parse response and add to vehicles array
//            NSError *parsingError = nil;
//            NSArray *vehicles = nil;
//            @try {
//                vehicles = [self parseTrainJsonVehiclesFromHslDev:response error:&parsingError];
//            }
//            @catch (NSException *exception) {}
//            
//            if (!parsingError && vehicles) {
//                completionBlock(vehicles, nil);
//            }else{
//                completionBlock(@[], @"Parsing vehicles failed!");
//            }
//        }else{
//            completionBlock(@[], @"Fetching vehicles failed!");
//        }
//    }];
}

- (void)startFetchingAllLiveVehiclesWithCodes:(NSArray *)lineCodes andTrainCodes:(NSArray *)trainCodes withCompletionHandler:(ActionBlock)completionHandler {
    
}

- (void)startFetchingAllLiveVehiclesWithCompletionHandler:(ActionBlock)completionHandler {

}

- (void)stopFetchingVehicles {
    
}

- (void)updateAllLiveVehiclesFromHSL:(NSTimer *)sender {
    [self fetchLiveVehiclesFromHSLLiveForLineCodes:nil andTrainCodes:nil withCompletionHandler:self.fetchAllFromHSLHandler];
}

- (void)updateLiveVehiclesWithCodeFromHSL:(NSTimer *)sender {
    NSDictionary *userInfo = [sender userInfo] ? [sender userInfo] : @{};
    [self fetchLiveVehiclesFromHSLLiveForLineCodes:userInfo[kTRELineCodesKey] andTrainCodes:nil withCompletionHandler:self.fetchLinesFromHSLHandler];
}

@end
