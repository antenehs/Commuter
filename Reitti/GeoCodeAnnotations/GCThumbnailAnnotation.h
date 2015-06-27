//
//  GCThumbnailAnnotation.h
//  GCThumbnailAnnotationView
//
//  Created by Jean-Pierre Simard on 4/21/13.
//  Copyright (c) 2013 JP Simard. All rights reserved.
//

@import Foundation;
@import MapKit;
#import "GCThumbnail.h"
#import "GCThumbnailAnnotationView.h"

@protocol GCThumbnailAnnotationProtocol <NSObject>

- (MKAnnotationView *)annotationViewInMap:(MKMapView *)mapView;

@end

@interface GCThumbnailAnnotation : NSObject <MKAnnotation, GCThumbnailAnnotationProtocol>

@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property (nonatomic, readonly) NSNumber *code;
//@property (nonatomic) AnnotationType annotationType;
@property (nonatomic) StopType stopType;
@property (nonatomic, readonly) GCThumbnail *thumbnail;

+ (instancetype)annotationWithThumbnail:(GCThumbnail *)thumbnail;
- (id)initWithThumbnail:(GCThumbnail *)thumbnail;
- (void)updateThumbnail:(GCThumbnail *)thumbnail animated:(BOOL)animated;

@end
