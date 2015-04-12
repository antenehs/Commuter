//
//  AddressSearchViewController.h
//  Reitti
//
//  Created by Anteneh Sahledengel on 6/8/14.
//  Copyright (c) 2014 Anteneh Sahledengel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AMBlurView.h"
#import "RettiDataManager.h"
#import "StopEntity.h"
#import "HistoryEntity.h"
#include "RouteEntity.h"
#include "RouteHistoryEntity.h"
#import "GeoCode.h"
//#import "RouteSearchViewController.h"

@class AddressSearchViewController;

@protocol AddressSearchViewControllerDelegate <NSObject>
- (void)searchResultSelectedAStop:(StopEntity *)stopEntity;
- (void)searchResultSelectedAGeoCode:(GeoCode *)geoCode;
- (void)searchResultSelectedANamedBookmark:(NamedBookmark *)namedBookmark;
- (void)searchResultSelectedCurrentLocation;
- (void)searchViewControllerWillBeDismissed:(NSString *)prevSearchTerm;
- (void)searchViewControllerDismissedToRouteSearch:(NSString *)prevSearchTerm;
@end

@interface AddressSearchViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,UIScrollViewDelegate,UISearchBarDelegate, RettiGeocodeSearchDelegate>{
    
    IBOutlet UISearchBar *addressSearchBar;
    IBOutlet UIButton *cancelButton;
    IBOutlet UIButton *leftNavBarButton;
    IBOutlet UITableView *searchResultTableView;
    IBOutlet UIView *searchResultTableViewContainer;
    IBOutlet UIImageView *tableViewBackgroundImageView;
    IBOutlet AMBlurView *tableViewBackGroundBlurView;
    IBOutlet UIView *backView;
    
    IBOutlet UIView *currentLocationContainerView;    
    
    UIColor *systemBackgroundColor;
    UIColor *systemTextColor;
    UIColor *systemSubTextColor;
    
    IBOutlet UISegmentedControl *listSegmentControl;
    IBOutlet UIActivityIndicatorView *searchActivityIndicator;
    
    int unRespondedRequestsCount;
    BOOL isFinalSearch;
    
    float topBoundary;
}

@property (strong, nonatomic) NSMutableArray * savedStops;
@property (strong, nonatomic) NSMutableArray * recentStops;
@property (strong, nonatomic) NSMutableArray * savedRoutes;
@property (strong, nonatomic) NSMutableArray * recentRoutes;
@property (strong, nonatomic) NSMutableArray * namedBookmarks;

@property (strong, nonatomic) NSMutableArray * dataToLoad;
@property (nonatomic) bool routeSearchMode;
@property (nonatomic) bool simpleSearchMode;
@property (nonatomic) bool darkMode;

@property (strong, nonatomic) NSString * prevSearchTerm;

@property (strong, nonatomic) RettiDataManager *reittiDataManager;

@property (nonatomic, weak) id <AddressSearchViewControllerDelegate> delegate;

@end
