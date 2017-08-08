//
//  InAppPurchaseViewController.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 7/27/17.
//  Copyright © 2017 Anteneh Sahledengel. All rights reserved.
//

#import "InAppPurchaseViewController.h"
#import "SwiftHeaders.h"
#import "ASA_Helpers.h"
#import "NSLayoutConstraint+Helper.h"
#import "AppFeatureManager.h"


@interface InAppPurchaseViewController ()

@property (strong, nonatomic) IBOutlet UIView *childContainer;
@property (strong, nonatomic) IBOutlet UIButton *purchaseButton;
@property (strong, nonatomic) IBOutlet UIButton *restoreButton;

@end

@implementation InAppPurchaseViewController

+(instancetype)instantiate {
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"InAppPurchase" bundle:nil];
    InAppPurchaseViewController *vc = [sb instantiateInitialViewController];
    vc.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    
    return vc;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setupNavigationBar];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self setupView];
}

- (void)setupNavigationBar {
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    [self.navigationController.navigationBar setTranslucent:YES];
    self.navigationController.navigationBar.backgroundColor = [UIColor clearColor];
    self.navigationController.view.backgroundColor = [UIColor clearColor];
    
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor]};
    
    UIBarButtonItem *closeItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"close-button-white"] asa_resizedToSize:CGSizeMake(25, 25)] style:UIBarButtonItemStylePlain target:self action:@selector(closeBarButtonTapped)];
    closeItem.tintColor = [UIColor whiteColor];
    
    self.navigationItem.rightBarButtonItem = closeItem;
}

-(void)setupView {
    
    [self.view asa_SetBlurredBackgroundWithImageNamed:nil];
    
    ProFeaturesViewController *childController = [ProFeaturesViewController main];
    [self addChildViewController:childController];
    //
    childController.view.translatesAutoresizingMaskIntoConstraints = NO;
    [_childContainer addSubview:childController.view];
    [_childContainer addConstraints:[NSLayoutConstraint superViewFillingConstraintsForView:childController.view]];
    
    [_childContainer updateConstraints];
    [_childContainer layoutIfNeeded];
    [_childContainer setClipsToBounds:YES];
    
    _purchaseButton.layer.cornerRadius = 15.0;
}

#pragma mark - Actions
-(void)closeBarButtonTapped {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)purchaseButtonTapped:(id)sender {
    [[AppFeatureManager sharedManager] purchaseProFeaturesWithCompletionBlock:^(NSString *errorMessage) {
        if (errorMessage) {
            [ReittiNotificationHelper showSimpleMessageWithTitle:@"Proccessing purchase failed." andContent:errorMessage inController:self];
        }
    }];
}

- (IBAction)restoreButtonTapped:(id)sender {
    [[AppFeatureManager sharedManager] restorePurchasesWithCompletionBlock:^(NSString *errorMessage) {
        if (errorMessage) {
            [ReittiNotificationHelper showSimpleMessageWithTitle:@"Restoring purchase failed." andContent:errorMessage inController:self];
        }
    }];
}


-(void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
