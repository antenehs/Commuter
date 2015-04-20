//
//  SettingDetailedViewController.h
//  Reitti
//
//  Created by Anteneh Sahledengel on 18/4/15.
//  Copyright (c) 2015 Anteneh Sahledengel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "SettingsManager.h"

typedef enum
{
    ViewControllerModeRegionSelection = 1,
    ViewControllerModeSelectHistoryTime = 2
} ViewControllerMode;

@interface SettingDetailedViewController : UIViewController{
    IBOutlet UITableView *mainTableView;
    IBOutlet MKMapView *backgroundMapView;
    
    NSIndexPath *checkedIndexPath;

}

@property (nonatomic) MKCoordinateRegion mapRegion;
@property (nonatomic) int selectedIndex;
@property (nonatomic) ViewControllerMode viewControllerMode;

@property (nonatomic, strong) NSArray *dataToLoad;

@property (nonatomic, strong) SettingsManager *settingsManager;

@end
