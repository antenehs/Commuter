//
//  ReittiMapkitHelper.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 17/4/16.
//  Copyright © 2016 Anteneh Sahledengel. All rights reserved.
//

#import "ReittiMapkitHelper.h"

@implementation ReittiMapkitHelper

+(BOOL)isValidCoordinate:(CLLocationCoordinate2D)coords {
    return CLLocationCoordinate2DIsValid(coords) && coords.latitude != 0 && coords.longitude != 0;
}

@end
