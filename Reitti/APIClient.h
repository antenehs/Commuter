//
//  Communication.h
//  Reitti
//
//  Created by Anteneh Sahledengel on 31/1/14.
//  Copyright (c) 2014 Anteneh Sahledengel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RestKit/RestKit.h>
#import "BusStop.h"
#import "BusStopShort.h"
#import "Line.h"
#import "GeoCode.h"
#import "Route.h"
#import "RouteLegs.h"
#import "RouteLeg.h"
#import "RouteLegLocation.h"
#import "Disruption.h"

typedef void (^ActionBlock)();

@interface APIClient : NSObject

-(id)init;

-(void)doJsonApiFetchWithParams:(NSDictionary *)params mappingDictionary:(NSDictionary *)mapping mapToClass:(Class)mapToClass mapKeyPath:(NSString *)keyPath andCompletionBlock:(ActionBlock)completionBlock;
-(void)doXmlApiFetchWithParams:(NSDictionary *)params mappingDictionary:(NSDictionary *)mapping mapToClass:(Class)mapToClass mapKeyPath:(NSString *)keyPath andCompletionBlock:(ActionBlock)completionBlock;
-(void)doJsonApiFetchWithParams:(NSDictionary *)params responseDescriptor:(RKResponseDescriptor *)responseDescriptor andCompletionBlock:(ActionBlock)completionBlock;
-(void)doXmlApiFetchWithParams:(NSDictionary *)params responseDescriptor:(RKResponseDescriptor *)responseDescriptor andCompletionBlock:(ActionBlock)completionBlock;
-(void)doApiFetchWithOutMappingWithParams:(NSDictionary *)params andCompletionBlock:(ActionBlock)completionBlock;

- (void)getAllLiveVehiclesFromPubTrans:(NSString *)lineCodes;

- (void)VehiclesFetchFromPubtransComplete:(NSData *)objectNotation;
- (void)VehiclesFetchFromPubtransFailed:(NSError *)error;

@property (nonatomic, strong) NSString *apiBaseUrl;

@end
