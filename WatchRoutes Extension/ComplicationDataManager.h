//
//  ComplecationDataManager.h
//  Reitti
//
//  Created by Anteneh Sahledengel on 9/7/16.
//  Copyright © 2016 Anteneh Sahledengel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Route.h"

extern NSString* ComplicationDepartureDate;
extern NSString* ComplicationImageName;
extern NSString* ComplicationTransportaionName;

@interface ComplicationDataManager : NSObject

+(instancetype)sharedManager;

-(void)setRoute:(Route *)route;

-(NSDictionary *)getComplicationData;

@property(nonatomic, strong)Route *routeForComplication;

@end
