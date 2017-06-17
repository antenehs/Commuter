//
//  LocationsAnnotation.h
//  Reitti
//
//  Created by Anteneh Sahledengel on 14/9/14.
//  Copyright (c) 2014 Anteneh Sahledengel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "AnnotationProtocols.h"

@interface LocationsAnnotation : NSObject<MKAnnotation, ReittiAnnotationProtocol>{
    
    NSString *title;
    CLLocationCoordinate2D coordinate;
    
}

@property (nonatomic, copy) NSString *code;
@property (nonatomic, copy) NSString *imageNameForView;
@property (nonatomic, copy) NSString *annotIdentifier;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;
@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;

//Positive -> up
@property (nonatomic) CGPoint imageCenterOffset;
@property (nonatomic) CGSize preferedSize;

//ReittiAnnotationProtocol
@property (nonatomic, weak) id associatedObject;
@property (nonatomic, strong) NSString *uniqueIdentifier;
@property (nonatomic) ReittiAnnotationType locationType;
@property (nonatomic, copy) AnnotationActionBlock calloutAccessoryAction;

@property (nonatomic) BOOL shrinksWhenZoomedOut;
@property (nonatomic, strong) UIColor *shrinkedImageColor;
@property (nonatomic) NSInteger shrinkingZoomLevel;

@property (nonatomic) BOOL disappearsWhenZoomedOut;
@property (nonatomic) NSInteger disappearingZoomLevel;


- (id)initWithTitle:(NSString *)ttl andSubtitle:(NSString *)subttl andCoordinate:(CLLocationCoordinate2D)c2d andLocationType:(ReittiAnnotationType)type;

@end
