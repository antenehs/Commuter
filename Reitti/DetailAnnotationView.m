//
//  DetailAnnotationView.m
//  CustomCallout
//
//  Created by Selvin on 05/04/15.
//  Copyright (c) 2015 S3lvin. All rights reserved.
//

#import "DetailAnnotationView.h"
#import "DetailAnnotationSettings.h"
#import "DefaultAnnotationCallout.h"

@interface DetailAnnotationView () {
    BOOL _hasCalloutView;
}

@property(nonatomic, strong) DetailAnnotationSettings *settings;

@end

@implementation DetailAnnotationView

- (instancetype)initWithAnnotation:(id<MKAnnotation>)annotation
                   reuseIdentifier:(NSString *)reuseIdentifier
                           pinView:(UIView *)pinView
                       calloutView:(UIView *)calloutView
                          settings:(DetailAnnotationSettings *)settings {

    NSAssert(pinView != nil, @"Pinview can not be nil");
    self = [super initWithAnnotation:annotation
                     reuseIdentifier:reuseIdentifier];
    if (self) {
        self.clipsToBounds = NO;
        _hasCalloutView = (calloutView) ? YES : NO;
        self.settings = settings;
        self.canShowCallout = NO;

        self.pinView = pinView;
        self.pinView.userInteractionEnabled = YES;
        self.calloutView = calloutView;
        self.calloutView.hidden = YES;

        [self addSubview:self.pinView];
        [self addSubview:self.calloutView];
        self.frame = [self calculateFrame];
        [self positionSubviews];
    }
    return self;
}

- (CGRect)calculateFrame {
    return self.pinView.bounds;
}

- (void)positionSubviews {
    self.pinView.center = self.center;
    if (_hasCalloutView) {
        CGRect frame = self.calloutView.frame;
        frame.origin.y = -frame.size.height - self.settings.calloutOffset;
        frame.origin.x = (self.frame.size.width - frame.size.width) / 2.0;
        self.calloutView.frame = frame;
    }
}

#pragma mark - Delegates

- (void)didSelectAnnotationViewInMap:(MKMapView *)mapView {
//    if ([self.pinView isKindOfClass:[UIImageView class]]) {
//        [(UIImageView *)self.pinView setImage:self.thumbnail.image]
//    }
    
    CGPoint annotPoint = [mapView convertCoordinate:self.annotation.coordinate toPointToView:mapView];
    
    CGFloat yOffset = annotPoint.y < 160 ? 160 - annotPoint.y : 0;
    CGFloat xOffset;
    if( annotPoint.x < 170){
        xOffset = 170 - annotPoint.x;
    }else if(annotPoint.x > mapView.frame.size.width - 170){
        xOffset = mapView.frame.size.width - annotPoint.x - 170;
    }else{
        xOffset = 0;
    }
    
    CGPoint centerPoint = [mapView convertCoordinate:mapView.region.center toPointToView:mapView];
    CGPoint fakecenter = CGPointMake(centerPoint.x - xOffset, centerPoint.y - yOffset);
    CLLocationCoordinate2D coordinate = [mapView convertPoint:fakecenter toCoordinateFromView:mapView];
    [mapView setCenterCoordinate:coordinate animated:YES];
    
    [self showCalloutView];
}

- (void)didDeselectAnnotationViewInMap:(MKMapView *)mapView {
    [self hideCalloutView];
}

- (void)setGoToHereDurationString:(MKMapView *)mapView duration:(NSString *)durationString withIconImage:(UIImage *)image {
    if ([self.calloutView conformsToProtocol:@protocol(AnnotationCalloutProtocol)] &&
        [self.calloutView respondsToSelector:@selector(setGoToHereDurationString:duration:withIconImage:)]) {
        [(NSObject<AnnotationCalloutProtocol> *)self.calloutView setGoToHereDurationString:mapView duration:durationString withIconImage:image];
    }
}

