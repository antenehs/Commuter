//
//  LocationsAnnotation.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 14/9/14.
//  Copyright (c) 2014 Anteneh Sahledengel. All rights reserved.
//

#import "LocationsAnnotation.h"
#import "LocationsAnnotationView.h"
#import "ASA_Helpers.h"
#import "AppManagerBase.h"

NSString *kLocationAnnotationViewReuseID = @"LocationAnnotationReuseId";
CGFloat kDefaultAnnotationImageWidth = 28.0;
CGFloat kDefaultAnnotationImageHeight = 42.0;

@interface LocationsAnnotation ()

@property (nonatomic, readwrite) LocationsAnnotationView *view;

@end

@implementation LocationsAnnotation

@synthesize title, subtitle , coordinate, code, locationType, imageNameForView;

- (id)initWithTitle:(NSString *)ttl andSubtitle:(NSString *)subttl andCoordinate:(CLLocationCoordinate2D)c2d andLocationType:(ReittiAnnotationType)type {
    if ((self = [super init])){
        title = ttl;
        coordinate = c2d;
        subtitle = subttl;
        locationType = type;
    }
    
    return self;
}

-(NSString *)uniqueIdentifier {
    if (!_uniqueIdentifier) {
        _uniqueIdentifier = self.code;
    }
    
    return _uniqueIdentifier;
}

-(NSInteger)shrinkingZoomLevel {
    if (_shrinkingZoomLevel == 0) {
        _shrinkingZoomLevel = 13;
    }
    
    return _shrinkingZoomLevel;
}

-(NSInteger)disappearingZoomLevel {
    if (_disappearingZoomLevel == 0) {
        _disappearingZoomLevel = 13;
    }
    
    return _disappearingZoomLevel;
}

-(NSString *)annotIdentifier {
    if (!_annotIdentifier) { _annotIdentifier = kLocationAnnotationViewReuseID; }
    
    return _annotIdentifier;
}

-(CGSize)annotationSize {
    if (self.preferedSize.height == 0 || self.preferedSize.width == 0) {
        return CGSizeMake(kDefaultAnnotationImageWidth, kDefaultAnnotationImageHeight);
    }
    
    return self.preferedSize;
}

-(MKAnnotationView *)annotationViewInMap:(MKMapView *)mapView {
    if ([self shrinksWhenZoomedOut] && [self zoomLevelForMapView:mapView] < self.shrinkingZoomLevel) {
        return [self smallAnnotationViewInMap:mapView];
    } else {
        return [self normalSizedAnnotationViewInMap:mapView];
    }
}

- (MKAnnotationView *)smallAnnotationViewInMap:(MKMapView *)mapView {
    if (!self.view || self.view.annotationSize != LocationsAnnotationViewSizeShrinked) {
        LocationsAnnotationView *reusableView = (LocationsAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:self.annotIdentifier];
        if (!reusableView || reusableView.annotationSize != LocationsAnnotationViewSizeShrinked) {
            self.view = [self shrinkedAnnotationView];
        } else {
            self.view = reusableView;
        }
    } else {
        self.view.annotation = self;
    }
    
    return self.view;
}

-(MKAnnotationView *)normalSizedAnnotationViewInMap:(MKMapView *)mapView {
    if (!self.view || self.view.annotationSize != LocationsAnnotationViewSizeNormal) {
        LocationsAnnotationView *reusableView = (LocationsAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:self.annotIdentifier];
        if (!reusableView || reusableView.annotationSize != LocationsAnnotationViewSizeNormal) {
            self.view = [self annotationView];
        } else {
            self.view = reusableView;
        }
    } else {
        self.view.annotation = self;
    }
    
    return self.view;
}

-(LocationsAnnotationView *)annotationView {
    LocationsAnnotationView *annotationView = [[LocationsAnnotationView alloc] initWithAnnotation:self reuseIdentifier:self.annotIdentifier];
    annotationView.enabled = YES;
    annotationView.canShowCallout = YES;
    //Add callout based on specified block.
    if (self.calloutAccessoryAction) {
        annotationView.leftCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    }
    
    annotationView.image = [UIImage imageNamed:self.imageNameForView];
    [annotationView setFrame:CGRectMake(0, 0, self.annotationSize.width, self.annotationSize.height)];
    annotationView.centerOffset = self.imageCenterOffset;
    annotationView.annotationSize = LocationsAnnotationViewSizeNormal;
    
    return annotationView;
}

-(LocationsAnnotationView *)shrinkedAnnotationView {
    LocationsAnnotationView *annotationView = [[LocationsAnnotationView alloc] initWithAnnotation:self reuseIdentifier:self.annotIdentifier];
    annotationView.enabled = YES;
    annotationView.canShowCallout = YES;
    //Add callout based on specified block.
    if (self.calloutAccessoryAction) {
        annotationView.leftCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    }
    
    UIColor *dotColor = self.shrinkedImageColor ? self.shrinkedImageColor : [AppManagerBase systemBlueColor];
    annotationView.image = [[UIImage new] asa_addCircleBackgroundWithColor:dotColor andImageSize:CGSizeMake(8, 8) andInset:CGPointZero andOffset:CGPointZero];
    [annotationView setFrame:CGRectMake(0, 0, 8, 8)];
    
    annotationView.annotationSize = LocationsAnnotationViewSizeShrinked;
    
    return annotationView;
}

#pragma mark - Helpers
-(NSUInteger)zoomLevelForMapView:(MKMapView *)mapView {
    return [self zoomLevelForMapRect:mapView.visibleMapRect withMapViewSizeInPixels:mapView.bounds.size];
}

//Zoom level goes from 1 (the world) to 20 (zoomed innnn)
-(NSUInteger)zoomLevelForMapRect:(MKMapRect)mRect withMapViewSizeInPixels:(CGSize)viewSizeInPixels {
    NSUInteger zoomLevel = 20; // MAXIMUM_ZOOM is 20 with MapKit
    MKZoomScale zoomScale = mRect.size.width / viewSizeInPixels.width; //MKZoomScale is just a CGFloat typedef
    double zoomExponent = log2(zoomScale);
    zoomLevel = (NSUInteger)(20 - ceil(zoomExponent));
    return zoomLevel;
}

@end
