//
//  RouteViewManager.h
//  Reitti
//
//  Created by Anteneh Sahledengel on 10/5/15.
//  Copyright (c) 2015 Anteneh Sahledengel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Route.h"
#import "Transport.h"

@interface RouteViewManager : NSObject

+ (UIView *)viewForRoute:(Route *)route longestDuration:(CGFloat)longestDuration width:(CGFloat)totalWidth alwaysShowVehicle:(BOOL)alwaysShow;

@end
