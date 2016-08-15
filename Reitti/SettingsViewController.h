//
//  SettingsViewController.h
//  Reitti
//
//  Created by Anteneh Sahledengel on 18/4/15.
//  Copyright (c) 2015 Anteneh Sahledengel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "SingleSelectTableViewController.h"
#import "SettingsManager.h"
#import "ToneSelectorTableViewController.h"
#import "RouteOptionsTableViewController.h"

@protocol SettingsDelegate <NSObject>
- (void)settingsValueChanged;
@end

@interface SettingsViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, SingleSelectTableViewControllerDelegate, ToneSelectorTableViewControllerDelegate>{
    
    NSInteger mapSettingsSection, otherSettingsSection, startingTabSection, advancedSettingSection, advancedModeSection;
    NSInteger mapTypeRow, liveVehiclesRow, routeSearchOptionRow, toneSelectorRow, clearHistoryRow, clearHistoryDaysRow, startingTabRow, locationRow, advancedSetttingsRow, trackingOptionRow;
    NSInteger numberOfSections, mapSectionNumberOfRows, otherSettingsNumberOfRows, startingTabSectionNumberOfRows, advancedSectionNumberOfRows, advancedModeNumberOfRows;
    
    IBOutlet UITableView *mainTableView;
    IBOutlet MKMapView *backgroundMapView;
    
    UISegmentedControl *mapModeSegmentControl;
    
    NSArray *dayNumbers;
    NSArray *dayStrings;
    
    NSArray *regionOptionNumbers;
    NSArray *regionOptionNames;
    NSArray *regionIncludingCities;
    
}

@property (nonatomic) MKCoordinateRegion mapRegion;

@property (nonatomic) BOOL advancedSettingsMode;

@property (nonatomic, strong)SettingsManager *settingsManager;

@property (nonatomic, weak) id <SettingsDelegate> delegate;

@end
