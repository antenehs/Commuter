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
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

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
    [self indicateActivity:NO];
    
    //Removed for now.
    self.restoreButton.hidden = YES;
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
    
    NSString *priceString = [[AppFeatureManager sharedManager] formattedProFeaturesPrice];
    NSString *buttonTitle = @"GO PRO";
    if (priceString) buttonTitle = [NSString stringWithFormat:@"GO PRO (%@)", priceString];

    [_purchaseButton setTitle:buttonTitle
                     forState:UIControlStateNormal];
    _purchaseButton.layer.cornerRadius = 15.0;
}

-(void)indicateActivity:(BOOL)indicate {
    indicate ? [self.activityIndicator startAnimating] : [self.activityIndicator stopAnimating];
}

#pragma mark - Actions
-(void)closeBarButtonTapped {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)purchaseButtonTapped:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:kProAppAppstoreLink]
                                       options:@{}
                             completionHandler:^(BOOL success) {
                                [self closeBarButtonTapped];
                             }];
    
    /*
     //Removed for now. No in app pirchase supported.
    [self indicateActivity:YES];
    [[AppFeatureManager sharedManager] purchaseProFeaturesWithCompletionBlock:^(NSString *errorMessage) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (errorMessage) {
                [ReittiNotificationHelper showSimpleMessageWithTitle:@"Proccessing purchase failed." andContent:errorMessage inController:self];
            } else {
                [ReittiNotificationHelper showSimpleMessageWithTitle:@"Purchase Successful!" andContent:errorMessage inController:self];
            }
            
            [self indicateActivity:NO];
        });
    }];
     */
}

- (IBAction)restoreButtonTapped:(id)sender {
    [self indicateActivity:YES];
    [[AppFeatureManager sharedManager] restorePurchasesWithCompletionBlock:^(NSString *errorMessage) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (errorMessage) {
                [ReittiNotificationHelper showSimpleMessageWithTitle:@"Restoring purchase failed." andContent:errorMessage inController:self];
            } else {
                [ReittiNotificationHelper showSimpleMessageWithTitle:@"Restore Successful!" andContent:errorMessage inController:self];
            }
            
            [self indicateActivity:NO];
        });
    }];
}



-(void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
