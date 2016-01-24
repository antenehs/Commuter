//
//  ReittiEmailAndShareManager.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 24/1/16.
//  Copyright © 2016 Anteneh Sahledengel. All rights reserved.
//

#import "ReittiEmailAndShareManager.h"
#import "AppManager.h"
#import "RettiDataManager.h"

NSString *ewketAppsEmailAddress = @"ewketapps@gmail.com";

@interface ReittiEmailAndShareManager ()

@property (nonatomic, strong)RettiDataManager *reittiDataManager;

@end

@implementation ReittiEmailAndShareManager

+(id)sharedManager{
    static ReittiEmailAndShareManager *sharedManager = nil;
    static dispatch_once_t oncetoken;
    
    dispatch_once(&oncetoken, ^{
        sharedManager = [[ReittiEmailAndShareManager alloc] init];
    });
    
    return sharedManager;
}

-(id)init{
    self = [super init];
    
    if (self) {
        self.reittiDataManager = [[RettiDataManager alloc] init];
    }
    
    return self;
}

-(MFMailComposeViewController *)mailComposeVcForFeatureRequestEmail{
    NSString *subject = [NSString stringWithFormat:@"[%@ Feature Request] - ", kAppFullName];
    
    return [self basicMaincomposeVcWithSubject:subject];
}

-(MFMailComposeViewController *)mailComposeVcForBugReportEmail{
    NSString *subject = [NSString stringWithFormat:@"[%@ Bug Report] - ", kAppFullName];
    
    MFMailComposeViewController *mc = [self basicMaincomposeVcWithSubject:subject];
//    [mc addAttachmentData:[self debugTextFileData] mimeType:@"text/plain" fileName:@"Debug.txt"];
    [mc setMessageBody:[self debugText] isHTML:NO];
    
    return mc;
}

-(MFMailComposeViewController *)mailComposeVcForHiEmail{
    NSString *subject = [NSString stringWithFormat:@"[%@ - Hi] - ", kAppFullName];
    
    return [self basicMaincomposeVcWithSubject:subject];
}

-(SLComposeViewController *)slComposeVcForFacebook{
    SLComposeViewController *controller = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
    
    [controller setInitialText:@"All the tool you need for conquering public transport in the Helsinki and Tampere regions."];
    [controller addURL:[NSURL URLWithString:@"https://www.facebook.com/Commuter-Reittiopas-ja-Aikataulut-144730139192404/"]];
    //        [controller addImage:[UIImage imageNamed:@"app-icon-v-2.4.png"]];
    
    return controller;
}

-(SLComposeViewController *)slComposeVcForTwitter{
    SLComposeViewController *tweetSheet = [SLComposeViewController
                                           composeViewControllerForServiceType:SLServiceTypeTwitter];
    [tweetSheet setInitialText:@"All the tool you need for conquering public transport in the Helsinki and Tampere regions."];
    [tweetSheet addURL:[NSURL URLWithString:[AppManager appAppstoreLink]]];
//    [tweetSheet addImage:[UIImage imageNamed:@"app-pro-logo-rounded2.png"]];
    
    return tweetSheet;
}

#pragma mark - Helpers

- (MFMailComposeViewController *)basicMaincomposeVcWithSubject:(NSString *)subject{
    NSString *emailTitle = subject;
    // Email Content
    NSString *messageBody = @"";
    // To address
    NSArray *toRecipents = [NSArray arrayWithObject:ewketAppsEmailAddress];
    
    MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
    [mc setSubject:emailTitle];
    [mc setMessageBody:messageBody isHTML:NO];
    [mc setToRecipients:toRecipents];
    
    return mc;
}

- (NSData *)debugTextFileData{
    NSArray *paths = NSSearchPathForDirectoriesInDomains
    (NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    //make a file name to write the data to using the documents directory:
    NSString *fileName = [NSString stringWithFormat:@"%@/Debug.txt",
                          documentsDirectory];
    //create content - four lines of text
    NSString *content = [self debugText];
    //save content to the documents directory
    [content writeToFile:fileName
              atomically:NO
                encoding:NSStringEncodingConversionAllowLossy
                   error:nil];
    
    NSData *myData = [NSData dataWithContentsOfFile:fileName];
    
    return myData;
}

- (NSString *)debugText{
    NSMutableString *debugText = [@"" mutableCopy];
    
    [debugText appendString:@"\n\n\n\n\n\n=========DEBUG INFO=========\n\n"];
    [debugText appendString:[NSString stringWithFormat:@"App Version: %@\n", [AppManager currentAppVersion]]];
    [debugText appendString:[NSString stringWithFormat:@"iOS Version: %@\n", [AppManager iosVersionNumber]]];
    [debugText appendString:[NSString stringWithFormat:@"Device: %@\n\n", [AppManager iosDeviceModel]]];
    
    [debugText appendString:[NSString stringWithFormat:@"Region: %u\n\n", [self.reittiDataManager userLocationRegion]]];
    [debugText appendString:@"============END============\n\n"];
    
    return debugText;
}


@end
