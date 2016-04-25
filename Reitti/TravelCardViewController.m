//
//  TravelCardViewController.m
//  
//
//  Created by Anteneh Sahledengel on 2/7/15.
//
//

#import "TravelCardViewController.h"
#import "TravelCardManager.h"
#import "ReittiStringFormatter.h"
#import "RettiDataManager.h"
#import "Reachability.h"
#import "ReittiNotificationHelper.h"
#import "SVProgressHUD.h"
//#import "HTMLReader.h"
//#import "HTMLDocument.h"
//#import "HTMLElement.h"
#import "TravelCard.h"
#import "AppManager.h"
#import "PeriodProductState.h"

@interface TravelCardViewController ()

- (BOOL)cellIsSelected:(NSIndexPath *)indexPath;

@end

NSString *ACCurrentProcessGetCards = @"ACCurrentProcessGetCards";
NSString *ACCurrentProcessCreateCard = @"ACCurrentProcessCreateCard";
NSString *ACCurrentProcessDeleteCard = @"ACCurrentProcessDeleteCard";
NSString *ACCurrentProcessRenameCard = @"ACCurrentProcessRenameCard";
//CGFloat KDefaultCardCellHeight = 140.0f;

@implementation TravelCardViewController

#define kCellHeight 150.0

@synthesize refreshControl;
@synthesize cards,cardsTableView;
@synthesize username, password;
@synthesize createCardNumber, createCardName;
@synthesize renameCardNumber, renameCardName, deleteCardNumber;
@synthesize currentProcessTask;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    webView.delegate = self;
    self.cardsTableView.delegate = self;
    
    triedLoginAlready = NO;
    ignoreWebChangesOnce = NO;
    userRequestedReload = NO;
    validateCardAddition = NO;
    validateCardDeletion = NO;
    
    selectedIndexes = [[NSMutableDictionary alloc] init];
    
    self.currentProcessTask = ACCurrentProcessGetCards;
    
    UITapGestureRecognizer *loginViewTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(loginViewTapped:)];
    
    [logginView addGestureRecognizer:loginViewTapRecognizer];
    [logginInnerContainerView addGestureRecognizer:loginViewTapRecognizer];
    
//    UITapGestureRecognizer *tableViewTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tableViewTapped:)];
    
//    [self.cardsTableView addGestureRecognizer:tableViewTapRecognizer];
    
    [self setUpLoginView];
    [self setTableBackgroundView];
//    tableViewController = [[UITableViewController alloc] init];
//    [self initRefreshControl];
    
    bottomToolBarView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    bottomToolBarView.layer.borderWidth = 0.5f;
    
    if (![TravelCardManager thereIsValidLoginInfo]) {
        [self hideLoginView:NO animated:NO];
    }else{
        [self hideLoginView:YES animated:NO];
        //Load previous value
        //TODO: may be a good thing if validy and age is checked
        self.cards = [TravelCardManager getPreviousValues];
        addCardMode = self.cards.count == 0;
        [self.cardsTableView reloadData];
        
        self.username = [TravelCardManager savedUserName];
        self.password = [TravelCardManager savedPassword];
        
        [self setLastUpdateTime];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
}

-(void)viewDidAppear:(BOOL)animated{
    [self setLastUpdateTime];
    updateTimeLabel.text = @"Updating ...";
    [self loadLogginPage];
    
    [[ReittiAnalyticsManager sharedManager] trackScreenViewForScreenName:NSStringFromClass([self class])];
}

- (void)appWillEnterForeground:(NSNotification *)notification {
    [self setLastUpdateTime];
    updateTimeLabel.text = @"Updating ...";
    [self loadLogginPage];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self setTableBackgroundView];
}

#pragma mark - view methods
-(void)setUpLoginView{
//    credentialsView.layer.cornerRadius = 10.0f;
//    credentialsView.layer.borderColor = [UIColor lightGrayColor].CGColor;
//    credentialsView.layer.borderWidth = 1.0f;
    logginButton.layer.cornerRadius = 10.0f;
    
    if ([TravelCardManager savedUserName]) {
        self.username = [TravelCardManager savedUserName];
        usernameTextbox.text = self.username;
    }
    
    //Temporary.. for testing only
//    usernameTextbox.text = @"rebekah";
//    passwordTextbox.text = @"Bsonofgod.1";
}

-(void)hideLoginView:(BOOL)hidden animated:(BOOL)animated{
    [self.navigationController setNavigationBarHidden:!hidden animated:animated];
    [UIView transitionWithView:logginView duration:animated?0.3:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        CGFloat hiddenHeight = self.view.frame.size.height > self.view.frame.size.width ? self.view.frame.size.height : self.view.frame.size.width;
        logginViewVerticalSpacing.constant = hidden ? hiddenHeight : 0;
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {}];
    
}

