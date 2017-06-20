//
//  RouteLeg+MapView.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 6/16/17.
//  Copyright © 2017 Anteneh Sahledengel. All rights reserved.
//

#import "RouteLeg+MapView.h"
#import "AppManager.h"
#import "SwiftHeaders.h"

@implementation RouteLeg (MapView)

-(ReittiPolyline *)mapPolyline {
    if (self.legShapeCoordLocations.count < 2) return nil;

    ReittiPolyline *polyline = [Polyline reittiPolylineFromLocationArray:self.legShapeCoordLocations];
    if (self.legType == LegTypeWalk) {
        polyline.strokeColor = [UIColor brownColor];
        polyline.lineDashPattern = @[@4, @10];
    }else{
        polyline.strokeColor = [AppManager colorForLegType:self.legType];
    }
    
    polyline.polylineType = ReittiPolylineTypeRouteLeg;
    polyline.uniqueIdentifier = self.legUniqueName;
    
    return polyline;
}

-(ReittiPolyline *)fullLinePolyline {
    if (!self.fullLineShapeLocations || self.fullLineShapeLocations.count < 2) return nil;
   
    ReittiPolyline *polyline = [Polyline reittiPolylineFromLocationArray:self.fullLineShapeLocations];
    if (self.legType == LegTypeWalk) { //Just in case
        polyline.strokeColor = [UIColor clearColor];
    }else{
        polyline.strokeColor = [[AppManager colorForLegType:self.legType] colorWithAlphaComponent:0.35];
        polyline.lineWidth = 2;
        
    }
    return polyline;
}

@end
