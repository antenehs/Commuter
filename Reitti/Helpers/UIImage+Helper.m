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

+(UIImage *)asa_imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

+ (UIImage *)asa_dottedLineImageWithFrame:(CGRect)rect andColor:(UIColor *)fillColor{
    BOOL isVertical = rect.size.width < rect.size.height;
    
    CGFloat rectHeight = rect.size.height;
    CGFloat rectWidth = rect.size.width;
    
    CGFloat lineThickness = isVertical ? rectWidth : rectHeight;
    
    CGPoint startPoint = CGPointMake(lineThickness/(isVertical ? 2 : 1), lineThickness/(isVertical ? 1 : 2));
    CGPoint endPoint = CGPointMake(rectWidth/(isVertical ? 2 : 1), rectHeight/(isVertical ? 1 : 2));
    
    UIBezierPath * path = [[UIBezierPath alloc] init];
    [path moveToPoint:startPoint];
    [path addLineToPoint:endPoint];
    [path setLineWidth:lineThickness];
    
    CGFloat dashes[] = { path.lineWidth * 0, path.lineWidth * 2 };
    [path setLineDash:dashes count:2 phase:0];
    [path setLineCapStyle:kCGLineCapRound];
    
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(rectWidth, rectHeight), false, 2);
    if (fillColor)
        [fillColor setStroke];
    
    [path stroke];
    UIImage * image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

+(UIImage *)asa_dashedLineImageWithFrame:(CGRect)rect andColor:(UIColor *)fillColor{
    BOOL isVertical = rect.size.width < rect.size.height;
    
    CGFloat rectHeight = rect.size.height;
    CGFloat rectWidth = rect.size.width;
    
    CGFloat lineThickness = isVertical ? rectWidth : rectHeight;
    
    CGPoint startPoint = CGPointMake(lineThickness/(isVertical ? 2 : 1), lineThickness/(isVertical ? 1 : 2));
    CGPoint endPoint = CGPointMake(rectWidth/(isVertical ? 2 : 1), rectHeight/(isVertical ? 1 : 2));
    
    UIBezierPath * path = [[UIBezierPath alloc] init];
    [path moveToPoint:startPoint];
    [path addLineToPoint:endPoint];
    [path setLineWidth:lineThickness];
    
    CGFloat dashes[] = { path.lineWidth, path.lineWidth * 2 };
    [path setLineDash:dashes count:2 phase:0];
    
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(rectWidth, rectHeight), false, 2);
    if (fillColor)
        [fillColor setStroke];
    
    [path stroke];
    UIImage * image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

+(UIImage *)asa_dashedRoundedLineImageWithFrame:(CGRect)rect andColor:(UIColor *)fillColor{
    BOOL isVertical = rect.size.width < rect.size.height;
    
    CGFloat rectHeight = rect.size.height;
    CGFloat rectWidth = rect.size.width;
    
    CGFloat lineThickness = isVertical ? rectWidth : rectHeight;
    
    CGPoint startPoint = CGPointMake(lineThickness/(isVertical ? 2 : 1), lineThickness/(isVertical ? 1 : 2));
    CGPoint endPoint = CGPointMake(rectWidth/(isVertical ? 2 : 1), rectHeight/(isVertical ? 1 : 2));
    
    UIBezierPath * path = [[UIBezierPath alloc] init];
    [path moveToPoint:startPoint];
    [path addLineToPoint:endPoint];
    [path setLineWidth:lineThickness];
    
    CGFloat dashes[] = { path.lineWidth, path.lineWidth * 2 };
    [path setLineDash:dashes count:2 phase:0];
    [path setLineCapStyle:kCGLineCapRound];
    
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(rectWidth, rectHeight), false, 2);
    if (fillColor)
        [fillColor setStroke];
    
    [path stroke];
    UIImage * image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}
@end
