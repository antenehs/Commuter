//
//  HSLRouteOptionManager.h
//  Reitti
//
//  Created by Anteneh Sahledengel on 28/2/16.
//  Copyright © 2016 Anteneh Sahledengel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RouteOptionManagerBase.h"

@interface HSLRouteOptionManager : RouteOptionManagerBase

+(id)sharedManager;

-(NSDictionary *)apiRequestParametersDictionaryForRouteOptions:(NSDictionary *)searchOptions;

+(NSDictionary *)transportTypeOptions;
+(NSArray *)allTrasportTypeNames;
+(NSArray *)getTransportTypeOptionsForDisplay;
+(NSArray *)getDefaultTransportTypeNames;

+(NSDictionary *)ticketZoneOptions;
+(NSArray *)getTicketZoneOptionsForDisplay;
+(NSInteger)getDefaultValueIndexForTicketZoneOptions;

+(NSDictionary *)changeMargineOptions;
+(NSArray *)getChangeMargineOptionsForDisplay;
+(NSInteger)getDefaultValueIndexForChangeMargineOptions;

+(NSDictionary *)walkingSpeedOptions;
+(NSArray *)getWalkingSpeedOptionsForDisplay;
+(NSInteger)getDefaultValueIndexForWalkingSpeedOptions;


@end
