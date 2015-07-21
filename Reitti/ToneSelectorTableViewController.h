//
//  ToneSelectorTableViewController.h
//  
//
//  Created by Anteneh Sahledengel on 19/7/15.
//
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@protocol ToneSelectorTableViewControllerDelegate <NSObject>
- (void)selectedTone:(NSString *)selectedTone;
@end

@interface ToneSelectorTableViewController : UITableViewController{
    NSIndexPath *preSelectedIndex;
}

@property (nonatomic, strong)NSIndexPath *checkedIndexPath;
@property (nonatomic, strong)NSString *selectedTone;
@property (nonatomic)SystemSoundID soundID;

@property (nonatomic, weak) id <ToneSelectorTableViewControllerDelegate> delegate;

@end
