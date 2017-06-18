//
//  LVThumbnailAnnotation.m
//  LVThumbnailAnnotationView
//

#import "LVThumbnailAnnotation.h"

@interface LVThumbnailAnnotation ()

@property (nonatomic, readwrite) LVThumbnailAnnotationView *view;

@end

@implementation LVThumbnailAnnotation

+ (instancetype)annotationWithThumbnail:(LVThumbnail *)thumbnail {
    return [[self alloc] initWithThumbnail:thumbnail];
}

- (id)initWithThumbnail:(LVThumbnail *)thumbnail {
    self = [super init];
    if (self) {
        _coordinate = thumbnail.coordinate;
        _code = thumbnail.code;
        _thumbnail = thumbnail;
        _vehicleType = thumbnail.vehicleType;
        _lineId = thumbnail.lineId;
        _associatedObject = thumbnail.associatedVehicle;
    }
    return self;
}

-(NSString *)uniqueIdentifier {
    if (!_uniqueIdentifier) {
        _uniqueIdentifier = _code;
    }
    
    return _uniqueIdentifier;
}

-(ReittiAnnotationType)annotationType {
    return LiveVehicleAnnotationType;
}

- (MKAnnotationView *)annotationViewInMap:(MKMapView *)mapView {
    if (!self.view) {
        self.view = (LVThumbnailAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:self.thumbnail.reuseIdentifier];
        if (!self.view) self.view = [[LVThumbnailAnnotationView alloc] initWithAnnotation:self reuseIdentifier:self.thumbnail.reuseIdentifier];
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

- (void)updateThumbnail:(LVThumbnail *)thumbnail animated:(BOOL)animated {
    if (animated) {
        [UIView animateWithDuration:1 animations:^{
            _coordinate = thumbnail.coordinate; // use ivar to avoid triggering setter
             [self.view updateWithThumbnail:thumbnail];
        }];
    } else {
        _coordinate = thumbnail.coordinate; // use ivar to avoid triggering setter
         [self.view updateWithThumbnail:thumbnail];
    }
}

- (void)updateBearing:(NSNumber *)bearing {
    self.thumbnail.bearing = bearing;
   [self.view setBearing:bearing];
}

- (void)updateVehicleImage:(UIImage *)image{
    self.thumbnail.image = image;
    [self.view updateAnnotationImageFromThumbnail:self.thumbnail];
}


@end
