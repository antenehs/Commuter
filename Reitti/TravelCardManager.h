//
//  TravelCardManager.h
//  
//
//  Created by Anteneh Sahledengel on 1/7/15.
//
//

#import <Foundation/Foundation.h>

@interface TravelCardManager : NSObject
+(id)sharedManager;

-(id)init;

+(void)saveCredentialsWithUsername:(NSString *)username andPassword:(NSString *)password;
+(NSString *)savedUserName;
+(NSString *)savedPassword;

+(void)savePreviousValues:(NSArray *)cardsArray;
+(NSArray *)getPreviousValues;

+(void)saveLastUpdateTime:(NSDate *)date;
+(NSDate *)getLastUpdateTime;

+(BOOL)thereIsValidLoginInfo;

//JS Methods
-(NSString *)loginJavaScript;
-(NSString *)logoutJavaScript;
-(NSString *)changeToFullVersionJavaScript;

//HTML scraping
+(NSArray *)parseCardsFromHtmlString:(NSString *)htmlString;
+(BOOL)tryParseCardsFromHtmlString:(NSString *)htmlString returnArray:(NSArray **)returnArray;
+(NSString *)parseErrorMessage:(NSString *)htmlString;
+(BOOL)isLoginScreen:(NSString *)htmlString;
+(BOOL)isMobileVersion:(NSString *)htmlString;

+(NSArray *)cardsFromJSON:(NSData *)objectNotation error:(NSError **)error;

@end