-(BOOL)isLogginViewHidden{
    return logginViewVerticalSpacing.constant != 0;
}

-(void)resignAllFirstResponders{
    [usernameTextbox resignFirstResponder];
    [passwordTextbox resignFirstResponder];
    
    [cardNumberTextbox resignFirstResponder];
    [cardNameTextbox resignFirstResponder];
}

- (void)setTableBackgroundView {
    UIView *bluredBackViewContainer = [[UIView alloc] initWithFrame:self.view.bounds];
    bluredBackViewContainer.backgroundColor = [UIColor whiteColor];
    UIImageView *mapImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"map_background.png"]];
    mapImageView.frame = bluredBackViewContainer.frame;
    mapImageView.alpha = 0.8;
    AMBlurView *blurView = [[AMBlurView alloc] initWithFrame:bluredBackViewContainer.frame];
    
    [bluredBackViewContainer addSubview:mapImageView];
    [bluredBackViewContainer addSubview:blurView];
    
    self.cardsTableView.backgroundView = bluredBackViewContainer;
    self.cardsTableView.backgroundColor = [UIColor clearColor];
}

#pragma mark - TableView methods
- (void)initRefreshControl{
    
    tableViewController.tableView = self.cardsTableView;
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(tableViewRefreshing) forControlEvents:UIControlEventValueChanged];
    //    refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"Pull to Reload Routes"];
    tableViewController.refreshControl = self.refreshControl;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return addCardMode ? 1 : self.cards.count + 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell;
    if (indexPath.section < self.cards.count && !addCardMode) {
        cell = [self.cardsTableView dequeueReusableCellWithIdentifier:@"cardCell2"];
        
        TravelCard *card = [self.cards objectAtIndex:indexPath.section];
        
        UILabel *title = (UILabel *)[cell viewWithTag:1001];
        UILabel *balanceLabel = (UILabel *)[cell viewWithTag:1002];
        UILabel *ticketName = (UILabel *)[cell viewWithTag:1003];
        UILabel *ticketPeriod = (UILabel *)[cell viewWithTag:1004];
        UILabel *periodDays = (UILabel *)[cell viewWithTag:1005];
//        UILabel *noPeriodLabel = (UILabel *)[cell viewWithTag:1006];
        
        title.text = card.name != nil ? card.name : card.internalBaseClassIdentifier;
        if (card.remainingMoney != 0 && card.remainingMoney > 0) {
//            balanceLabel.text = [NSString stringWithFormat:@"%@ €", [ReittiStringFormatter formatRoundedNumberFromDouble:card.remainingMoney roundDigits:2 androundUp:NO]];
            balanceLabel.attributedText = [ReittiStringFormatter formatAttributedString:[ReittiStringFormatter formatRoundedNumberFromDouble:card.remainingMoney roundDigits:2 androundUp:NO]
                                                                               withUnit:@" €"
                                                                               withFont:[balanceLabel font] andUnitFontSize:24];
        }else{
            balanceLabel.text = @"-";
        }
        
        if (card.periodProductState.startDate != nil) {
            NSDate *startDate = [card getPeriodStartDate];
            NSDate *expiryDate = [card getPeriodEndDate];
            
//            periodDays.text = [NSString stringWithFormat:@"%d days", (int)[RettiDataManager daysBetweenDate:[NSDate date] andDate:expiryDate]];
            int daysFromNow = (int)[RettiDataManager daysBetweenDate:[NSDate date] andDate:expiryDate];
            if (daysFromNow < -1) {
                periodDays.text = @"N/A";
            }else{
                if(daysFromNow < 6)
                    periodDays.textColor = [AppManager systemOrangeColor];
                else
                    periodDays.textColor = [UIColor blackColor];
                NSAttributedString *daysString = [ReittiStringFormatter formatAttributedString:[NSString stringWithFormat:@"%d",daysFromNow]
                                                                                      withUnit:@" days"
                                                                                      withFont:[balanceLabel font] andUnitFontSize:24];
                periodDays.attributedText = daysString;
            }
            
            ticketPeriod.text = [NSString stringWithFormat:@"%@ - %@",[[ReittiDateFormatter sharedFormatter] formatDate:startDate], [[ReittiDateFormatter sharedFormatter] formatDate:expiryDate]];
            ticketName.text = card.periodProductState.productName;
            
//            noPeriodLabel.hidden = YES;
            ticketName.hidden = NO;
//            ticketPeriod.hidden = NO;
        }else{
            ticketPeriod.text = @"No valid season ticket";
//            noPeriodLabel.hidden = NO;
            ticketName.hidden = YES;
//            ticketPeriod.hidden = YES;
            
            periodDays.text = @"-";
        }
    }else{
        cell = [self.cardsTableView dequeueReusableCellWithIdentifier:@"noCardsCell"];
        UIButton *addCardButton = (UIButton *)[cell viewWithTag:1003];
        addCardBigButton = addCardButton;
        UIButton *addCardButton2 = (UIButton *)[cell viewWithTag:1008];
        addCardSmallButton = addCardButton2;
        UIButton *cancelButton = (UIButton *)[cell viewWithTag:1007];
        
        cardNameTextbox = (UITextField *)[cell viewWithTag:1002];
        cardNumberTextbox = (UITextField *)[cell viewWithTag:1001];
        
        UILabel *titleLabel = (UILabel *)[cell viewWithTag:1000];
        UIView *textFieldsContainer = [cell viewWithTag:1006];
        
        if (self.cards.count > 0) {
            titleLabel.text = @"Add a card using the number on the back of the travel card.";
        }else{
            titleLabel.text = @"You have not yet added any cards to 'Oma Matkakortti' service.";
        }
        
        titleLabel.hidden = !addCardMode;
        textFieldsContainer.hidden = !addCardMode;
        addCardButton.hidden = addCardMode;
        addCardButton2.hidden = !addCardMode;
        cancelButton.hidden = !addCardMode;
        
        addCardButton.layer.cornerRadius = 10.0f;
        addCardButton2.layer.cornerRadius = 10.0f;
        cancelButton.layer.cornerRadius = 10.0f;
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section < self.cards.count && !addCardMode) {
        if([self cellIsSelected:indexPath]) {
            return kCellHeight + 35.0f;
        }
        return kCellHeight;
    }else{
        return addCardMode ? 210 : 45;
    }
}

