//
//  StopEntity.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 25/3/14.
//  Copyright (c) 2014 Anteneh Sahledengel. All rights reserved.
//

#import "StopEntity.h"
#import "StopLine.h"
#import "ReittiStringFormatter.h"
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

-(NSArray *)lineCodes{
    //Prior version from 4.1 stop lines as dictionary. So ignore them
    if (![self.stopLines isKindOfClass:[NSArray class]])
        return nil;
    
    if (self.stopLines && self.stopLines.count > 0) {
        if ([self.stopLines[0] isKindOfClass:[StopLine class]]) {
            NSMutableArray *lineCodeArray = [@[] mutableCopy];
            for (StopLine *line in self.stopLines) {
                [lineCodeArray addObject:line.code];
            }
            
            return lineCodeArray;
        }
    }
    
    return nil;
}

-(NSString *)linesString{
    if (!self.lineCodes) {
        return @"";
    }
    return [ReittiStringFormatter commaSepStringFromArray:self.lineCodes withSeparator:@", "];
}

@end
