//
//  HSLRouteOptionManager.h
//  Reitti
//
//  Created by Anteneh Sahledengel on 28/2/16.
//  Copyright © 2016 Anteneh Sahledengel. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HSLRouteOptionManager : NSObject

+(id)sharedManager;

+(NSDictionary *)transportTypeOptions;
+(NSDictionary *)ticketZoneOptions;
+(NSDictionary *)changeMargineOptions;
+(NSDictionary *)walkingSpeedOptions;


@end
