//
//  LVThumbnailAnnotation.h
//  LVThumbnailAnnotationView
//

@import Foundation;
@import MapKit;
#import "LVThumbnail.h"
#import "LVThumbnailAnnotationView.h"

@protocol LVThumbnailAnnotationProtocol <NSObject>

- (MKAnnotationView *)annotationViewInMap:(MKMapView *)mapView;
- (void)updateThumbnail:(LVThumbnail *)thumbnail animated:(BOOL)animated;
- (void)updateBearing:(NSNumber *)bearing;
- (void)updateVehicleImage:(UIImage *)image;

@end

@interface LVThumbnailAnnotation : NSObject <MKAnnotation, LVThumbnailAnnotationProtocol>

@property (nonatomic, readwrite) CLLocationCoordinate2D coordinate;
@property (nonatomic, readonly) NSString *code;
@property (nonatomic, readonly) NSString *lineId;
@property (nonatomic) VehicleType vehicleType;
@property (nonatomic, readwrite) LVThumbnail *thumbnail;

+ (instancetype)annotationWithThumbnail:(LVThumbnail *)thumbnail;
- (id)initWithThumbnail:(LVThumbnail *)thumbnail;
- (void)updateThumbnail:(LVThumbnail *)thumbnail animated:(BOOL)animated;

@end
