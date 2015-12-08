//
//  UISearchBar+Helper.h
//  Reitti
//
//  Created by Anteneh Sahledengel on 4/12/15.
//  Copyright © 2015 Anteneh Sahledengel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface UISearchBar (Helper)

-(void)asa_removeBackgroundAndBorder;
-(void)asa_setTextColor:(UIColor *)color;
-(void)asa_setTextColorAndPlaceholderText:(UIColor *)color placeHolderColor:(UIColor *)placeHolderColor;

@end
