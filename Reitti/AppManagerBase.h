//
//  AppManagerBase.h
//  Reitti
//
//  Created by Anteneh Sahledengel on 8/12/15.
//  Copyright © 2015 Anteneh Sahledengel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

extern NSString *kUserDefaultsSuitNameForDeparturesWidget;
extern NSString *kUserDefaultsSuitNameForRoutesWidget;

extern NSString *kUserDefaultsNamedBookmarksKey;
extern NSString *kUserDefaultsSavedStopsKey;

extern NSString *urlSpaceEscapingString;

@interface AppManagerBase : NSObject

+(BOOL)isNewInstallOrNewVersion;
+(BOOL)isNewInstall;
+(void)setCurrentAppVersion;

+(NSString *)iosDeviceModel;
+(NSString *)iosVersionNumber;

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
