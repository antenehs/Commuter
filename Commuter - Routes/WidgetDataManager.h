//
//  WidgetDataManager.h
//  Reitti
//
//  Created by Anteneh Sahledengel on 10/12/15.
//  Copyright © 2015 Anteneh Sahledengel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NamedBookmarkE.h"
#import <MapKit/MapKit.h>
#import "HSLAPIClient.h"
#import "TREAPIClient.h"
#import "MatkaApiClient.h"

@interface WidgetDataManager : NSObject

//typedef enum
//{
//    HSLRegion = 0,
//    TRERegion = 1,
//    FINRegion = 4,
//    HSLandTRERegion = 2,
//    OtherRegion = 3
//} Region;

typedef struct {
    CLLocationCoordinate2D topLeftCorner;
    CLLocationCoordinate2D bottomRightCorner;
} RTCoordinateRegion;

-(void)getRouteForNamedBookmark:(NamedBookmarkE *)namedBookmark fromLocation:(CLLocation *)location routeOptions:(NSDictionary *)options andCompletionBlock:(ActionBlock)completionBlock;

-(void)fetchStopForCode:(NSString *)code fetchFromApi:(ReittiApi)api withCompletionBlock:(ActionBlock)completionBlock;

@end
