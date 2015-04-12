//
//  AddressTypeTableViewController
//  Reitti
//
//  Created by Anteneh Sahledengel on 6/4/15.
//  Copyright (c) 2015 Anteneh Sahledengel. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AddressTypeViewControllerDelegate <NSObject>
- (void)selectedAddressType:(NSDictionary *)stopEntity;
@end

@interface AddressTypeTableViewController : UITableViewController

@property (nonatomic, weak) id <AddressTypeViewControllerDelegate> delegate;

@end
