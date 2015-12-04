//
//  UISearchBar+Helper.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 4/12/15.
//  Copyright © 2015 Anteneh Sahledengel. All rights reserved.
//

#import "UISearchBar+Helper.h"

@implementation UISearchBar (Helper)

-(void)asa_removeBackgroundAndBorder{
    for (UIView *firstSubView in self.subviews)
    {
        for (UIView *subview in firstSubView.subviews) {
            // Remove the default background
            if ([subview isKindOfClass:NSClassFromString(@"UISearchBarBackground")]) {
                [subview removeFromSuperview];
            }
            
            // Remove the rounded corners
            if ([subview isKindOfClass:NSClassFromString(@"UITextField")]) {
                UITextField *textField = (UITextField *)subview;
                [textField setBackgroundColor:[UIColor clearColor]];
                textField.layer.borderColor =[[UIColor lightGrayColor] CGColor];
                textField.clearButtonMode = UITextFieldViewModeNever;
                for (UIView *subsubview in textField.subviews) {
                    if ([subsubview isKindOfClass:NSClassFromString(@"_UISearchBarSearchFieldBackgroundView")]) {
                        [subsubview removeFromSuperview];
                    }
                }
            }
            
        }
    }
}

-(void)asa_setTextColor:(UIColor *)color{
    for (UIView *subView in self.subviews)
    {
        for (UIView *secondLevelSubview in subView.subviews){
            if ([secondLevelSubview isKindOfClass:[UITextField class]])
            {
                UITextField *searchBarTextField = (UITextField *)secondLevelSubview;
                
                //set font color here
                searchBarTextField.textColor = color;
                
                break;
            }
        }
    }
}

@end
