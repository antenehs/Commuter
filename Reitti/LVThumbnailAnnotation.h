//
//  LVThumbnailAnnotation.h
//  LVThumbnailAnnotationView
//

@import Foundation;
@import MapKit;
#import "LVThumbnail.h"
#import "LVThumbnailAnnotationView.h"
#import "AnnotationProtocols.h"

@protocol LVThumbnailAnnotationProtocol <NSObject>

- (void)updateThumbnail:(LVThumbnail *)thumbnail animated:(BOOL)animated;
- (void)updateBearing:(NSNumber *)bearing;
- (void)updateVehicleImage:(UIImage *)image;

@end

@interface LVThumbnailAnnotation : NSObject <MKAnnotation, LVThumbnailAnnotationProtocol, ReittiAnnotationProtocol>

@property (nonatomic, readwrite) CLLocationCoordinate2D coordinate;
@property (nonatomic, readonly) NSString *code;
@property (nonatomic, readonly) NSString *lineId;
@property (nonatomic) VehicleType vehicleType;
@property (nonatomic, readwrite) LVThumbnail *thumbnail;

@property (nonatomic, weak) id associatedObject;
@property (nonatomic, strong) NSString *uniqueIdentifier;

@property (nonatomic) BOOL shrinksWhenZoomedOut;
@property (nonatomic, strong) UIColor *shrinkedImageColor;
@property (nonatomic) NSInteger shrinkingZoomLevel;

@property (nonatomic) BOOL disappearsWhenZoomedOut;
@property (nonatomic) NSInteger disappearingZoomLevel;

+ (instancetype)annotationWithThumbnail:(LVThumbnail *)thumbnail;
- (id)initWithThumbnail:(LVThumbnail *)thumbnail;
- (void)updateThumbnail:(LVThumbnail *)thumbnail animated:(BOOL)animated;

@end
