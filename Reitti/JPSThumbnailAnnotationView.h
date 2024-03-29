//
//  JPSThumbnailAnnotationView.h
//  JPSThumbnailAnnotationView
//
//  Created by Jean-Pierre Simard on 4/21/13.
//  Copyright (c) 2013 JP Simard. All rights reserved.
//

@import MapKit;

@class AnnotationThumbnail;

typedef void (^ActionBlock)();

extern NSString * const kJPSThumbnailAnnotationViewReuseID;

typedef NS_ENUM(NSInteger, JPSThumbnailAnnotationViewAnimationDirection) {
    JPSThumbnailAnnotationViewAnimationDirectionGrow,
    JPSThumbnailAnnotationViewAnimationDirectionShrink,
};

typedef NS_ENUM(NSInteger, JPSThumbnailAnnotationViewState) {
    JPSThumbnailAnnotationViewStateCollapsed,
    JPSThumbnailAnnotationViewStateExpanded,
    JPSThumbnailAnnotationViewStateAnimating,
};

typedef NS_ENUM(NSInteger, JPSThumbnailAnnotationViewSize) {
    JPSThumbnailAnnotationViewSizeShrinked,
    JPSThumbnailAnnotationViewSizeNormal
};

@protocol JPSThumbnailAnnotationViewProtocol <NSObject>

- (void)didSelectAnnotationViewInMap:(MKMapView *)mapView;
- (void)didDeselectAnnotationViewInMap:(MKMapView *)mapView;
- (void)setGoToHereDurationString:(MKMapView *)mapView duration:(NSString *)durationString withIconImage:(UIImage *)image;
- (void)setSubtitleLabelText:(NSString *)subtitleText;
- (void)setGeoCodeAddress:(MKMapView *)mapView address:(NSString *)address;

@end

@interface JPSThumbnailAnnotationView : MKAnnotationView <JPSThumbnailAnnotationViewProtocol>

- (id)initWithAnnotation:(id<MKAnnotation>)annotation
         reuseIdentifier:(NSString *)reuseIdentifier
          annotationSize:(JPSThumbnailAnnotationViewSize)annotationSize;

- (void)updateWithThumbnail:(AnnotationThumbnail *)thumbnail;

+(CGSize)imageSize;

@property (nonatomic) JPSThumbnailAnnotationViewSize annotationSize;

@end
