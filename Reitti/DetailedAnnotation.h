//
//  DetailedAnnotation.h
//  JPSThumbnailAnnotationView
//
//  Created by Jean-Pierre Simard on 4/21/13.
//  Copyright (c) 2013 JP Simard. All rights reserved.
//

@import Foundation;
@import MapKit;
#import "AnnotationThumbnail.h"
#import "AnnotationProtocols.h"

@interface DetailedAnnotation : NSObject <MKAnnotation, ReittiAnnotationProtocol>

@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property (nonatomic, readonly) NSString *code;
@property (nonatomic, readonly) AnnotationThumbnail *thumbnail;

//ReittiAnnotationProtocol
@property (nonatomic, weak) id associatedObject;
@property (nonatomic, strong) NSString *uniqueIdentifier;

@property (nonatomic) BOOL shrinksWhenZoomedOut;
@property (nonatomic, strong) UIColor *shrinkedImageColor;
@property (nonatomic) NSInteger shrinkingZoomLevel;

@property (nonatomic) BOOL disappearsWhenZoomedOut;
@property (nonatomic) NSInteger disappearingZoomLevel;

@property (nonatomic) ReittiAnnotationType annotationType;

+ (instancetype)annotationWithThumbnail:(AnnotationThumbnail *)thumbnail;
- (id)initWithThumbnail:(AnnotationThumbnail *)thumbnail;
//- (void)updateThumbnail:(AnnotationThumbnail *)thumbnail animated:(BOOL)animated;

@end
