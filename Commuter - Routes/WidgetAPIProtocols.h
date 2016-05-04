//
//  APIProtocols.h
//  Reitti
//
//  Created by Anteneh Sahledengel on 10/12/15.
//  Copyright © 2015 Anteneh Sahledengel. All rights reserved.
//

#import <MapKit/MapKit.h>

typedef void (^ActionBlock)();

@protocol WidgetRouteSearchProtocol <NSObject>
- (void)searchRouteForFromCoords:(CLLocationCoordinate2D)fromCoords andToCoords:(CLLocationCoordinate2D)toCoords withOptions:(NSDictionary *)options andCompletionBlock:(ActionBlock)completionBlock;
@end

@protocol WidgetStopSearchProtocol <NSObject>
- (void)fetchStopForCode:(NSString *)code completionBlock:(ActionBlock)completionBlock;
@end