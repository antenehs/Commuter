//
//  StopAnnotation.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 4/3/14.
//  Copyright (c) 2014 Anteneh Sahledengel. All rights reserved.
//

#import "ServicePointAnnotation.h"

@implementation ServicePointAnnotation

@synthesize title, subtitle , coordinate, code, imageNameForView, annotIdentifier, isSelected, annotationType;

- (id)initWithTitle:(NSString *)ttl andSubtitle:(NSString *)subttl andCoordinate:(CLLocationCoordinate2D)c2d  andAnnotationType:(AnnotationType)annotType {
	if ((self = [super init])){
        title = ttl;
        coordinate = c2d;
        subtitle = subttl;
        annotationType = annotType;
    }	
    
	return self;
}

@end
