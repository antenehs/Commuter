//
//  MatkaCommunicator.h
//  Reitti
//
//  Created by Anteneh Sahledengel on 9/4/16.
//  Copyright © 2016 Anteneh Sahledengel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ApiProtocols.h"
#import "APIClient.h"
#import "EnumManager.h"

@interface MatkaCommunicator: NSObject <RouteSearchProtocol, RouteSearchOptionProtocol, StopsInAreaSearchProtocol, StopDetailFetchProtocol, GeocodeProtocol, ReverseGeocodeProtocol, LineDetailFetchProtocol, TransportTypeFetchProtocol, AnnotationFilterOptionProtocol> {
    NSArray *apiUserNames;
    
    APIClient *timeTableClient;
    APIClient *genericClient;
}

+(instancetype)sharedManager;

@end
