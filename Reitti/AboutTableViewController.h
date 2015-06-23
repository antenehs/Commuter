//
//  AboutTableViewController.h
//  
//
//  Created by Anteneh Sahledengel on 23/6/15.
//
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "RettiDataManager.h"
#import "SettingsManager.h"

@interface AboutTableViewController : UITableViewController<UIActionSheetDelegate, MFMailComposeViewControllerDelegate>

@property (strong, nonatomic) RettiDataManager *reittiDataManager;
@property (strong, nonatomic) SettingsManager *settingsManager;

@end
