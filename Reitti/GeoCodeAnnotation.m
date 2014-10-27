//
//  GeoCodeAnnotation.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 4/3/14.
//  Copyright (c) 2014 Anteneh Sahledengel. All rights reserved.
//

#import "GeoCodeAnnotation.h"

@implementation GeoCodeAnnotation

@synthesize title, subtitle , coordinate, code, locationType;

- (id)initWithTitle:(NSString *)ttl andSubtitle:(NSString *)subttl coordinate:(CLLocationCoordinate2D)c2d andLocationType:(LocationType)type {
	if ((self = [super init])){
        title = ttl;
        coordinate = c2d;
        subtitle = subttl;
        locationType = type;
    }	
    
	return self;
}

@end
