//
//  DetailAnnotationView.h
//  CustomCallout
//
//  Created by Selvin on 05/04/15.
//  Copyright (c) 2015 S3lvin. All rights reserved.
//

#import <MapKit/MapKit.h>
#import "DetailAnnotationSettings.h"
#import "AnnotationProtocols.h"
#import "AnnotationThumbnail.h"

typedef NS_ENUM(NSInteger, DetailAnnotationViewSize) {
    DetailAnnotationViewSizeShrinked,
    DetailAnnotationViewSizeNormal
};

@interface DetailAnnotationView : MKAnnotationView <DetailAnnotationViewProtocol>

@property(nonatomic, strong) UIView *pinView;
@property(nonatomic, strong) UIView *calloutView;

- (instancetype)initWithAnnotation:(id<MKAnnotation>)annotation
                   reuseIdentifier:(NSString *)reuseIdentifier
                           pinView:(UIView *)pinView
                       calloutView:(UIView *)calloutView
                          settings:(DetailAnnotationSettings *)settings;


@property (nonatomic) DetailAnnotationViewSize annotationSize;
- (void)updateWithThumbnail:(AnnotationThumbnail *)thumbnail;

@end
