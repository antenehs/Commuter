//
//  MultiSelectTableViewController.h
//  
//
//  Created by Anteneh Sahledengel on 12/7/15.
//
//

#import <UIKit/UIKit.h>

@protocol MultiSelectTableViewControllerDelegate <NSObject>
- (NSArray *)dataListForMultiSelector;
- (NSArray *)alreadySelectedValues;
- (void)selectedList:(NSArray *)selectedList;
@end

@interface MultiSelectTableViewController : UITableViewController{
    NSArray *dataToLoad;
}

@property (nonatomic, strong) NSMutableArray *selectedList;
@property (nonatomic, weak) UIViewController *callerViewController;

@property (nonatomic, weak) id <MultiSelectTableViewControllerDelegate> multiSelectTableViewControllerDelegate;

@end
