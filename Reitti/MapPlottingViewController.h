//
//  MapPlottingViewController.h
//  Reitti
//
//  Created by Anteneh Sahledengel on 5/19/17.
//  Copyright © 2017 Anteneh Sahledengel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "ReittiModels.h"
#import "LocationsAnnotation.h"
#import "LVThumbnailAnnotation.h"
#import "JPSThumbnailAnnotation.h"
#import "GCThumbnailAnnotation.h"

@interface MapPlottingViewController : UIViewController <MKMapViewDelegate> {
    IBOutlet MKMapView *mapView;
}

-(void)plotStopAnnotationsInLine:(Line *)line;
-(void)plotStopAnnotationsInLine:(Line *)line withCalloutAction:(AnnotationActionBlock)calloutAction;

@end
