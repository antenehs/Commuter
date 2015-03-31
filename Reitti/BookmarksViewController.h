//
//  BookmarksViewController.h
//  Reitti
//
//  Created by Anteneh Sahledengel on 23/3/14.
//  Copyright (c) 2014 Anteneh Sahledengel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AMBlurView.h"
#import "RettiDataManager.h"
#import "StopViewController.h"
#import "RouteSearchViewController.h"

@class BookmarksViewController;

@protocol BookmarksViewControllerDelegate <NSObject>
- (void)savedStopSelected:(NSNumber *)code fromMode:(int)mode;
- (void)viewControllerWillBeDismissed:(int)mode;
- (void)deletedSavedStopForCode:(NSNumber *)code;
- (void)deletedHistoryStopForCode:(NSNumber *)code;
- (void)deletedSavedRouteForCode:(NSString *)code;
- (void)deletedHistoryRouteForCode:(NSString *)code;
- (void)deletedAllSavedStops;
- (void)deletedAllHistoryStops;
@end

@interface BookmarksViewController : UITableViewController<UIActionSheetDelegate,StopViewControllerDelegate, RouteSearchViewControllerDelegate>{
    IBOutlet AMBlurView *selectorView;
    IBOutlet UISegmentedControl *listSegmentControl;
    IBOutlet UIView *bluredBackView;
    IBOutlet UIBarButtonItem *addBookmarkButton;
    IBOutlet UIBarButtonItem *widgetSettingButton;
    
    UIColor *systemBackgroundColor;
    UIColor *systemTextColor;
    UIColor *systemSubTextColor;
}

@property (strong, nonatomic) NSMutableArray * savedStops;
@property (strong, nonatomic) NSMutableArray * recentStops;
@property (strong, nonatomic) NSMutableArray * savedRoutes;
@property (strong, nonatomic) NSMutableArray * recentRoutes;
//mode 0 = bookmark & mode 1 = recents
@property (nonatomic) int mode;
@property (nonatomic) bool darkMode;

@property (strong, nonatomic) NSMutableArray * dataToLoad;
@property (strong, nonatomic) UIColor * _tintColor;

@property (strong, nonatomic) RettiDataManager *reittiDataManager;

@property (nonatomic, weak) id <BookmarksViewControllerDelegate> delegate;

@end
