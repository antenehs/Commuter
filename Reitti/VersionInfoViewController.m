//
//  VersionInfoViewController.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 20/4/15.
//  Copyright (c) 2015 Anteneh Sahledengel. All rights reserved.
//

#import "VersionInfoViewController.h"

@interface VersionInfoViewController ()

@end

@implementation VersionInfoViewController
@synthesize webView;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    NSString *htmlFile = [[NSBundle mainBundle] pathForResource:@"versionInfo" ofType:@"html"];
    NSString* htmlString = [NSString stringWithContentsOfFile:htmlFile encoding:NSUTF8StringEncoding error:nil];
    [webView loadHTMLString:htmlString baseURL:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
