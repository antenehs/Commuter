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
#import "StopEntity.h"
#import "ReittiStringFormatter.h"
#import "BookmarksViewController.h"
#import "WebViewController.h"
#import "SWTableViewCell.h"
#import "CustomeTableViewCell.h"
#import "CommandView.h"
#import "CustomBadge.h"
#import "JPSThumbnailAnnotation.h"
#import "LVThumbnailAnnotation.h"
#import <AddressBookUI/AddressBookUI.h>
#import "EditAddressTableViewController.h"
#import "SettingsViewController.h"
#import "SettingsManager.h"
#import "HMSegmentedControl.h"
#import "NearByStop.h"
#import "CacheManager.h"

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

typedef enum
{
    MainMapViewModeStops = 0,
    MainMapViewModeLive = 1,
    MainMapViewModeStopsAndLive = 2
} MainMapViewMode;

@interface SearchController : UIViewController<RettiDataManagerDelegate,RettiRouteSearchDelegate, RettiReverseGeocodeSearchDelegate, ReittiDisruptionFetchDelegate, ReittiLiveVehicleFetchDelegate, SettingsDelegate, UISearchBarDelegate, CLLocationManagerDelegate, MKMapViewDelegate, UITableViewDataSource,UITableViewDelegate,UIActionSheetDelegate, UIAlertViewDelegate, MFMailComposeViewControllerDelegate, UIGestureRecognizerDelegate, BookmarksViewControllerDelegate, SWTableViewCellDelegate,AddressSearchViewControllerDelegate>{
    IBOutlet UISearchBar *mainSearchBar;
    IBOutlet UIButton *currentLocationButton;
    IBOutlet UIButton *infoAndAboutButton;
    IBOutlet UIView *rightNavButtonsView;
    IBOutlet UIButton *listNearbyStops;
    IBOutlet NSLayoutConstraint *nearByStopsViewTopSpacing;
    
    HMSegmentedControl *segmentedControl;
    
    UIColor *systemBackgroundColor;
    UIColor *systemTextColor;
    UIColor *systemSubTextColor;
    
    //toolbar
    UIButton *settingsBut;
    UIButton *listButton;
    UIButton *bookmarkButton;
    
    //Multiple searchs view
    IBOutlet UITableView *searchResultsTable;
    IBOutlet UILabel *searchResultsLabel;
    IBOutlet UIButton *hideSearchResultViewButton;
    
    //Map view
    int bigAnnotationWidth;
    int bigAnnotationHeight;
    int smallAnnotationWidth;
    int smallAnnotationHeight;
    
    UITapGestureRecognizer *searchResultsViewGestureRecognizer;
    
    UIPanGestureRecognizer *stopViewDragGestureRecognizer;
    UIPanGestureRecognizer *searchResultViewDragGestureRecognizer;
    
    CLLocationManager *locationManager;
    EKEventStore * _eventStore;
    
    NSObject<JPSThumbnailAnnotationViewProtocol> *selectedAnnotationView;
    MKAnnotationView *droppedPinAnnotationView;

    //NSTimer *notificationTimer;
    
    //local vars
    BOOL locNotAvailableNotificationShow;
    BOOL centerMap;
    BOOL isStopViewDisplayed;
    BOOL isSearchResultsViewDisplayed;
    BOOL stopViewDragedDown;
    BOOL tableViewIsDecelerating;
    BOOL justReloading;
    BOOL requestedForListing;
    BOOL firstRecievedLocation;
    BOOL userLocationUpdated;
    BOOL removeAnnotationsOnce;
    float topLayoutGuide;
    float bottomLayoutGuide;
    int bookmarkViewMode;
    int appOpenCount;
    int retryCount;
    NSString *timeToSetAlarm;
    NSString *selectedStopCode, *selectedStopShortCode, *selectedStopName;
    NSString *selectedAnnotationUniqeName;
    NSString *selectedAnnotationCoords;
    NSNumber *selectedStopLongCode;
    NSNumber *prevSelectedStopLongCode;
    
    NSString *droppedPinLocation;
    CLLocationCoordinate2D droppedPinCoords;
    
    CLLocationCoordinate2D selectedStopAnnotationCoords;
    
    NSString * selectedFromLocation;
    NSString * selectedFromCoords;
    
    NSString * prevSearchedCoords;
    
    NamedBookmark *selectedNamedBookmark;
    GeoCode *selectedGeoCode;
    
    StopAnnotation *lastSelectedAnnotation;
    bool annotationSelectionChanged;
    int annotationAnimCounter;
    bool lastSelectionDismissed;
    bool ignoreRegionChange;
    BOOL canShowDroppedPin;
    CGRect searchBarFrame;
    
    NSIndexPath * departuresTableIndex;
    
    CustomBadge *customBadge;
    
    UIView *centerLocatorView;
    
    NSTimer *refreshTimer;
}

-(void)initDataComponentsAndModules;
-(void)initDataComponentsAndModulesWithManagedObjectCOntext:(NSManagedObjectContext *)mngdObjectContext;
-(void)openRouteSearchView;
-(void)openRouteViewToLocationName:(NSString *)locationName locationCoords:(NSString *)coords;
-(void)openRouteViewForFromLocation:(MKDirectionsRequest *)directionsInfo;
-(void)openBookmarksView;
-(void)openWidgetSettingsView;
-(void)openStopViewForCode:(NSNumber *)code;

@property (strong, nonatomic) IBOutlet MKMapView *mapView;

@property (strong, nonatomic) IBOutlet AMBlurView *StopView;
@property (strong, nonatomic) IBOutlet AMBlurView *searchResultsView;
@property (strong, nonatomic) NSArray * departures;
@property (strong, nonatomic) NSDictionary * _stopLinesDetail;
@property (strong, nonatomic) BusStop * _busStop;
@property (strong, nonatomic) GeoCode *droppedPinGeoCode;
@property (nonatomic) bool darkMode;
@property (nonatomic) MainMapViewMode mapMode;

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
@property (strong, nonatomic) SettingsManager *settingsManager;
@property (strong, nonatomic) CacheManager *cacheManager;
//@property (strong, nonatomic) StopViewController *stopViewController;

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;


@end
