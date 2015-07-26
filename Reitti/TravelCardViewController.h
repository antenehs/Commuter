//
//  TravelCardViewController.h
//  
//
//  Created by Anteneh Sahledengel on 2/7/15.
//
//

#import <UIKit/UIKit.h>
#import "AMBlurView.h"

@interface TravelCardViewController : UIViewController<UIWebViewDelegate, UITableViewDataSource,UITableViewDelegate, UITextFieldDelegate, UIAlertViewDelegate>{
    IBOutlet UIWebView *webView;
    NSString *editorJsString;
    IBOutlet UIButton *reloadButton;
    
    BOOL triedLoginAlready;
    BOOL ignoreWebChangesOnce;
    BOOL userRequestedReload;
    BOOL validateCardAddition;
    BOOL validateCardDeletion;
    
    NSMutableDictionary *selectedIndexes;
    
    UITableViewController *tableViewController;
    
    //Login screen outlets
    IBOutlet UIView *logginView;
    IBOutlet UIView *logginInnerContainerView;
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
    
    //Add card views
    IBOutlet UITextField *cardNumberTextbox;
    IBOutlet UITextField *cardNameTextbox;
    UIButton *addCardBigButton;
    UIButton *addCardSmallButton;
    BOOL addCardMode;
    
    //Bottom toolbar view
    IBOutlet UILabel *updateTimeLabel;
    IBOutlet AMBlurView *bottomToolBarView;
    IBOutlet UIActivityIndicatorView *miscActivityIndicator;
}

@property (strong, nonatomic) UIRefreshControl *refreshControl;

@property(nonatomic,strong) NSArray *cards;
@property(nonatomic,strong) NSString *username;
@property(nonatomic,strong) NSString *password;
@property(nonatomic,strong) NSString *createCardNumber;
@property(nonatomic,strong) NSString *createCardName;
@property(nonatomic,strong) NSString *renameCardNumber;
@property(nonatomic,strong) NSString *renameCardName;
@property(nonatomic,strong) NSString *deleteCardNumber;
@property(nonatomic,strong) NSString *currentProcessTask;
@property (strong, nonatomic) IBOutlet UITableView *cardsTableView;

@end