-(void)tableView:(UITableView *)thisTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if(addCardMode){
        [self tableViewTapped:self];
    }else{
        [thisTableView deselectRowAtIndexPath:indexPath animated:TRUE];
        
        // Toggle 'selected' state
        BOOL isSelected = ![self cellIsSelected:indexPath];
        
        // Store cell 'selected' state keyed on indexPath
        NSNumber *selectedIndex = [NSNumber numberWithBool:isSelected];
        [selectedIndexes setObject:selectedIndex forKey:indexPath];
        
        // This is where magic happens...
        [self.cardsTableView beginUpdates];
        [self.cardsTableView endUpdates];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section < self.cards.count && !addCardMode) {
        return 30;
    }
    
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (section < self.cards.count && !addCardMode) {
        TravelCard *card = [self.cards objectAtIndex:section];
        
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 30)];
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width - 60, 30)];
        titleLabel.font = [titleLabel.font fontWithSize:14];
        titleLabel.textColor = [UIColor darkGrayColor];
        titleLabel.text = [NSString stringWithFormat:@"  %@", card.name != nil ? card.name : card.internalBaseClassIdentifier];
        
        titleLabel.text = [titleLabel.text uppercaseString];
        
        [view addSubview:titleLabel];
        
        return view;
    }
    
    return nil;
    
}

#pragma mark - WebView methods
-(void)webViewDidStartLoad:(UIWebView *)webView {
    
}

- (void)webViewDidFinishLoad:(UIWebView *)_webView{
    if (!ignoreWebChangesOnce) {
        NSString *htmlString;
        htmlString = [self webHtml];
        
        if ([TravelCardManager isLoginScreen:htmlString]) {
            if (triedLoginAlready) {
                NSString *wrongCredError;
                wrongCredError = [TravelCardManager parseErrorMessage:htmlString];
                
                [self onLoginFailed:wrongCredError];
                
                triedLoginAlready = NO;
            }else{
                [self login];
            }
            
        }else{
            //TODO: Handle different cases for the login
            //Check if it is mobile Version
            if ([TravelCardManager isMobileVersion:htmlString]) {
                [self changeToFullPageVersion:YES];
            }else{
                if (self.currentProcessTask == ACCurrentProcessGetCards) {
                    NSArray *tempArray = nil;
                    
                    if ([TravelCardManager tryParseCardsFromHtmlString:htmlString returnArray:&tempArray]) {
                        self.cards = tempArray;
                        addCardMode = self.cards.count == 0;
                        [self.cardsTableView reloadData];
                        
                        [self onLoginSuccessful];
                        
                        //Log out imidiately. Keep the webpage at login screen because it might time out
                        [self logoutWebPage:NO];
                        
                        if (validateCardAddition && self.createCardNumber != nil) {
                            if ([self cardForCardNumber:self.createCardNumber] == nil) {
                                [ReittiNotificationHelper showSimpleMessageWithTitle:@"Adding new card failed. Please check if the number is correct or try adding the card from Omamatkakortti.fi" andContent:nil];
                            }
                            
                            validateCardAddition = NO;
                        }
                        
                        if (validateCardDeletion && self.deleteCardNumber != nil) {
                            if ([self cardForCardNumber:self.createCardNumber] != nil) {
                                [ReittiNotificationHelper showErrorBannerMessage:@"Seems like the card is not deleted properly. Please try again from Omamatkakortti.fi" andContent:nil];
                            }
                        
                            validateCardDeletion = NO;
                        }
                        
                    }else{
                        NSLog(@"Parsing cards failed");
                        NSString *failureString = [TravelCardManager parseErrorMessage:htmlString];
                        [self onCardParsingFailed:failureString withNotify:userRequestedReload];
                        userRequestedReload = NO;
                    }
                    
                    [self indicateActivity:NO];
                }else if (self.currentProcessTask == ACCurrentProcessCreateCard) {
                    [self addCard];
                    //2: Clear text fields
                    
                    //Only change mode if creation is successful
                    self.currentProcessTask = ACCurrentProcessGetCards;
                    validateCardAddition = YES;
                    
                    [webView reload];
//                    [self debugButtonPressed:self];
                }else if (self.currentProcessTask == ACCurrentProcessRenameCard) {
                    [self renameCard];
//                    NSString *failureString = [TravelCardManager parseErrorMessage:htmlString];
//                    if (failureString != nil) {
//                        [ReittiNotificationHelper showErrorBannerMessage:failureString andContent:nil];
//                    }
                    //2: Clear text fields
                    self.currentProcessTask = ACCurrentProcessGetCards;
                    
                    [webView reload];
//                    [self debugButtonPressed:self];
                }else if (self.currentProcessTask == ACCurrentProcessDeleteCard) {
                    [self deleteCard];
                    validateCardDeletion = YES;
                    //2: Clear text fields
                    self.currentProcessTask = ACCurrentProcessGetCards;
                    
                    [webView reload];
//                    [self debugButtonPressed:self];
                }
            }
        }
    }else{
        ignoreWebChangesOnce = NO;
    }
}

