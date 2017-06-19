//
//  MapViewProtocols.h
//  Reitti
//
//  Created by Anteneh Sahledengel on 6/15/17.
//  Copyright © 2017 Anteneh Sahledengel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "LocationsAnnotation.h"
#import "DetailedAnnotation.h"
#import "GCThumbnailAnnotation.h"
#import "LVThumbnailAnnotation.h"
#import "ReittiPolyline.h"
#import "DetailAnnotationView.h"
#import "DefaultAnnotationCallout.h"
#import "AnnotationThumbnail.h"


@protocol MapViewAnnotationProtocol <NSObject>
-(id<MKAnnotation>)mapAnnotation;
@end

@protocol MapViewPolylineProtocol <NSObject>
-(ReittiPolyline *)mapPolyline;
@end
