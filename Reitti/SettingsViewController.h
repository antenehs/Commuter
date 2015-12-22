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
    
    NSInteger mapSettingsSection, widgetSettingSection, otherSettingsSection;
    NSInteger mapTypeRow, liveVehiclesRow, departuresWidgetRow, routeSearchOptionRow, toneSelectorRow, clearHistoryRow, clearHistoryDaysRow, locationRow;
    NSInteger numberOfSections, mapSectionNumberOfRows, wigetSectionNumberOfRows, otherSettingsNumberOfRows;
    
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

@property (nonatomic, strong)SettingsManager *settingsManager;

@property (nonatomic, weak) id <SettingsDelegate> delegate;

@end
