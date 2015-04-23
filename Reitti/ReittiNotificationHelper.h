//
//  ReittiNotificationHelper.h
//  Reitti
//
//  Created by Anteneh Sahledengel on 8/4/15.
//  Copyright (c) 2015 Anteneh Sahledengel. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ReittiNotificationHelper : NSObject

+(void)showSimpleMessageWithTitle:(NSString *)title andContent:(NSString *)content;

+(void)showSuccessBannerMessage:(NSString *)title andContent:(NSString *)content;
+(void)showErrorBannerMessage:(NSString *)title andContent:(NSString *)content;
+(void)showWarningBannerMessage:(NSString *)title andContent:(NSString *)content;
+(void)showInfoBannerMessage:(NSString *)title andContent:(NSString *)content;

@end
