
//
//  RouteSearchViewController.h
//  Reitti
//
//  Created by Anteneh Sahledengel on 11/8/14.
//  Copyright (c) 2014 Anteneh Sahledengel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AMBlurView.h"
#import "ReittiShapeMaker.h"
#import "RettiDataManager.h"
#import "StopEntity.h"
#import "AddressSearchViewController.h"
#import "RouteSearchOptions.h"
#import "SettingsManager.h"
#import "RouteOptionsTableViewController.h"
#import "JTMaterialSpinner.h"
#import "BaseViewController.h"

@class RouteSearchViewController;

@protocol RouteSearchViewControllerDelegate <NSObject>
- (void)routeModified;
@end

@protocol RouteSearchViewControllerViewCycleDelegate <NSObject>
- (void)routeSearchViewControllerDismissed;
@end

@interface RouteSearchViewController : BaseViewController<UISearchBarDelegate, UITableViewDataSource,UITableViewDelegate,CLLocationManagerDelegate ,AddressSearchViewControllerDelegate,UIGestureRecognizerDelegate, RouteOptionSelectionDelegate, UIViewControllerPreviewingDelegate>{
    
    IBOutlet UISearchBar *fromSearchBar;
    IBOutlet UISearchBar *toSearchBar;
    IBOutlet UISearchBar *activeSearchBar;
    IBOutlet UIView *fromFieldBackView;
    IBOutlet UIView *toFieldBackView;
    IBOutlet UITextField *fromTextField;
    IBOutlet UITextField *toTextField;
    IBOutlet UIButton *bookmarkRouteButton;
    
    IBOutlet UIView *searchBarsView;
    IBOutlet UIActivityIndicatorView *searchActivityIndicator;
    IBOutlet JTMaterialSpinner *searchActivitySpinner;
    JTMaterialSpinner *loadingCellSpinner;
    IBOutlet AMBlurView *selectTimeButton;
    IBOutlet UILabel *selectedTimeLabel;
    IBOutlet UILabel *routeOptionsLable;
    
    UITableViewController *tableViewController;
    
    IBOutlet UITableView *routeResultsTableView;
    IBOutlet UIView *routeResultsTableContainerView;
    
    UIColor *systemBackgroundColor;
    UIColor *systemTextColor;
    UIColor *systemSubTextColor;
    
    NSString *fromString;
    NSString *fromCoords;
    
    NSString *toString;
    NSString *toCoords;
    
    NSString *currentLocationText;
    
    RouteSearchOptions *localRouteSearchOptions;
    
    NSTimer *tableLoadTimer;
    NSMutableArray *routeListCopy;
    int timerCallCount;
    BOOL tableReloadAnimatedMode;
    int tableRowNumberForAnimation;
    
    BOOL routeBookmarked;
    BOOL refreshingRouteTable;
    
    BOOL showTopLoadingView;
    
    BOOL nextRoutesRequested;
    BOOL prevRoutesRequested;
    BOOL pendingRequestCanceled;
    
    BOOL isShowingOptionsView;
    BOOL isSelectingAddress;
    
    BOOL toolBarIsShowing;
    
    NSMutableDictionary *lineDetailMap;
}
-(void)setUpMainView;
-(void)clearSearchResults;
-(void)searchRouteForFromLocation:(NSString *)fromLoc fromLocationCoords:(NSString *)fromCoordinates andToLocation:(NSString *)toLoc toLocationCoords:(NSString *)toCoordinates;

@property (strong, nonatomic) NSMutableArray * savedStops;
@property (strong, nonatomic) NSMutableArray * recentStops;
@property (strong, nonatomic) NSMutableArray * savedRoutes;
@property (strong, nonatomic) NSMutableArray * recentRoutes;
@property (strong, nonatomic) NSMutableArray * namedBookmarks;

@property (strong, nonatomic) NSMutableArray * dataToLoad;
@property (strong, nonatomic) NSMutableArray * routeList;
@property (nonatomic) bool darkMode;
@property (nonatomic) bool isRootViewController;

@property (strong, nonatomic) NSString * prevToLocation;
@property (strong, nonatomic) NSString * prevToCoords;

@property (strong, nonatomic) NSString * prevFromLocation;
@property (strong, nonatomic) NSString * prevFromCoords;

@property (strong, nonatomic) GeoCode * droppedPinGeoCode;

@property (nonatomic)ReittiApi useApi;

@property (strong, nonatomic) NSArray * disruptionsList;

@property (strong, nonatomic) NSNumber * modalViewControllerMode;

@property (strong, nonatomic) SettingsManager *settingsManager;
@property (strong, nonatomic) CLLocation * currentUserLocation;
@property (strong, nonatomic) CLLocationManager *locationManager;

@property (strong, nonatomic) UIRefreshControl *refreshControl;

@property (nonatomic, weak) id <RouteSearchViewControllerDelegate> delegate;
@property (nonatomic, weak) id <RouteSearchViewControllerViewCycleDelegate> viewCycledelegate;

@end
