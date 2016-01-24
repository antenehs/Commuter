//
//  ReittiEmailAndShareManager.h
//  Reitti
//
//  Created by Anteneh Sahledengel on 24/1/16.
//  Copyright © 2016 Anteneh Sahledengel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MessageUI/MessageUI.h>
#import <Social/Social.h>

@interface ReittiEmailAndShareManager : NSObject
+(id)sharedManager;

-(MFMailComposeViewController *)mailComposeVcForFeatureRequestEmail;
-(MFMailComposeViewController *)mailComposeVcForBugReportEmail;
-(MFMailComposeViewController *)mailComposeVcForHiEmail;

-(SLComposeViewController *)slComposeVcForFacebook;
-(SLComposeViewController *)slComposeVcForTwitter;

@end
