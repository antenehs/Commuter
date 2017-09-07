//
//  BaseTableViewController.h
//  Reitti
//
//  Created by Anteneh Sahledengel on 9/6/17.
//  Copyright © 2017 Anteneh Sahledengel. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BaseTableViewController : UITableViewController

-(void)setTitleViewSize:(CGSize)size;
-(void)setRightBarItemSize:(CGSize)size;
-(void)setLeftBarItemSize:(CGSize)size;

@end
