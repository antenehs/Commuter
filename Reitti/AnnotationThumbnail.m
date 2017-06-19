//
//  AnnotationThumbnail.m
//  DetailedAnnotation
//
//  Created by Jean-Pierre Simard on 4/22/13.
//  Copyright (c) 2013 JP Simard. All rights reserved.
//

#import "AnnotationThumbnail.h"

@implementation AnnotationThumbnail

-(NSString *)annotIdentifier {
    if (!_reuseIdentifier) { _reuseIdentifier = @"JPSThumbnailAnnotationViewReuseID"; }
    
    return _reuseIdentifier;
}

@end
