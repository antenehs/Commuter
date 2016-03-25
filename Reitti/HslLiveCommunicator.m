//
//  HslLiveCommunicator.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 19/5/15.
//  Copyright (c) 2015 Anteneh Sahledengel. All rights reserved.
//

#import "HslLiveCommunicator.h"
#import "Vehicle.h"
#import "DevHslVehicle.h"
#import "ReittiStringFormatter.h"

@interface HslLiveCommunicator ()

@property (nonatomic, strong)APIClient *hslLiveApiClient;
@property (nonatomic, strong)APIClient *hslDevApiClient;

@end

@implementation HslLiveCommunicator

-(id)init{
    self = [super init];
    
    if (self) {
        self.hslLiveApiClient = [[APIClient alloc] init];
        self.hslLiveApiClient.apiBaseUrl = @"http://83.145.232.209:10001/";
        
        self.hslDevApiClient = [[APIClient alloc] init];
        self.hslDevApiClient.apiBaseUrl = @"http://dev.hsl.fi/siriaccess/vm/json";
    }
    
    return self;
}

#pragma mark - fetching from HSLLive CSV interface

-(void)getAllLiveVehiclesFromHSLLive:(NSArray *)lineCodes withCompletionBlock:(ActionBlock)completionBlock{
    NSMutableDictionary *optionsDict = [@{} mutableCopy];
    
    //&lng1=22&lat1=59&lng2=26&lat2=62&online=1&vehicletype=0,1,2,3,5"
    [optionsDict setValue:@"vehicles" forKey:@"type"];
    [optionsDict setValue:@"22" forKey:@"lng1"];
    [optionsDict setValue:@"59" forKey:@"lat1"];
    [optionsDict setValue:@"26" forKey:@"lng2"];
    [optionsDict setValue:@"62" forKey:@"lat2"];
    [optionsDict setValue:@"1" forKey:@"online"];
    [optionsDict setValue:@"0,1,2,3,5" forKey:@"vehicletype"]; //Excluding 4 - train
    
    if (lineCodes != nil && lineCodes.count > 0) {
        NSMutableArray *tempArray = [@[] mutableCopy];
        
        for (NSString *lineCode in lineCodes) {
            NSArray *segments = [lineCode componentsSeparatedByString:@" "];
            if (segments.count > 1) {
                [tempArray addObject:[NSString stringWithFormat:@"%@.%@", [segments firstObject], [segments lastObject]]];
            }else if(segments.count == 1){
                [tempArray addObject:[segments firstObject]];
            }
        }
        
        if (tempArray.count > 0) {
            NSString *codesString = [ReittiStringFormatter commaSepStringFromArray:tempArray withSeparator:@"_"];
            [optionsDict setValue:codesString forKey:@"lines"];
        }else{
            completionBlock(nil, @"Invalid line code provided.");
            return;
        }
    }
    
    [self.hslLiveApiClient doApiFetchWithOutMappingWithParams:optionsDict andCompletionBlock:^(NSData *response, NSError *error){
        if (!error) {
//            [self.delegate receivedVehiclesCSV:response];
            NSString *parsingError = nil;
            NSArray *vehicles = [self parseCSVVehiclesFromData:response error:&parsingError];
            if (vehicles && vehicles.count != 0) {
                completionBlock(vehicles, nil);
            }else{
                completionBlock(nil, parsingError);
            }
        }else{
             completionBlock(nil, @"Fetching vehicles from HSL live failed.");
        }
    }];
}

#pragma mark - fetching from HSL DEV's navigator json interface.

