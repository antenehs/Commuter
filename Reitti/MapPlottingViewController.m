//
//  MapPlottingViewController.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 5/19/17.
//  Copyright © 2017 Anteneh Sahledengel. All rights reserved.
//

#import "MapPlottingViewController.h"
#import "ReittiStringFormatter.h"
#import "AppManager.h"

@interface MapPlottingViewController ()

@end

@implementation MapPlottingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    mapView.delegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



-(void)plotStopAnnotationsInLine:(Line *)line {
    [self plotStopAnnotationsInLine:line withCalloutAction:nil];
}

-(void)plotStopAnnotationsInLine:(Line *)line withCalloutAction:(AnnotationActionBlock)calloutAction{
    for (LineStop *stop in line.lineStops) {
        CLLocationCoordinate2D coordinate = [ReittiStringFormatter convertStringTo2DCoord:stop.coords];
        
        NSString * name = stop.name;
        NSString * shortCode = stop.codeShort;
        
        if (name == nil || name == (id)[NSNull null]) {
            name = @"";
        }
        
        if (shortCode == nil || shortCode == (id)[NSNull null]) {
            shortCode = @"";
        }
        
        LocationsAnnotation *newAnnotation = [[LocationsAnnotation alloc] initWithTitle:name andSubtitle:shortCode andCoordinate:coordinate andLocationType:StopLocation];
        newAnnotation.code = stop.gtfsId;
        newAnnotation.imageNameForView = [AppManager stopAnnotationImageNameForStopType:[EnumManager stopTypeFromLegType:[EnumManager legTrasportTypeForLineType:line.lineType]]];
        
        newAnnotation.annotIdentifier = @"LocationAnnotation";
        if (calloutAction)
            newAnnotation.calloutAccessoryAction = calloutAction;
        
        [mapView addAnnotation:newAnnotation];
    }
}

- (MKAnnotationView *)mapView:(MKMapView *)_mapView viewForAnnotation:(id <MKAnnotation>)annotation {
    
    static NSString *locationIdentifier = @"location";
    
    if ([annotation isKindOfClass:[LocationsAnnotation class]]) {
        LocationsAnnotation *locAnnotation = (LocationsAnnotation *)annotation;
        MKAnnotationView *annotationView = (MKAnnotationView *) [_mapView dequeueReusableAnnotationViewWithIdentifier:locationIdentifier];
        if (annotationView == nil) {
            annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:locationIdentifier];
            annotationView.enabled = YES;
            
            annotationView.canShowCallout = YES;
            //Add callout based on specified block.
            if (locAnnotation.calloutAccessoryAction) {
                annotationView.leftCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
            }
            
        } else {
            annotationView.annotation = annotation;
        }
        
        annotationView.image = [UIImage imageNamed:locAnnotation.imageNameForView];
        [annotationView setFrame:CGRectMake(0, 0, 28, 42)];
        annotationView.centerOffset = CGPointMake(0,-15);
        
        return annotationView;
    }
    
    if ([annotation conformsToProtocol:@protocol(LVThumbnailAnnotationProtocol)]) {
        
        return [((NSObject<LVThumbnailAnnotationProtocol> *)annotation) annotationViewInMap:_mapView];
    }
    
    return nil;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
    id <MKAnnotation> annotation = [view annotation];
    
    if ([annotation isKindOfClass:[LocationsAnnotation class]]) {
        LocationsAnnotation *locAnnotation = (LocationsAnnotation *)annotation;
        if (locAnnotation.calloutAccessoryAction)
            locAnnotation.calloutAccessoryAction(view);
    }else{
        return;
    }
}

@end
