//
//  BookmarksViewController.h
//  Reitti
//
//  Created by Anteneh Sahledengel on 23/3/14.
//  Copyright (c) 2014 Anteneh Sahledengel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <iAd/iAd.h>
#import "AMBlurView.h"
#import "RettiDataManager.h"
#import "StopViewController.h"
#import "RouteSearchViewController.h"
#import "EditAddressTableViewController.h"

@class BookmarksViewController;

@interface BookmarksViewController : UITableViewController<UIActionSheetDelegate,StopViewControllerDelegate, RouteSearchViewControllerDelegate,ADBannerViewDelegate, CLLocationManagerDelegate, UIViewControllerPreviewingDelegate, UICollectionViewDataSource, UICollectionViewDelegate>{
    IBOutlet UISegmentedControl *listSegmentControl;
    IBOutlet UIBarButtonItem *widgetSettingButton;
    
    IBOutlet UIButton *showRoutesButton;
    IBOutlet UIButton *showDeparturesButton;
    
    UIColor *systemBackgroundColor;
    UIColor *systemTextColor;
    UIColor *systemSubTextColor;
    
    ADBannerView *_bannerView;
    
    NSTimer *refreshTimer;
    
    UIActivityIndicatorView *boomarkActivityIndicator;
    UIActivityIndicatorView *stopActivityIndicator;
    
    BOOL firstTimeLocation;
    BOOL trackedMoveOnce;
    BOOL trackedNumbersOnce;
    BOOL swipedToDelete;
    
    NSInteger namedBookmarkSection, savedStopsSection, savedRouteSection;
}

- (void)openAddBookmarkController;

@property (strong, nonatomic) NSMutableArray * savedStops;
@property (strong, nonatomic) NSMutableArray * recentStops;
@property (strong, nonatomic) NSMutableArray * savedRoutes;
@property (strong, nonatomic) NSMutableArray * recentRoutes;
@property (strong, nonatomic) NSMutableArray * savedNamedBookmarks;
//mode 0 = bookmark & mode 1 = recents
@property (nonatomic) int mode;
@property (nonatomic) bool darkMode;

@property (strong, nonatomic) NSMutableArray * dataToLoad;
@property (strong, nonatomic) NSMutableDictionary *namedBRouteDetail;
@property (strong, nonatomic)NSMutableDictionary *stopDetailMap;

@property (strong, nonatomic) UIColor * _tintColor;

//@property (strong, nonatomic) GeoCode * droppedPinGeoCode;

@property (strong, nonatomic) CLLocation * currentUserLocation;
@property (strong, nonatomic) CLLocation * previousCenteredLocation;
@property (strong, nonatomic) CLLocationManager *locationManager;

@property (strong, nonatomic) SettingsManager * settingsManager;

@end
