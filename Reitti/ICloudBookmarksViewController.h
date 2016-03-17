//
//  ICloudBookmarksViewController.h
//  Reitti
//
//  Created by Anteneh Sahledengel on 13/3/16.
//  Copyright © 2016 Anteneh Sahledengel. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ICloudBookmarksViewController : UIViewController <UITableViewDataSource, UITableViewDelegate> {
    BOOL markAllAsDownloaded;
}

@property (strong, nonatomic) IBOutlet UITableView *tableView;

@end
