//
//  MoreTableViewController.h
//  
//
//  Created by Anteneh Sahledengel on 23/6/15.
//
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

@interface MoreTableViewController : UITableViewController<MFMailComposeViewControllerDelegate>{
//    BOOL thereIsDisruptions;
    NSURL *appTranslateUrl;
    
    NSInteger featurePreviewSection, messageSection, debugFeaturesSection, moreFeaturesSection, settingsSection, commuterSection;
    NSInteger useDigiTransitRow;
    NSInteger messageRow;
    NSInteger routinesRow, ticketsSalesPointsRow, icloudBookmarksRow, matkakorttiRow, disruptionsRow;
    NSInteger settingsRow;
    NSInteger aboutCommuterRow, goProRow, translateRow, newInVersionRow, contactMeRow, rateInAppStoreRow, shareRow;
    NSInteger numberOfDebugRows, numberOfMoreFeatures, numberOfSettingsRows, numberOfCommuterRows , numberOfSection;
    
    BOOL canShowLines;
}

@end
