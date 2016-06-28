//
//  WatchDataManager.h
//  Reitti
//
//  Created by Anteneh Sahledengel on 28/6/16.
//  Copyright © 2016 Anteneh Sahledengel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NamedBookmarkE.h"
#import <MapKit/MapKit.h>
#import "WatchHslApi.h"

@interface WatchDataManager : NSObject

-(void)getRouteForNamedBookmark:(NamedBookmarkE *)namedBookmark fromLocation:(CLLocation *)location routeOptions:(NSDictionary *)options andCompletionBlock:(ActionBlock)completionBlock;

@end
