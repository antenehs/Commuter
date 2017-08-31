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
#import "MapViewManager.h"

@interface LineDetailViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>{
    
    CLLocationCoordinate2D upperBound;
    CLLocationCoordinate2D lowerBound;
    CLLocationCoordinate2D leftBound;
    CLLocationCoordinate2D rightBound;
    
    IBOutlet MKMapView *mapView;
    
    IBOutlet UILabel *nameLabel;
    IBOutlet AMBlurView *tableViewContainerView;
    
    IBOutlet JTMaterialSpinner *activityIndicator;
    
    IBOutlet UITableView *stopsTableView;
    IBOutlet UILabel *stopsListHeaderLabel;
    IBOutlet UIView *titleSeparatorView;
    
    IBOutlet NSLayoutConstraint *tableViewTopSpacingConstraint;
    
    BOOL viewApearForTheFirstTime;
    bool lineBookmarked;
}

@property (strong, nonatomic) StaticRoute *staticRoute;

@property (strong, nonatomic) Line *line;
@property (strong, nonatomic) SettingsManager *settingsManager;

@end
