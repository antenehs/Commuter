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
    
    BOOL canShowLines;
    BOOL canShowDisruptions;
}

@end
