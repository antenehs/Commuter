//
//  LVThumbnailAnnotationView.h
//  LVThumbnailAnnotationView
//

@import MapKit;

@class LVThumbnail;

typedef void (^ActionBlock)();

extern NSString * const kLVThumbnailAnnotationViewReuseID;

typedef NS_ENUM(NSInteger, LVThumbnailAnnotationViewAnimationDirection) {
    LVThumbnailAnnotationViewAnimationDirectionGrow,
    LVThumbnailAnnotationViewAnimationDirectionShrink,
};

typedef NS_ENUM(NSInteger, LVThumbnailAnnotationViewState) {
    LVThumbnailAnnotationViewStateCollapsed,
    LVThumbnailAnnotationViewStateExpanded,
    LVThumbnailAnnotationViewStateAnimating,
};

@protocol LVThumbnailAnnotationViewProtocol <NSObject>

- (void)didSelectAnnotationViewInMap:(MKMapView *)mapView;
- (void)didDeselectAnnotationViewInMap:(MKMapView *)mapView;
- (void)setGoToHereDurationString:(MKMapView *)mapView duration:(NSString *)durationString;
- (void)setGeoCodeAddress:(MKMapView *)mapView address:(NSString *)address;
- (void)setBearing:(NSNumber *)bearing;

@end

@interface LVThumbnailAnnotationView : MKAnnotationView <LVThumbnailAnnotationViewProtocol>

- (id)initWithAnnotation:(id<MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier;

- (void)updateWithThumbnail:(LVThumbnail *)thumbnail;

@end
