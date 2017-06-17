//
//  GCThumbnailAnnotation.m
//  GCThumbnailAnnotationView
//
//  Created by Jean-Pierre Simard on 4/21/13.
//  Copyright (c) 2013 JP Simard. All rights reserved.
//

#import "GCThumbnailAnnotation.h"

@interface GCThumbnailAnnotation ()

@property (nonatomic, readwrite) GCThumbnailAnnotationView *view;
//@property (nonatomic, readonly) GCThumbnail *thumbnail;

@end

@implementation GCThumbnailAnnotation

+ (instancetype)annotationWithThumbnail:(GCThumbnail *)thumbnail {
    return [[self alloc] initWithThumbnail:thumbnail];
}

- (id)initWithThumbnail:(GCThumbnail *)thumbnail {
    self = [super init];
    if (self) {
        _coordinate = thumbnail.coordinate;
        _code = thumbnail.code;
        _thumbnail = thumbnail;
//        _annotationType = thumbnail.annotationType;
        _stopType = thumbnail.stopType;
    }
    return self;
}

- (MKAnnotationView *)annotationViewInMap:(MKMapView *)mapView {
    if (!self.view) {
        self.view = (GCThumbnailAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:kGCThumbnailAnnotationViewReuseID];
        if (!self.view) self.view = [[GCThumbnailAnnotationView alloc] initWithAnnotation:self reuseIdentifier:self.thumbnail.reuseIdentifier];
    } else {
        self.view.annotation = self;
    }
    [self updateThumbnail:self.thumbnail animated:NO];
    
    return self.view;
}

- (void)updateThumbnail:(GCThumbnail *)thumbnail animated:(BOOL)animated {
    if (animated) {
        [UIView animateWithDuration:0.33f animations:^{
            _coordinate = thumbnail.coordinate; // use ivar to avoid triggering setter
        }];
    } else {
        _coordinate = thumbnail.coordinate; // use ivar to avoid triggering setter
    }
    
    [self.view updateWithThumbnail:thumbnail];
}


@end
