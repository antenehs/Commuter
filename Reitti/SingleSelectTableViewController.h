//
//  SingleSelectTableViewController.h
//  Reitti
//
//  Created by Anteneh Sahledengel on 30/11/15.
//  Copyright © 2015 Anteneh Sahledengel. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString * kSSDataDisplayTextKey;
extern NSString * kSSDataDetailTextKey;
extern NSString * kSSDataSubtitleTextKey;
extern NSString * kSSDataValueKey;
extern NSString * kSSDataPictureKey;

@protocol SingleSelectTableViewControllerDelegate <NSObject>
- (NSArray *)dataListForSelectorForViewControllerIndex:(NSInteger)viewControllerIndex;

- (void)selectedIndex:(NSInteger)selectedIndex senderViewControllerIndex:(NSInteger)viewControllerIndex;
@optional
- (NSInteger)alreadySelectedIndexForViewControllerIndex:(NSInteger)viewControllerIndex;

- (NSString *)viewControllerTitleForViewControllerIndex:(NSInteger)viewControllerIndex;
@end

@interface SingleSelectTableViewController : UITableViewController{
    NSArray *dataToLoad;
    NSInteger selectedIndex;
    
    NSIndexPath * checkedIndexPath;
}

@property NSInteger viewControllerIndex;

@property (nonatomic, weak) id <SingleSelectTableViewControllerDelegate> singleSelectTableViewControllerDelegate;

@end
