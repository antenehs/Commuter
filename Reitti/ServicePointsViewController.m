//
//  ServicePointsViewController.m
//  
//
//  Created by Anteneh Sahledengel on 31/8/15.
//
//

#import "ServicePointsViewController.h"
#import "HSLServicePointManager.h"
#import "ServicePointAnnotation.h"
#import "AppManager.h"
#import "RouteSearchViewController.h"
#import "ReittiStringFormatter.h"

@interface ServicePointsViewController ()

@end

@implementation ServicePointsViewController

@synthesize hslSalesPoints, hslServicePoints;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    skipUserLocation = YES;
    
    self.title = @"SALES POINTS";
    
    [self initializeMapView];
    self.hslServicePoints = [HSLServicePointManager getServicePoints];
    self.hslSalesPoints = [HSLServicePointManager getSalesPoints];
    
    [self plotSalesPointAnnotations];
    
    currentLocationButton.layer.cornerRadius = 4.0;
    currentLocationButton.layer.borderWidth = 0.5;
    currentLocationButton.layer.borderColor = [UIColor lightGrayColor].CGColor;
    
    selectedToLocationcoords = selectedToLocationName = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - map view methods
- (void)initializeMapView
{
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.distanceFilter = kCLDistanceFilterNone;
    locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
    [locationManager requestWhenInUseAuthorization];
    [locationManager startUpdatingLocation];
    
    mainMapView.delegate = self;
    
    CLLocationCoordinate2D coord = {.latitude =  60.1733239, .longitude =  24.9410248};
    [self centerMapRegionToCoordinate:coord];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
     CLLocation *newLocation = [locations lastObject];
    
    if (currentUserLocation == nil && !skipUserLocation) {
        currentUserLocation = newLocation;
        [self centerMapRegionToCoordinate:currentUserLocation.coordinate];
        return;
    }
    
    skipUserLocation = NO;

//    CLLocationDistance dist = [currentUserLocation distanceFromLocation:newLocation];
//    if (dist > 10) {
//        currentUserLocation = newLocation;
//        [self centerMapRegionToCoordinate:currentUserLocation.coordinate];
//    }
}

-(BOOL)isLocationServiceAvailableWithNotification:(BOOL)notify{
    BOOL accessGranted = [CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse;
    NSLog(@"%d",[CLLocationManager authorizationStatus]);
    BOOL locationServicesEnabled = [CLLocationManager locationServicesEnabled];
    
    if (!locationServicesEnabled) {
        if (notify) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Uh-Oh"
                                                                message:@"Looks like location services is not enabled. Enable it from Settings/Privacy/Location Services to get nearby stops suggestions."
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
            [alertView show];
        }
        
        return NO;
    }
    
    if (!accessGranted) {
        if (notify) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Uh-Oh"
                                                                message:@"Looks like access is not granted to this app for location services. Grant access from Settings/Privacy/Location Services to get nearby stops suggestions."
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
            [alertView show];
        }
        
        return NO;
    }
    
    return YES;
}

-(BOOL)centerMapRegionToCoordinate:(CLLocationCoordinate2D)coord{
    
    if (!CLLocationCoordinate2DIsValid(coord) || coord.latitude == 0) {
        return NO;
    }
    
    MKCoordinateSpan span = {.latitudeDelta =  0.01, .longitudeDelta =  0.01};
    MKCoordinateRegion region = {coord, span};
    
    [mainMapView setRegion:region animated:YES];
    
    return YES;
}

-(void)plotSalesPointAnnotations{
    for (id<MKAnnotation> annotation in mainMapView.annotations) {
        if ([annotation isKindOfClass:[ServicePointAnnotation class]]) {
            [mainMapView removeAnnotation:annotation];
        }
    }
    
    for (ServicePoint *servicePoint in self.hslSalesPoints) {
        NSString * title = servicePoint.title;
        NSString * subTitle = servicePoint.address;
        CLLocationCoordinate2D coords = servicePoint.coordinates;
        
        ServicePointAnnotation *newAnnotation = [[ServicePointAnnotation alloc] initWithTitle:title andSubtitle:subTitle andCoordinate:coords andAnnotationType:SalesPointAnnotationType];
        newAnnotation.imageNameForView = @"salesPointAnnotation";
        newAnnotation.annotIdentifier = @"salesPointAnnotation";
        
        [mainMapView addAnnotation:newAnnotation];
    }
    
    for (ServicePoint *servicePoint in self.hslServicePoints) {
        NSString * title = servicePoint.title;
        NSString * subTitle = servicePoint.address;
        CLLocationCoordinate2D coords = servicePoint.coordinates;
        
        ServicePointAnnotation *newAnnotation = [[ServicePointAnnotation alloc] initWithTitle:title andSubtitle:subTitle andCoordinate:coords andAnnotationType:ServicePointAnnotationType];
        newAnnotation.imageNameForView = @"servicePointAnnotation";
        newAnnotation.annotIdentifier = @"servicePointAnnotation";
        
        [mainMapView addAnnotation:newAnnotation];
    }
}

