//
//  MapPlottingViewController.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 5/19/17.
//  Copyright © 2017 Anteneh Sahledengel. All rights reserved.
//

#import "MapViewManager.h"
#import "ASA_Helpers.h"
#import "AppManager.h"

#define degreesToRadians(x) (M_PI * x / 180.0)
#define radiansToDegrees(x) (x * 180.0 / M_PI)

@interface MapViewManager ()
@property (nonatomic, weak) MKMapView *mapView;
@property (nonatomic, strong) CLLocation *previousCircledLocation;

@property (nonatomic) NSUInteger mapZoomLevel;

@end

@implementation MapViewManager

+(instancetype)managerForMapView:(MKMapView *)mapView {
    MapViewManager *manager = [MapViewManager new];
    if (manager) {
        manager.mapView = mapView;
        mapView.delegate = manager;
        
        [manager updateZoomLevel];
    }
    
    return manager;
}

#pragma mark - Annotation Plotting
//This method should be called only once for an annotation type in a map
-(void)plotOnlyNewAnnotations:(NSArray *)annotations forAnnotationType:(ReittiAnnotationType)annotationType {
    if (!annotations) { return; }
    
    NSArray *codeList = [self collectReittiAnnotationUniqueCodesFromAnnotations:annotations];
    
    codeList = [self removeAllReittiAnotationsOfType:annotationType notInCodeList:codeList];
    
    NSArray *newAnnotations = [self collectReittiAnnotationForUniqueCodes:codeList fromAnnotations:annotations];
    
    [self plotAnnotations:newAnnotations];
}

-(void)plotAnnotations:(NSArray *)annotations {
    if (!annotations || annotations.count == 0) return;
    
    //Filter out annotations that should disappear for zoom level
    annotations = [self filterOutAnnotationsForZoomLevel:annotations];
    
    @try {
//        FIRCrashLog(@"Bike annotation name: %@ coord: %@,%@", station.name, station.lon, station.lat );
        [self.mapView removeAnnotations:annotations];
        [self.mapView addAnnotations:annotations];
    }
    @catch (NSException *exception) {
        NSLog(@"Adding annotations failed!!! Exception %@", exception);
    }
}

-(void)plotVehicleAnnotations:(NSArray *)vehicleList {
    
    NSMutableArray *codeList = [self collectVehicleCodes:vehicleList];
    NSMutableArray *annotToRemove = [[NSMutableArray alloc] init];
    NSMutableArray *existingVehicles = [[NSMutableArray alloc] init];
    
    for (id<MKAnnotation> annotation in self.mapView.annotations) {
        if ([annotation isKindOfClass:[LVThumbnailAnnotation class]]) {
            LVThumbnailAnnotation *annot = (LVThumbnailAnnotation *)annotation;
            
            if (![codeList containsObject:annot.code]) {
                [annotToRemove addObject:annotation];
            }else{
                [codeList removeObject:annot.code];
                [existingVehicles addObject:annotation];
            }
        }
    }
    
    for (id<MKAnnotation> annotation in existingVehicles) {
        if ([annotation isKindOfClass:[LVThumbnailAnnotation class]]) {
            LVThumbnailAnnotation *annot = (LVThumbnailAnnotation *)annotation;
            @try {
                Vehicle *updatedVehicle = [[self collectVehiclesForCodes:@[annot.code] fromVehicles:vehicleList] firstObject];
                
                if (updatedVehicle.bearing == -1 || updatedVehicle.bearing == 0) {
                    double bearing = [MapViewManager getHeadingForDirectionFromCoordinate:annot.coordinate toCoordinate:updatedVehicle.coords];
                    if (bearing != 0) {
                        updatedVehicle.bearing = bearing;
                        [annot updateVehicleImage:[AppManager vehicleImageForVehicleType:updatedVehicle.vehicleType]];
                    }else{
                        updatedVehicle.bearing = -1; //Do not update
                    }
                }
                
                if (updatedVehicle.bearing != -1) {
                    [((NSObject<LVThumbnailAnnotationProtocol> *)annot) updateBearing:[NSNumber numberWithDouble:updatedVehicle.bearing]];
                }
                
                annot.coordinate = updatedVehicle.coords;
            }
            @catch (NSException *exception) {
                NSLog(@"Failed to update annotation for vehicle with code: %@", annot.code);
                [annotToRemove addObject:annot];
                [codeList addObject:annot.code];
            }
        }
    }
    
    [self.mapView removeAnnotations:annotToRemove];
    
    NSArray *newVehicles = [self collectVehiclesForCodes:codeList fromVehicles:vehicleList];
    
    for (Vehicle *vehicle in newVehicles) {
        LVThumbnail *vehicleAnT = [[LVThumbnail alloc] init];
        //        vehicleAnT.image = [AppManager vehicleImageForVehicleType:vehicle.vehicleType];
        vehicleAnT.bearing = [NSNumber numberWithDouble:vehicle.bearing];
        vehicleAnT.image = [AppManager vehicleImageForVehicleType:vehicle.vehicleType];
        vehicleAnT.bearing = [NSNumber numberWithDouble:vehicle.bearing];
        if (vehicle.bearing != -1 ) {
            vehicleAnT.image = [AppManager vehicleImageForVehicleType:vehicle.vehicleType];
        }else{
            vehicleAnT.image = [AppManager vehicleImageWithNoBearingForVehicleType:vehicle.vehicleType];
        }
        vehicleAnT.code = vehicle.vehicleId;
        vehicleAnT.title = vehicle.vehicleName;
        vehicleAnT.lineId = vehicle.vehicleLineId;
        vehicleAnT.vehicleType = vehicle.vehicleType;
        vehicleAnT.coordinate = vehicle.coords;
        vehicleAnT.reuseIdentifier = [NSString stringWithFormat:@"reusableIdentifierFor%@", vehicle.vehicleId];
        vehicleAnT.associatedVehicle = vehicle;
        
        [self.mapView addAnnotation:[LVThumbnailAnnotation annotationWithThumbnail:vehicleAnT]];
    }
}

