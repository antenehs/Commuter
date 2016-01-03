//
//  UIImage+Helper.h
//  Reitti
//
//  Created by Anteneh Sahledengel on 22/12/15.
//  Copyright © 2015 Anteneh Sahledengel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface UIImage (Helper)

-(UIImage *)asa_addCircleBackgroundWithColor:(UIColor *)color andImageSize:(CGSize)size andInset:(CGPoint)inset andOffset:(CGPoint)offset;

+(UIImage *)asa_imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize;

+(UIImage *)asa_dottedLineImageWithFrame:(CGRect)rect andColor:(UIColor *)fillColor;
+(UIImage *)asa_dashedLineImageWithFrame:(CGRect)rect andColor:(UIColor *)fillColor;
+(UIImage *)asa_dashedRoundedLineImageWithFrame:(CGRect)rect andColor:(UIColor *)fillColor;

@end
