//
//  ComplecationDataManager.h
//  Reitti
//
//  Created by Anteneh Sahledengel on 9/7/16.
//  Copyright © 2016 Anteneh Sahledengel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Route.h"

extern NSString* ComplicationCurrentEntry;
extern NSString* ComplicationTextData;
extern NSString* ComplicationShortTextData;

@interface ComplicationDataManager : NSObject

+(instancetype)sharedManager;

-(void)setDepartureTime:(NSDate *)date;
-(void)setRoute:(Route *)route;
-(NSDate *)getDepartureTime;

@end