#pragma mark - Selection
-(void)selectReittiAnnotationWithUniqueId:(NSString *)uniqueId andType:(ReittiAnnotationType)annotationType {
    id annot = [self reittiAnnotationWithUniqueId:uniqueId andType:annotationType];
    if (annot) [self.mapView selectAnnotation:annot animated:YES];
}

#pragma mark - Annotation filter helpers
-(NSArray *)filterOutAnnotationsForZoomLevel:(NSArray *)annotations {
    NSMutableArray *filtered = [@[] mutableCopy];
    NSInteger currentZoomLevel = [self zoomLevel];
    for (id<MKAnnotation> annotation in annotations) {
        if ([annotation conformsToProtocol:@protocol(ReittiAnnotationProtocol)]) {
            if([(NSObject<ReittiAnnotationProtocol> *)annotation disappearsWhenZoomedOut]) {
                if (currentZoomLevel < [(NSObject<ReittiAnnotationProtocol> *)annotation disappearingZoomLevel]) {
                    [self.mapView removeAnnotation:annotation];
                } else {
                    [filtered addObject:annotation];
                }
            } else {
                [filtered addObject:annotation];
            }
        } else {
            [filtered addObject:annotation];
        }
    }
    
    return filtered;
}

-(void)removeReittiAnnotationWithUniqueId:(NSString *)uniqueId andType:(ReittiAnnotationType)annotationType {
    id annot = [self reittiAnnotationWithUniqueId:uniqueId andType:annotationType];
    if (annot) [self.mapView removeAnnotation:annot];
}

-(id<ReittiAnnotationProtocol>)reittiAnnotationWithUniqueId:(NSString *)uniqueId andType:(ReittiAnnotationType)annotationType {
    for (id<MKAnnotation> annotation in self.mapView.annotations) {
        if ([annotation conformsToProtocol:@protocol(ReittiAnnotationProtocol)]) {
            if ([(NSObject<ReittiAnnotationProtocol> *)annotation annotationType] == annotationType &&
                [[(NSObject<ReittiAnnotationProtocol> *)annotation uniqueIdentifier] isEqualToString:uniqueId]) {
                return (NSObject<ReittiAnnotationProtocol> *)annotation;
            }
        }
    }
    
    return nil;
}

-(void)removeAllReittiAnotationsOfType:(ReittiAnnotationType)annotationType {
    NSMutableArray *array = [@[] mutableCopy];
    for (id<MKAnnotation> annotation in self.mapView.annotations) {
        if ([annotation conformsToProtocol:@protocol(ReittiAnnotationProtocol)]) {
            if ([(NSObject<ReittiAnnotationProtocol> *)annotation annotationType] == annotationType) {
                [array addObject:annotation];
            }
        }
    }
    
    [self.mapView removeAnnotations:array];
}

