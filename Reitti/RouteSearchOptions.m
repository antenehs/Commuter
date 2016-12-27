//
//  RouteSearchOptions.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 29/3/15.
//  Copyright (c) 2015 Anteneh Sahledengel. All rights reserved.
//

#import "RouteSearchOptions.h"
#import "AppManager.h"
#import "CoreDataManager.h"
#import "RettiDataManager.h"

@interface RouteSearchOptions ()
@property(nonatomic, strong)RettiDataManager *reittiDataManager;
@end

@implementation RouteSearchOptions

@synthesize date, selectedTimeType, selectedRouteSearchOptimization, selectedRouteTrasportTypes,selectedTicketZone,selectedChangeMargine, selectedWalkingSpeed, numberOfResults;

+(id)defaultOptions{
    RouteSearchOptions * defaultOptions = [[RouteSearchOptions alloc] init];
    
    if (defaultOptions) {
        defaultOptions.selectedTimeType = RouteTimeNow;
        defaultOptions.selectedRouteSearchOptimization = RouteSearchOptionFastest;
        defaultOptions.date = [NSDate date];
        
        defaultOptions.selectedRouteTrasportTypes = [defaultOptions allTrasportTypeNames];
    }
    
    return defaultOptions;
}

-(id)init{
    self = [super init];
    if (self) {
        self.numberOfResults = 5;
    }
    
    return self;
}

-(RettiDataManager *)reittiDataManager{
    if (!_reittiDataManager) {
        _reittiDataManager = [[RettiDataManager alloc] init];
    }
    
    return _reittiDataManager;
}

-(NSArray *)allTrasportTypeNames{
    return [self.reittiDataManager allTrasportTypeNames];
}

-(NSArray *)getTransportTypeOptions{
    return [self.reittiDataManager getTransportTypeOptions];
}

-(NSArray *)getTicketZoneOptions{
    return [self.reittiDataManager getTicketZoneOptions];
}

-(NSInteger)getDefaultValueIndexForTicketZoneOptions{
    return [self.reittiDataManager getDefaultValueIndexForTicketZoneOptions];
}

-(NSArray *)getChangeMargineOptions{
    return [self.reittiDataManager getChangeMargineOptions];
}

-(NSInteger)getDefaultValueIndexForChangeMargineOptions{
    return [self.reittiDataManager getDefaultValueIndexForChangeMargineOptions];
}

-(NSArray *)getWalkingSpeedOptions{
    return [self.reittiDataManager getWalkingSpeedOptions];
}

-(NSInteger)getDefaultValueIndexForWalkingSpeedOptions{
    return [self.reittiDataManager getDefaultValueIndexForWalkingSpeedOptions];
}

+(NSInteger)getIndexForOptionName:(NSString *)option fromOptionsList:(NSArray *)options{
    for (int i = 0; i < options.count; i++) {
        if (options[i][displayTextOptionKey] != nil && [options[i][displayTextOptionKey] isEqualToString:option]) {
            return i;
        }
    }
    
    return 0;
}

-(NSInteger)getSelectedTicketZoneIndex{
    if (self.selectedTicketZone == nil) 
        return [self getDefaultValueIndexForTicketZoneOptions];
    
    return [RouteSearchOptions getIndexForOptionName:self.selectedTicketZone fromOptionsList:[self getTicketZoneOptions]];
}

-(NSInteger)getSelectedChangeMargineIndex{
    if (self.selectedChangeMargine == nil)
        return [self getDefaultValueIndexForChangeMargineOptions];
    
    return [RouteSearchOptions getIndexForOptionName:self.selectedChangeMargine fromOptionsList:[self getChangeMargineOptions]];
}

-(NSInteger)getSelectedWalkingSpeedIndex{
    if (self.selectedWalkingSpeed == nil)
        return [self getDefaultValueIndexForWalkingSpeedOptions];
    
    return [RouteSearchOptions getIndexForOptionName:self.selectedWalkingSpeed fromOptionsList:[self getWalkingSpeedOptions]];
}


-(BOOL)isAllTrasportTypesSelected{
    return self.selectedRouteTrasportTypes == nil || self.selectedRouteTrasportTypes.count == [[self getTransportTypeOptions] count];
}

