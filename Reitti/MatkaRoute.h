//
//  MatkaRoute.h
//  Reitti
//
//  Created by Anteneh Sahledengel on 11/4/16.
//  Copyright © 2016 Anteneh Sahledengel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MatkaRouteLength.h"

@interface MatkaRoute : NSObject

@property(nonatomic, strong)NSNumber *time;
@property(nonatomic, strong)NSNumber *distance;
@property(nonatomic, strong)NSArray *points;
@property(nonatomic, strong)NSArray *routeLegs;

@end
