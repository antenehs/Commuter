//
//  ReittiPolyline.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 6/15/17.
//  Copyright © 2017 Anteneh Sahledengel. All rights reserved.
//

#import "ReittiPolyline.h"
#import "ASA_Helpers.h"

@implementation ReittiPolyline

+(instancetype)polylineWithCoordinates:(const CLLocationCoordinate2D *)coords count:(NSUInteger)count {
    ReittiPolyline *polyline = [super polylineWithCoordinates:coords count:count];
    
    if (polyline) {
        polyline.coordinates = coords;
        polyline.coordsCount = count;
        polyline.regionToFitPolyline = [self evaluateRegionToFitCoords:coords andCount:count];
    }
    
    return polyline;
}

-(CGFloat)lineWidth {
    if (_lineWidth == 0) {
        _lineWidth = 4;
    }
    
    return _lineWidth;
}

+(MKCoordinateRegion)evaluateRegionToFitCoords:(const CLLocationCoordinate2D *)coords andCount:(NSUInteger)count {
    CLLocationCoordinate2D upperBound = {.latitude =  -90.0, .longitude =  0.0};;
    CLLocationCoordinate2D lowerBound = {.latitude =  90.0, .longitude =  0.0};
    CLLocationCoordinate2D leftBound = {.latitude =  0, .longitude =  180.0};
    CLLocationCoordinate2D rightBound = {.latitude =  0, .longitude =  -180.0};
    
    for (int i = 0; i < count; i++) {
        CLLocationCoordinate2D coord = coords[i];
        
        if (![ReittiMapkitHelper isValidCoordinate:coord])
            continue;
        
        if (coord.latitude > upperBound.latitude) {
            upperBound = coord;
        }
        if (coord.latitude < lowerBound.latitude) {
            lowerBound = coord;
        }
        if (coord.longitude > rightBound.longitude) {
            rightBound = coord;
        }
        if (coord.longitude < leftBound.longitude) {
            leftBound = coord;
        }
    }
    
    CLLocationCoordinate2D centerCoord = {.latitude =  (upperBound.latitude + lowerBound.latitude)/2, .longitude =  (leftBound.longitude + rightBound.longitude)/2};
    MKCoordinateSpan span = {.latitudeDelta =  upperBound.latitude - lowerBound.latitude, .longitudeDelta =  rightBound.longitude - leftBound.longitude };
    span.latitudeDelta += 0.3 * span.latitudeDelta;
    span.longitudeDelta += 0.3 * span.longitudeDelta;
    MKCoordinateRegion region = {centerCoord, span};
    
    return region;
}

@end