-(void)removeAllReittiAnotationsExceptOfType:(ReittiAnnotationType)annotationType {
    NSMutableArray *array = [@[] mutableCopy];
    for (id<MKAnnotation> annotation in self.mapView.annotations) {
        if ([annotation conformsToProtocol:@protocol(ReittiAnnotationProtocol)]) {
            if ([(NSObject<ReittiAnnotationProtocol> *)annotation annotationType] != annotationType) {
                [array addObject:annotation];
            }
        }
    }
    
    [self.mapView removeAnnotations:array];
}

//Returns array of the not removed codes 12
-(NSArray *)removeAllReittiAnotationsOfType:(ReittiAnnotationType)annotationType notInCodeList:(NSArray *)codeList {
    NSMutableArray *array = [@[] mutableCopy];
    NSMutableArray *remainingCodes = [codeList mutableCopy];
    for (id<MKAnnotation> annotation in self.mapView.annotations) {
        if ([annotation conformsToProtocol:@protocol(ReittiAnnotationProtocol)]) {
            ReittiAnnotationType existingType = [(NSObject<ReittiAnnotationProtocol> *)annotation annotationType];
            if (![EnumManager isAnnotationType:existingType sameAsAnnotaionType:annotationType]) continue;
            
            NSString *annotIdentifier = [(NSObject<ReittiAnnotationProtocol> *)annotation uniqueIdentifier];
            if (![codeList containsObject:annotIdentifier]) {
                //Remove stop if it doesn't exist in the new list
                [array addObject:annotation];
            }else{
                [remainingCodes removeObject:annotIdentifier];
            }
        }
    }
    
    [self.mapView removeAnnotations:array];
    
    return remainingCodes;
}

-(void)removeAllAnotationsOfType:(Class)annotationType {
    [self.mapView removeAnnotations:[self getAllAnnotationsOfType:annotationType]];
}

-(void)removeAllAnotationsExceptOfType:(Class)annotationType {
    [self.mapView removeAnnotations:[self getAllAnnotationsExceptOfType:annotationType]];
}

-(NSArray *)getAllAnnotationsOfType:(Class)annotationType {
    NSMutableArray *array = [@[] mutableCopy];
    for (id<MKAnnotation> annotation in self.mapView.annotations) {
        if ([annotation isKindOfClass:annotationType]) {
            [array addObject:annotation];
        }
    }
    
    return array;
}

-(NSArray *)getAllAnnotationsExceptOfType:(Class)annotationType {
    NSMutableArray *array = [@[] mutableCopy];
    for (id<MKAnnotation> annotation in self.mapView.annotations) {
        if (![annotation isKindOfClass:annotationType]) {
            [array addObject:annotation];
        }
    }
    
    return array;
}

-(NSArray *)getAllShrinkableAndDisapearingAnnotations {
    NSMutableArray *annots = [[NSMutableArray alloc] init];
    
    for (id<MKAnnotation> annotation in self.mapView.annotations) {
        if ([annotation conformsToProtocol:@protocol(ReittiAnnotationProtocol)]) {
            if ([(NSObject<ReittiAnnotationProtocol> *)annotation shrinksWhenZoomedOut] ||
                [(NSObject<ReittiAnnotationProtocol> *)annotation disappearsWhenZoomedOut])
                [annots addObject:annotation];
        }
    }
    
    return annots;
}

-(NSMutableArray *)collectVehicleCodes:(NSArray *)vehicleList {
    NSMutableArray *codeList = [[NSMutableArray alloc] init];
    
    for (Vehicle *vehicle in vehicleList) {
        [codeList addObject:vehicle.vehicleId];
    }
    return codeList;
}

-(NSArray *)collectVehiclesForCodes:(NSArray *)codeList fromVehicles:(NSArray *)vehicleList {
    return [vehicleList filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"%@ containsObject:self.vehicleId",codeList ]];
}

