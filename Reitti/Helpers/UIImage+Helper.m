//
//  UIImage+Helper.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 22/12/15.
//  Copyright © 2015 Anteneh Sahledengel. All rights reserved.
//

#import "UIImage+Helper.h"

@implementation UIImage (Helper)

-(UIImage *)asa_addCircleBackgroundWithColor:(UIColor *)color andImageSize:(CGSize)size andInset:(CGPoint)inset andOffset:(CGPoint)offset{
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0.f);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    [[UIColor clearColor] set];
    CGContextFillRect(ctx, rect);
    UIBezierPath *bezierPath = [UIBezierPath bezierPathWithRoundedRect:rect
                                                          cornerRadius:rect.size.width/2];
    CGContextSetFillColorWithColor(ctx, color.CGColor);
    [bezierPath fill];
    [bezierPath addClip];
    
    
    CGRect pictureRect = CGRectInset(rect, inset.x, inset.y);
    pictureRect = CGRectOffset(pictureRect, offset.x, offset.y);
    
    [self drawInRect:pictureRect];
    UIImage *finalImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return finalImage;
}

@end
