//
//  JPSThumbnailAnnotation.m
//  JPSThumbnailAnnotationView
//
//  Created by Jean-Pierre Simard on 4/21/13.
//  Copyright (c) 2013 JP Simard. All rights reserved.
//

#import "JPSThumbnailAnnotation.h"
#import "ASA_Helpers.h"
#import "SwiftHeaders.h"
#import "AppManager.h"

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
    }
    return self;
}

-(NSString *)uniqueIdentifier {
    if (!_uniqueIdentifier) {
        _uniqueIdentifier = self.code;
    }
    
    return _uniqueIdentifier;
}

-(NSInteger)shrinkingZoomLevel {
    if (_shrinkingZoomLevel == 0) {
        _shrinkingZoomLevel = 13;
    }
    
    return _shrinkingZoomLevel;
}

-(NSInteger)disappearingZoomLevel {
    if (_disappearingZoomLevel == 0) {
        _disappearingZoomLevel = 13;
    }
    
    return _disappearingZoomLevel;
}

- (MKAnnotationView *)annotationViewInMap:(MKMapView *)mapView {
    if ([self shrinksWhenZoomedOut] && [self zoomLevelForMapView:mapView] < self.shrinkingZoomLevel) {
        return [self smallAnnotationViewInMap:mapView];
    } else {
        return [self normalSizedAnnotationViewInMap:mapView];
    }
}

- (MKAnnotationView *)smallAnnotationViewInMap:(MKMapView *)mapView {
    if (!self.view || self.view.annotationSize != JPSThumbnailAnnotationViewSizeShrinked) {
        JPSThumbnailAnnotationView *reusableView = (JPSThumbnailAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:self.thumbnail.reuseIdentifier];
        if (!reusableView || reusableView.annotationSize != JPSThumbnailAnnotationViewSizeShrinked) {
            self.view = [[JPSThumbnailAnnotationView alloc] initWithAnnotation:self reuseIdentifier:self.thumbnail.reuseIdentifier annotationSize:JPSThumbnailAnnotationViewSizeShrinked];
        } else {
            self.view = reusableView;
        }
    } else {
        self.view.annotation = self;
    }
    
    self.thumbnail.shrinkedImage = [self shrinkedImage];
    [self updateThumbnail:self.thumbnail animated:NO];
    
    return self.view;
}

-(MKAnnotationView *)normalSizedAnnotationViewInMap:(MKMapView *)mapView {
    if (!self.view || self.view.annotationSize != JPSThumbnailAnnotationViewSizeNormal) {
        JPSThumbnailAnnotationView *reusableView = (JPSThumbnailAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:self.thumbnail.reuseIdentifier];
        if (!reusableView || reusableView.annotationSize != JPSThumbnailAnnotationViewSizeNormal) {
            self.view = [[JPSThumbnailAnnotationView alloc] initWithAnnotation:self reuseIdentifier:self.thumbnail.reuseIdentifier annotationSize:JPSThumbnailAnnotationViewSizeNormal];
        } else {
            self.view = reusableView;
        }
    } else {
        self.view.annotation = self;
    }
    
    [self updateThumbnail:self.thumbnail animated:NO];
    
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

#pragma mark - helpers
-(NSUInteger)zoomLevelForMapView:(MKMapView *)mapView {
    return [self zoomLevelForMapRect:mapView.visibleMapRect withMapViewSizeInPixels:mapView.bounds.size];
}

//Zoom level goes from 1 (the world) to 20 (zoomed innnn)
-(NSUInteger)zoomLevelForMapRect:(MKMapRect)mRect withMapViewSizeInPixels:(CGSize)viewSizeInPixels {
    NSUInteger zoomLevel = 20; // MAXIMUM_ZOOM is 20 with MapKit
    MKZoomScale zoomScale = mRect.size.width / viewSizeInPixels.width; //MKZoomScale is just a CGFloat typedef
    double zoomExponent = log2(zoomScale);
    zoomLevel = (NSUInteger)(20 - ceil(zoomExponent));
    return zoomLevel;
}

-(UIImage *)shrinkedImage {
    UIColor *dotColor = self.shrinkedImageColor ? self.shrinkedImageColor : [AppManagerBase systemBlueColor];
    dotColor = [dotColor colorWithAlphaComponent:0.8];
    CGSize imageSize = [JPSThumbnailAnnotationView imageSize];
    
    UIImage *dotImage = [[UIImage new] asa_addCircleBackgroundWithColor:dotColor andImageSize:CGSizeMake(8, 8) andInset:CGPointZero andOffset:CGPointZero];
    
    UIImage *marginedImage = [dotImage asa_addMarginWithInsets:UIEdgeInsetsMake(imageSize.height - 14, (imageSize.width - 8)/2, 6, (imageSize.width - 8)/2 )];
    
    return marginedImage;
}


@end
