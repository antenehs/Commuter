//
//  JPSThumbnailAnnotation.m
//  JPSThumbnailAnnotationView
//
//  Created by Jean-Pierre Simard on 4/21/13.
//  Copyright (c) 2013 JP Simard. All rights reserved.
//

#import "JPSThumbnailAnnotation.h"

@interface JPSThumbnailAnnotation ()

@property (nonatomic, readwrite) JPSThumbnailAnnotationView *view;
//@property (nonatomic, readonly) JPSThumbnail *thumbnail;

@end

@implementation JPSThumbnailAnnotation

+ (instancetype)annotationWithThumbnail:(JPSThumbnail *)thumbnail {
    return [[self alloc] initWithThumbnail:thumbnail];
}

- (id)initWithThumbnail:(JPSThumbnail *)thumbnail {
    self = [super init];
    if (self) {
        _coordinate = thumbnail.coordinate;
        _code = thumbnail.code;
        _thumbnail = thumbnail;
        _annotationType = thumbnail.annotationType;
        _stopType = thumbnail.stopType;
    }
    return self;
}

- (MKAnnotationView *)annotationViewInMap:(MKMapView *)mapView {
    if (!self.view) {
        self.view = (JPSThumbnailAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:kJPSThumbnailAnnotationViewReuseID];
        if (!self.view) self.view = [[JPSThumbnailAnnotationView alloc] initWithAnnotation:self reuseIdentifier:self.thumbnail.reuseIdentifier];
    } else {
        self.view.annotation = self;
    }
    [self updateThumbnail:self.thumbnail animated:NO];
    
//    if (self.thumbnail.selected) {
//        [self.view didSelectAnnotationViewInMap:mapView];
//        [self.view setSelected:YES];
//        [mapView selectAnnotation:self animated:YES];
//    }
    
    return self.view;
}

- (void)updateThumbnail:(JPSThumbnail *)thumbnail animated:(BOOL)animated {
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
