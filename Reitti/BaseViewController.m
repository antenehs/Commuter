//
//  BaseViewController.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 9/6/17.
//  Copyright © 2017 Anteneh Sahledengel. All rights reserved.
//

#import "BaseViewController.h"

@interface BaseViewController ()

@end

@implementation BaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
}

-(void)setTitleViewSize:(CGSize)size {
    [self.navigationItem.titleView.widthAnchor constraintEqualToConstant:size.width].active = YES;
    [self.navigationItem.titleView.heightAnchor constraintEqualToConstant:size.height].active = YES;
}

-(void)setRightBarItemSize:(CGSize)size {
    [self.navigationItem.rightBarButtonItem.customView.widthAnchor constraintEqualToConstant:size.width].active = YES;
    [self.navigationItem.rightBarButtonItem.customView.heightAnchor constraintEqualToConstant:size.height].active = YES;
}

-(void)setLeftBarItemSize:(CGSize)size {
    [self.navigationItem.leftBarButtonItem.customView.widthAnchor constraintEqualToConstant:size.width].active = YES;
    [self.navigationItem.leftBarButtonItem.customView.heightAnchor constraintEqualToConstant:size.height].active = YES;
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
