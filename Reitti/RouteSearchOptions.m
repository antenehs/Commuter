//
//  RouteSearchOptions.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 29/3/15.
//  Copyright (c) 2015 Anteneh Sahledengel. All rights reserved.
//

#import "RouteSearchOptions.h"
#import "AppManager.h"
#import "SettingsManager.h"
#import "CoreDataManager.h"
#import "RettiDataManager.h"

NSString * displayTextOptionKey = @"displayText";
NSString * detailOptionKey = @"detail";
NSString * valueOptionKey = @"value";
NSString * pictureOptionKey = @"picture";
NSString * defaultOptionKey = @"default";

NSInteger kDefaultNumberOfResults = 5;

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
        _reittiDataManager = [[RettiDataManager alloc] initWithManagedObjectContext:[[CoreDataManager sharedManager] managedObjectContext]];
        
        SettingsManager *settingsManager = [[SettingsManager alloc] initWithDataManager:self.reittiDataManager];
        
        [self.reittiDataManager setUserLocationToRegion:[settingsManager userLocation]];
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
    
    self.date = [aDecoder decodeObjectForKey:@"date"];
    self.selectedTimeType = (RouteTimeType)[[aDecoder decodeObjectForKey:@"selectedTimeType"] intValue];
    self.selectedRouteSearchOptimization = (RouteSearchOptimization)[[aDecoder decodeObjectForKey:@"selectedRouteSearchOptimization"] intValue];
    self.selectedRouteTrasportTypes = [aDecoder decodeObjectForKey:@"selectedRouteTrasportTypes"];
    self.selectedTicketZone = [aDecoder decodeObjectForKey:@"selectedTicketZone"];
    self.selectedChangeMargine = [aDecoder decodeObjectForKey:@"selectedChangeMargine"];
    self.selectedWalkingSpeed = [aDecoder decodeObjectForKey:@"selectedWalkingSpeed"];
    self.numberOfResults = [[aDecoder decodeObjectForKey:@"numberOfResults"] integerValue];
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:date forKey:@"date"];
    [aCoder encodeObject:[NSNumber numberWithInt:selectedTimeType] forKey:@"selectedTimeType"];
    [aCoder encodeObject:[NSNumber numberWithInt:selectedRouteSearchOptimization] forKey:@"selectedRouteSearchOptimization"];
    [aCoder encodeObject:selectedRouteTrasportTypes forKey:@"selectedRouteTrasportTypes"];
    [aCoder encodeObject:selectedTicketZone forKey:@"selectedTicketZone"];
    [aCoder encodeObject:selectedChangeMargine forKey:@"selectedChangeMargine"];
    [aCoder encodeObject:selectedWalkingSpeed forKey:@"selectedWalkingSpeed"];
    [aCoder encodeObject:[NSNumber numberWithInteger:numberOfResults] forKey:@"numberOfResults"];
}

- (NSDictionary *)dictionaryRepresentation
{
    NSMutableDictionary *dict = [@{} mutableCopy];
    
    [dict setValue:date forKey:@"date"];
    [dict setValue:[NSNumber numberWithInt:selectedTimeType] forKey:@"selectedTimeType"];
    [dict setValue:[NSNumber numberWithInt:selectedRouteSearchOptimization] forKey:@"selectedRouteSearchOptimization"];
    [dict setValue:selectedRouteTrasportTypes forKey:@"selectedRouteTrasportTypes"];
    [dict setValue:selectedTicketZone forKey:@"selectedTicketZone"];
    [dict setValue:selectedChangeMargine forKey:@"selectedChangeMargine"];
    [dict setValue:selectedWalkingSpeed forKey:@"selectedWalkingSpeed"];
    [dict setValue:[NSNumber numberWithInteger:numberOfResults] forKey:@"numberOfResults"];
    
    return dict;
}


@end
