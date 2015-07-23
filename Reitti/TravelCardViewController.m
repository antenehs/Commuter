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
//#import "HTMLReader.h"
//#import "HTMLDocument.h"
//#import "HTMLElement.h"
#import "TravelCard.h"
#import "PeriodProductState.h"

@interface TravelCardViewController ()

- (BOOL)cellIsSelected:(NSIndexPath *)indexPath;

@end

NSString *ACCurrentProcessGetCards = @"ACCurrentProcessGetCards";
NSString *ACCurrentProcessCreateCard = @"ACCurrentProcessCreateCard";
//CGFloat KDefaultCardCellHeight = 140.0f;

@implementation TravelCardViewController

#define kCellHeight 140.0

@synthesize refreshControl;
@synthesize cards,cardsTableView;
@synthesize username, password;
@synthesize createCardNumber, createCardName;
@synthesize currentProcessTask;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    webView.delegate = self;
    self.cardsTableView.delegate = self;
    
    triedLoginAlready = NO;
    ignoreWebChangesOnce = NO;
    
    selectedIndexes = [[NSMutableDictionary alloc] init];
    
    self.currentProcessTask = ACCurrentProcessGetCards;
    
    UITapGestureRecognizer *loginViewTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(loginViewTapped:)];
    
    [logginView addGestureRecognizer:loginViewTapRecognizer];
    
    UITapGestureRecognizer *tableViewTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tableViewTapped:)];
    
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
        
        [self loadLogginPage];
    }
}

