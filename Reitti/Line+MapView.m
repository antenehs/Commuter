//
//  Line+MapView.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 6/15/17.
//  Copyright © 2017 Anteneh Sahledengel. All rights reserved.
//

#import "Line+MapView.h"
#import "LineStop+MapView.h"
#import "AppManager.h"
#import "MapViewManager.h"
#import "SwiftHeaders.h"

@implementation Line (MapView)

-(ReittiPolyline *)mapPolyline {
//    int shapeCount = (int)self.shapeCoordinates.count;
//    
//    // create an array of coordinates from allPins
//    CLLocationCoordinate2D coordinates[shapeCount];
//    int i = 0;
//    
//    for (CLLocation *location in self.shapeCoordinates) {
//        CLLocationCoordinate2D coord = location.coordinate;
//        coordinates[i] = coord;
//        i++;
//    }
    
    // create a polyline with all cooridnates
//    ReittiPolyline *polyline = [ReittiPolyline polylineWithCoordinates:coordinates count:shapeCount];
    ReittiPolyline *polyline = [Polyline reittiPolylineFromLocationArray:self.shapeCoordinates];
    polyline.strokeColor = [AppManager colorForLineType:self.lineType];
    
    return polyline;
}

-(NSArray *)lineStopAnnotations {
    NSMutableArray *stopAnnotations = [@[] mutableCopy];
    
    if (!self.lineStops) return stopAnnotations;
    
    NSString *imageNameForStop = [AppManager stopAnnotationImageNameForStopType:[EnumManager stopTypeFromLegType:[EnumManager legTrasportTypeForLineType:self.lineType]]];
    
    for (LineStop *stop in self.lineStops) {
        LocationsAnnotation *stopAnnot = (LocationsAnnotation *)stop.mapAnnotation;
        stopAnnot.imageNameForView = imageNameForStop;
        stopAnnot.annotIdentifier = [NSString stringWithFormat:@"LineStop-%@", imageNameForStop];
        stopAnnot.shrinksWhenZoomedOut = YES;
        stopAnnot.shrinkedImageColor = [AppManager colorForLineType:self.lineType];
        
        [stopAnnotations addObject:stopAnnot];
    }
    
    return stopAnnotations;
}

@end
