//
//  EditReminderTableViewController.h
//  
//
//  Created by Anteneh Sahledengel on 11/7/15.
//
//

#import <UIKit/UIKit.h>
#import "AddressSearchViewController.h"
#import "MultiSelectTableViewController.h"
#import "ToneSelectorTableViewController.h"
#import "ReittiRemindersManager.h"

@interface EditReminderTableViewController : UITableViewController<AddressSearchViewControllerDelegate, MultiSelectTableViewControllerDelegate, ToneSelectorTableViewControllerDelegate>{
    BOOL addressRequestedForFrom;
    BOOL addressRequestedForTo;
    BOOL dateSetOnce;
    
    UIDatePicker *datePicker;
    
    IBOutlet UIButton *doneButton;
}

@property (nonatomic, strong)RoutineEntity *routine;

@property (nonatomic, strong)NSString *fromDisplayName;
@property (nonatomic, strong)NSString *fromString;
@property (nonatomic, strong)NSString *fromCoords;
@property (nonatomic, strong)NSString *toDisplayName;
@property (nonatomic, strong)NSString *toString;
@property (nonatomic, strong)NSString *toCoords;
@property (nonatomic, strong)NSArray *selectedDaysList;
@property (nonatomic, strong)NSString *repeatString;
@property (nonatomic, strong)NSString *toneName;

@property (nonatomic, strong)NSDate *routineDate;

@property (nonatomic, strong)NSManagedObjectContext *managedObjectContext;


@end