-(void)viewDidAppear:(BOOL)animated{
    [self setLastUpdateTime];
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
    usernameTextbox.text = @"rebekah";
    passwordTextbox.text = @"Bsonofgod.1";
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
        cell = [self.cardsTableView dequeueReusableCellWithIdentifier:@"cardCell"];
        
        TravelCard *card = [self.cards objectAtIndex:indexPath.section];
        
        UILabel *title = (UILabel *)[cell viewWithTag:1001];
        UILabel *balanceLabel = (UILabel *)[cell viewWithTag:1002];
        UILabel *ticketName = (UILabel *)[cell viewWithTag:1003];
        UILabel *ticketPeriod = (UILabel *)[cell viewWithTag:1004];
        UILabel *periodDays = (UILabel *)[cell viewWithTag:1005];
        UILabel *noPeriodLabel = (UILabel *)[cell viewWithTag:1006];
        
        title.text = card.name != nil ? card.name : card.internalBaseClassIdentifier;
        if (card.remainingMoney != 0 && card.remainingMoney > 0) {
            balanceLabel.text = [NSString stringWithFormat:@"%@ €", [ReittiStringFormatter formatRoundedNumberFromDouble:card.remainingMoney roundDigits:2 androundUp:NO]];
        }else{
            balanceLabel.text = @"-";
        }
        
        if (card.periodProductState.startDate != nil) {
            NSDate *startDate = [card getPeriodStartDate];
            NSDate *expiryDate = [card getPeriodEndDate];
            
            periodDays.text = [NSString stringWithFormat:@"%d days", (int)[RettiDataManager daysBetweenDate:[NSDate date] andDate:expiryDate]];
            ticketPeriod.text = [NSString stringWithFormat:@"%@ - %@",[ReittiStringFormatter formatFullDate:startDate], [ReittiStringFormatter formatFullDate:expiryDate]];
            ticketName.text = card.periodProductState.productName;
            
            noPeriodLabel.hidden = YES;
            ticketName.hidden = NO;
            ticketPeriod.hidden = NO;
        }else{
            noPeriodLabel.hidden = NO;
            ticketName.hidden = YES;
            ticketPeriod.hidden = YES;
            
            periodDays.text = @"-";
        }
    }else{
        cell = [self.cardsTableView dequeueReusableCellWithIdentifier:@"noCardsCell"];
        UIButton *addCardButton = (UIButton *)[cell viewWithTag:1003];
        UIButton *addCardButton2 = (UIButton *)[cell viewWithTag:1008];
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
            return kCellHeight * 2.0;
        }
        return 140;
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
                    }else{
                        NSLog(@"Parsing cards failed");
                    }
                }
                
                if (self.currentProcessTask == ACCurrentProcessCreateCard) {
                    [self addCard];
                    //TODO: 1: Check if card creation is successful
                    //2: Clear text fields
                    self.currentProcessTask = ACCurrentProcessGetCards;
                    
                    [webView reload];
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
    
    if (!loginActivityIndicator.isAnimating && [self hasValidCredentials]) {
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
    ignoreWebChangesOnce = NO;
    triedLoginAlready = NO;
    [webView reload];
    
//    if (![self isInternetConnectionAvailable])
//    return;
//    
//    [self logoutWebPage:YES];
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
        //Temp for testing
//        cardNameTextbox.text = @"New Card 1";
        
        if ([cardNumberTextbox.text isEqualToString: @"924620001149570011"]) {
            cardNumberTextbox.text = @"924620001111360144";
        }else{
            cardNumberTextbox.text = @"924620001149570011";
        }
        
        self.createCardNumber = cardNumberTextbox.text;
        self.createCardName = cardNameTextbox.text;
        
        if (self.createCardNumber == nil || [self.createCardNumber isEqualToString:@""]) {
            [ReittiNotificationHelper showErrorBannerMessage:@"Travel card number is required." andContent:nil];
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
        
        if (![self isInternetConnectionAvailable])
            return;
        
        [self resignAllFirstResponders];
        triedLoginAlready = NO;
        self.currentProcessTask = ACCurrentProcessCreateCard;
        [self loadLogginPage];
        
        [self debugButtonPressed:self];
        
        //TODO: Set current activity type
    }
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

-(BOOL)cardExistsWithNumber:(NSString *)cardNum{
    for (TravelCard *card in self.cards) {
        if ([card.internalBaseClassIdentifier isEqualToString:cardNum]) {
            return YES;
        }
    }
    
    return NO;
}

-(BOOL)cardExistsWithName:(NSString *)cardName{
    if (cardName == nil || [cardName isEqualToString:@""])
        return NO;
    
    for (TravelCard *card in self.cards) {
        if ([card.name isEqualToString:cardName]) {
            return YES;
        }
    }
    
    return NO;
}

-(BOOL)hasValidCredentials{
    return self.username != nil && self.password != nil;
}

- (void)login {
//    NSString *jsFilePath = [[NSBundle mainBundle] pathForResource:@"logginJS" ofType:@"js"];
    NSString *jsFilePath = [[TravelCardManager sharedManager] loginJavaScript];
    
    editorJsString = [NSString stringWithContentsOfFile:jsFilePath encoding:NSUTF8StringEncoding error:nil];
    editorJsString = [editorJsString stringByReplacingOccurrencesOfString:@"##USERNAME##" withString:self.username];
    editorJsString = [editorJsString stringByReplacingOccurrencesOfString:@"##PASSWORD##" withString:self.password];
    
    [webView stringByEvaluatingJavaScriptFromString:editorJsString];
    
    triedLoginAlready = YES;
}

- (void)logout {
    [self logoutWebPage: NO];
    
    triedLoginAlready = NO;
    self.password = nil;
    passwordTextbox.text = @"";
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
    editorJsString = [editorJsString stringByReplacingOccurrencesOfString:@"##NEWCARDNUMBER##" withString:self.createCardNumber];
    editorJsString = [editorJsString stringByReplacingOccurrencesOfString:@"##NEWCARDNAME##" withString:self.createCardName];
    
    //This won't reload the page
    [webView stringByEvaluatingJavaScriptFromString:editorJsString];
}

-(void)onLoginSuccessful{
    [self hideLoginView:YES animated:YES];
    [loginActivityIndicator stopAnimating];
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
    
    infoLabel.text = errorMessage;
}

-(void)setLastUpdateTime{
    if ([[TravelCardManager getLastUpdateTime] timeIntervalSinceNow] > -180) {
        updateTimeLabel.text = @"Updated just now";
    }else{
        updateTimeLabel.text = [NSString stringWithFormat:@"Last updated %@", [ReittiStringFormatter formatPrittyDate:[TravelCardManager getLastUpdateTime]]];
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
