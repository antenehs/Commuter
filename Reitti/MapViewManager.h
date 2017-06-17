//
//  MapPlottingViewController.h
//  Reitti
//
//  Created by Anteneh Sahledengel on 5/19/17.
//  Copyright © 2017 Anteneh Sahledengel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MapViewHelpers.h"
#import "ReittiModels.h"

@protocol MapViewManagerDelegate <NSObject>
@optional

- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated;
- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated;

@end

@interface MapViewManager : NSObject <MKMapViewDelegate> {
    MKMapRect previousRegion;
}

+(instancetype)managerForMapView:(MKMapView *)mapView;

//Remove Annotations
-(void)removeAllReittiAnotationsOfType:(ReittiAnnotationType)locationType;
-(void)removeAllReittiAnotationsExceptOfType:(ReittiAnnotationType)locationType;
-(void)removeAllAnotationsOfType:(Class)annotationType;
-(void)removeAllAnotationsExceptOfType:(Class)annotationType;

-(NSArray *)removeAllLocationAnotationsOfType:(ReittiAnnotationType)locationType notInCodeList:(NSArray *)codeList;

//specialized plots
-(void)plotVehicleAnnotations:(NSArray *)vehicleList;

-(void)plotOnlyNewAnnotations:(NSArray *)annotations forAnnotationType:(ReittiAnnotationType)locationType;
-(void)plotAnnotations:(NSArray *)annotations;
-(void)drawPolyline:(ReittiPolyline *)polyline;
-(void)drawPolyline:(ReittiPolyline *)polyline andAdjustToFit:(BOOL)adjustToFit;


//Helpers
+(double)getHeadingForDirectionFromCoordinate:(CLLocationCoordinate2D)fromLoc toCoordinate:(CLLocationCoordinate2D)toLoc;
+(MKCoordinateRegion)evaluateRegionToFitCoords:(CLLocationCoordinate2D *)coords andCount:(NSUInteger)count;

@property (nonatomic, weak) id<MapViewManagerDelegate> delegate;

@end
