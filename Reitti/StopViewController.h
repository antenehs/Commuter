//
//  StopViewController.h
//  Reitti
//
//  Created by Anteneh Sahledengel on 19/1/14.
//  Copyright (c) 2014 Anteneh Sahledengel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <EventKit/EventKit.h>
#import <iAd/iAd.h>
#import "AMBlurView.h"
#import "BusStop.h"
#import "StopEntity.h"
#import "StopAnnotation.h"
#import "ReittiStringFormatter.h"
#import "RettiDataManager.h"
#import "CustomeTableViewCell.h"
#import "SWTableViewCell.h"
#import "ReittiRemindersManager.h"
#import "SettingsManager.h"

@class StopViewController;

@protocol StopViewControllerDelegate <NSObject>
- (void)savedStop:(StopEntity *)busStop;
- (void)deletedSavedStop:(StopEntity *)busStop;
@end

@interface StopViewController : UIViewController<UITableViewDataSource,UITableViewDelegate, SWTableViewCellDelegate, RettiDataManagerDelegate, UIActionSheetDelegate, SWTableViewCellDelegate, ADBannerViewDelegate, MKMapViewDelegate, UIAlertViewDelegate>{
    
    IBOutlet AMBlurView *stopView;
    IBOutlet UIView *topBarView;
    IBOutlet AMBlurView *bottomBarView;
    IBOutlet AMBlurView *topToolBar;
    
    UIColor *systemBackgroundColor;
    UIColor *systemTextColor;
    UIColor *systemSubTextColor;
    
    IBOutlet UILabel *stopCodeLabel;
    IBOutlet UILabel *stopNameLabel;
    IBOutlet UILabel *cityNameLabel;
    IBOutlet UITableView *departuresTable;
    IBOutlet AMBlurView *departuresTableViewContainer;
    IBOutlet MKMapView *mapView;
    
    IBOutlet UIButton *cancelButton;
    IBOutlet UILabel *stopViewTitle;
    IBOutlet UILabel *stopViewSubTitle;
    IBOutlet UIButton *bookmarkButton;
    IBOutlet UIButton *seeFullTimeTableButton;
    IBOutlet UIButton *showLocationButton;
    IBOutlet UIActivityIndicatorView *activityView;
    IBOutlet UILabel *pressingInfoLabel;
    IBOutlet UIBarButtonItem *showLocationBarButtonItem;
    
    UIButton *fullTimeTableButton;
    
    EKEventStore * _eventStore;
    BOOL stopFetched;
    bool stopBookmarked;
    NSString *timeToSetAlarm;
    NSIndexPath * departuresTableIndex;
    NSInteger pressTime;
    
    NSTimer *timer;
    
    ADBannerView *_bannerView;
}

-(void)setUpStopViewForBusStop:(BusStop *)busStop;

//@property (strong, nonatomic) IBOutlet UIView *StopView;
@property (strong, nonatomic) NSNumber * modalMode;

@property (strong, nonatomic) NSArray * departures;
@property (strong, nonatomic) BusStop * _busStop;
@property (strong, nonatomic) StopEntity * stopEntity;

@property (strong, nonatomic) NSString * stopCode;
@property (strong, nonatomic) NSString * stopShortCode;
@property (strong, nonatomic) NSString * stopName;
@property (nonatomic) CLLocationCoordinate2D stopCoords;
@property (strong, nonatomic) NSString * backButtonText;

@property (nonatomic) bool darkMode;

@property (strong, nonatomic) NSDictionary * _stopLinesDetail;
@property (strong, nonatomic) NSDictionary * _stopLineNames;

@property (strong, nonatomic) UIRefreshControl *refreshControl;

@property (strong, nonatomic) RettiDataManager *reittiDataManager;
@property (strong, nonatomic) SettingsManager * settingsManager;
@property (strong, nonatomic) ReittiRemindersManager * reittiReminderManager;

//@property (strong, nonatomic) GeoCode * droppedPinGeoCode;

@property (nonatomic, weak) id <StopViewControllerDelegate> delegate;

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end
