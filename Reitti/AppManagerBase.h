//
//  AppManagerBase.h
//  Reitti
//
//  Created by Anteneh Sahledengel on 8/12/15.
//  Copyright © 2015 Anteneh Sahledengel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

//extern NSString *kUserDefaultsSuitNameForDeparturesWidget;
//extern NSString *kUserDefaultsSuitNameForRoutesWidget;

extern NSString *kUserDefaultsNamedBookmarksKey;
extern NSString *kUserDefaultsSavedStopsKey;
//extern NSString *kUserDefaultsSelectedSavedStopsKey;
extern NSString *kUserDefaultsStopSourceApiKey;
extern NSString *kUserDefaultsRouteSearchOptionsKey;

extern NSString *urlSpaceEscapingString;

extern NSString *kGoProDetailUrl;
extern NSString *kFeatureTrackingUrl;
extern NSString *kProAppAppstoreLink;
extern NSString *kProAppRateAppStoreLink;

@interface AppManagerBase : NSObject

+(BOOL)isNewInstallOrNewVersion;
+(BOOL)isNewInstall;
+(void)setCurrentAppVersion;
+(NSString *)currentAppVersion;

+(BOOL)isPreDigiTransitVersion;
+(BOOL)isProVersion;
+(BOOL)isDebugMode;

+(NSString *)nsUserDefaultsStopsWidgetSuitName;
+(NSString *)nsUserDefaultsRoutesExtensionSuitName;
+(NSString *)nsUserDefaultsWatchRoutesSuitName;

+(NSString *)appFullName;

+(UIImage *)roundedAppLogoSmall;
+(UIImage *)roundedAppLogoLarge;

+(UIImage *)appVersionPicture;

+(NSString *)appAppstoreLink;
+(NSString *)appAppstoreRateLink;
+(NSString *)matkakorttiAppAppstoreUrl;

+(NSString *)mainAppUrl;

//App theme
+(UIColor *)systemGreenColor;
+(UIColor *)systemOrangeColor;
+(UIColor *)systemBlueColor;
+(UIColor *)systemRedColor;
+(UIColor *)systemCyanColor;
+(UIColor *)systemPurpleColor;
+(UIColor *)systemYellowColor;

//Sounds
+(NSArray *)toneNames;
+(NSString *)defailtToneName;


@end
