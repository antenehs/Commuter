//
//  ReittiLocationManager.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 6/21/17.
//  Copyright © 2017 Anteneh Sahledengel. All rights reserved.
//

#import "ReittiLocationManager.h"
#import "ReittiNotificationHelper.h"
#import "AppManager.h"

@interface ReittiLocationManager () <CLLocationManagerDelegate> {
    BOOL skipUserLocation;
}

@property (strong, nonatomic) CLLocation * currentUserLocation;
@property (strong, nonatomic) CLLocationManager *locationManager;

@end

@implementation ReittiLocationManager

+(instancetype)sharedManager {
    static ReittiLocationManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedInstance = [ReittiLocationManager new];
    });
    
    return sharedInstance;
}

-(instancetype)init {
    self = [super init];
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.distanceFilter = kCLDistanceFilterNone;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
    [self.locationManager startUpdatingLocation];
    [self.locationManager requestAlwaysAuthorization];
    
    skipUserLocation = YES;
    
    return self;
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    if (!skipUserLocation || [AppManagerBase isDebugMode]) {
        self.currentUserLocation = [locations lastObject];
        
        if (self.delegate) {
            [self.delegate locationManager:manager didUpdateLocations:locations];
        }
    }
    
    skipUserLocation = NO;
}

+(BOOL)isLocationServiceAvailableWithMessage:(bool)showMessage showMessageIn:(UIViewController *)viewController {
    BOOL accessGranted = [CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse;
    BOOL locationServicesEnabled = [CLLocationManager locationServicesEnabled];
    NSString *messageTitle, *messageBody;
    
    ShowMessageBlock showMessageBlock = ^(NSString *messageTitle, NSString *messageBody) {
        UIAlertController *controller = [UIAlertController alertControllerWithTitle:messageTitle message:messageBody preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) { }];
        
        [controller addAction:okAction];
        
        UIAlertAction *settingsAction = [UIAlertAction actionWithTitle:@"Settings" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
        }];
        
        [controller addAction:settingsAction];
        
        [viewController presentViewController:controller animated:YES completion:nil];
    };
    
    if (!locationServicesEnabled) {
        messageTitle = @"Looks like location services is not enabled";
        messageBody = @"Enable it from Settings/Privacy/Location Services.";
        showMessageBlock(messageTitle, messageBody);
        
        return NO;
    }
    
    if (!accessGranted) {
        messageTitle = @"Looks like access is not granted to this app for location services.";
        messageBody = @"Grant access from Settings/Privacy/Location Services.";
        showMessageBlock(messageTitle, messageBody);
        
        return NO;
    }
    
    return YES;
}

@end
