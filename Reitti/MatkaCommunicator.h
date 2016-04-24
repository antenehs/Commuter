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

@interface MatkaCommunicator: NSObject <RouteSearchProtocol, StopsInAreaSearchProtocol, StopDetailFetchProtocol, GeocodeProtocol, ReverseGeocodeProtocol, LineDetailFetchProtocol> {
    NSArray *apiUserNames;
    
    APIClient *timeTableClient;
    APIClient *genericClient;
}

+ (LineType)lineTypeForMatkaTrasportType:(NSNumber *)trasportType;
+ (LegTransportType)legTypeForMatkaTrasportType:(NSNumber *)trasportType;

@end
