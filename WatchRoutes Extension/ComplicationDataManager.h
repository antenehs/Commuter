//
//  ComplecationDataManager.h
//  Reitti
//
//  Created by Anteneh Sahledengel on 9/7/16.
//  Copyright © 2016 Anteneh Sahledengel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Route.h"

//extern NSString* ComplicationTransportationsDate;
//extern NSString* ComplicationTransportationImageName;
//extern NSString* ComplicationTransportationName;
//extern NSString* ComplicationTransportationColor;
//extern NSString* ComplicationTransportations;
extern NSString* ComplicationRoute;

@interface ComplicationDataManager : NSObject

+(instancetype)sharedManager;

-(void)setRoute:(Route *)route;
-(Route *)getComplicationRoute;

@end