#pragma mark - IBActions
- (IBAction)loginButtonPressed:(id)sender {
    self.username = usernameTextbox.text;
    self.password = passwordTextbox.text;
    
    if (![self validateLoggin])
        return;
    
    if (![self isInternetConnectionAvailable])
        return;
    
    if (/*!loginActivityIndicator.isAnimating && */[self hasValidCredentials]) {
        [loginActivityIndicator startAnimating];
        [self loadLogginPage];
        [self resignAllFirstResponders];
    }
}

- (IBAction)logOutButtonPressed:(id)sender {
    [self logout];
    [self hideLoginView:NO animated:YES];
}

- (IBAction)reloadButtonPressed:(id)sender {
    userRequestedReload = YES;
    [self reloadCards];
}

- (IBAction)createAccountButtonPressed:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://omamatkakortti.hsl.fi/Registration.aspx"]];
}

- (IBAction)openCardsViewButtonPressed:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://omamatkakortti.hsl.fi/Basic/Cards.aspx"]];
}

-(IBAction)loginViewTapped:(id)sender{
    [self resignAllFirstResponders];
}

-(IBAction)tableViewTapped:(id)sender{
    [self resignAllFirstResponders];
}

- (IBAction)addCardButtonPressed:(id)sender {
    if (!addCardMode) {
        addCardMode = YES;
        //1. Login
        
        //2. Validate if card can be created locally
        
        
        [self.cardsTableView reloadData];
    }else{
        if (![self isInternetConnectionAvailable])
            return;
        
        //Temp for testing
//        cardNameTextbox.text = @"New Card 1";
        
//        if ([cardNumberTextbox.text isEqualToString: @"924620001149570011"]) {
//            cardNumberTextbox.text = @"924620001111360144";
//        }else{
//            cardNumberTextbox.text = @"924620001149570011";
//        }
        
        self.createCardNumber = cardNumberTextbox.text;
        self.createCardName = cardNameTextbox.text;
        
        if (self.createCardNumber == nil || [self.createCardNumber isEqualToString:@""]) {
            [ReittiNotificationHelper showErrorBannerMessage:@"Travel card number is required." andContent:nil];
            return;
        }
        
        if (![self isValidCardNumber:self.createCardNumber]) {
            [ReittiNotificationHelper showErrorBannerMessage:@"Invalid card number. Card number can only contain numbers and is 18 digits long." andContent:nil];
            return;
        }
        
        if (![self isValidCardName:self.createCardName]) {
            [ReittiNotificationHelper showErrorBannerMessage:@"Invalid card name!" andContent:@"Invalid card name. Card name can only contain 20 characters. The permitted symbols are numbers, letters and spaces."];
            return;
        }
        
        if ([self cardExistsWithNumber:self.createCardNumber]){
            [ReittiNotificationHelper showErrorBannerMessage:@"A card with that number exists already." andContent:nil];
            return;
        }
        
        if ([self cardExistsWithName:self.createCardName]){
            [ReittiNotificationHelper showErrorBannerMessage:@"A card with that name exists already." andContent:nil];
            return;
        }
        
        [self resignAllFirstResponders];
        triedLoginAlready = NO;
        self.currentProcessTask = ACCurrentProcessCreateCard;
        [self loadLogginPage];
        
//        [self debugButtonPressed:self];
        
        [self indicateActivity:YES];
    }
}

