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
#import "AMBlurView.h"
#import "BusStop.h"
#import "StopEntity.h"
#import "StopAnnotation.h"
#import "ReittiStringFormatter.h"
#import "RettiDataManager.h"
#import "CustomeTableViewCell.h"
#import "SWTableViewCell.h"

@class StopViewController;

@protocol StopViewControllerDelegate <NSObject>
- (void)savedStop:(StopEntity *)busStop;
- (void)deletedSavedStop:(StopEntity *)busStop;
@end

@interface StopViewController : UIViewController<UITableViewDataSource,UITableViewDelegate, SWTableViewCellDelegate, RettiDataManagerDelegate, UIActionSheetDelegate, SWTableViewCellDelegate>{
    
    IBOutlet AMBlurView *stopView;
    IBOutlet AMBlurView *topBarView;
    IBOutlet AMBlurView *bottomBarView;
    
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
    IBOutlet UIActivityIndicatorView *activityView;
    IBOutlet UILabel *pressingInfoLabel;
    
    EKEventStore * _eventStore;
    
    bool stopBookmarked;
    NSString *timeToSetAlarm;
    NSIndexPath * departuresTableIndex;
    NSInteger pressTime;
    
    NSTimer *timer;
}

-(void)setUpStopViewForBusStop:(BusStop *)busStop;

//@property (strong, nonatomic) IBOutlet UIView *StopView;

@property (strong, nonatomic) NSArray * departures;
@property (strong, nonatomic) BusStop * _busStop;
@property (strong, nonatomic) StopEntity * stopEntity;

@property (strong, nonatomic) NSString * stopCode;
@property (strong, nonatomic) NSString * backButtonText;

@property (nonatomic) bool darkMode;

@property (strong, nonatomic) NSDictionary * _stopLinesDetail;

@property (strong, nonatomic) UIRefreshControl *refreshControl;

@property (strong, nonatomic) RettiDataManager *reittiDataManager;

@property (nonatomic, weak) id <StopViewControllerDelegate> delegate;

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end
