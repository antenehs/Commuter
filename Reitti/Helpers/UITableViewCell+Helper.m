//
//  UITableViewCell+Helper.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 30/11/15.
//  Copyright © 2015 Anteneh Sahledengel. All rights reserved.
//

#import "UITableViewCell+Helper.h"

@implementation UITableViewCell (Helper)

- (void)adjustImageViewSize:(CGSize)size{
    
    UIGraphicsBeginImageContextWithOptions(size, NO, UIScreen.mainScreen.scale);
    CGRect imageRect = CGRectMake(0.0, 0.0, size.width, size.height);
    [self.imageView.image drawInRect:imageRect];
    self.imageView.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
}

@end
