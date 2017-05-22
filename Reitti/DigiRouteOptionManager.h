//
//  DigiRouteOptionManager.h
//  Reitti
//
//  Created by Anteneh Sahledengel on 5/21/17.
//  Copyright © 2017 Anteneh Sahledengel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RouteOptionManagerBase.h"

@interface DigiRouteOptionManager : RouteOptionManagerBase

+(id)sharedManager;

+(NSDictionary *)apiRequestParametersDictionaryForRouteOptions:(NSDictionary *)searchOptions;

+(NSDictionary *)transportTypeOptions;
+(NSArray *)allTrasportTypeNames;
+(NSArray *)getTransportTypeOptionsForDisplay;

+(NSDictionary *)changeMargineOptions;
+(NSArray *)getChangeMargineOptionsForDisplay;
+(NSInteger)getDefaultValueIndexForChangeMargineOptions;

+(NSDictionary *)walkingSpeedOptions;
+(NSArray *)getWalkingSpeedOptionsForDisplay;
+(NSInteger)getDefaultValueIndexForWalkingSpeedOptions;

@end
