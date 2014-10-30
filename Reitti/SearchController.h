//
//  SearchController.h
//  Reitti
//
//  Created by Anteneh Sahledengel on 15/1/14.
//  Copyright (c) 2014 Anteneh Sahledengel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <MessageUI/MessageUI.h>
#import <EventKit/EventKit.h>
#import "AMBlurView.h"
#import "StopViewController.h"
#import "AddressSearchViewController.h"
#import "RettiDataManager.h"
#import "StopAnnotation.h"
#import "GeoCodeAnnotation.h"
#import "GeoCode.h"
#import "BusStopShort.h"
#import "MBProgressHUD.h"
#import "BusStop.h"
#import "ReittiStringFormatter.h"
#import "BookmarksViewController.h"
#import "WebViewController.h"
#import "SWTableViewCell.h"
#import "CustomeTableViewCell.h"
#import "CommandView.h"
#import "CustomBadge.h"

typedef enum
{
    RNotificationTypeInfo = 1,
    RNotificationTypeConfirmation = 2,
    RNotificationTypeWarning = 3,
    RNotificationTypeError = 4
} RNotificationType;

typedef enum
{
    RSearchResultViewModeSearchResults = 1,
    RSearchResultViewModeNearByStops = 2
} RSearchResultViewMode;

@interface SearchController : UIViewController<RettiDataManagerDelegate, ReittiDisruptionFetchDelegate, UISearchBarDelegate, CLLocationManagerDelegate, MKMapViewDelegate, UITableViewDataSource,UITableViewDelegate,UIActionSheetDelegate, UIAlertViewDelegate, MFMailComposeViewControllerDelegate, UIGestureRecognizerDelegate, BookmarksViewControllerDelegate, SWTableViewCellDelegate,AddressSearchViewControllerDelegate>{
    IBOutlet AMBlurView *blurView;
    IBOutlet AMBlurView *commandView;
    IBOutlet MKMapView *mapView;
    IBOutlet UISegmentedControl *searchTypeSegmentControl;
    IBOutlet UIButton *hideSearchViewButton;
    IBOutlet UISearchBar *fromSearchBar;
    IBOutlet UISearchBar *toSearchBar;
    IBOutlet UISearchBar *stopSearchBar;
    IBOutlet UISearchBar *mainSearchBar;
    IBOutlet UIButton *exchangeButton;
    IBOutlet UISegmentedControl *timeSegmentControl;
    IBOutlet UIDatePicker *datePicker;
    IBOutlet UILabel *showSearchViewLabel;
    IBOutlet UIImageView *shadowImageView;
    IBOutlet UIToolbar *mainToolBar;
    IBOutlet UIButton *currentLocationButton;
    IBOutlet UILabel *appTitileLable;
    IBOutlet UIButton *bookmarksButton;
    IBOutlet UIButton *infoAndAboutButton;
    IBOutlet UIButton *sendEmailButton;
    IBOutlet UIButton *listNearbyStops;
    
    UIColor *systemBackgroundColor;
    UIColor *systemTextColor;
    UIColor *systemSubTextColor;
    
    //toolbar
    IBOutlet UIToolbar *toolBar;
    IBOutlet UIBarButtonItem *reloadBarButtonItem;
    IBOutlet UIBarButtonItem *savedStopsBarButtonItem;
    IBOutlet UIBarButtonItem *backBarButtonItem;
    IBOutlet UIBarButtonItem *forwardBarButtonItem;
    
    //Stop view
    IBOutlet UILabel *stopCodeLabel;
    IBOutlet UILabel *stopNameLabel;
    IBOutlet UILabel *cityNameLabel;
    IBOutlet UITableView *departuresTable;
    IBOutlet UIButton *addBookmarkButton;
    
    //Multiple searchs view
    IBOutlet UITableView *searchResultsTable;
    IBOutlet UILabel *searchResultsLabel;
    IBOutlet UIButton *hideSearchResultViewButton;
        
    //notification view
    IBOutlet UIImageView *notificationImageView;
    IBOutlet UILabel *notificationMessageLabel;
    
    //Command View
    IBOutlet UILabel *selectedStopLabel;
    IBOutlet UILabel *selectedStopNameLabel;
    IBOutlet UIButton *showStopTimeTableButton;
    IBOutlet UIButton *searchRouteToLocationButton;
    IBOutlet UIView *commandViewButtonSeparator;
    
    //Map view
    int bigAnnotationWidth;
    int bigAnnotationHeight;
    int smallAnnotationWidth;
    int smallAnnotationHeight;
    
    
    UITapGestureRecognizer *tapGestureRecognizer;
    UITapGestureRecognizer *blurViewGestureRecognizer;
    UITapGestureRecognizer *toolBarGestureRecognizer;
    UITapGestureRecognizer *stopViewGestureRecognizer;
    UITapGestureRecognizer *searchResultsViewGestureRecognizer;
    
    UIPanGestureRecognizer *stopViewDragGestureRecognizer;
    UIPanGestureRecognizer *searchResultViewDragGestureRecognizer;
    
    CLLocationManager *locationManager;
    EKEventStore * _eventStore;

    //NSTimer *notificationTimer;
    
    //local vars
    BOOL centerMap;
    BOOL isStopViewDisplayed;
    BOOL isSearchResultsViewDisplayed;
    BOOL stopViewDragedDown;
    BOOL justReloading;
    BOOL requestedForListing;
    float topLayoutGuide;
    float bottomLayoutGuide;
    int bookmarkViewMode;
    int appOpenCount;
    int retryCount;
    NSString *timeToSetAlarm;
    NSString *selectedStopCode;
    NSString *selectedAnnotationUniqeName;
    NSString *selectedAnnotationCoords;
    NSNumber *selectedStopLongCode;
    NSNumber *prevSelectedStopLongCode;
    
    StopAnnotation *lastSelectedAnnotation;
    bool annotationSelectionChanged;
    int annotationAnimCounter;
    bool lastSelectionDismissed;
    bool ignoreRegionChange;
    CGRect searchBarFrame;
    
    NSIndexPath * departuresTableIndex;
    
    CustomBadge *customBadge;
    
    NSTimer *refreshTimer;
}

-(void)setUpStopViewForBusStop:(BusStop *)busStop;
-(void)openRouteSearchView;
-(void)openBookmarksView;

@property (strong, nonatomic) IBOutlet AMBlurView *StopView;
@property (strong, nonatomic) IBOutlet AMBlurView *searchResultsView;
@property (strong, nonatomic) NSArray * departures;
@property (strong, nonatomic) NSDictionary * _stopLinesDetail;
@property (strong, nonatomic) BusStop * _busStop;
@property (nonatomic) bool darkMode;

@property (strong, nonatomic) IBOutlet AMBlurView *notificationView;

@property (strong, nonatomic) UIRefreshControl *refreshControl;
@property (strong, nonatomic) NSTimer * notificationTimer;

@property (nonatomic) bool searchViewHidden;
@property (strong, nonatomic)NSArray * searchedStopList;
@property (strong, nonatomic)NSArray * nearByStopList;
@property (strong, nonatomic)NSArray * disruptionList;
@property (nonatomic)RSearchResultViewMode searchResultListViewMode;
@property (strong, nonatomic)CLLocation * currentUserLocation;

@property (strong, nonatomic) RettiDataManager *reittiDataManager;
//@property (strong, nonatomic) StopViewController *stopViewController;

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;


@end