-(BOOL)isAllTrasportTypesExcluded{
    return self.selectedRouteTrasportTypes != nil && self.selectedRouteTrasportTypes.count == 0;
}

-(NSArray *)listOfExcludedtransportTypes{
    if ([self isAllTrasportTypesSelected])
        return nil;

    NSArray *transportTypes = [self getTransportTypeOptions];
    NSMutableArray *excluded = [@[] mutableCopy];
    
    for (NSDictionary *dict in transportTypes) {
        if (![self.selectedRouteTrasportTypes containsObject:[dict objectForKey:displayTextOptionKey]]) {
            [excluded addObject:[dict objectForKey:displayTextOptionKey]];
        }
    }
    
    return excluded;
}


-(id)copy{
    RouteSearchOptions *copy = [RouteSearchOptions new];
    
    copy.date = self.date;
    copy.selectedTimeType = self.selectedTimeType;
    copy.selectedRouteTrasportTypes = self.selectedRouteTrasportTypes;
    copy.selectedRouteSearchOptimization = self.selectedRouteSearchOptimization;
    copy.selectedTicketZone = self.selectedTicketZone;
    copy.selectedChangeMargine = self.selectedChangeMargine;
    copy.selectedWalkingSpeed = self.selectedWalkingSpeed;
    copy.numberOfResults = self.numberOfResults;
    
    return copy;
}

#pragma mark - NSCoding Methods

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    
    self.date = [aDecoder decodeObjectForKey:kRouteSearchDateKey];
    self.selectedTimeType = (RouteTimeType)[[aDecoder decodeObjectForKey:kSelectedRouteTimeTypeKey] intValue];
    self.selectedRouteSearchOptimization = (RouteSearchOptimization)[[aDecoder decodeObjectForKey:kSelectedRouteSearchOptimizationKey] intValue];
    self.selectedRouteTrasportTypes = [aDecoder decodeObjectForKey:kSelectedRouteTrasportTypesKey];
    self.selectedTicketZone = [aDecoder decodeObjectForKey:kSelectedTicketZoneKey];
    self.selectedChangeMargine = [aDecoder decodeObjectForKey:kSelectedChangeMargineKey];
    self.selectedWalkingSpeed = [aDecoder decodeObjectForKey:kSelectedWalkingSpeedKey];
    self.numberOfResults = [[aDecoder decodeObjectForKey:kNumberOfRouteResultsKey] integerValue];
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:date forKey:kRouteSearchDateKey];
    [aCoder encodeObject:[NSNumber numberWithInt:selectedTimeType] forKey:kSelectedRouteTimeTypeKey];
    [aCoder encodeObject:[NSNumber numberWithInt:selectedRouteSearchOptimization] forKey:
     kSelectedRouteSearchOptimizationKey];
    [aCoder encodeObject:selectedRouteTrasportTypes forKey:kSelectedRouteTrasportTypesKey];
    [aCoder encodeObject:selectedTicketZone forKey:kSelectedTicketZoneKey];
    [aCoder encodeObject:selectedChangeMargine forKey:kSelectedChangeMargineKey];
    [aCoder encodeObject:selectedWalkingSpeed forKey:kSelectedWalkingSpeedKey];
    [aCoder encodeObject:[NSNumber numberWithInteger:numberOfResults] forKey:kNumberOfRouteResultsKey];
}

- (NSDictionary *)dictionaryRepresentation
{
    NSMutableDictionary *dict = [@{} mutableCopy];
    
    [dict setValue:date forKey:kRouteSearchDateKey];
    [dict setValue:[NSNumber numberWithInt:selectedTimeType] forKey:kSelectedRouteTimeTypeKey];
    [dict setValue:[NSNumber numberWithInt:selectedRouteSearchOptimization] forKey:kSelectedRouteSearchOptimizationKey];
    [dict setValue:selectedRouteTrasportTypes forKey:kSelectedRouteTrasportTypesKey];
    [dict setValue:selectedTicketZone forKey:kSelectedTicketZoneKey];
    [dict setValue:selectedChangeMargine forKey:kSelectedChangeMargineKey];
    [dict setValue:selectedWalkingSpeed forKey:kSelectedWalkingSpeedKey];
    [dict setValue:[NSNumber numberWithInteger:numberOfResults] forKey:kNumberOfRouteResultsKey];
    
    return dict;
}


@end
