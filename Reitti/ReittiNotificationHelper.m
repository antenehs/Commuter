//
//  ReittiNotificationHelper.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 8/4/15.
//  Copyright (c) 2015 Anteneh Sahledengel. All rights reserved.
//

#import "ReittiNotificationHelper.h"
#import "TSMessage.h"

@implementation ReittiNotificationHelper

+(void)showSimpleMessageWithTitle:(NSString *)title andContent:(NSString *)content{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title                                                                                    message:content
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
    [alertView show];
}

+(void)showSuccessBannerMessage:(NSString *)title andContent:(NSString *)content{
    [TSMessage showNotificationWithTitle:title
                                subtitle:content
                                    type:TSMessageNotificationTypeSuccess];
}

+(void)showErrorBannerMessage:(NSString *)title andContent:(NSString *)content{
    [TSMessage showNotificationWithTitle:title
                                subtitle:content
                                    type:TSMessageNotificationTypeError];
}

+(void)showWarningBannerMessage:(NSString *)title andContent:(NSString *)content{
    [TSMessage showNotificationWithTitle:title
                                subtitle:content
                                    type:TSMessageNotificationTypeWarning];
}

+(void)showInfoBannerMessage:(NSString *)title andContent:(NSString *)content{
    [TSMessage showNotificationWithTitle:title
                                subtitle:content
                                    type:TSMessageNotificationTypeMessage];
}

@end
