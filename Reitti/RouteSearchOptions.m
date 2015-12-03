//
//  RouteSearchOptions.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 29/3/15.
//  Copyright (c) 2015 Anteneh Sahledengel. All rights reserved.
//

#import "RouteSearchOptions.h"
#import "AppManager.h"

NSString * displayTextOptionKey = @"displayText";
NSString * detailOptionKey = @"detail";
NSString * valueOptionKey = @"value";
NSString * pictureOptionKey = @"picture";
NSString * defaultOptionKey = @"default";

NSInteger kDefaultNumberOfResults = 5;

@implementation RouteSearchOptions

@synthesize date, selectedTimeType, selectedRouteSearchOptimization, selectedRouteTrasportTypes,selectedTicketZone,selectedChangeMargine, selectedWalkingSpeed, numberOfResults;

+(id)defaultOptions{
    RouteSearchOptions * defaultOptions = [[RouteSearchOptions alloc] init];
    
    if (defaultOptions) {
        defaultOptions.selectedTimeType = RouteTimeNow;
        defaultOptions.selectedRouteSearchOptimization = RouteSearchOptionFastest;
        defaultOptions.date = [NSDate date];
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

+(NSArray *)getTransportTypeOptions{
    return @[@{displayTextOptionKey : @"Bus", valueOptionKey : @"bus", pictureOptionKey : [AppManager lightColorImageForLegTransportType:LegTypeBus]},
             @{displayTextOptionKey : @"Metro", valueOptionKey : @"metro", pictureOptionKey : [UIImage imageNamed:@"Subway-100.png"]},
             @{displayTextOptionKey : @"Train", valueOptionKey : @"train", pictureOptionKey : [AppManager lightColorImageForLegTransportType:LegTypeTrain]},
             @{displayTextOptionKey : @"Tram", valueOptionKey : @"tram", pictureOptionKey : [AppManager lightColorImageForLegTransportType:LegTypeTram]},
             @{displayTextOptionKey : @"Ferry", valueOptionKey : @"ferry", pictureOptionKey : [AppManager lightColorImageForLegTransportType:LegTypeFerry]},
             @{displayTextOptionKey : @"Uline", valueOptionKey : @"uline", pictureOptionKey : [AppManager lightColorImageForLegTransportType:LegTypeBus]}];
}

+(NSArray *)getTicketZoneOptions{
    return @[@{displayTextOptionKey : @"All HSL Regions (Default)", valueOptionKey : @"whole", defaultOptionKey : @"yes"},
             @{displayTextOptionKey : @"Regional" , valueOptionKey: @"region"},
             @{displayTextOptionKey : @"Helsinki Internal", valueOptionKey : @"helsinki"},
             @{displayTextOptionKey : @"Espoo Internal", valueOptionKey : @"espoo"},
             @{displayTextOptionKey : @"Vantaa Internal", valueOptionKey : @"vantaa"}];
}

+(NSInteger)getDefaultValueIndexForTicketZoneOptions{
    return 0;
}

+(NSArray *)getChangeMargineOptions{
    return @[@{displayTextOptionKey : @"0 minute" , valueOptionKey: @"0"},
             @{displayTextOptionKey : @"1 minute" , valueOptionKey: @"1"},
             @{displayTextOptionKey : @"3 minutes (Default)", valueOptionKey : @"3", defaultOptionKey : @"yes"},
             @{displayTextOptionKey : @"5 minutes", valueOptionKey : @"5"},
             @{displayTextOptionKey : @"7 minutes", valueOptionKey : @"7"},
             @{displayTextOptionKey : @"9 minutes", valueOptionKey : @"9"},
             @{displayTextOptionKey : @"10 minutes", valueOptionKey : @"10"}];
}

+(NSInteger)getDefaultValueIndexForChangeMargineOptions{
    return 2;
}

+(NSArray *)getWalkingSpeedOptions{
    return @[@{displayTextOptionKey : @"Slow Walking", detailOptionKey : @"20 m/minute", valueOptionKey : @"20"},
             @{displayTextOptionKey : @"Normal Walking (Default)" , detailOptionKey : @"70 m/minute", valueOptionKey: @"70", defaultOptionKey : @"yes"},
             @{displayTextOptionKey : @"Fast Walking", detailOptionKey : @"150 m/minute", valueOptionKey : @"150"},
             @{displayTextOptionKey : @"Running", detailOptionKey : @"250 m/minute", valueOptionKey : @"250"},
             @{displayTextOptionKey : @"Fast Running", detailOptionKey : @"350 m/minute", valueOptionKey : @"350"},
             @{displayTextOptionKey : @"Bolting", detailOptionKey : @"500 m/minute", valueOptionKey : @"500"}];
}

+(NSInteger)getDefaultValueIndexForWalkingSpeedOptions{
    return 1;
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
        return [RouteSearchOptions getDefaultValueIndexForTicketZoneOptions];
    
    return [RouteSearchOptions getIndexForOptionName:self.selectedTicketZone fromOptionsList:[RouteSearchOptions getTicketZoneOptions]];
}

-(NSInteger)getSelectedChangeMargineIndex{
    if (self.selectedChangeMargine == nil)
        return [RouteSearchOptions getDefaultValueIndexForChangeMargineOptions];
    
    return [RouteSearchOptions getIndexForOptionName:self.selectedChangeMargine fromOptionsList:[RouteSearchOptions getChangeMargineOptions]];
}

-(NSInteger)getSelectedWalkingSpeedIndex{
    if (self.selectedWalkingSpeed == nil)
        return [RouteSearchOptions getDefaultValueIndexForWalkingSpeedOptions];
    
    return [RouteSearchOptions getIndexForOptionName:self.selectedWalkingSpeed fromOptionsList:[RouteSearchOptions getWalkingSpeedOptions]];
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

@end