-(NSArray *)collectReittiAnnotationUniqueCodesFromAnnotations:(NSArray *)anotations {
    NSMutableArray *codeList = [[NSMutableArray alloc] init];
    
    for (id<MKAnnotation> annotation in anotations) {
        if ([annotation conformsToProtocol:@protocol(ReittiAnnotationProtocol)]) {
            NSString *uniqueIdentifier = [(NSObject<ReittiAnnotationProtocol> *)annotation uniqueIdentifier];
            if (!uniqueIdentifier) continue;
            [codeList addObject:uniqueIdentifier];
        }
    }
    
    return codeList;
}

-(NSArray *)collectReittiAnnotationForUniqueCodes:(NSArray *)codeList fromAnnotations:(NSArray *)annotations {
    return [annotations filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"%@ containsObject:self.uniqueIdentifier", codeList]];
}

#pragma mark - Line Drawing
-(void)drawPolylineForObject:(id<MapViewPolylineProtocol>)drawableObject {
    [self drawPolylineForObject:drawableObject andAdjustToFit:NO];
}

-(void)drawPolylineForObject:(id<MapViewPolylineProtocol>)drawableObject andAdjustToFit:(BOOL)adjustToFit {
    if ([drawableObject conformsToProtocol:@protocol(MapViewPolylineProtocol)]) {
        id polyline = (ReittiPolyline *)[drawableObject mapPolyline];
        [self drawPolyline:polyline andAdjustToFit:adjustToFit];
    }
}

-(void)drawPolyline:(ReittiPolyline *)polyline {
    [self drawPolyline:polyline andAdjustToFit:NO];
}

-(void)drawPolyline:(ReittiPolyline *)polyline andAdjustToFit:(BOOL)adjustToFit {
    if (!polyline) return;
    
    [self removeAllOverlaysForUniqId:polyline.uniqueIdentifier andType:polyline.polylineType];
    
    [self.mapView addOverlay:polyline];
    
    if (adjustToFit) {
        MKCoordinateRegion region = polyline.regionToFitPolyline;
        
        if ([ReittiMapkitHelper isValidCoordinate:region.center])
            [self.mapView setRegion:region animated:YES];
    }
}

-(void)drawFiveMinWalkingCircleAtCoordinate:(CLLocation *)center {
    if ([self zoomLevel] < 14) return;
    
    if (self.previousCircledLocation) {
        CLLocationDistance distance = [center distanceFromLocation:self.previousCircledLocation];
        if (distance < 20) return;
    }
    
    [self removeFiveMinWalkingCircle];
    
    //Add circle overlay
    MKCircle *circle = [MKCircle circleWithCenterCoordinate:center.coordinate radius:400];
    [self.mapView addOverlay:circle];
    
    //Add label annotation
    MKCoordinateRegion coordRegion = MKCoordinateRegionForMapRect(circle.boundingMapRect);
    double annotLat = center.coordinate.latitude + coordRegion.span.latitudeDelta/2;
    CLLocationCoordinate2D annotCoord = CLLocationCoordinate2DMake(annotLat, center.coordinate.longitude);
    
    LocationsAnnotation *annot = [[LocationsAnnotation alloc] initWithTitle:nil andSubtitle:@"5 min walking radius" andCoordinate:annotCoord andLocationType:FiveMinMarkerAnnotationType];
    annot.imageNameForView = @"5minAnnot";
    annot.preferedSize = CGSizeMake(24, 30);
    
    [self.mapView addAnnotation:annot];
    
    self.previousCircledLocation = center;
}


#pragma mark - Polyline filtering
-(void)removeFiveMinWalkingCircle {
    [self removeAllCircleOverlays];
    [self removeAllReittiAnotationsOfType:FiveMinMarkerAnnotationType];
    
    self.previousCircledLocation = nil;
}

-(void)removeAllOverlaysOfType:(ReittiPolylineType)polylineType {
    for (id<MKOverlay> overlay in self.mapView.overlays) {
        if ([overlay isKindOfClass:[ReittiPolyline class]] &&
            [(ReittiPolyline *)overlay polylineType] == polylineType) {
            
            [self.mapView removeOverlay:overlay];
        }
    }
}

-(void)removeAllOverlaysForUniqId:(NSString *)uniqueId andType:(ReittiPolylineType)polylineType {
    for (id<MKOverlay> overlay in self.mapView.overlays) {
        if ([overlay isKindOfClass:[ReittiPolyline class]] &&
            [(ReittiPolyline *)overlay polylineType] == polylineType &&
            [[(ReittiPolyline *)overlay uniqueIdentifier] isEqualToString:uniqueId]) {
            
            [self.mapView removeOverlay:overlay];
        }
    }
}

