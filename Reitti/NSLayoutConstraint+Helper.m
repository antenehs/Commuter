//
//  NSLayoutConstraint+Helper.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 7/27/17.
//  Copyright © 2017 Anteneh Sahledengel. All rights reserved.
//

#import "NSLayoutConstraint+Helper.h"

@implementation NSLayoutConstraint (Helper)

+(NSArray<NSLayoutConstraint *> *)superViewFillingConstraintsForView:(UIView *)view {
    NSArray *horizontalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[view]|" options:0 metrics:nil views:@{@"view": view}];
    
    NSArray *verticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[view]|" options:0 metrics:nil views:@{@"view": view}];
    
    NSMutableArray *constraints = [horizontalConstraints mutableCopy];
    [constraints addObjectsFromArray:verticalConstraints];
    
    return constraints;
}



@end
