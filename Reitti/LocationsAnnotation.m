//
//  LocationsAnnotation.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 14/9/14.
//  Copyright (c) 2014 Anteneh Sahledengel. All rights reserved.
//

#import "LocationsAnnotation.h"

@implementation LocationsAnnotation

@synthesize title, subtitle , coordinate, code, locationType, imageNameForView, annotIdentifier;

- (id)initWithTitle:(NSString *)ttl andSubtitle:(NSString *)subttl andCoordinate:(CLLocationCoordinate2D)c2d andLocationType:(AnnotationLocationType)type {
    if ((self = [super init])){
        title = ttl;
        coordinate = c2d;
        subtitle = subttl;
        locationType = type;
    }
    
    return self;
}

@end
