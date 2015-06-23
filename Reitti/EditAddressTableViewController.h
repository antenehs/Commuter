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

@interface EditAddressTableViewController : UITableViewController<AddressSearchViewControllerDelegate, AddressTypeViewControllerDelegate,UITextFieldDelegate,UIActionSheetDelegate, RettiReverseGeocodeSearchDelegate>{
    
    IBOutlet UITextField *nameTextView;
    IBOutlet UILabel *nameLabel;
    
    MKMapView *mapView;
    BOOL showMap;
    
    BOOL requestedForSaving;
}

@property(nonatomic, strong)NSDictionary *addressTypeDictionary;
@property(nonatomic, strong)NSString *preSelectType;
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

//@property (strong, nonatomic) GeoCode * droppedPinGeoCode;
@property (strong, nonatomic) GeoCode * currentLocationGeoCode;;
@property (strong, nonatomic) CLLocation * currentUserLocation;

@property(nonatomic, strong)RettiDataManager *reittiDataManager;

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end