- (void)setSubtitleLabelText:(NSString *)subtitleText {
    if ([self.calloutView conformsToProtocol:@protocol(AnnotationCalloutProtocol)] &&
        [self.calloutView respondsToSelector:@selector(setSubtitleLabelText:)]) {
        [(NSObject<AnnotationCalloutProtocol> *)self.calloutView setSubtitleLabelText:subtitleText];
    }
}

#pragma mark - Hide and show

- (void)showCalloutView {
    if (_hasCalloutView) {
        if (self.calloutView.isHidden) {
            switch (self.settings.showAnimationType) {
                case DetailCalloutAnimationNone: {
                    self.calloutView.hidden = NO;
                } break;
                case DetailCalloutAnimationZoomIn: {
                    self.calloutView.transform = CGAffineTransformMakeScale(0.025, 0.25);
                    self.calloutView.hidden = NO;
                    [UIView animateWithDuration:self.settings.animationDuration animations:^{
                        self.calloutView.transform = CGAffineTransformMakeScale(1.0, 1.0);
                    } completion:nil];
                } break;
                case DetailCalloutAnimationFadeIn: {
                    self.calloutView.alpha = 0.0;
                    self.calloutView.hidden = NO;
                    [UIView animateWithDuration:self.settings.animationDuration animations:^{
                        self.calloutView.alpha = 1.0;
                    } completion:nil];
                } break;
                default: {
                    self.calloutView.hidden = NO;
                } break;
            }
        }
    }
    
    if ([self.calloutView conformsToProtocol:@protocol(AnnotationCalloutProtocol)] &&
        [self.calloutView respondsToSelector:@selector(didShowCalloutView)]) {
        [(NSObject<AnnotationCalloutProtocol> *)self.calloutView didShowCalloutView];
    }
}

- (void)hideCalloutView {
    if (_hasCalloutView) {
        if (!self.calloutView.isHidden) {
            switch (self.settings.hideAnimationType) {
            case DetailCalloutAnimationNone: {
                self.calloutView.hidden = YES;
            } break;
            case DetailCalloutAnimationZoomIn: {
                self.calloutView.transform = CGAffineTransformMakeScale(1.0, 1.0);
                [UIView animateWithDuration:self.settings.animationDuration animations:^{
                    self.calloutView.transform = CGAffineTransformMakeScale(0.25, 0.25);
                } completion:^(BOOL finished) {
                    self.calloutView.hidden = YES;
                }];
            } break;
            case DetailCalloutAnimationFadeIn: {
                self.calloutView.alpha = 1.0;
                [UIView animateWithDuration:self.settings.animationDuration animations:^{
                    self.calloutView.alpha = 0.0;
                } completion:^(BOOL finished) {
                    self.calloutView.hidden = YES;
                }];
            } break;
            default: {
                self.calloutView.hidden = YES;
            } break;
            }
        }
    }
    
    if ([self.calloutView conformsToProtocol:@protocol(AnnotationCalloutProtocol)] &&
        [self.calloutView respondsToSelector:@selector(didHideCalloutView)]) {
        [(NSObject<AnnotationCalloutProtocol> *)self.calloutView didHideCalloutView];
    }
}

#pragma mark - Hit test

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *hitView = [super hitTest:point withEvent:event];
    if (hitView == self)
        return nil;
    return hitView;
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    BOOL isCallout = (CGRectContainsPoint(self.calloutView.frame, point));
    BOOL isPin = (CGRectContainsPoint(self.pinView.frame, point));
    return isCallout || isPin;
}

#pragma mark - PinView

- (void)setPinView:(UIView *)pinView {
    //Removing old pinView
    [_pinView removeFromSuperview];
    
    //Adding new pinView to the view's hierachy
    _pinView = pinView;
    [self addSubview:_pinView];
    
    //Position the new pinView
    self.frame = [self calculateFrame];
    self.pinView.center = self.center;
}

- (void)setCalloutView:(UIView *)calloutView {
    //Removing old calloutView
    [_calloutView removeFromSuperview];
    
    //Adding new calloutView to the view's hierachy
    _calloutView = calloutView;
    [self addSubview:_calloutView];
    
    self.calloutView.hidden = YES;
    
    [self positionSubviews];
    
}

@end
