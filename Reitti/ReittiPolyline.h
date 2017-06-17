//
//  ReittiPolyline.h
//  Reitti
//
//  Created by Anteneh Sahledengel on 6/15/17.
//  Copyright © 2017 Anteneh Sahledengel. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface ReittiPolyline : MKPolyline

@property(strong, nonatomic)UIColor *strokeColor;
@property(strong, nonatomic)NSArray *lineDashPattern;
@property(nonatomic)CGFloat lineWidth;

@property(nonatomic)const CLLocationCoordinate2D *coordinates;
@property(nonatomic)NSUInteger coordsCount;

@property(nonatomic)MKCoordinateRegion regionToFitPolyline;

//+(instancetype)reittiPolylineWithCoordinates:(const CLLocationCoordinate2D * _Nullable)coords count:(NSUInteger)count;

@end
