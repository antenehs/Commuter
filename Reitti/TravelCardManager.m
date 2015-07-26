//
//  TravelCardManager.m
//  
//
//  Created by Anteneh Sahledengel on 1/7/15.
//
//

#import "TravelCardManager.h"
#import "HTMLReader.h"
#import "HTMLDocument.h"
#import "HTMLElement.h"
#import "TravelCard.h"

@implementation TravelCardManager
+(id)sharedManager{
    static TravelCardManager *travelCardManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        travelCardManager = [[TravelCardManager alloc] init];
    });
    
    return travelCardManager;
}

-(id)init{
    self = [super init];
    
    if (self != nil) {
        [self testLoadPage];
    }
    
    return self;
    
}

+(void)saveCredentialsWithUsername:(NSString *)username andPassword:(NSString *)password{
    username = username != nil ? username : @"";
    password = password != nil ? password : @"";
    
    NSMutableDictionary *credsDictionary = [[NSMutableDictionary alloc] initWithObjects:@[username,password] forKeys:@[@"username", @"password"]];
    
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    
    if (standardUserDefaults) {
        [standardUserDefaults setObject:credsDictionary forKey:@"SavedCredentials"];
        [standardUserDefaults synchronize];
    }
}

+(NSString *)savedUserName{
    NSDictionary *savedCredentials = [[NSUserDefaults standardUserDefaults] objectForKey:@"SavedCredentials"];
    
    return [[savedCredentials objectForKey:@"username"] isEqualToString:@""] ? nil :[savedCredentials objectForKey:@"username"] ;
}

+(NSString *)savedPassword{
    NSDictionary *savedCredentials = [[NSUserDefaults standardUserDefaults] objectForKey:@"SavedCredentials"];
    
    return [[savedCredentials objectForKey:@"password"] isEqualToString:@""] ? nil :[savedCredentials objectForKey:@"password"] ;
}

+(void)savePreviousValues:(NSArray *)cardsArray{
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    
    if (standardUserDefaults) {
        NSMutableArray *array = [@[] mutableCopy];
        for (TravelCard *card in cardsArray) {
            [array addObject:[card dictionaryRepresentation]];
        }
        
        [standardUserDefaults setObject:array forKey:@"previousCardValues"];
        [standardUserDefaults synchronize];
    }
}

+(NSArray *)getPreviousValues{
    NSArray *savedValues = [[NSUserDefaults standardUserDefaults] objectForKey:@"previousCardValues"];
    
    NSMutableArray *array = [@[] mutableCopy];
    for (NSDictionary *dict in savedValues) {
        [array addObject:[[TravelCard alloc] initWithDictionary:dict]];
    }
    
    return array;
}

+(void)saveLastUpdateTime:(NSDate *)date{
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    
    if (standardUserDefaults) {
        [standardUserDefaults setObject:date forKey:@"lastUpdateDate"];
        [standardUserDefaults synchronize];
    }
}

+(NSDate *)getLastUpdateTime{
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"lastUpdateDate"];
}

+(BOOL)thereIsValidLoginInfo{
    return [TravelCardManager savedUserName] != nil && [TravelCardManager savedPassword] != nil;
}

-(NSString *)loginJavaScript{
    return [[NSBundle mainBundle] pathForResource:@"logginJS" ofType:@"js"];
}

-(NSString *)logoutJavaScript{
    return [[NSBundle mainBundle] pathForResource:@"logoutJS" ofType:@"js"];
}

-(NSString *)createCardJavaScript{
    return [[NSBundle mainBundle] pathForResource:@"createCardJS" ofType:@"js"];
}

-(NSString *)deleteCardJavaScript{
    return [[NSBundle mainBundle] pathForResource:@"deleteCardJS" ofType:@"js"];
}
-(NSString *)renameCardJavaScript{
    return [[NSBundle mainBundle] pathForResource:@"renameCardJS" ofType:@"js"];
}

-(NSString *)changeToFullVersionJavaScript{
    return [[NSBundle mainBundle] pathForResource:@"changeToFullVersionJS" ofType:@"js"];
}

