//
//  SettingsViewController.h
//  Reitti
//
//  Created by Anteneh Sahledengel on 18/4/15.
//  Copyright (c) 2015 Anteneh Sahledengel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "SettingDetailedViewController.h"
#import "SettingsManager.h"

@protocol SettingsDelegate <NSObject>
- (void)settingsValueChanged;
@end

@interface SettingsViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>{
    
    IBOutlet UITableView *mainTableView;
    IBOutlet MKMapView *backgroundMapView;
    
    NSArray *historyTimeInDays;
    NSArray *regions;
    
}

@property (nonatomic) MKCoordinateRegion mapRegion;

@property (nonatomic) bool isRootViewController;

@property (nonatomic, strong)SettingsManager *settingsManager;

@property (nonatomic, weak) id <SettingsDelegate> delegate;

@end
