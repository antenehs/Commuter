//
//  StopEntity.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 25/3/14.
//  Copyright (c) 2014 Anteneh Sahledengel. All rights reserved.
//

#import "StopEntity.h"
#import "CacheManager.h"

@implementation StopEntity

@dynamic busStopCode;
@dynamic stopLines;
@dynamic busStopShortCode;
@dynamic busStopName;
@dynamic busStopCity;
@dynamic busStopURL;
@dynamic busStopCoords;
@dynamic busStopWgsCoords;

-(StopType)stopType{
    @try {
        StaticStop *staticStop = [[CacheManager sharedManager] getStopForCode:[NSString stringWithFormat:@"%@", self.busStopCode]];
        if (staticStop != nil) {
            return staticStop.reittiStopType;
        }else{
            return StopTypeBus;
        }
    }
    @catch (NSException *exception) {
        
    }
}

-(void)setStopType:(StopType)stopType{
    self.stopType = stopType;
}

@end