-(void)getAllLiveVehiclesFromHSLDev:(NSArray *)lineCodes withCompletionBlock:(ActionBlock)completionBlock{
    
    if (lineCodes && lineCodes.count > 0) {
        
        __block NSInteger totalCount = lineCodes.count;
        __block NSMutableArray *vehicleResponses = [@[] mutableCopy];
        
        for (NSString *lineCode in lineCodes) {
            NSMutableDictionary *optionsDict = [@{} mutableCopy];
            
            [optionsDict setValue:@"HSL" forKey:@"OperatorRef"];
            
            NSArray *segments = [lineCode componentsSeparatedByString:@" "];
            NSString * formattedCode = [segments firstObject];
            
            [optionsDict setValue:formattedCode forKey:@"lineRef"];
            
            [self.hslDevApiClient doApiFetchWithOutMappingWithParams:optionsDict andCompletionBlock:^(NSData *response, NSError *error){
                
                if (!error) {
                    //Parse response and add to vehicles array
                    NSError *parsingError = nil;
                    NSArray *vehicles = [self parseTrainJsonVehiclesFromHslDev:response error:&parsingError];
                    
                    if (!parsingError && vehicles) {
                        [vehicleResponses addObjectsFromArray:vehicles];
                    }
                }
                
                totalCount--;
                if (totalCount == 0) {
                    completionBlock(vehicleResponses, error);
                }
            }];
        }
    }else{
        NSMutableDictionary *optionsDict = [@{} mutableCopy];
        
        [optionsDict setValue:@"HSL" forKey:@"OperatorRef"];
        
        [self.hslDevApiClient doApiFetchWithOutMappingWithParams:optionsDict andCompletionBlock:^(NSData *response, NSError *error){
            if (!error) {
                //Parse response and add to vehicles array
                NSError *parsingError = nil;
                NSArray *vehicles = nil;
                @try {
                     vehicles = [self parseTrainJsonVehiclesFromHslDev:response error:&parsingError];
                }
                @catch (NSException *exception) {}
                
                if (!parsingError && vehicles) {
                    completionBlock(vehicles, nil);
                }else{
                    completionBlock(@[], @"Parsing vehicles failed!");
                }
            }else{
                completionBlock(@[], @"Fetching vehicles failed!");
            }
        }];
    }
}

#pragma mark - Helper methods

-(NSArray *)parseCSVVehiclesFromData:(NSData *)objectNotation error:(NSString **)errorString{
    NSString* vehiclesString =  [[NSString alloc] initWithData:objectNotation encoding:NSUTF8StringEncoding];
    
    if (vehiclesString == nil) {
        *errorString = @"csv string is empty.";
        return nil;
    }
    
    NSMutableArray *vehicles = [[NSMutableArray alloc] init];
    
    NSArray *allLines = [vehiclesString componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    
    for (NSString *csvLine in allLines) {
        @try {
            Vehicle *vehicle = [[Vehicle alloc] initWithCSV:csvLine];
            if (vehicle != nil) {
                [vehicles addObject:vehicle];
            }
        }
        @catch (NSException *exception) {
            *errorString = [NSString stringWithFormat:@"parsing csv line - %@ - threw an exception", csvLine];
            return nil;
        }
    }
    
    return vehicles;
}

-(NSArray *)parseTrainJsonVehiclesFromHslDev:(NSData *)objectNotation error:(NSError **)error{
    
    NSError *localError = nil;
    NSDictionary *parsedObject = [NSJSONSerialization JSONObjectWithData:objectNotation options:0 error:&localError];
    
    if (localError != nil) {
        *error = localError;
        return nil;
    }
    
    NSMutableArray *vehicles = [@[] mutableCopy];
    
    if (parsedObject[@"Siri"] && parsedObject[@"Siri"][@"ServiceDelivery"] && parsedObject[@"Siri"][@"ServiceDelivery"][@"VehicleMonitoringDelivery"]) {
        
        NSArray *monitoringDeliveries = parsedObject[@"Siri"][@"ServiceDelivery"][@"VehicleMonitoringDelivery"];
        
        for (NSDictionary *monitoringDelivery in monitoringDeliveries) {
            NSArray *results = monitoringDelivery[@"VehicleActivity"];
            
            for (NSDictionary *vehicleDictionary in results) {
                @try {
                    DevHslVehicle *devVehicle = [[DevHslVehicle alloc] initWithDictionary:vehicleDictionary];
                    
                    if (devVehicle) {
                        Vehicle *vehicle = [[Vehicle alloc] initWithHslDevVehicle:devVehicle];
                        
                        if (vehicle && vehicle.vehicleType == VehicleTypeTrain) {
                            [vehicles addObject:vehicle];
                        }
                    }
                }
                @catch (NSException *exception) {}
            }
        }
    }
    
    return vehicles;
}


#pragma mark - Obsolete delegate methods
//- (void)VehiclesFetchFromHslLiveComplete:(NSData *)objectNotation{
//    [self.delegate receivedVehiclesCSV:objectNotation];
//}
//- (void)VehiclesFetchFromHslLiveFailed:(NSError *)error{
//    [self.delegate fetchingVehiclesFromHSLLiveFailedWithError:error];
//}

//- (void)dealloc
//{
//    NSLog(@"Communication:This ARC deleted my HSL Live API.");
//}

@end
