//
//  AnnotationProtocols.h
//  Reitti
//
//  Created by Anteneh Sahledengel on 6/15/17.
//  Copyright © 2017 Anteneh Sahledengel. All rights reserved.
//

typedef void (^AnnotationActionBlock)(MKAnnotationView *onAnnotation);

typedef enum {
    DefaultAddressLocation = 0,
    StartLocation = 1,
    DestinationLocation = 2,
    StopLocation = 3,
    TransferStopLocation = 4,
    OtherStopLocation = 5,
    BikeStationLocation = 6,
    ServicePointAnnotationType = 7,
    SalesPointAnnotationType = 8,
    LiveVehicleAnnotationType = 9
} ReittiAnnotationType;

@protocol ReittiAnnotationProtocol <NSObject>

- (MKAnnotationView *)annotationViewInMap:(MKMapView *)mapView;

@property (nonatomic, weak) id associatedObject;
@property (nonatomic, strong) NSString *uniqueIdentifier;

@optional
- (MKAnnotationView *)smallAnnotationViewInMap:(MKMapView *)mapView;
@property (nonatomic) BOOL shrinksWhenZoomedOut;
@property (nonatomic, strong) UIColor *shrinkedImageColor;
@property (nonatomic) NSInteger shrinkingZoomLevel;

@property (nonatomic) BOOL disappearsWhenZoomedOut;
@property (nonatomic) NSInteger disappearingZoomLevel;

@property (nonatomic) ReittiAnnotationType locationType;
@property (nonatomic, copy) AnnotationActionBlock calloutAccessoryAction;

@end