- (MKAnnotationView *)mapView:(MKMapView *)_mapView viewForAnnotation:(id <MKAnnotation>)annotation {
//    static NSString *selectedIdentifier = @"selectedLocation";
    if ([annotation isKindOfClass:[ServicePointAnnotation class]]) {
        ServicePointAnnotation *spAnnotation = (ServicePointAnnotation *)annotation;
        
        MKAnnotationView *annotationView = (MKAnnotationView *) [_mapView dequeueReusableAnnotationViewWithIdentifier:spAnnotation.annotIdentifier];
        if (annotationView == nil) {
            annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:spAnnotation.annotIdentifier];
            annotationView.enabled = YES;
            annotationView.canShowCallout = YES;
            
            NSString *imageName = spAnnotation.imageNameForView;
            annotationView.image = [UIImage imageNamed:imageName];
            
            UIButton *leftCalloutButton = [UIButton buttonWithType:UIButtonTypeCustom];
            leftCalloutButton.frame = CGRectMake(0, 0, 55, 55);
            [leftCalloutButton setImage:[UIImage imageNamed:@"goTolocation.png"] forState:UIControlStateNormal];
            leftCalloutButton.tintColor = [AppManager systemGreenColor];
            
            annotationView.leftCalloutAccessoryView = leftCalloutButton;
            
            [annotationView setFrame:CGRectMake(0, 0, 30, 32)];
            annotationView.centerOffset = CGPointMake(0,-15);
            
        } else {
            annotationView.annotation = annotation;
        }
        
        return annotationView;
    }
    
    return nil;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    id <MKAnnotation> annotation = [view annotation];
    if ([annotation isKindOfClass:[ServicePointAnnotation class]])
    {
        ServicePointAnnotation *spAnnotation = (ServicePointAnnotation *)annotation;
        MKPlacemark *placemark = [[MKPlacemark alloc] initWithCoordinate:spAnnotation.coordinate addressDictionary:nil];
        
        selectedToLocationName = spAnnotation.title;
        selectedToLocationcoords = [ReittiStringFormatter convert2DCoordToString:placemark.coordinate];
        
        [self performSegueWithIdentifier:@"showDirectionsToServicePoint" sender:self];
        
//        MKMapItem *mapItem = [[MKMapItem alloc] initWithPlacemark:placemark];
//        [mapItem setName:spAnnotation.title];
//        
//        [self launchMapsAppForDirectionTo:mapItem];
    }
}

- (void)launchMapsAppForDirectionTo:(MKMapItem *)from{
//    [from openInMapsWithLaunchOptions:nil];
    [MKMapItem openMapsWithItems:[NSArray arrayWithObject:from]
                   launchOptions:[NSDictionary dictionaryWithObjectsAndKeys:
                                  MKLaunchOptionsDirectionsModeWalking, MKLaunchOptionsDirectionsModeKey, nil]];
}

#pragma mark - IB Actions
- (IBAction)currentLocationButtonTapped:(id)sender {
    if (![self isLocationServiceAvailableWithNotification:YES])
        return;
    
    if (mainMapView.userLocation.location != nil) {
        [self centerMapRegionToCoordinate:mainMapView.userLocation.location.coordinate];
    }
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showDirectionsToServicePoint"]) {
        UINavigationController *navigationController = (UINavigationController *)segue.destinationViewController;
        RouteSearchViewController *routeSearchViewController = [[navigationController viewControllers] lastObject];
        
        routeSearchViewController.prevToLocation = selectedToLocationName;
        routeSearchViewController.prevToCoords = selectedToLocationcoords;
        
//        routeSearchViewController.delegate = self;
//        routeSearchViewController.managedObjectContext = self.reittiDataManager.managedObjectContext;
    }
}


@end
