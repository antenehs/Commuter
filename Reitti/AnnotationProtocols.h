//
//  AnnotationProtocols.h
//  Reitti
//
//  Created by Anteneh Sahledengel on 6/15/17.
//  Copyright © 2017 Anteneh Sahledengel. All rights reserved.
//

#import "EnumManager.h"

typedef void (^AnnotationActionBlock)(MKAnnotationView *onAnnotation);

@protocol ReittiAnnotationProtocol <NSObject>

- (MKAnnotationView *)annotationViewInMap:(MKMapView *)mapView;

@property (nonatomic, weak) id associatedObject;
@property (nonatomic, strong) NSString *uniqueIdentifier;

@optional
@property (nonatomic) BOOL shrinksWhenZoomedOut;
@property (nonatomic, strong) UIColor *shrinkedImageColor;
@property (nonatomic) NSInteger shrinkingZoomLevel;

@property (nonatomic) BOOL disappearsWhenZoomedOut;
@property (nonatomic) NSInteger disappearingZoomLevel;

@property (nonatomic) ReittiAnnotationType annotationType;

@end

@protocol ReittiActionableAnnotationProtocol <NSObject>

@optional
@property (nonatomic, copy) AnnotationActionBlock primaryAccessoryAction;
@property (nonatomic, copy) AnnotationActionBlock secondaryButtonBlock;
@property (nonatomic, copy) AnnotationActionBlock disclosureBlock;

@end

@protocol DetailAnnotationViewProtocol <NSObject>

- (void)didSelectAnnotationViewInMap:(MKMapView *)mapView;
- (void)didDeselectAnnotationViewInMap:(MKMapView *)mapView;
- (void)setGoToHereDurationString:(MKMapView *)mapView duration:(NSString *)durationString withIconImage:(UIImage *)image;
- (void)setSubtitleLabelText:(NSString *)subtitleText;

@end


@protocol AnnotationCalloutProtocol <NSObject>
@optional
- (void)didShowCalloutView;
- (void)didHideCalloutView;
- (void)setGoToHereDurationString:(MKMapView *)mapView duration:(NSString *)durationString withIconImage:(UIImage *)image;
- (void)setSubtitleLabelText:(NSString *)subtitleText;
@end
