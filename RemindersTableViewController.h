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
    
    NSInteger routinesSection, departureNotifSection, routeNotifSection;
}

@property (nonatomic, strong) NSMutableArray *savedRoutines;
@property (nonatomic, strong) NSMutableArray *departureNotifications;
@property (nonatomic, strong) NSMutableArray *routeNotifications;
@property (nonatomic, strong) ReittiRemindersManager *remindersManager;
@end