- (IBAction)deleteCardButtonPressed:(id)sender{
    if (![self isInternetConnectionAvailable])
        return;
    
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.cardsTableView];
    NSIndexPath *indexPath = [self.cardsTableView indexPathForRowAtPoint:buttonPosition];
    
    if (indexPath.section < self.cards.count && !addCardMode) {
        TravelCard *cardToEdit = [self.cards objectAtIndex:indexPath.section];
        self.deleteCardNumber = cardToEdit.internalBaseClassIdentifier;
    }else{
        //Notify that renaming failed
        return;
    }
    
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Are you sure you want to delete the card?" message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Delete", nil];
    alert.tag = 1001;
    [alert show];
}

- (IBAction)renameCardButtonPressed:(id)sender{
    
    if (![self isInternetConnectionAvailable])
        return;
    
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.cardsTableView];
    NSIndexPath *indexPath = [self.cardsTableView indexPathForRowAtPoint:buttonPosition];
    
    if (indexPath.section < self.cards.count && !addCardMode) {
        TravelCard *cardToEdit = [self.cards objectAtIndex:indexPath.section];
        self.renameCardNumber = cardToEdit.internalBaseClassIdentifier;
        self.renameCardName = cardToEdit.name;
    }else{
        //Notify that renaming failed
        return;
    }
    
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Rename your card to" message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Rename", nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    if (self.renameCardName != nil && self.renameCardName.length != 18) {
        [[alert textFieldAtIndex:0] setText:self.renameCardName];
    }
    alert.tag = 2002;
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag == 1001) {
        if (buttonIndex == 1) {
            //Go on and delete it.
            [self completeCardDeletion];
        }
    }else{/*alert is from text input*/
        if (buttonIndex == 1) {
            NSString *newName = [[alertView textFieldAtIndex:0] text];
            [self completeRenameCardTo:newName];
        }
    }
}

-(void)completeCardDeletion{
    [self indicateActivity:YES];
    
    TravelCard *cardToDelete = [self cardForCardNumber:self.deleteCardNumber];
    if (cardToDelete != nil){
        NSMutableArray *tempArray = [self.cards mutableCopy];
        [tempArray removeObject:cardToDelete];
        self.cards = tempArray;
        [self.cardsTableView reloadData];
    }
    
    triedLoginAlready = NO;
    self.currentProcessTask = ACCurrentProcessDeleteCard;
    [self loadLogginPage];
    
//    [self debugButtonPressed:self];
}

-(void)completeRenameCardTo:(NSString *)newName{
    if (![self isValidCardName:newName]) {
        //The normal banner cant be used because it dosn't work well with the disapearing action sheet
        [ReittiNotificationHelper showSimpleMessageWithTitle:@"Invalid card name!" andContent:@"Invalid card name. Card name can only contain 20 characters. The permitted symbols are numbers, letters and spaces."];
        return;
    }
    
    if ([self.renameCardName isEqualToString:newName]){
//        [ReittiNotificationHelper showErrorBannerMessage:@"The new name is the same as before." andContent:nil];
        [ReittiNotificationHelper showSimpleMessageWithTitle:@"The new name is the same as before."  andContent:nil];
        return;
    }
    
    self.renameCardName = newName;
    
    if ([self cardExistsWithName:self.renameCardName]){
//        [ReittiNotificationHelper showErrorBannerMessage:@"A card with that name exists already." andContent:nil];
        [ReittiNotificationHelper showSimpleMessageWithTitle:@"A card with that name exists already."  andContent:nil];
        return;
    }
    
    [self indicateActivity:YES];

    triedLoginAlready = NO;
    self.currentProcessTask = ACCurrentProcessRenameCard;
    [self loadLogginPage];
    
//    [self debugButtonPressed:self];
}

- (IBAction)canelAddCardButtonPressed:(id)sender {
    if (addCardMode) {
        addCardMode = NO;
        [self.cardsTableView reloadData];
    }
}

-(IBAction)debugButtonPressed:(id)sender{
    cardsTableView.hidden = !cardsTableView.hidden;
}

-(void)tableViewRefreshing{
    [self.refreshControl endRefreshing];
}

#pragma mark - Textviewdelegate methods
-(void)textFieldDidBeginEditing:(UITextField *)textField{
    
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [self loginButtonPressed:self];
    return YES;
}

#pragma mark - private helpers
- (NSString *)webHtml {
    NSString *htmlString = [webView stringByEvaluatingJavaScriptFromString:@"document.documentElement.outerHTML"];
    return htmlString;
}

