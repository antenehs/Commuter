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
    ReittiPolyline *polyline = [Polyline reittiPolylineFromLocationArray:self.selectedPatternShapeCoordinates];
    polyline.strokeColor = [AppManager colorForLineType:self.lineType];
    polyline.polylineType = ReittiPolylineTypeLine;
    polyline.uniqueIdentifier = self.code;
    
    return polyline;
}

-(NSArray *)lineStopAnnotations {
    NSMutableArray *stopAnnotations = [@[] mutableCopy];
    
    if (!self.selectedPatternStops) return stopAnnotations;
    
    NSString *imageNameForStop = [AppManager stopAnnotationImageNameForStopType:[EnumManager stopTypeFromLegType:[EnumManager legTrasportTypeForLineType:self.lineType]]];
    
    for (LineStop *stop in self.selectedPatternStops) {
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
