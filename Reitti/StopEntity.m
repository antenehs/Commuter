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

#ifndef APPLE_WATCH
#import "CacheManager.h"
#import "AppManager.h"
#endif

@interface StopEntity ()

#if APPLE_WATCH
@property (nonatomic, retain) NSString * iconName;
#endif

@end

@implementation StopEntity

#ifndef APPLE_WATCH

@dynamic busStopCode;
@dynamic stopLines;
@dynamic busStopShortCode;
@dynamic busStopName;
@dynamic busStopCity;
@dynamic busStopURL;
@dynamic busStopCoords;
@dynamic busStopWgsCoords;
@dynamic fetchedFrom;
@dynamic stopGtfsId;
@dynamic stopTypeNumber;
@dynamic isHistory;

//@synthesize stopType;

#else

@synthesize busStopCode;
@synthesize stopLines;
@synthesize busStopShortCode;
@synthesize busStopName;
@synthesize busStopCity;
@synthesize busStopURL;
@synthesize busStopCoords;
@synthesize busStopWgsCoords;
@synthesize fetchedFrom;
@synthesize iconName;
@synthesize stopGtfsId;
@synthesize stopTypeNumber;
@synthesize isHistory;

-(void)setIconName:(NSString *)name {
    iconName = name;
}

#endif

#ifndef APPLE_WATCH
-(StopType)stopType {
    
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

-(BOOL)isHistoryStop {
    return self.isHistory ? [self.isHistory boolValue] : YES;
}

-(BOOL)isDigiTransitStop {
    return ![self.stopGtfsId isEqualToString:@"NONE"];
}

-(NSString *)iconName {
    return [AppManager stopIconNameForStopType:self.stopType];
}

-(BusStopShort *)toBusStopShort {
    BusStopShort *castedBSS = [[BusStopShort alloc] init];
    castedBSS.code = self.busStopCode;
    castedBSS.codeShort = self.busStopShortCode;
    castedBSS.coords = self.busStopWgsCoords;
    castedBSS.name = self.busStopName;
    castedBSS.city = self.busStopCity;
    castedBSS.address = nil;
    castedBSS.distance = [NSNumber numberWithInt:0];
    castedBSS.stopType = self.stopType;
    
    return castedBSS;
}

#endif

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
                if (line.code) {
                    [lineCodeArray addObject:line.code];
                }
            }
            
            return lineCodeArray;
        }
    }
    
    return nil;
}

-(NSArray *)fullLineCodes{

    //Prior version from 4.1 stop lines as dictionary. So ignore them
    if (![self.stopLines isKindOfClass:[NSArray class]])
        return nil;
    
    if (self.stopLines && self.stopLines.count > 0) {
        if ([self.stopLines[0] isKindOfClass:[StopLine class]]) {
            NSMutableArray *lineCodeArray = [@[] mutableCopy];
            for (StopLine *line in self.stopLines) {
                [lineCodeArray addObject:line.fullCode];
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

#if APPLE_WATCH
+(instancetype)initWithDictionary:(NSDictionary *)dict {
    if (!dict) return nil;
    
    StopEntity *entity = [StopEntity new];
    entity.busStopCode = dict[@"busStopCode"];
    entity.busStopShortCode = dict[@"busStopShortCode"];
    entity.busStopName = dict[@"busStopName"];
    entity.busStopCity = dict[@"busStopCity"];
    entity.busStopURL = dict[@"busStopURL"];
    entity.busStopCoords = dict[@"busStopCoords"];
    entity.busStopWgsCoords = dict[@"busStopWgsCoords"];
    entity.fetchedFrom = dict[@"fetchedFrom"];
    entity.iconName = dict[@"iconName"];
    entity.stopTypeNumber = dict[@"stopTypeNumber"];
    entity.isHistory = dict[@"isHistory"];
    entity.stopGtfsId = dict[@"stopGtfsId"];
    
    return entity;
}
#endif

-(NSDictionary *)dictionaryRepresentation {
    NSMutableDictionary *dict = [@{} mutableCopy];
    [dict setValue:self.busStopCode forKey:@"busStopCode"];
    //    [dict setValue:self.stopLines forKey:@"stopLines"]; //TODO
    [dict setValue:self.busStopShortCode forKey:@"busStopShortCode"];
    [dict setValue:self.busStopName forKey:@"busStopName"];
    [dict setValue:self.busStopCity forKey:@"busStopCity"];
    [dict setValue:self.busStopURL forKey:@"busStopURL"];
    [dict setValue:self.busStopCoords forKey:@"busStopCoords"];
    [dict setValue:self.busStopWgsCoords forKey:@"busStopWgsCoords"];
    [dict setValue:self.fetchedFrom forKey:@"fetchedFrom"];
    [dict setValue:self.iconName forKey:@"iconName"];
    [dict setValue:self.stopTypeNumber forKey:@"stopTypeNumber"];
    [dict setValue:self.isHistory forKey:@"isHistory"];
    [dict setValue:self.stopGtfsId forKey:@"stopGtfsId"];
    
    return dict;
}

@end
