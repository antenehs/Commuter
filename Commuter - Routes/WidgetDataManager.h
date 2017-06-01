//
//  WidgetDataManager.h
//  Reitti
//
//  Created by Anteneh Sahledengel on 10/12/15.
//  Copyright © 2015 Anteneh Sahledengel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NamedBookmark.h"
#import <MapKit/MapKit.h>
#import "ApiProtocols.h"

@interface WidgetDataManager : NSObject

typedef struct {
    CLLocationCoordinate2D topLeftCorner;
    CLLocationCoordinate2D bottomRightCorner;
} RTCoordinateRegion;

-(void)getRouteForNamedBookmark:(NamedBookmark *)namedBookmark fromLocation:(CLLocation *)location routeOptions:(RouteSearchOptions *)options andCompletionBlock:(ActionBlock)completionBlock;

-(void)fetchStopForCode:(NSString *)code fetchFromApi:(ReittiApi)api withCompletionBlock:(ActionBlock)completionBlock;

@end
