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

@end

@implementation TravelCardViewController

@synthesize refreshControl;
@synthesize cards,tableView;
@synthesize username, password;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    webView.delegate = self;
    
    triedLoginAlready = NO;
    ignoreWebChangesOnce = NO;
    
    UITapGestureRecognizer *loginViewTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(loginViewTapped:)];
    
    [logginView addGestureRecognizer:loginViewTapRecognizer];
    
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
        [self.tableView reloadData];
        
        self.username = [TravelCardManager savedUserName];
        self.password = [TravelCardManager savedPassword];
        
        [self setLastUpdateTime];
        
        [self loadLogginPage];
    }
}

-(void)viewDidAppear:(BOOL)animated{
    [self setLastUpdateTime];
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
    
    self.tableView.backgroundView = bluredBackViewContainer;
    self.tableView.backgroundColor = [UIColor clearColor];
}

#pragma mark - TableView methods
- (void)initRefreshControl{
    
    tableViewController.tableView = self.tableView;
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(tableViewRefreshing) forControlEvents:UIControlEventValueChanged];
    //    refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"Pull to Reload Routes"];
    tableViewController.refreshControl = self.refreshControl;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.cards.count > 0 ? self.cards.count : 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell;
    if (self.cards.count > 0) {
        cell = [self.tableView dequeueReusableCellWithIdentifier:@"cardCell"];
        
        TravelCard *card = [self.cards objectAtIndex:indexPath.section];
        
        UILabel *title = (UILabel *)[cell viewWithTag:1001];
        UILabel *balanceLabel = (UILabel *)[cell viewWithTag:1002];
        UILabel *ticketName = (UILabel *)[cell viewWithTag:1003];
        UILabel *ticketPeriod = (UILabel *)[cell viewWithTag:1004];
        UILabel *periodDays = (UILabel *)[cell viewWithTag:1005];
        UILabel *noPeriodLabel = (UILabel *)[cell viewWithTag:1006];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
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
        cell = [self.tableView dequeueReusableCellWithIdentifier:@"noCardsCell"];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

//-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
//    return 80;
//}

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
            //Check if it is mobile Version
            if ([TravelCardManager isMobileVersion:htmlString]) {
                [self changeToFullPageVersion:YES];
            }else{
                NSArray *tempArray = nil;
                
                if ([TravelCardManager tryParseCardsFromHtmlString:htmlString returnArray:&tempArray]) {
                    self.cards = tempArray;
                    [self.tableView reloadData];
                    
                    [self onLoginSuccessful];
                    
                    //Log out imidiately. Keep the webpage at login screen because it might time out
                    [self logoutWebPage:NO];
                }else{
                    NSLog(@"Parsing cards failed");
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

-(IBAction)debugButtonPressed:(id)sender{
    tableView.hidden = !tableView.hidden;
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
    NSURL *url = [NSURL URLWithString:@"https://omamatkakortti.hsl.fi/mobile/Login.aspx"];
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
