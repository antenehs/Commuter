
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
#import "RoutePreviewView.h"
#import "RettiDataManager.h"
#import "StopEntity.h"
#import "HistoryEntity.h"
#import "AddressSearchViewController.h"
#import "RouteSearchOptions.h"
#import "RouteOptionsTableViewController.h"

@class RouteSearchViewController;

@protocol RouteSearchViewControllerDelegate <NSObject>
- (void)routeModified;
@end

@protocol RouteSearchViewControllerViewCycleDelegate <NSObject>
- (void)routeSearchViewControllerDismissed;
@end

@interface RouteSearchViewController : UIViewController<UISearchBarDelegate, UITableViewDataSource,UITableViewDelegate,CLLocationManagerDelegate,UIActionSheetDelegate, RettiRouteSearchDelegate,AddressSearchViewControllerDelegate,UIGestureRecognizerDelegate, RouteOptionSelectionDelegate>{
    
    IBOutlet UISearchBar *fromSearchBar;
    IBOutlet UISearchBar *toSearchBar;
    IBOutlet UISearchBar *activeSearchBar;
    IBOutlet UIView *fromFieldBackView;
    IBOutlet UIView *toFieldBackView;
    IBOutlet UITextField *fromTextField;
    IBOutlet UITextField *toTextField;
    IBOutlet UIButton *bookmarkRouteButton;
    
    IBOutlet UIView *searchBarsView;
    IBOutlet UITableView *searchSuggestionsTableView;
    IBOutlet UIActivityIndicatorView *searchActivityIndicator;
    IBOutlet AMBlurView *timeSelectionView;
    IBOutlet UISegmentedControl *timeTypeSegmentControl;
    IBOutlet UIDatePicker *datePicker;
    IBOutlet AMBlurView *selectTimeButton;
    IBOutlet UILabel *selectedTimeLabel;
    IBOutlet UIView *timeSelectionViewShadeView;
    UITapGestureRecognizer *timeSelectionShadeTapGestureRecognizer;
    
    IBOutlet AMBlurView *searchOptionSelectionView;
    IBOutlet UISegmentedControl *searchOptionSegmentControl;
    
    IBOutlet UIScrollView *searchResultScroller;
    IBOutlet UIButton *loadMoreButton;
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
    
    SelectedTimeType selectedTimeType;
    NSDate *selectedTime;
    NSString *selectedTimeString;
    NSString *selectedDateString;
    
    NSTimer *tableLoadTimer;
    NSMutableArray *routeListCopy;
    int timerCallCount;
    BOOL tableReloadAnimatedMode;
    int tableRowNumberForAnimation;
    
    RouteSearchOption selectedSearchOption;
    
    BOOL routeBookmarked;
    BOOL refreshingRouteTable;
    
    BOOL nextRoutesRequested;
    BOOL prevRoutesRequested;
    
    BOOL toolBarIsShowing;
    
}

@property (strong, nonatomic) NSMutableArray * savedStops;
@property (strong, nonatomic) NSMutableArray * recentStops;

@property (strong, nonatomic) NSMutableArray * dataToLoad;
@property (strong, nonatomic) NSMutableArray * routeList;
@property (nonatomic) bool darkMode;

@property (strong, nonatomic) NSString * prevToLocation;
@property (strong, nonatomic) NSString * prevToCoords;

@property (strong, nonatomic) NSString * prevFromLocation;
@property (strong, nonatomic) NSString * prevFromCoords;

@property (strong, nonatomic) RettiDataManager *reittiDataManager;
@property (strong, nonatomic) CLLocation * currentUserLocation;
@property (strong, nonatomic) CLLocationManager *locationManager;

@property (strong, nonatomic) UIRefreshControl *refreshControl;

@property (nonatomic, weak) id <RouteSearchViewControllerDelegate> delegate;
@property (nonatomic, weak) id <RouteSearchViewControllerViewCycleDelegate> viewCycledelegate;

@end
