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

@protocol RouteOptionSelectionDelegate <NSObject>
- (void)optionSelectionDidComplete:(RouteSearchOptions *)routeOptions;
@end

@interface RouteOptionsTableViewController : UITableViewController{
  
}

@property (nonatomic,retain) UISegmentedControl *timeTypeSegmentControl;
@property (nonatomic,retain) UIDatePicker *datePicker;

@property (nonatomic,retain) NSIndexPath * checkedIndexPath ;

@property (nonatomic, strong) NSDate *selectedDate;
@property (nonatomic) SelectedTimeType selectedTimeType;
@property (nonatomic) RouteSearchOption selectedSearchOption;

@property (nonatomic, weak) id <RouteOptionSelectionDelegate> routeOptionSelectionDelegate;

@end