+ (NSArray *)cardsFromJSON:(NSData *)objectNotation error:(NSError **)error{
    NSError *localError = nil;
    NSArray *parsedObject = [NSJSONSerialization JSONObjectWithData:objectNotation options:0 error:&localError];
    
    if (localError != nil) {
        *error = localError;
        return nil;
    }
    
    NSMutableArray *cards = [[NSMutableArray alloc] init];
    
    for (NSDictionary *cardsDict in parsedObject) {
        TravelCard *card = [[TravelCard alloc] initWithDictionary:cardsDict];
        
        [cards addObject:card];
    }
    
    return cards;
}

+(NSArray *)parseCardsFromHtmlString:(NSString *)htmlString{
//    NSString *documentString = [webView stringByEvaluatingJavaScriptFromString:@"document.documentElement.outerHTML"];
    HTMLDocument *home = [HTMLDocument documentWithString:htmlString];
    NSArray *scripts = [home nodesMatchingSelector:@"script"];
    
    NSArray *returnArray = [[NSArray alloc] init];
    
    [self extractCardsJsonFromScripts:scripts parsedCards:&returnArray];
    
    return returnArray;
}

+(BOOL)tryParseCardsFromHtmlString:(NSString *)htmlString returnArray:(NSArray **)returnArray{
    //    NSString *documentString = [webView stringByEvaluatingJavaScriptFromString:@"document.documentElement.outerHTML"];
    HTMLDocument *home = [HTMLDocument documentWithString:htmlString];
    NSArray *scripts = [home nodesMatchingSelector:@"script"];
    
    if (scripts == nil || scripts.count == 0) {
        return NO;
    }
    
    //Check there is no error message.
    if ([self parseErrorMessage:htmlString] != nil) {
        return NO;
    }
    
    *returnArray = [[NSArray alloc] init];
    
    return [self extractCardsJsonFromScripts:scripts parsedCards:returnArray];
}

+(NSString *)parseErrorMessage:(NSString *)htmlString {
    //Check if login failed
    NSString *wrongCredError = @"Wrong username or password or the new user account has not been activated";
    NSString *requestDataNotFound = @"The requested data was not found. Unable to establish connection to customer register.";
    NSString *invalidCardNameError = @"Invalid card name. Card name can only contain 20 characters. The permitted symbols are numbers, letters and spaces.";
//    NSString *cardNotFoundError = @"The requested data was not found. Unable to establish connection to customer register.";
    NSString *defaultErrorMess = @"Error occured connecting to Oma Matkakortti. Try again later.";
    @try {
        HTMLDocument *home = [HTMLDocument documentWithString:htmlString];
        HTMLElement *validationSummary = [home firstNodeMatchingSelector:@"#Etuile_mainValidationSummary"];
        if (validationSummary != nil) {
            //There is validation error summary
            HTMLElement *errorList = [validationSummary firstNodeMatchingSelector:@"ul"];
            if (errorList != nil && errorList.childElementNodes.count > 0) {
                for (int i = 0; i < errorList.childElementNodes.count; i++) {
                    //always ignore the last error because it always complains about the browser
                    if (i == errorList.childElementNodes.count - 1 && errorList.childElementNodes.count > 1) {
                        //Return default error
                        return defaultErrorMess;
                    }
                    
                    HTMLElement *firstErrorNode = errorList.childElementNodes[i];
                    if ([[firstErrorNode.innerHTML lowercaseString] containsString:@"username"] ||
                        [[firstErrorNode.innerHTML lowercaseString] containsString:@"password"] ||
                        [[firstErrorNode.innerHTML lowercaseString] containsString:@"käyttäjätunnus"] ||
                        [[firstErrorNode.innerHTML lowercaseString] containsString:@"salasana"]) {
                        
                        return wrongCredError;
                    }
                    
                    if ([[firstErrorNode.innerHTML lowercaseString] containsString:@"he requested data"] ||
                        [[firstErrorNode.innerHTML lowercaseString] containsString:@"yytämääsi tietoa ei löytynyt"]) {
                        
                        return requestDataNotFound;
                    }
                    
                    if ([[firstErrorNode.innerHTML lowercaseString] containsString:@"nvalid card name"] ||
                        [[firstErrorNode.innerHTML lowercaseString] containsString:@"ortin nimi ei kelpaa"]) {
                        
                        return invalidCardNameError;
                    }
                }
            }else{
                //Return default error
                if (errorList.childElementNodes.count == 1) {
                    HTMLElement *firstErrorNode = errorList.childElementNodes[0];
                    return firstErrorNode.innerHTML != nil ? firstErrorNode.innerHTML : defaultErrorMess;
                }
                return defaultErrorMess;
            }
        }
    }
    @catch (NSException *exception) {
        return defaultErrorMess;
    }
    
    return nil;
}

