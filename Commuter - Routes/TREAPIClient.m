//
//  TREAPIClient.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 10/12/15.
//  Copyright © 2015 Anteneh Sahledengel. All rights reserved.
//

#import "TREAPIClient.h"

@implementation TREAPIClient

- (id)init{
    self = [super init];
    if (self) {
        self.apiClient = [[APIClient alloc] init];
        self.apiClient.apiBaseUrl = @"http://api.publictransport.tampere.fi/1_0_3/";
    }
    
    return self;
}

- (void)searchRouteForFromCoords:(CLLocationCoordinate2D)fromCoords andToCoords:(CLLocationCoordinate2D)toCoords withOptions:(NSDictionary *)optionsDict andCompletionBlock:(ActionBlock)completionBlock {
    
    if (!optionsDict) {
        optionsDict = [@{} mutableCopy];
    }
    
    //TODO: Select from list
    [optionsDict setValue:@"asacommuterwidget2" forKey:@"user"];
    [optionsDict setValue:@"rebekah" forKey:@"pass"];
    
    [super searchRouteForFromCoords:fromCoords andToCoords:toCoords withOptions:optionsDict andCompletionBlock:completionBlock];
}

@end
