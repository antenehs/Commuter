//
//  GCThumbnailAnnotationView.h
//  GCThumbnailAnnotationView
//
//  Created by Jean-Pierre Simard on 4/21/13.
//  Copyright (c) 2013 JP Simard. All rights reserved.
//

@import MapKit;

@class GCThumbnail;

typedef void (^ActionBlock)();

extern NSString * const kGCThumbnailAnnotationViewReuseID;

typedef NS_ENUM(NSInteger, GCThumbnailAnnotationViewAnimationDirection) {
    GCThumbnailAnnotationViewAnimationDirectionGrow,
    GCThumbnailAnnotationViewAnimationDirectionShrink,
};

typedef NS_ENUM(NSInteger, GCThumbnailAnnotationViewState) {
    GCThumbnailAnnotationViewStateCollapsed,
    GCThumbnailAnnotationViewStateExpanded,
    GCThumbnailAnnotationViewStateAnimating,
};

@protocol GCThumbnailAnnotationViewProtocol <NSObject>

- (void)didSelectAnnotationViewInMap:(MKMapView *)mapView;
- (void)didDeselectAnnotationViewInMap:(MKMapView *)mapView;
- (void)setGoToHereDurationString:(MKMapView *)mapView duration:(NSString *)durationString;
- (void)setGeoCodeAddress:(MKMapView *)mapView address:(NSString *)address;
- (void)enableAddressInfoButton;

@end

@interface GCThumbnailAnnotationView : MKAnnotationView <GCThumbnailAnnotationViewProtocol>

- (id)initWithAnnotation:(id<MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier;

- (void)updateWithThumbnail:(GCThumbnail *)thumbnail;

@end
