//
//  HSLandTRECommonApiClient.h
//  Reitti
//
//  Created by Anteneh Sahledengel on 10/12/15.
//  Copyright © 2015 Anteneh Sahledengel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "APIClient.h"
#import "WidgetHelpers.h"

@interface HSLandTRECommonApiClient : NSObject

-(void)searchRouteForFromCoords:(CLLocationCoordinate2D)fromCoords andToCoords:(CLLocationCoordinate2D)toCoords withOptions:(NSDictionary *)optionsDict andCompletionBlock:(ActionBlock)completionBlock;

@property (strong, nonatomic)APIClient *apiClient;

@end
