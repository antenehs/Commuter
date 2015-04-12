//
//  EditAddressTableViewController.h
//  Reitti
//
//  Created by Anteneh Sahledengel on 7/4/15.
//  Copyright (c) 2015 Anteneh Sahledengel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "AddressSearchViewController.h"
#import "RettiDataManager.h"
#import "AddressTypeTableViewController.h"
#import "ReittiNotificationHelper.h"
#import "RouteSearchViewController.h"

typedef enum
{
    ViewControllerModeAddNewAddress = 1,
    ViewControllerModeEditAddress = 2,
    ViewControllerModeViewNamedBookmark = 3,
    ViewControllerModeViewGeoCode = 4
} EditAddressViewControllerMode;

@interface EditAddressTableViewController : UITableViewController<AddressSearchViewControllerDelegate, AddressTypeViewControllerDelegate,UITextFieldDelegate,UIActionSheetDelegate>{
    
    IBOutlet UITextField *nameTextView;
    IBOutlet UILabel *nameLabel;
    
    MKMapView *mapView;
    BOOL showMap;
}

@property(nonatomic, strong)NSDictionary *addressTypeDictionary;
@property(nonatomic, strong)NamedBookmark *namedBookmark;
@property(nonatomic, strong)GeoCode *geoCode;

@property(nonatomic, strong)NSString *name;
@property(nonatomic, strong)NSString *fullAddress;
@property(nonatomic, strong)NSString *streetAddress;
@property(nonatomic, strong)NSString *city;
@property(nonatomic, strong)NSString *searchedName;
@property(nonatomic, strong)NSString *coords;
@property(nonatomic, strong)NSString *iconName;

@property(nonatomic)EditAddressViewControllerMode viewControllerMode;

@property(nonatomic, strong)RettiDataManager *reittiDataManager;

@end
