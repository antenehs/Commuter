//
//  RouteLocation.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 13/9/14.
//  Copyright (c) 2014 Anteneh Sahledengel. All rights reserved.
//

#import "RouteLocation.h"
#import "ReittiMapkitHelper.h"

@implementation RouteLocation

@synthesize isHeaderLocation;
@synthesize locationLegType;

//@synthesize coordsDictionary;
@synthesize arrTime;
@synthesize depTime;
@synthesize name;
@synthesize stopCode;
@synthesize shortCode;
@synthesize stopAddress;

-(CLLocationCoordinate2D)coords {
    if ([ReittiMapkitHelper isValidCoordinate:_coords]) {
        _coords = CLLocationCoordinate2DMake([[self.coordsDictionary objectForKey:@"y"] floatValue],[[self.coordsDictionary objectForKey:@"x"] floatValue]);
    }
    return _coords;
}

@end
