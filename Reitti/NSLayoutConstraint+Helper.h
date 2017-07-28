//
//  NSLayoutConstraint+Helper.h
//  Reitti
//
//  Created by Anteneh Sahledengel on 7/27/17.
//  Copyright © 2017 Anteneh Sahledengel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface NSLayoutConstraint (Helper)

+(NSArray<NSLayoutConstraint *> *)superViewFillingConstraintsForView:(UIView *)view;

@end
