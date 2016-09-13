//
//  RouteHeaderRowController.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 13/9/16.
//  Copyright © 2016 Anteneh Sahledengel. All rights reserved.
//

#import "RouteHeaderRowController.h"

@implementation RouteHeaderRowController

-(void)setupWithRoute:(Route *)route {
    [self.toLabel setText:route.toLocationName ];
}

@end
