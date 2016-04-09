//
//  MatkaCommunicator.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 9/4/16.
//  Copyright © 2016 Anteneh Sahledengel. All rights reserved.
//

#import "MatkaCommunicator.h"
#import "MatkaNearbyStop.h"

@implementation MatkaCommunicator

-(id)init{
    self = [super init];
    super.apiBaseUrl = @"http://api.matka.fi/timetables/?m=stop&user=asacommuter&pass=rebekah&x=3386050&y=6675010&radius=1000";
    
    apiUserNames = @[@"asacommuter"];
    
    return self;
}

- (void)fetchStopsInAreaForRegionCenterCoords:(CLLocationCoordinate2D)regionCenter andDiameter:(NSInteger)diameter withCompletionBlock:(ActionBlock)completionBlock {
    NSMutableDictionary *options = [@{} mutableCopy];
    
    RKObjectMapping* nameMapping = [RKObjectMapping mappingForClass:[MatkaStopName class] ];
    [nameMapping addAttributeMappingsFromDictionary: @{ @"text" : @"name",
                                                        @"lang" : @"language"
                                                        }];
    
    RKObjectMapping* stopMapping = [RKObjectMapping mappingForClass:[MatkaNearbyStop class] ];
    [stopMapping addAttributeMappingsFromDictionary:@{
                                                            @"xCoord" : @"xCoord",
                                                            @"yCoord" : @"yCoord",
                                                            @"id"     : @"stopId",
                                                            @"distance" : @"distance",
                                                            @"code" : @"stopShortCode",
                                                            @"tranportType" : @"transportType",
                                                            @"companyCode" : @"companyCode",
                                                            }];
    
    [stopMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"name"
                                                                                      toKeyPath:@"stopNames"
                                                                                    withMapping:nameMapping]];
    
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:stopMapping
                                                                                            method:RKRequestMethodAny
                                                                                       pathPattern:nil
                                                                                           keyPath:@"MATKAXML.XY2STOPS.STOP"
                                                                                       statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    [super doXmlApiFetchWithParams:options responseDescriptor:responseDescriptor andCompletionBlock:^(NSArray *matkaStops, NSError *error) {
        
        if (!error) {
            NSLog(@"no error");
        }
        
    }];
}

#pragma mark - Helper methods
- (NSString *)getApiUsername{
    return apiUserNames[0];
}

@end
