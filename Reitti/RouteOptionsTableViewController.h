//
//  RouteOptionsTableViewController.h
//  Reitti
//
//  Created by Anteneh Sahledengel on 29/3/15.
//  Copyright (c) 2015 Anteneh Sahledengel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RettiDataManager.h"
#import "RouteSearchOptions.h"
#import "SettingsManager.h"
#import "SingleSelectTableViewController.h"

@protocol RouteOptionSelectionDelegate <NSObject>
- (void)optionSelectionDidComplete:(RouteSearchOptions *)routeOptions;
@end

@interface RouteOptionsTableViewController : UITableViewController <SingleSelectTableViewControllerDelegate>{
    NSInteger dateAndTimeSection, transportTypeSection, searchOptionSection, advancedOptionsSection, saveSettingsSections;
    NSInteger ticketZoneSelectorViewIndex, changeMargineSelectorViewIndex, walkingSpeedSelectorViewIndex;
    NSInteger numberOfSections;
    
    NSArray *trasportTypes;
    BOOL settingsChanged;
    
    IBOutlet UIButton *rememberOptionsButton;
    
}

@property (nonatomic,retain) UISegmentedControl *timeTypeSegmentControl;
@property (nonatomic,strong) UIDatePicker *datePicker;

@property (nonatomic,retain) NSIndexPath * checkedIndexPath ;

//@property (nonatomic, strong) NSDate *selectedDate;
//@property (nonatomic) RouteTimeType selectedTimeType;
//@property (nonatomic) RouteSearchOptimization selectedSearchOption;
@property (nonatomic, strong) RouteSearchOptions *routeSearchOptions;

@property (nonatomic) BOOL globalSettingsMode;
@property (nonatomic, strong)SettingsManager *settingsManager;

@property (nonatomic, weak) id <RouteOptionSelectionDelegate> routeOptionSelectionDelegate;

@end