-(void)removeAllCircleOverlays {
    for (id<MKOverlay> overlay in self.mapView.overlays) {
        if ([overlay isKindOfClass:[MKCircle class]]) {
            [self.mapView removeOverlay:overlay];
        }
    }
}

#pragma mark - Map Delegates
-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
    if ([annotation conformsToProtocol:@protocol(ReittiAnnotationProtocol)]) {
        return [((NSObject<ReittiAnnotationProtocol> *)annotation) annotationViewInMap:mapView];
    }
    
//    if ([annotation conformsToProtocol:@protocol(ReittiAnnotationProtocol)]) {
//        return [((NSObject<ReittiAnnotationProtocol> *)annotation) annotationViewInMap:mapView];
//    }
    
    if ([annotation conformsToProtocol:@protocol(GCThumbnailAnnotationProtocol)]) {
        return [((NSObject<GCThumbnailAnnotationProtocol> *)annotation) annotationViewInMap:mapView];
    }
    
    return nil;
}

-(MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay{
    
    if ([overlay isKindOfClass:[MKPolyline class]]) {
        MKPolylineRenderer *polylineRenderer = [[MKPolylineRenderer alloc] initWithOverlay:(MKPolyline *)overlay];
        polylineRenderer.lineWidth	  = 4.0f;
        polylineRenderer.lineJoin	  = kCGLineJoinRound;
        polylineRenderer.lineCap	  = kCGLineCapRound;
        
        polylineRenderer.alpha = 1.0;
        if ([overlay isKindOfClass:[ReittiPolyline class]]) {
            ReittiPolyline *reittiPolyline = (ReittiPolyline *)overlay;
            polylineRenderer.lineWidth	  = reittiPolyline.lineWidth;
            polylineRenderer.strokeColor = reittiPolyline.strokeColor;
            polylineRenderer.lineDashPattern = reittiPolyline.lineDashPattern;
        }
        
        return polylineRenderer;
    } else if ([overlay isKindOfClass:[MKCircle class]]) {
        MKCircleRenderer *circleView = [[MKCircleRenderer alloc] initWithOverlay:overlay];
        circleView.lineWidth = 2;
        circleView.strokeColor = [[UIColor grayColor] colorWithAlphaComponent:0.7];
        circleView.fillColor = [[UIColor greenColor] colorWithAlphaComponent:0.03];
        return circleView;
    } else {
        return nil;
    }
}

-(void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
    
    if ([view.annotation conformsToProtocol:@protocol(ReittiActionableAnnotationProtocol)]) {
        AnnotationActionBlock calloutAccessoryAction = [((NSObject<ReittiActionableAnnotationProtocol> *)view.annotation) primaryAccessoryAction];
        if (calloutAccessoryAction)
            calloutAccessoryAction(view);
    }
}

-(void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray<MKAnnotationView *> *)views {
    if ([self.delegate respondsToSelector:@selector(mapView:didAddAnnotationViews:)]) {
        [self.delegate mapView:self.mapView didAddAnnotationViews:views];
    }
}

-(void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated {
    if (self.ignoreRegionChange)
        return;
    
    previousRegion = mapView.visibleMapRect;
    
    if ([self.delegate respondsToSelector:@selector(mapView:regionWillChangeAnimated:)]) {
        [self.delegate mapView:self.mapView regionWillChangeAnimated:animated];
    }
}

-(void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    [self updateZoomLevel];
    
    if (self.ignoreRegionChange){
        self.ignoreRegionChange = NO;
        return;
    }
    
    if ([self zoomLevel] != [self zoomLevelForMapRect:previousRegion withMapViewSizeInPixels:mapView.bounds.size]) {
        //Zoom level changed. Force update. Do it only for stationary annotations
        NSArray *allAnnotations = [self getAllShrinkableAndDisapearingAnnotations];
        [self.mapView removeAnnotations:allAnnotations];
        [self plotAnnotations:allAnnotations];
        
        //Remove circle overlay
        if ([self zoomLevel] < 14) {
            [self removeAllCircleOverlays];
            [self removeAllReittiAnotationsOfType:FiveMinMarkerAnnotationType];
            self.previousCircledLocation = nil;
        }
    }
    
    if ([self.delegate respondsToSelector:@selector(mapView:regionDidChangeAnimated:)]) {
        [self.delegate mapView:self.mapView regionDidChangeAnimated:animated];
    }
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
    if ([view conformsToProtocol:@protocol(DetailAnnotationViewProtocol)]) {
        self.ignoreRegionChange = YES;
        
        [((NSObject<DetailAnnotationViewProtocol> *)view) didSelectAnnotationViewInMap:mapView];
    }
    
    if ([view conformsToProtocol:@protocol(GCThumbnailAnnotationViewProtocol)]) {
        [((NSObject<GCThumbnailAnnotationViewProtocol> *)view) didSelectAnnotationViewInMap:mapView];
    }
    
    if ([view conformsToProtocol:@protocol(LVThumbnailAnnotationViewProtocol)]) {
        //Do nothing just yet
    }
    
    if ([self.delegate respondsToSelector:@selector(mapView:didSelectAnnotationView:)]) {
        [self.delegate mapView:self.mapView didSelectAnnotationView:view];
    }
    
    view.layer.zPosition = 0;
}

- (void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view {
    if ([view conformsToProtocol:@protocol(JPSThumbnailAnnotationViewProtocol)]) {
        [((NSObject<JPSThumbnailAnnotationViewProtocol> *)view) didDeselectAnnotationViewInMap:mapView];
        NSAssert(false, @"This should not be used anymore");
    }
    
    if ([view conformsToProtocol:@protocol(DetailAnnotationViewProtocol)]) {
        [((NSObject<DetailAnnotationViewProtocol> *)view) didDeselectAnnotationViewInMap:mapView];
    }
    
    if ([view conformsToProtocol:@protocol(GCThumbnailAnnotationViewProtocol)]) {
        [((NSObject<GCThumbnailAnnotationViewProtocol> *)view) didDeselectAnnotationViewInMap:mapView];
    }
    
    if ([self.delegate respondsToSelector:@selector(mapView:didDeselectAnnotationView:)]) {
        [self.delegate mapView:self.mapView didDeselectAnnotationView:view];
    }
    
    view.layer.zPosition = -1;
}

- (void)mapViewDidFinishLoadingMap:(MKMapView *)mapView {
    if ([self.delegate respondsToSelector:@selector(mapViewDidFinishLoadingMap:)]) {
        [self.delegate mapViewDidFinishLoadingMap:mapView];
    }
}


#pragma mark - Helpers
-(void)updateZoomLevel {
    self.mapZoomLevel = [self zoomLevelForMapRect:self.mapView.visibleMapRect withMapViewSizeInPixels:self.mapView.bounds.size];
}

-(NSUInteger)zoomLevel {
    return self.mapZoomLevel;
}

//Zoom level goes from 1 (the world) to 20 (zoomed innnn)
-(NSUInteger)zoomLevelForMapRect:(MKMapRect)mRect withMapViewSizeInPixels:(CGSize)viewSizeInPixels {
    NSUInteger zoomLevel = 20; // MAXIMUM_ZOOM is 20 with MapKit
    MKZoomScale zoomScale = mRect.size.width / viewSizeInPixels.width; //MKZoomScale is just a CGFloat typedef
    double zoomExponent = log2(zoomScale);
    zoomLevel = (NSUInteger)(20 - ceil(zoomExponent));
    return zoomLevel;
}

+(double)getHeadingForDirectionFromCoordinate:(CLLocationCoordinate2D)fromLoc toCoordinate:(CLLocationCoordinate2D)toLoc {
    double fLat = degreesToRadians(fromLoc.latitude);
    double fLng = degreesToRadians(fromLoc.longitude);
    double tLat = degreesToRadians(toLoc.latitude);
    double tLng = degreesToRadians(toLoc.longitude);
    
    double degree = radiansToDegrees(atan2(sin(tLng-fLng)*cos(tLat), cos(fLat)*sin(tLat)-sin(fLat)*cos(tLat)*cos(tLng-fLng)));
    
    if (degree >= 0) {
        return degree;
    } else {
        return 360+degree;
    }
}

+(MKCoordinateRegion)evaluateRegionToFitCoords:(CLLocationCoordinate2D *)coords andCount:(NSUInteger)count {
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
