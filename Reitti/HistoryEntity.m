//
//  HistoryEntity.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 25/3/14.
//  Copyright (c) 2014 Anteneh Sahledengel. All rights reserved.
//

#import "HistoryEntity.h"
#import "CacheManager.h"

@implementation HistoryEntity

@dynamic busStopURL;
@dynamic busStopCity;
@dynamic busStopCode;
@dynamic busStopName;
@dynamic busStopShortCode;
@dynamic busStopCoords;
@dynamic busStopWgsCoords;
@dynamic fetchedFrom;
@synthesize stopGtfsId;
@synthesize stopTypeNumber;
@synthesize isHistory;

-(StopType)stopType{
    if (!self.stopTypeNumber || [self.stopTypeNumber intValue] == 0) {
        //THis shouldn't be a case for new version
        @try {
            StaticStop *staticStop = [[CacheManager sharedManager] getStopForCode:[NSString stringWithFormat:@"%@", self.busStopCode]];
            if (staticStop != nil) {
                return staticStop.reittiStopType;
            }else{
                return StopTypeBus;
            }
        } @catch (NSException *exception) {}
    } else {
        int intVal = [self.stopTypeNumber intValue];
        @try {
            return (StopType)intVal;
        } @catch (NSException *exception) {
            return StopTypeBus;
        }
    }
}

-(void)setStopType:(StopType)stopType{
    self.stopType = stopType;
}

-(ReittiApi)fetchedFromApi {
    if (self.fetchedFrom) {
        int intVal = [self.fetchedFrom intValue];
        @try {
            return (ReittiApi)intVal;
        } @catch (NSException *exception) {
            self.fetchedFrom = @0;
            return ReittiAutomaticApi;
        }
    } else {
        self.fetchedFrom = @0;
        return ReittiAutomaticApi;
    }
}

@end
