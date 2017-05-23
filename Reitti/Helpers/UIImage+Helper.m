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

-(UIImage *)asa_imageWithColor:(UIColor *)tintColor {
    UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(context, 0, self.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextSetBlendMode(context, kCGBlendModeNormal);

    CGRect rect = CGRectMake(0, 0, self.size.width, self.size.height);
    CGContextClipToMask(context, rect, self.CGImage);
    [tintColor setFill];
    CGContextFillRect(context, rect);
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

//public func asa_imageWithColor(tintColor: UIColor) -> UIImage {
//    UIGraphicsBeginImageContextWithOptions(size, false, scale)
//    
//    let context = UIGraphicsGetCurrentContext()!
//    context.translateBy(x: 0, y: size.height)
//    context.scaleBy(x: 1.0, y: -1.0)
//    context.setBlendMode(CGBlendMode.normal)
//    
//    let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
//    context.clip(to: rect, mask: self.cgImage!)
//    tintColor.setFill()
//    context.fill(rect)
//    
//    let newImage = UIGraphicsGetImageFromCurrentImageContext()!
//    UIGraphicsEndImageContext()
//    
//    return newImage
//}



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


//RAndom stuff copy pasted
+ (UIImage* )setBackgroundImageByColor:(UIColor *)backgroundColor withFrame:(CGRect )rect{
    
    // tcv - temporary colored view
    UIView *tcv = [[UIView alloc] initWithFrame:rect];
    [tcv setBackgroundColor:backgroundColor];
    
    
    // set up a graphics context of button's size
    CGSize gcSize = tcv.frame.size;
    UIGraphicsBeginImageContext(gcSize);
    // add tcv's layer to context
    [tcv.layer renderInContext:UIGraphicsGetCurrentContext()];
    // create background image now
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
    //    [tcv release];
    
}





+ (UIImage*) replaceColor:(UIColor*)color inImage:(UIImage*)image withTolerance:(float)tolerance {
    CGImageRef imageRef = [image CGImage];
    
    NSUInteger width = CGImageGetWidth(imageRef);
    NSUInteger height = CGImageGetHeight(imageRef);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    NSUInteger bytesPerPixel = 4;
    NSUInteger bytesPerRow = bytesPerPixel * width;
    NSUInteger bitsPerComponent = 8;
    NSUInteger bitmapByteCount = bytesPerRow * height;
    
    unsigned char *rawData = (unsigned char*) calloc(bitmapByteCount, sizeof(unsigned char));
    
    CGContextRef context = CGBitmapContextCreate(rawData, width, height,
                                                 bitsPerComponent, bytesPerRow, colorSpace,
                                                 kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGColorSpaceRelease(colorSpace);
    
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), imageRef);
    
    CGColorRef cgColor = [color CGColor];
    const CGFloat *components = CGColorGetComponents(cgColor);
    float r = components[0];
    float g = components[1];
    float b = components[2];
    //float a = components[3]; // not needed
    
    r = r * 255.0;
    g = g * 255.0;
    b = b * 255.0;
    
    const float redRange[2] = {
        MAX(r - (tolerance / 2.0), 0.0),
        MIN(r + (tolerance / 2.0), 255.0)
    };
    
    const float greenRange[2] = {
        MAX(g - (tolerance / 2.0), 0.0),
        MIN(g + (tolerance / 2.0), 255.0)
    };
    
    const float blueRange[2] = {
        MAX(b - (tolerance / 2.0), 0.0),
        MIN(b + (tolerance / 2.0), 255.0)
    };
    
    int byteIndex = 0;
    
    while (byteIndex < bitmapByteCount) {
        unsigned char red   = rawData[byteIndex];
        unsigned char green = rawData[byteIndex + 1];
        unsigned char blue  = rawData[byteIndex + 2];
        
        if (((red >= redRange[0]) && (red <= redRange[1])) &&
            ((green >= greenRange[0]) && (green <= greenRange[1])) &&
            ((blue >= blueRange[0]) && (blue <= blueRange[1]))) {
            // make the pixel transparent
            //
            rawData[byteIndex] = 0;
            rawData[byteIndex + 1] = 0;
            rawData[byteIndex + 2] = 0;
            rawData[byteIndex + 3] = 0;
        }
        
        byteIndex += 4;
    }
    
    UIImage *result = [UIImage imageWithCGImage:CGBitmapContextCreateImage(context)];
    
    CGContextRelease(context);
    free(rawData);
    
    return result;
}

+(UIImage *)changeWhiteColorTransparent: (UIImage *)image
{
    CGImageRef rawImageRef=image.CGImage;
    
    const CGFloat colorMasking[6] = {222, 255, 222, 255, 222, 255};
    
    UIGraphicsBeginImageContext(image.size);
    CGImageRef maskedImageRef=CGImageCreateWithMaskingColors(rawImageRef, colorMasking);
    {
        //if in iphone
        CGContextTranslateCTM(UIGraphicsGetCurrentContext(), 0.0, image.size.height);
        CGContextScaleCTM(UIGraphicsGetCurrentContext(), 1.0, -1.0);
    }
    
    CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, image.size.width, image.size.height), maskedImageRef);
    UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
    CGImageRelease(maskedImageRef);
    UIGraphicsEndImageContext();
    return result;
}




+(UIImage *)changeColorTo:(NSMutableArray*) array Transparent: (UIImage *)image
{
    CGImageRef rawImageRef=image.CGImage;
    
    //    const float colorMasking[6] = {222, 255, 222, 255, 222, 255};
    
    const CGFloat colorMasking[6] = {[[array objectAtIndex:0] floatValue], [[array objectAtIndex:1] floatValue], [[array objectAtIndex:2] floatValue], [[array objectAtIndex:3] floatValue], [[array objectAtIndex:4] floatValue], [[array objectAtIndex:5] floatValue]};
    
    
    UIGraphicsBeginImageContext(image.size);
    CGImageRef maskedImageRef=CGImageCreateWithMaskingColors(rawImageRef, colorMasking);
    {
        //if in iphone
        CGContextTranslateCTM(UIGraphicsGetCurrentContext(), 0.0, image.size.height);
        CGContextScaleCTM(UIGraphicsGetCurrentContext(), 1.0, -1.0);
    }
    
    CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, image.size.width, image.size.height), maskedImageRef);
    UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
    CGImageRelease(maskedImageRef);
    UIGraphicsEndImageContext();
    return result;
}

+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    //UIGraphicsBeginImageContext(newSize);
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();    
    UIGraphicsEndImageContext();
    return newImage;
}
@end
