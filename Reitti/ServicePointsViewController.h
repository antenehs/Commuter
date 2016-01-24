//
//  ServicePointsViewController.h
//  
//
//  Created by Anteneh Sahledengel on 31/8/15.
//
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface ServicePointsViewController : UIViewController<MKMapViewDelegate, CLLocationManagerDelegate>{
    
    IBOutlet MKMapView *mainMapView;
    
    IBOutlet UIButton *currentLocationButton;
    CLLocationManager *locationManager;
    CLLocation * currentUserLocation;
    
    BOOL skipUserLocation;
    
    NSString *selectedToLocationName;
    NSString *selectedToLocationcoords;
    
}

@property(nonatomic, strong)NSArray *hslServicePoints;
@property(nonatomic, strong)NSArray *hslSalesPoints;

@end
