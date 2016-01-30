//
//  MoreTableViewController.h
//  
//
//  Created by Anteneh Sahledengel on 23/6/15.
//
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

@interface MoreTableViewController : UITableViewController<UIActionSheetDelegate, MFMailComposeViewControllerDelegate>{
    BOOL thereIsDisruptions;
    
    NSInteger moreFeaturesSection, settingsSection, commuterSection;
    NSInteger routinesRow, ticketsSalesPointsRow, matkakorttiRow, disruptionsRow;
    NSInteger settingsRow;
    NSInteger aboutCommuterRow, goProRow, newInVersionRow, contactMeRow, rateInAppStoreRow, shareRow;
    NSInteger numberOfMoreFeatures, numberOfSettingsRows, numberOfCommuterRows , numberOfSection;
    
    BOOL canShowLines;
//    BOOL canShowDisruptions;
}

@end
