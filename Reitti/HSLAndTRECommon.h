//
//  HSLAndTRECommon.h
//  Reitti
//
//  Created by Anteneh Sahledengel on 7/12/15.
//  Copyright © 2015 Anteneh Sahledengel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "APIClient.h"

typedef void (^ActionBlock)();

@interface HSLAndTRECommon : APIClient

-(void)searchRouteForFromCoords:(CLLocationCoordinate2D)fromCoords andToCoords:(CLLocationCoordinate2D)toCoords withOptionsDictionary:(NSDictionary *)optionsDict andCompletionBlock:(ActionBlock)completionBlock;

@end
