//
//  TravelCardViewController.h
//  
//
//  Created by Anteneh Sahledengel on 2/7/15.
//
//

#import <UIKit/UIKit.h>
#import "AMBlurView.h"

@interface TravelCardViewController : UIViewController<UIWebViewDelegate, UITableViewDataSource,UITableViewDelegate, UITextFieldDelegate>{
    IBOutlet UIWebView *webView;
    NSString *editorJsString;
    
    BOOL triedLoginAlready;
    BOOL ignoreWebChangesOnce;
    
    UITableViewController *tableViewController;
    
    //Login screen outlets
    IBOutlet UIView *logginView;
    IBOutlet UIImageView *matkakorttiLogo;
    IBOutlet UIView *credentialsView;
    IBOutlet UITextField *usernameTextbox;
    IBOutlet UIImageView *userFieldIcon;
    IBOutlet UIImageView *passwordFieldIcon;
    IBOutlet UITextField *passwordTextbox;
    IBOutlet UIView *separatorLineView;
    IBOutlet UIButton *logginButton;
    IBOutlet UIActivityIndicatorView *loginActivityIndicator;
    IBOutlet UIButton *newAccountButton;
    
    IBOutlet UILabel *infoLabel;
    IBOutlet UIImageView *infoLabelIcon;
    
    IBOutlet NSLayoutConstraint *logginViewVerticalSpacing;
    
    //Bottom toolbar view
    IBOutlet UILabel *updateTimeLabel;
    IBOutlet AMBlurView *bottomToolBarView;
}

@property (strong, nonatomic) UIRefreshControl *refreshControl;

@property(nonatomic,strong) NSArray *cards;
@property(nonatomic,strong) NSString *username;
@property(nonatomic,strong) NSString *password;
@property (strong, nonatomic) IBOutlet UITableView *tableView;

@end
