//
//  ReittiNotificationHelper.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 8/4/15.
//  Copyright (c) 2015 Anteneh Sahledengel. All rights reserved.
//

#import "ReittiNotificationHelper.h"
#import "TSMessage.h"
#import "AppManager.h"
#import <StoreKit/StoreKit.h>

@implementation ReittiNotificationHelper

#pragma mark - review
+(void)showRateAppNotificationInController:(UIViewController *)viewController {
    int appOpenCount = [AppManager getAndIncrimentAppOpenCountForRating];
    
    if (appOpenCount < 5 || [AppManager isNewInstallOrNewVersion]) return;
    
    if ([SKStoreReviewController class]) {
        [SKStoreReviewController requestReview];
        [AppManager setAppOpenCountForRating:-8];
        return;
    }
    
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Enjoy Using The App?"
                                                                   message:@"The gift of 5 little starts is satisfying for both of us more than you think."
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"Rate" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {
                                                              [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[AppManager appAppstoreRateLink]]];
                                                              [AppManager setAppOpenCountForRating:-50];
                                                              
                                                          }];
    
    UIAlertAction* laterAction = [UIAlertAction actionWithTitle:@"Maybe later" style:UIAlertActionStyleCancel
                                                        handler:^(UIAlertAction * action) {
                                                            [AppManager setAppOpenCountForRating:-8];
                                                        }];
    
    [alert addAction:laterAction];
    [alert addAction:defaultAction];
    [viewController presentViewController:alert animated:YES completion:nil];
}

#pragma mark - Generic notifs
+(void)showSimpleMessageWithTitle:(NSString *)title andContent:(NSString *)content inController:(UIViewController *)viewController {
    UIAlertController *controller = [UIAlertController alertControllerWithTitle:title message:content preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) { }];
    
    [controller addAction:okAction];
    
    [viewController presentViewController:controller animated:YES completion:nil];
}



#pragma mark - banner notif
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
