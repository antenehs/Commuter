//
//  TRELiveTrafficManager.h
//  Reitti
//
//  Created by Anteneh Sahledengel on 26/3/16.
//  Copyright © 2016 Anteneh Sahledengel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ApiProtocols.h"

@interface TRELiveTrafficManager : NSObject <LiveTrafficFetchProtocol> {
    BOOL allVehiclesAreBeingFetch;
    
    NSTimer *refreshTimer;
    NSTimer *linesFetchRefreshTimer;
}

-(id)init;

@end
