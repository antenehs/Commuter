//
//  LocationsAnnotation.h
//  Reitti
//
//  Created by Anteneh Sahledengel on 14/9/14.
//  Copyright (c) 2014 Anteneh Sahledengel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

typedef enum
{
    StartLocation = 1,
    DestinationLocation = 2,
    StopLocation = 3
} AnnotationLocationType;

@interface LocationsAnnotation : NSObject<MKAnnotation>{
    
    NSString *title;
    CLLocationCoordinate2D coordinate;
    
}

@property (nonatomic, copy) NSNumber *code;
@property (nonatomic, copy) NSString *imageNameForView;
@property (nonatomic, copy) NSString *annotIdentifier;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;
@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property (nonatomic, readonly) AnnotationLocationType locationType;

- (id)initWithTitle:(NSString *)ttl andSubtitle:(NSString *)subttl andCoordinate:(CLLocationCoordinate2D)c2d andLocationType:(AnnotationLocationType)type;

@end
