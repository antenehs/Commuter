//
//  LineDetailViewController.h
//  
//
//  Created by Anteneh Sahledengel on 21/6/15.
//
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "Line.h"
#import "RettiDataManager.h"
#import "SettingsManager.h"
#import "StaticRoute.h"
#import "AMBlurView.h"
#import "JTMaterialSpinner.h"

@interface LineDetailViewController : UIViewController<MKMapViewDelegate, UITableViewDataSource, UITableViewDelegate>{
    IBOutlet MKMapView *routeMapView;
    
    CLLocationCoordinate2D upperBound;
    CLLocationCoordinate2D lowerBound;
    CLLocationCoordinate2D leftBound;
    CLLocationCoordinate2D rightBound;
    
    NSString *selectedAnnotionStopShortCode, *selectedAnnotionStopName;
    NSString *selectedAnnotionStopCode;
    CLLocationCoordinate2D selectedAnnotationStopCoords;
    
    IBOutlet UILabel *nameLabel;
    IBOutlet AMBlurView *tableViewContainerView;
    
    IBOutlet JTMaterialSpinner *activityIndicator;
    
    IBOutlet UITableView *stopsTableView;
    IBOutlet UILabel *stopsListHeaderLabel;
    IBOutlet UIView *titleSeparatorView;
    
    IBOutlet NSLayoutConstraint *tableViewTopSpacingConstraint;
    
    BOOL viewApearForTheFirstTime;
}

@property (strong, nonatomic) StaticRoute *staticRoute;

@property (strong, nonatomic) Line *line;
@property (strong, nonatomic) RettiDataManager *reittiDataManager;
@property (strong, nonatomic) SettingsManager *settingsManager;

@end
