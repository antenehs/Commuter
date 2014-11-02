//
//  WidgetSettingsViewController.h
//  Reitti
//
//  Created by Anteneh Sahledengel on 1/11/14.
//  Copyright (c) 2014 Anteneh Sahledengel. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WidgetSettingsViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>{
    
    IBOutlet UIView *bluredBackView;
}

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property(nonatomic, strong)NSArray * savedStops;

@property(nonatomic, strong) NSMutableArray * selectedStops;
@property(nonatomic, strong) NSMutableArray * unselectedStops;
@property(nonatomic, strong) NSUserDefaults * widgetUserDefaults;

@end
