//
//  LocationsAnnotation.h
//  Reitti
//
//  Created by Anteneh Sahledengel on 14/9/14.
//  Copyright (c) 2014 Anteneh Sahledengel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

typedef void (^AnnotationActionBlock)(MKAnnotationView *onAnnotation);

typedef enum
{
    DefaultAddressLocation = 0,
    StartLocation = 1,
    DestinationLocation = 2,
    StopLocation = 3,
    TransferStopLocation = 4,
    OtherStopLocation = 5,
    BikeStationLocation = 6,
    ServicePointAnnotationType = 7,
    SalesPointAnnotationType = 8
} AnnotationLocationType;

@interface LocationsAnnotation : NSObject<MKAnnotation>{
    
    NSString *title;
    CLLocationCoordinate2D coordinate;
    
}

@property (nonatomic, copy) NSString *code;
@property (nonatomic, copy) NSString *imageNameForView;
@property (nonatomic, copy) NSString *annotIdentifier;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;
@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property (nonatomic, readonly) AnnotationLocationType locationType;

@property (nonatomic, copy) AnnotationActionBlock calloutAccessoryAction;



- (id)initWithTitle:(NSString *)ttl andSubtitle:(NSString *)subttl andCoordinate:(CLLocationCoordinate2D)c2d andLocationType:(AnnotationLocationType)type;

@end