+(BOOL)isLoginScreen:(NSString *)htmlString{
    HTMLDocument *home = [HTMLDocument documentWithString:htmlString];
    HTMLElement *loginForm = [home firstNodeMatchingSelector:@"#Etuile_MainContent_LoginControl_LoginForm_UserName"];
    
    return loginForm != nil;
}

+(BOOL)isMobileVersion:(NSString *)htmlString{
    HTMLDocument *home = [HTMLDocument documentWithString:htmlString];
    HTMLElement *fullVersionLink = [home firstNodeMatchingSelector:@"#Etuile_FullVersionLink"];
    
    return fullVersionLink != nil;
}

//Returns true if script with JSON object is found
+(BOOL)extractCardsJsonFromScripts:(NSArray *)scriptElements parsedCards:(NSArray **)parsedCards{
    
    BOOL scriptMachFound = NO;
    for (HTMLElement *element in scriptElements) {
        if ([element.innerHTML containsString:@"parseJSON('"]) {
            scriptMachFound = YES;
            //Parse json from the inner HTML
//            NSLog(@"%@", element.innerHTML);
            NSString *searchedString = element.innerHTML;
            NSRange   searchedRange = NSMakeRange(0, [searchedString length]);
            NSString *pattern = @".*?parseJSON\\('(.*)'\\).*";
            NSError  *error = nil;
            
            NSRegularExpression* regex = [NSRegularExpression regularExpressionWithPattern: pattern options:0 error:&error];
            NSArray* matches = [regex matchesInString:searchedString options:0 range: searchedRange];
            for (NSTextCheckingResult* match in matches) {
                NSString* matchText = [searchedString substringWithRange:[match range]];
//                NSLog(@"match: %@", matchText);
                NSRange group1 = [match rangeAtIndex:1];
//                NSLog(@"group1: %@", [searchedString substringWithRange:group1]);
                
                NSString *jsonString = [searchedString substringWithRange:group1];
                NSError *error = nil;
                
                NSData* data = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
                *parsedCards = [TravelCardManager cardsFromJSON:data error:&error];
            }
        }
    }
    
    return scriptMachFound;
}

-(void)testLoadPage{
    // Load a web page.
    NSURL *URL = [NSURL URLWithString:@"https://omamatkakortti.hsl.fi/mobile/Login.aspx"];
    NSURLSession *session = [NSURLSession sharedSession];
    [[session dataTaskWithURL:URL completionHandler:
      ^(NSData *data, NSURLResponse *response, NSError *error) {
          NSString *contentType = nil;
          if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
              NSDictionary *headers = [(NSHTTPURLResponse *)response allHeaderFields];
              contentType = headers[@"Content-Type"];
          }
          HTMLDocument *home = [HTMLDocument documentWithData:data
                                            contentTypeHeader:contentType];
          HTMLElement *loginForm = [home firstNodeMatchingSelector:@"#aspnetForm"];
          HTMLElement *userName = [home firstNodeMatchingSelector:@"#Etuile_MainContent_LoginControl_LoginForm_UserName"];
          HTMLElement *password = [home firstNodeMatchingSelector:@"#Etuile_MainContent_LoginControl_LoginForm_Password"];
          
          HTMLElement *loginButton = [home firstNodeMatchingSelector:@"#Etuile_MainContent_LoginControl_LoginForm_LoginButton"];
          
          userName.textContent = @"antenehs";
          password.textContent = @"Bsonofgod.1";
          
          NSString * onClick = loginButton.attributes[@"onclick"];
//          NSCharacterSet *whitespace = [NSCharacterSet whitespaceAndNewlineCharacterSet];
//          NSLog(@"%@", [div.textContent stringByTrimmingCharactersInSet:whitespace]);
          // => A WHATWG-compliant HTML parser in Objective-C.
      }] resume];
}

@end
