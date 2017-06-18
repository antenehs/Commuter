//
//  JPSThumbnailAnnotation.h
//  JPSThumbnailAnnotationView
//
//  Created by Jean-Pierre Simard on 4/21/13.
//  Copyright (c) 2013 JP Simard. All rights reserved.
//

@import Foundation;
@import MapKit;
#import "JPSThumbnail.h"
#import "JPSThumbnailAnnotationView.h"
#import "AnnotationProtocols.h"

//@protocol JPSThumbnailAnnotationProtocol <NSObject>
//- (MKAnnotationView *)annotationViewInMap:(MKMapView *)mapView;
//@end

@interface JPSThumbnailAnnotation : NSObject <MKAnnotation, ReittiAnnotationProtocol>

@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property (nonatomic, readonly) NSString *code;
//@property (nonatomic) StopType stopType;
@property (nonatomic, readonly) JPSThumbnail *thumbnail;

//REittiAnnotationProtocol
@property (nonatomic, weak) id associatedObject;
@property (nonatomic, strong) NSString *uniqueIdentifier;

@property (nonatomic) BOOL shrinksWhenZoomedOut;
@property (nonatomic, strong) UIColor *shrinkedImageColor;
@property (nonatomic) NSInteger shrinkingZoomLevel;

@property (nonatomic) BOOL disappearsWhenZoomedOut;
@property (nonatomic) NSInteger disappearingZoomLevel;

@property (nonatomic) ReittiAnnotationType annotationType;

+ (instancetype)annotationWithThumbnail:(JPSThumbnail *)thumbnail;
- (id)initWithThumbnail:(JPSThumbnail *)thumbnail;
- (void)updateThumbnail:(JPSThumbnail *)thumbnail animated:(BOOL)animated;

@end
