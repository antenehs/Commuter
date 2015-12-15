//
//  HSLAPIClient.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 10/12/15.
//  Copyright © 2015 Anteneh Sahledengel. All rights reserved.
//

#import "HSLAPIClient.h"
#import "WidgetHelpers.h"


@implementation HSLAPIClient

- (id)init{
    self = [super init];
    if (self) {
        self.apiClient = [[APIClient alloc] init];
        self.apiClient.apiBaseUrl = @"http://api.reittiopas.fi/hsl/1_2_0/";
    }
    
    return self;
}

- (void)searchRouteForFromCoords:(CLLocationCoordinate2D)fromCoords andToCoords:(CLLocationCoordinate2D)toCoords withOptions:(NSDictionary *)optionsDict andCompletionBlock:(ActionBlock)completionBlock {
    
    if (!optionsDict) {
        optionsDict = [@{} mutableCopy];
    }
    
    //TODO: Select from list
    [optionsDict setValue:@"asacommuterstops" forKey:@"user"];
    [optionsDict setValue:@"rebekah" forKey:@"pass"];
    
    [super searchRouteForFromCoords:fromCoords andToCoords:toCoords withOptions:optionsDict andCompletionBlock:completionBlock];
}


@end
