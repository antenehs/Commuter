//
//  MatkaRouteWalk.h
//  Reitti
//
//  Created by Anteneh Sahledengel on 11/4/16.
//  Copyright © 2016 Anteneh Sahledengel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MatkaRouteLength.h"
#import "MatkaRouteLocation.h"

@interface MatkaRouteLeg : NSObject

@property(nonatomic, strong)NSNumber *time;
@property(nonatomic, strong)NSNumber *distance;
@property(nonatomic, strong)MatkaRouteLocation *startLocation;
@property(nonatomic, strong)MatkaRouteLocation *destLocation;

//Start and dest stops

@property(nonatomic, strong)NSArray *locations;

@end
