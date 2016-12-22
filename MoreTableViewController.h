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
//    BOOL thereIsDisruptions;
    NSURL *appTranslateUrl;
    
    NSInteger debugFeaturesSection, moreFeaturesSection, settingsSection, commuterSection;
    NSInteger useDigiTransitRow;
    NSInteger routinesRow, ticketsSalesPointsRow, icloudBookmarksRow, matkakorttiRow, disruptionsRow;
    NSInteger settingsRow;
    NSInteger aboutCommuterRow, goProRow, translateRow, newInVersionRow, contactMeRow, rateInAppStoreRow, shareRow;
    NSInteger numberOfDebugRows, numberOfMoreFeatures, numberOfSettingsRows, numberOfCommuterRows , numberOfSection;
    
    BOOL canShowLines;
//    BOOL canShowDisruptions;
}

@end
