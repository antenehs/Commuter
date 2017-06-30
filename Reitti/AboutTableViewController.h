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

@interface AboutTableViewController : UITableViewController<MFMailComposeViewControllerDelegate>

@property (strong, nonatomic) SettingsManager *settingsManager;

@end
