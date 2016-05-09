//
//  TRELiveTrafficManager.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 26/3/16.
//  Copyright © 2016 Anteneh Sahledengel. All rights reserved.
//

#import "TRELiveTrafficManager.h"
#import "APIClient.h"
#import "TREVehiceDataModels.h"
#import "Vehicle.h"
#import "ReittiStringFormatter.h"

NSString *kTRELineCodesKey = @"lineCodes";

@interface TRELiveTrafficManager ()

@property (nonatomic, strong)APIClient *itsfApiClient;

@property (nonatomic, copy) ActionBlock fetchAllFromTREHandler;
@property (nonatomic, copy) ActionBlock fetchLinesFromTREHandler;

@end

@implementation TRELiveTrafficManager

-(id)init{
    self = [super init];
    
    if (self) {
        allVehiclesAreBeingFetch = NO;
        self.itsfApiClient = [[APIClient alloc] init];
        self.itsfApiClient.apiBaseUrl = @"http://data.itsfactory.fi/journeys/api/1/vehicle-activity";
    }
    
    return self;
}

- (void)fetchLiveVehiclesFromTREForLineCodes:(NSArray *)lineCodes withCompletionHandler:(ActionBlock)completionHandler{
    //Check for straight three times fail and cancel automatically updating.
    
    NSMutableDictionary *optionsDict = [@{} mutableCopy];
    
    if (lineCodes && lineCodes.count > 0) {
        NSString *linesString = [self formatLineStrings:(NSArray *)lineCodes];
        [optionsDict setValue:linesString forKey:@"lineRef"];
    }
    
    [self.itsfApiClient doApiFetchWithOutMappingWithParams:optionsDict andCompletionBlock:^(NSData *response, NSError *error){
        if (!error) {
            //Parse response and add to vehicles array
            NSError *parsingError = nil;
            NSArray *vehicles = nil;
            @try {
                vehicles = [self parseJsonVehiclesFromItsFactory:response error:&parsingError];
            }
            @catch (NSException *exception) {}
            
            if (!parsingError && vehicles) {
                completionHandler(vehicles, nil);
            }else{
                completionHandler(@[], @"Parsing vehicles failed!");
            }
        }else{
            completionHandler(@[], @"Fetching vehicles failed!");
        }
    }];
}

-(NSString *)formatLineStrings:(NSArray *)lineCodes {
    NSMutableArray *codes = [@[] mutableCopy];
    for (NSString *lineCode in lineCodes) {
        NSArray *parts = [lineCode componentsSeparatedByString:@" "];
        if (parts.count < 1)
            continue;
        
        NSString *code = parts[0];
        [codes addObject:code];
        
        //For each code with letter, add also the root number. In tre, it can only be searched for the core number.
        NSString* coreNumber = [code stringByTrimmingCharactersInSet: [NSCharacterSet letterCharacterSet]];
        if (coreNumber && coreNumber.length != 0 && ![coreNumber isEqualToString:code]) {
            [codes addObject:coreNumber];
        }
    }
    
    return [ReittiStringFormatter commaSepStringFromArray:codes withSeparator:@","];
}

-(NSArray *)parseJsonVehiclesFromItsFactory:(NSData *)objectNotation error:(NSError **)error{
    
    NSError *localError = nil;
    NSDictionary *parsedObject = [NSJSONSerialization JSONObjectWithData:objectNotation options:0 error:&localError];
    
    if (localError != nil) {
        *error = localError;
        return nil;
    }
    
    NSMutableArray *vehicles = [@[] mutableCopy];
    
    if (parsedObject[@"body"]) {
        
        NSArray *monitoringVehicles = parsedObject[@"body"];
        
        for (NSDictionary *monitoringVehicle in monitoringVehicles) {
            @try {
                TREVehicle *treVehicle = [[TREVehicle alloc] initWithDictionary:monitoringVehicle];
                
                if (treVehicle) {
                    //Tre vehickes eg, 1C and 1V are under 1. So the specific number is changed here.
                    if (treVehicle.monitoredVehicleJourney.journeyPatternRef &&
                        ![treVehicle.monitoredVehicleJourney.journeyPatternRef isEqualToString:@""] &&
                        ![treVehicle.monitoredVehicleJourney.lineRef isEqualToString:treVehicle.monitoredVehicleJourney.journeyPatternRef]) {
                        treVehicle.monitoredVehicleJourney.lineRef = treVehicle.monitoredVehicleJourney.journeyPatternRef;
                    }
                    
                    Vehicle *vehicle = [[Vehicle alloc] initWithTreVehicle:treVehicle];
                    
                    [vehicles addObject:vehicle];
                }
            }
            @catch (NSException *exception) {}
        }
    }
    
    return vehicles;
}

- (void)startFetchingAllLiveVehiclesWithCodes:(NSArray *)lineCodes andTrainCodes:(NSArray *)trainCodes withCompletionHandler:(ActionBlock)completionHandler {
    @try {
        self.fetchLinesFromTREHandler = completionHandler;
        [self fetchLiveVehiclesFromTREForLineCodes:lineCodes withCompletionHandler:completionHandler];
        
        NSDictionary *userInfo = @{kTRELineCodesKey : lineCodes ? lineCodes : @[]};
        linesFetchRefreshTimer = [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(updateLiveVehiclesWithCodeFromTRE:) userInfo:userInfo repeats:YES];
    }
    @catch (NSException *exception) {
        completionHandler(nil, exception.reason);
    }
}

- (void)startFetchingAllLiveVehiclesWithCompletionHandler:(ActionBlock)completionHandler {
    if (!allVehiclesAreBeingFetch) {
        self.fetchAllFromTREHandler = completionHandler;
        [self fetchLiveVehiclesFromTREForLineCodes:nil withCompletionHandler:completionHandler];
        refreshTimer = [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(updateAllLiveVehiclesFromTRE:) userInfo:nil repeats:YES];
        allVehiclesAreBeingFetch = YES;
    }
    
//    [self fetchLiveVehiclesFromTREForLineCodes:nil withCompletionHandler:completionHandler];
}

- (void)stopFetchingVehicles {
    [refreshTimer invalidate];
    [linesFetchRefreshTimer invalidate];
    allVehiclesAreBeingFetch = NO;
    
    self.fetchAllFromTREHandler = nil;
    self.fetchLinesFromTREHandler = nil;
}

- (void)updateAllLiveVehiclesFromTRE:(NSTimer *)sender {
    [self fetchLiveVehiclesFromTREForLineCodes:nil withCompletionHandler:self.fetchAllFromTREHandler];
}

- (void)updateLiveVehiclesWithCodeFromTRE:(NSTimer *)sender {
    NSDictionary *userInfo = [sender userInfo] ? [sender userInfo] : @{};
    [self fetchLiveVehiclesFromTREForLineCodes:userInfo[kTRELineCodesKey] withCompletionHandler:self.fetchLinesFromTREHandler];
}

@end
