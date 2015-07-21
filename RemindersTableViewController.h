//
//  RemindersTableViewController.h
//  
//
//  Created by Anteneh Sahledengel on 11/7/15.
//
//

#import <UIKit/UIKit.h>
#import "ReittiRemindersManager.h"

@interface RemindersTableViewController : UITableViewController{
    BOOL notificationIsAllowed;
}

@property (nonatomic, strong) NSMutableArray *savedRoutines;
@property (nonatomic, strong) ReittiRemindersManager *remindersManager;
@end
