//
//  LocationsAnnotationView.h
//  Reitti
//
//  Created by Anteneh Sahledengel on 6/17/17.
//  Copyright © 2017 Anteneh Sahledengel. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface LocationsAnnotationView : MKAnnotationView

typedef NS_ENUM(NSInteger, LocationsAnnotationViewSize) {
    LocationsAnnotationViewSizeShrinked,
    LocationsAnnotationViewSizeNormal
};

- (id)initWithAnnotation:(id<MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier;

@property (nonatomic) LocationsAnnotationViewSize annotationSize;

@end