-(void)loadLogginPage{
    if (![self isInternetConnectionAvailable]){
        [self setLastUpdateTime];
        return;
    }
    
    NSURL *url = [NSURL URLWithString:@"https://omamatkakortti.hsl.fi/Login.aspx"];
    NSMutableURLRequest *requestObj = [NSMutableURLRequest requestWithURL:url];
    [requestObj setValue:[NSString stringWithFormat:@"%@ Safari/528.16", [requestObj valueForHTTPHeaderField:@"User-Agent"]] forHTTPHeaderField:@"User_Agent"];
    [webView loadRequest:requestObj];
}

- (BOOL)isInternetConnectionAvailable {
    BOOL toReturn = YES;
    Reachability *internetReachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus netStatus = [internetReachability currentReachabilityStatus];
    
    if (netStatus == NotReachable) {
        [ReittiNotificationHelper showErrorBannerMessage:@"No internet connection" andContent:@"Active internet connection is required to use the service."];
        toReturn = NO;
        [self indicateActivity:NO];
        [loginActivityIndicator stopAnimating];
    }
    
    return toReturn;
}

-(BOOL)validateLoggin{
    BOOL invalid = NO;
    BOOL userNameMissing = NO;
    BOOL passwordMissing = NO;
    if (usernameTextbox.text == nil || [usernameTextbox.text isEqualToString:@""]) {
        userFieldIcon.image = [UIImage imageNamed:@"user-red-50.png"];
        invalid = YES;
        userNameMissing = YES;
    }else{
        userFieldIcon.image = [UIImage imageNamed:@"user-50.png"];
    }
    
    if (passwordTextbox.text == nil || [passwordTextbox.text isEqualToString:@""]) {
        passwordFieldIcon.image = [UIImage imageNamed:@"lock-red-50.png"];
        invalid = YES;
        passwordMissing = YES;
    }else{
        passwordFieldIcon.image = [UIImage imageNamed:@"lock-50.png"];
    }
    
    if (invalid) {
        infoLabel.hidden = NO;
        infoLabelIcon.hidden = NO;
        if (userNameMissing && passwordMissing) {
            infoLabel.text = @"Username and Password can't be empty";
        }else if (userNameMissing){
            infoLabel.text = @"Username can't be empty";
        }else{
            infoLabel.text = @"Password can't be empty";
        }
    }else{
        infoLabel.hidden = YES;
        infoLabelIcon.hidden = YES;
    }
    
    return !invalid;
}

-(BOOL)validateNewCardInfo{
    return YES;
}

-(TravelCard *)cardForCardNumber:(NSString *)cardNum{
    for (TravelCard *card in self.cards) {
        if ([card.internalBaseClassIdentifier isEqualToString:cardNum]) {
            return card;
        }
    }
    
    return nil;
}

-(BOOL)cardExistsWithNumber:(NSString *)cardNum{
    return [self cardForCardNumber:cardNum] != nil;
}

-(BOOL)cardExistsWithName:(NSString *)cardName{
    if (cardName == nil || [cardName isEqualToString:@""])
        return NO;
    
    for (TravelCard *card in self.cards) {
        if ([[card.name lowercaseString] isEqualToString:[cardName lowercaseString]]) {
            return YES;
        }
    }
    
    return NO;
}

-(BOOL)isValidCardName:(NSString *)name{
    if (name.length > 20)
        return NO;
    
    NSCharacterSet *alphaSet = [NSCharacterSet alphanumericCharacterSet];
    name  = [name stringByReplacingOccurrencesOfString:@" " withString:@""];
    return [[name stringByTrimmingCharactersInSet:alphaSet] isEqualToString:@""];
}

