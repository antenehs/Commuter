//
//  DropDownListView.h
//  Reitti
//
//  Created by Anteneh Sahledengel on 8/29/17.
//  Copyright © 2017 Anteneh Sahledengel. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DropDownListView;

@protocol DropDownListViewDelegate <NSObject>

@optional
-(void)dropDownList:(DropDownListView *)dropDownListView selectedObjectAtIndex:(NSInteger)index;

@end

@interface DropDownListView : UIView

-(void)setupWithOptions:(NSArray<NSString *> *)options;
-(void)setupWithOptions:(NSArray<NSString *> *)options preSelectedIndex:(NSInteger)index;

@property(nonatomic, weak)id<DropDownListViewDelegate> delegate;
@property(nonatomic, weak)UIViewController *optionPresenterController;

@end
