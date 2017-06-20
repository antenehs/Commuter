//
//  ReittiLocationManager.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 6/21/17.
//  Copyright © 2017 Anteneh Sahledengel. All rights reserved.
//

#import "ReittiLocationManager.h"

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
    if (!skipUserLocation) {
        self.currentUserLocation = [locations lastObject];
        
        if (self.delegate) {
            [self.delegate locationManager:manager didUpdateLocations:locations];
        }
    }
    
    skipUserLocation = NO;
}

@end