-(BOOL)isValidCardNumber:(NSString *)number{
    if (number.length != 18)
        return NO;
    
    NSCharacterSet *numericSet = [NSCharacterSet characterSetWithCharactersInString:@"1234567890"];
    number  = [number stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    return [[number stringByTrimmingCharactersInSet:numericSet] isEqualToString:@""];
}

-(BOOL)hasValidCredentials{
    return self.username != nil && self.password != nil;
}

-(void)reloadCards{
    self.currentProcessTask = ACCurrentProcessGetCards;
    ignoreWebChangesOnce = NO;
    triedLoginAlready = NO;
    [self loadLogginPage];
    
    [self indicateActivity:YES];
}

- (NSString *)stringByReplacingUnsafeCharsForJavaScriptIn:(NSString *)unsafeString{
    /*
     // This implementation does not work for finish characters
    const char *chars = [unsafeString UTF8String];
    NSMutableString *escapedString = [NSMutableString string];
    while (*chars)
    {
        if (*chars == '\\')
            [escapedString appendString:@"\\\\"];
        else if (*chars == '"')
            [escapedString appendString:@"\\\""];
        else if (*chars == '\'')
            [escapedString appendString:@"\\\'"];
        else
            [escapedString appendFormat:@"%c", *chars];
        ++chars;
    }
    
    return escapedString;
    */
    
    unsafeString = [unsafeString stringByReplacingOccurrencesOfString:@"\\" withString:@"\\\\"];
    unsafeString = [unsafeString stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
    unsafeString = [unsafeString stringByReplacingOccurrencesOfString:@"\'" withString:@"\\\'"];
    
    return unsafeString;
}

- (void)login {
//    NSString *jsFilePath = [[NSBundle mainBundle] pathForResource:@"logginJS" ofType:@"js"];
    NSString *jsFilePath = [[TravelCardManager sharedManager] loginJavaScript];
    
    //It is important to escape strings
    editorJsString = [NSString stringWithContentsOfFile:jsFilePath encoding:NSUTF8StringEncoding error:nil];
    editorJsString = [editorJsString stringByReplacingOccurrencesOfString:@"##USERNAME##" withString:[self stringByReplacingUnsafeCharsForJavaScriptIn:self.username]];
    editorJsString = [editorJsString stringByReplacingOccurrencesOfString:@"##PASSWORD##" withString:[self stringByReplacingUnsafeCharsForJavaScriptIn:self.password]];
    
    [webView stringByEvaluatingJavaScriptFromString:editorJsString];
    
    triedLoginAlready = YES;
}

- (void)logout {
    [self logoutWebPage: NO];
    
    triedLoginAlready = NO;
    self.password = nil;
    passwordTextbox.text = @"";
    infoLabel.hidden = YES;
    infoLabelIcon.hidden = YES;
    [TravelCardManager saveCredentialsWithUsername:self.username andPassword:nil];
}

- (void)logoutWebPage:(BOOL)handleChanges {
    NSString *jsFilePath = [[TravelCardManager sharedManager] logoutJavaScript];
    
    NSString *logoutJsString = [NSString stringWithContentsOfFile:jsFilePath encoding:NSUTF8StringEncoding error:nil];
    
    NSString *htmlString;
    htmlString = [self webHtml];
    if (![TravelCardManager isLoginScreen:htmlString]) {
        ignoreWebChangesOnce = !handleChanges;
        
        [webView stringByEvaluatingJavaScriptFromString:logoutJsString];
    }
}

- (void)changeToFullPageVersion:(BOOL)handleChanges {
    NSString *jsFilePath = [[TravelCardManager sharedManager] changeToFullVersionJavaScript];
    
    NSString *changeToFullVersionJS = [NSString stringWithContentsOfFile:jsFilePath encoding:NSUTF8StringEncoding error:nil];
    
    NSString *htmlString;
    htmlString = [self webHtml];
    if ([TravelCardManager isMobileVersion:htmlString]) {
        ignoreWebChangesOnce = !handleChanges;
        
        [webView stringByEvaluatingJavaScriptFromString:changeToFullVersionJS];
    }
}

-(void)addCard{
    //    NSString *jsFilePath = [[NSBundle mainBundle] pathForResource:@"logginJS" ofType:@"js"];
    NSString *jsFilePath = [[TravelCardManager sharedManager] createCardJavaScript];
    
    editorJsString = [NSString stringWithContentsOfFile:jsFilePath encoding:NSUTF8StringEncoding error:nil];
    editorJsString = [editorJsString stringByReplacingOccurrencesOfString:@"##NEWCARDNUMBER##" withString:[self stringByReplacingUnsafeCharsForJavaScriptIn:self.createCardNumber]];
    editorJsString = [editorJsString stringByReplacingOccurrencesOfString:@"##NEWCARDNAME##" withString:[self stringByReplacingUnsafeCharsForJavaScriptIn:self.createCardName]];
    
    //This won't reload the page
    [webView stringByEvaluatingJavaScriptFromString:editorJsString];
}

-(void)renameCard{
    //    NSString *jsFilePath = [[NSBundle mainBundle] pathForResource:@"logginJS" ofType:@"js"];
    NSString *jsFilePath = [[TravelCardManager sharedManager] renameCardJavaScript];
    
    editorJsString = [NSString stringWithContentsOfFile:jsFilePath encoding:NSUTF8StringEncoding error:nil];
    editorJsString = [editorJsString stringByReplacingOccurrencesOfString:@"##NEWCARDNUMBER##" withString:[self stringByReplacingUnsafeCharsForJavaScriptIn:self.renameCardNumber]];
    editorJsString = [editorJsString stringByReplacingOccurrencesOfString:@"##NEWCARDNAME##" withString:[self stringByReplacingUnsafeCharsForJavaScriptIn:self.renameCardName]];
    
    //This won't reload the page
    [webView stringByEvaluatingJavaScriptFromString:editorJsString];
}

-(void)deleteCard{
    //    NSString *jsFilePath = [[NSBundle mainBundle] pathForResource:@"logginJS" ofType:@"js"];
    NSString *jsFilePath = [[TravelCardManager sharedManager] deleteCardJavaScript];
    
    editorJsString = [NSString stringWithContentsOfFile:jsFilePath encoding:NSUTF8StringEncoding error:nil];
    editorJsString = [editorJsString stringByReplacingOccurrencesOfString:@"##CARDNUMBER##" withString:[self stringByReplacingUnsafeCharsForJavaScriptIn:self.deleteCardNumber]];
    
    //This won't reload the page
    [webView stringByEvaluatingJavaScriptFromString:editorJsString];
}

-(void)onLoginSuccessful{
    [self hideLoginView:YES animated:YES];
    [loginActivityIndicator stopAnimating];
    [self indicateActivity:NO];
    
    infoLabel.hidden = YES;
    infoLabelIcon.hidden = YES;
    
    [TravelCardManager saveCredentialsWithUsername:self.username andPassword:self.password];
    [TravelCardManager savePreviousValues:self.cards];
    [TravelCardManager saveLastUpdateTime:[NSDate date]];
    [self setLastUpdateTime];
    
}

-(void)onLoginFailed:(NSString *)errorMessage{
    infoLabel.hidden = NO;
    infoLabelIcon.hidden = NO;
    [loginActivityIndicator stopAnimating];
    [self indicateActivity:NO];
    
    infoLabel.text = errorMessage;
    [self setLastUpdateTime];
}

-(void)onCardParsingFailed:(NSString *)errorMessage withNotify:(BOOL)notify{
    infoLabel.hidden = NO;
    infoLabelIcon.hidden = NO;
    [loginActivityIndicator stopAnimating];
    [self indicateActivity:NO];
    
    infoLabel.text = errorMessage;
    [self setLastUpdateTime];
    
    if (notify) {
        [ReittiNotificationHelper showErrorBannerMessage:errorMessage andContent:nil];
    }
}

-(void)indicateActivity:(BOOL)inidicate{
    //While there is activity, diable all buttons,
    self.cardsTableView.allowsSelection = !inidicate;
    if (addCardBigButton != nil) {
        addCardBigButton.enabled = !inidicate;
    }
    
    if (addCardSmallButton != nil) {
        addCardSmallButton.enabled = !inidicate;
    }
    
    reloadButton.enabled = !inidicate;
    
//    updateTimeLabel.hidden = inidicate;
//    inidicate ? [miscActivityIndicator startAnimating] : [miscActivityIndicator stopAnimating];
    inidicate ? [SVProgressHUD show] : [SVProgressHUD dismiss];
}

-(void)setLastUpdateTime{
    if ([[TravelCardManager getLastUpdateTime] timeIntervalSinceNow] > -180) {
        updateTimeLabel.text = @"Updated just now";
    }else{
        updateTimeLabel.text = [NSString stringWithFormat:@"Last updated %@", [[ReittiDateFormatter sharedFormatter] formatPrittyDate:[TravelCardManager getLastUpdateTime]]];
    }
}

- (BOOL)cellIsSelected:(NSIndexPath *)indexPath {
    // Return whether the cell at the specified index path is selected or not
    NSNumber *selectedIndex = [selectedIndexes objectForKey:indexPath];
    return selectedIndex == nil ? FALSE : [selectedIndex boolValue];
}

//-(NSArray *)extractCardsJsonFromScripts:(NSArray *)scriptElements{
//    NSArray *parsedCards = [[NSArray alloc] init];
//    for (HTMLElement *element in scriptElements) {
//        if ([element.innerHTML containsString:@"parseJSON('"]) {
//            //Parse json from the inner HTML
//            NSLog(@"%@", element.innerHTML);
//            NSString *searchedString = element.innerHTML;
//            NSRange   searchedRange = NSMakeRange(0, [searchedString length]);
//            NSString *pattern = @".*?parseJSON\\('(.*)'\\).*";
//            NSError  *error = nil;
//            
//            NSRegularExpression* regex = [NSRegularExpression regularExpressionWithPattern: pattern options:0 error:&error];
//            NSArray* matches = [regex matchesInString:searchedString options:0 range: searchedRange];
//            for (NSTextCheckingResult* match in matches) {
//                NSString* matchText = [searchedString substringWithRange:[match range]];
//                NSLog(@"match: %@", matchText);
//                NSRange group1 = [match rangeAtIndex:1];
//                NSLog(@"group1: %@", [searchedString substringWithRange:group1]);
//                
//                NSString *jsonString = [searchedString substringWithRange:group1];
//                NSError *error = nil;
//                
//                NSData* data = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
//                parsedCards = [TravelCardManager cardsFromJSON:data error:&error];
//            }
//        }
//    }
//    
//    return parsedCards;
//}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
