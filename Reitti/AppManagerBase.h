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

+(BOOL)isProVersion;

+(NSString *)iosDeviceName;
+(NSString *)iosDeviceModel;
+(NSString *)iosVersionNumber;
+(NSString *)iosDeviceUniqueIdentifier;

+(NSString *)nsUserDefaultsStopsWidgetSuitName;
+(NSString *)nsUserDefaultsRoutesWidgetSuitName;

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

//Sounds
+(NSArray *)toneNames;
+(NSString *)defailtToneName;


@end
