//
//  EditAddressTableViewController.h
//  Reitti
//
//  Created by Anteneh Sahledengel on 7/4/15.
//  Copyright (c) 2015 Anteneh Sahledengel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AddressSearchViewController.h"
#import "RettiDataManager.h"

@interface EditAddressTableViewController : UITableViewController<AddressSearchViewControllerDelegate>{
    BOOL hasAddress;
}

@property(nonatomic, strong)NSDictionary *addressDictionary;
@property(nonatomic)BOOL isNewAddress;

@property(nonatomic, strong)NSString *name;
@property(nonatomic, strong)NSString *address;

@property(nonatomic, strong)RettiDataManager *reittiDataManager;

@end
