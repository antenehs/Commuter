//
//  ReittiPolyline.h
//  Reitti
//
//  Created by Anteneh Sahledengel on 6/15/17.
//  Copyright © 2017 Anteneh Sahledengel. All rights reserved.
//

#import <MapKit/MapKit.h>

typedef enum {
    ReittiPolylineTypeUnknown = 0,
    ReittiPolylineTypeRouteLeg = 1,
    ReittiPolylineTypeLine =2,
    ReittiPolylineTypeWalkableRadius = 3
} ReittiPolylineType;

@interface ReittiPolyline : MKPolyline

@property(strong, nonatomic)NSString *uniqueIdentifier;
@property(strong, nonatomic)UIColor *strokeColor;
@property(strong, nonatomic)NSArray *lineDashPattern;
@property(nonatomic)CGFloat lineWidth;

@property(nonatomic)ReittiPolylineType polylineType;

@property(nonatomic)const CLLocationCoordinate2D *coordinates;
@property(nonatomic)NSUInteger coordsCount;

@property(nonatomic)MKCoordinateRegion regionToFitPolyline;

@end
