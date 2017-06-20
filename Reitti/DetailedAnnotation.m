//
//  DetailedAnnotation.m
//  JPSThumbnailAnnotationView
//
//  Created by Jean-Pierre Simard on 4/21/13.
//  Copyright (c) 2013 JP Simard. All rights reserved.
//

#import "DetailedAnnotation.h"
#import "ASA_Helpers.h"
#import "SwiftHeaders.h"
#import "AppManager.h"
#import "MapViewProtocols.h"

@interface DetailedAnnotation ()

@property (nonatomic, readwrite) DetailAnnotationView *view;

@end

@implementation DetailedAnnotation

+ (instancetype)annotationWithThumbnail:(AnnotationThumbnail *)thumbnail {
    return [[self alloc] initWithThumbnail:thumbnail];
}

- (id)initWithThumbnail:(AnnotationThumbnail *)thumbnail {
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

-(void)setPrimaryAccessoryAction:(AnnotationActionBlock)primaryAccessoryAction {
    self.thumbnail.primaryButtonBlock = primaryAccessoryAction;
}

-(void)setSecondaryButtonBlock:(AnnotationActionBlock)secondaryButtonBlock {
    self.thumbnail.secondaryButtonBlock = secondaryButtonBlock;
}

-(void)setDisclosureBlock:(AnnotationActionBlock)disclosureBlock {
    self.thumbnail.disclosureBlock = disclosureBlock;
}

- (MKAnnotationView *)annotationViewInMap:(MKMapView *)mapView {
    if ([self shrinksWhenZoomedOut] && [self zoomLevelForMapView:mapView] < self.shrinkingZoomLevel) {
        return [self smallAnnotationViewInMap:mapView];
    } else {
        return [self normalSizedAnnotationViewInMap:mapView];
    }
}

- (MKAnnotationView *)smallAnnotationViewInMap:(MKMapView *)mapView {
    
    if (!self.view || self.view.annotationSize != DetailAnnotationViewSizeShrinked) {
        DetailAnnotationView *reusableView = (DetailAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:self.thumbnail.reuseIdentifier];
        
        if (!reusableView || reusableView.annotationSize != DetailAnnotationViewSizeShrinked) {
            self.view = [self newShrinkedAnnotationView];
        } else {
            self.view = reusableView;
        }
    } else {
        self.view.annotation = self;
    }
    
    [self updateThumbnail];
    return self.view;
}

-(MKAnnotationView *)normalSizedAnnotationViewInMap:(MKMapView *)mapView {
    if (!self.view || self.view.annotationSize != DetailAnnotationViewSizeNormal) {
        
         DetailAnnotationView *reusableView = (DetailAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:self.thumbnail.reuseIdentifier];
        
        if (!reusableView || reusableView.annotationSize != DetailAnnotationViewSizeNormal) {
            self.view = [self newNormalSizeAnnotationView];
        } else {
            self.view = reusableView;
        }
    }else {
        self.view.annotation = self;
    }
    
    [self updateThumbnail];
    return self.view;
}

-(DetailAnnotationView *)newShrinkedAnnotationView {
    UIImageView *pinView = [[UIImageView alloc] initWithImage:[self shrinkedImage]];
    pinView.frame = CGRectMake(0, 0, 16, 16);
    
    UIView *calloutView = [DefaultAnnotationCallout calloutForThumbnail:self.thumbnail andSettings:[DetailAnnotationSettings defaultSettings]];
    
    DetailAnnotationView *annotView = [[DetailAnnotationView alloc] initWithAnnotation:self
                                                   reuseIdentifier:self.thumbnail.reuseIdentifier
                                                           pinView:pinView
                                                       calloutView:calloutView
                                                          settings:[DetailAnnotationSettings defaultSettings]];
    
    annotView.annotationSize = DetailAnnotationViewSizeShrinked;
    
    return annotView;
}

-(DetailAnnotationView *)newNormalSizeAnnotationView {
    UIImageView *pinView = [[UIImageView alloc] initWithImage:self.thumbnail.image];
    pinView.frame = CGRectMake(0, 0, 28, 42);
    
    UIView *calloutView = [DefaultAnnotationCallout calloutForThumbnail:self.thumbnail andSettings:[DetailAnnotationSettings defaultSettings]];
    
    DetailAnnotationView *annotView = [[DetailAnnotationView alloc] initWithAnnotation:self
                                                   reuseIdentifier:self.thumbnail.reuseIdentifier
                                                           pinView:pinView
                                                       calloutView:calloutView
                                                          settings:[DetailAnnotationSettings defaultSettings]];
    annotView.centerOffset = CGPointMake(0, -15);
    annotView.annotationSize = DetailAnnotationViewSizeNormal;
    
    return annotView;
}

- (void)updateThumbnail {
    self.thumbnail.shrinkedImage = [self shrinkedImage];
    
    [self.view updateWithThumbnail:self.thumbnail];
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
    
    UIImage *dotImage = [[UIImage new] asa_addCircleBackgroundWithColor:dotColor andImageSize:CGSizeMake(8, 8) andInset:CGPointZero andOffset:CGPointZero];
    
    UIImage *marginedImage = [dotImage asa_addMarginWithWithuniformInsetSize:4];
    
    return marginedImage;
}


@end
