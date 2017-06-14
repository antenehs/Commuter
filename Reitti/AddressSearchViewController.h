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
#include "RouteEntity.h"
#import "GeoCode.h"

@class AddressSearchViewController;

@protocol AddressSearchViewControllerDelegate <NSObject>
- (void)searchResultSelectedAStop:(StopEntity *)stopEntity;
- (void)searchResultSelectedAGeoCode:(GeoCode *)geoCode;
- (void)searchResultSelectedANamedBookmark:(NamedBookmark *)namedBookmark;
- (void)searchResultSelectedCurrentLocation;
- (void)searchViewControllerDismissedToRouteSearch:(NSString *)prevSearchTerm;

@optional
- (void)searchResultSelectedARoute:(RouteEntity *)routeEntity;
@end

typedef enum {
    AddressSearchViewControllerKeyBoardTypeText = 1,
    AddressSearchViewControllerKeyBoardTypeNumber = 2
} AddressSearchViewControllerKeyBoardType;

typedef enum {
    AddressSearchViewControllerPrefilDataTypeNone = 0,
    AddressSearchViewControllerPrefilDataTypeAll = 1,
    AddressSearchViewControllerPrefilDataTypeSingleAddressed = 2,
    AddressSearchViewControllerPrefilDataTypeTwoAddressed =3,
} AddressSearchViewControllerPrefilDataType;

@interface AddressSearchViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,UIScrollViewDelegate,UISearchBarDelegate>{
    
    IBOutlet UISearchBar *addressSearchBar;
    IBOutlet UIButton *cancelButton;
    IBOutlet UIButton *leftNavBarButton;
    IBOutlet UITableView *searchResultTableView;
    IBOutlet UIView *backView;
    IBOutlet UIActivityIndicatorView *searchActivityIndicator;
    
    int unRespondedRequestsCount;
    BOOL isFinalSearch;
    BOOL streetAddressInputMode;
    NSString *addressWithoutStreetNum;
    
    BOOL isInitialMergedView;
    AddressSearchViewControllerKeyBoardType keyboardType;
    
    float topBoundary;
}

@property (nonatomic) AddressSearchViewControllerPrefilDataType prefilDataType;

@property (strong, nonatomic) NSMutableArray * dataToLoad;
@property (strong, nonatomic) NSMutableArray * additionalGeoCodeResults;
@property (nonatomic) bool routeSearchMode;
@property (nonatomic) bool simpleSearchMode;
@property (nonatomic) bool darkMode;

@property (strong, nonatomic) NSString * prevSearchTerm;

@property (strong, nonatomic) GeoCode * droppedPinGeoCode;

@property (nonatomic, weak) id <AddressSearchViewControllerDelegate> delegate;

@end
