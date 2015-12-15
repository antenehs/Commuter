//
//  DrawnBubbleView.m
//  BubbleView
//
//  Created by Mikael Hallendal on 2011-02-19.
//  Copyright 2011 Mikael Hallendal. All rights reserved.
//

#import "ASABubbleView.h"
#import <QuartzCore/QuartzCore.h>

#define HORIZONTAL_PADDING 0
#define VERTICAL_PADDING 0
#define ARROW_HEIGHT 10
#define ARROW_WIDTH 20
#define DEFAULT_ARROW_POSITION 60
#define CORNER_RADIUS 5
#define ACTIVATION_PADDING 0

CGFloat 
clamp(CGFloat value, CGFloat minValue, CGFloat maxValue) 
{
    if (value < minValue) {
        return minValue;
    }
    
    if (value > maxValue) {
        return maxValue;
    }
    
    return value;
}

@implementation ASABubbleView
//@synthesize gradientStartColor = _gradientStartColor;
//@synthesize gradientEndColor = _gradientEndColor;
@synthesize borderColor = _borderColor;

//Init methods
- (id)initWithFrame:(CGRect)frame activationFrame:(CGRect)activationFrame
{
    self = [super initWithFrame:frame];
    if (self) {
        _activationFrame = activationFrame;
        [self setupDefaultValuesAndLayers];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        return [self initWithFrame:[self frame]];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupDefaultValuesAndLayers];
    }
    return self;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setupDefaultValuesAndLayers];
    }
    return self;
}

- (id)initWithHeight:(CGFloat)height activationFrame:(CGRect)activationFrame
{
    CGRect frame = CGRectMake(0.0, CGRectGetMaxY(activationFrame) + ACTIVATION_PADDING, [UIScreen mainScreen].bounds.size.width, height);
    
    return [self initWithFrame:frame activationFrame:activationFrame];
}

//-(void)drawRect:(CGRect)rect{
//    for (CALayer *layer in self.layer.sublayers) {
//        if ([layer.name isEqualToString:@"MainBubbleLayer"]) {
//            [layer setFrame:rect];
//        }
//    }
////    [self.layer addSublayer:[self bubbleLayer]];
//}

- (void)setActivationFrame:(CGRect)activationFrame{
    for (CALayer *layer in self.layer.sublayers) {
        if ([layer.name isEqualToString:@"MainBubbleLayer"]) {
            [layer removeFromSuperlayer];
        }
    }
    _activationFrame = activationFrame;
    [self.layer addSublayer:[self bubbleLayer]];
}


- (CGRect)bubbleFrame
{
    CGSize viewSize = self.frame.size;
    CGRect frame = CGRectMake(HORIZONTAL_PADDING, ARROW_HEIGHT + VERTICAL_PADDING, 
                              viewSize.width - 2 * HORIZONTAL_PADDING, 
                              viewSize.height - ARROW_HEIGHT - 2 * VERTICAL_PADDING);
    return frame;
}

- (CGFloat)minArrowPosition
{
    return CGRectGetMinX([self bubbleFrame]) + ARROW_WIDTH / 2 + CORNER_RADIUS;
}

- (CGFloat)maxArrowPosition
{
    return CGRectGetMaxX([self bubbleFrame]) - ARROW_WIDTH / 2 - CORNER_RADIUS;
}

- (CGFloat)arrowPosition
{
    if (CGRectIsEmpty(_activationFrame)) {
        return DEFAULT_ARROW_POSITION;
    }
    
    return clamp(CGRectGetMidX(_activationFrame), [self minArrowPosition], [self maxArrowPosition]);
}

- (CGPoint)arrowMiddleBase
{
    CGRect bubbleFrame = [self bubbleFrame];
    return CGPointMake(CGRectGetMinX(bubbleFrame) + [self arrowPosition], CGRectGetMinY(bubbleFrame));
}

- (UIBezierPath *)bubblePathWithRoundedCornerRadius:(CGFloat)cornerRadius
{
    UIBezierPath *path = [UIBezierPath bezierPath];

    CGRect bubbleFrame = [self bubbleFrame];
    CGPoint arrowMiddleBase = CGPointMake([self arrowPosition], bubbleFrame.origin.y);

    // Start at the arrow
    [path moveToPoint:CGPointMake(arrowMiddleBase.x - ARROW_WIDTH / 2, arrowMiddleBase.y)];
    [path addLineToPoint:CGPointMake(arrowMiddleBase.x, arrowMiddleBase.y - ARROW_HEIGHT)];
    [path addLineToPoint:CGPointMake(arrowMiddleBase.x + ARROW_WIDTH / 2, arrowMiddleBase.y)];
    [path addLineToPoint:CGPointMake(bubbleFrame.origin.x + bubbleFrame.size.width - cornerRadius, 
                                     arrowMiddleBase.y)];
    // Top right corner
    [path addArcWithCenter:CGPointMake(CGRectGetMaxX(bubbleFrame) - cornerRadius, 
                                       arrowMiddleBase.y + cornerRadius)
                    radius:cornerRadius startAngle:3 * M_PI / 2 endAngle:2 * M_PI
                 clockwise:YES];
    
    [path addLineToPoint:CGPointMake(CGRectGetMaxX(bubbleFrame), 
                                     CGRectGetMaxY(bubbleFrame) - cornerRadius)];
    // Bottom right corner
    [path addArcWithCenter:CGPointMake(CGRectGetMaxX(bubbleFrame) - cornerRadius, 
                                       CGRectGetMaxY(bubbleFrame) - cornerRadius) 
                    radius:cornerRadius startAngle:0 endAngle:M_PI / 2
                 clockwise:YES];
    [path addLineToPoint:CGPointMake(CGRectGetMinX(bubbleFrame) + cornerRadius, 
                                     CGRectGetMaxY(bubbleFrame))];

    // Bottom left corner
    [path addArcWithCenter:CGPointMake(CGRectGetMinX(bubbleFrame) + cornerRadius,
                                       CGRectGetMaxY(bubbleFrame) - cornerRadius)
                    radius:cornerRadius startAngle:M_PI / 2 endAngle:M_PI clockwise:YES];
    [path addLineToPoint:CGPointMake(CGRectGetMinX(bubbleFrame), 
                                     CGRectGetMinY(bubbleFrame) + cornerRadius)];
    
    // Top left corner
    [path addArcWithCenter:CGPointMake(CGRectGetMinX(bubbleFrame) + cornerRadius, 
                                       CGRectGetMinY(bubbleFrame) + cornerRadius)
                    radius:cornerRadius startAngle:M_PI endAngle:3 * M_PI / 2 clockwise:YES];
    
    [path closePath];
    
    return path;
}

- (CALayer *)bubbleLayer
{
    CALayer *bubbleLayer = [CALayer layer];
    bubbleLayer.frame = (CGRect) { CGPointZero, self.frame.size };
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.frame = (CGRect) { CGPointZero, bubbleLayer.frame.size };
    
    UIBezierPath *path = [self bubblePathWithRoundedCornerRadius:10.0];
   
//    // Gradient colors from gray to black. It is just one color now
    gradientLayer.colors = [NSArray arrayWithObjects:(id)[UIColor blackColor].CGColor, (id)[UIColor blackColor].CGColor, nil];
    
    // Apply a mask to the gradient layer
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.path = path.CGPath;
    gradientLayer.mask = maskLayer;
    
    // Draw the border
    CAShapeLayer *outlineLayer = [CAShapeLayer layer];
    outlineLayer.path = path.CGPath;
    outlineLayer.strokeColor = self.borderColor.CGColor;
    outlineLayer.lineWidth = 1.0;
    outlineLayer.fillColor = [UIColor clearColor].CGColor;

//    // And finally a shadow 
//    CAShapeLayer *shadowLayer = [CAShapeLayer layer];
//    shadowLayer.shadowPath = path.CGPath;
//    shadowLayer.shadowColor = [UIColor blackColor].CGColor;
//    shadowLayer.shadowRadius = 5;
//    shadowLayer.shadowOffset = CGSizeMake(1.0, 1.0);
//    shadowLayer.shadowOpacity = 0.75;
    
//    [bubbleLayer addSublayer:shadowLayer];
    [bubbleLayer addSublayer:gradientLayer];
    [bubbleLayer addSublayer:outlineLayer];
    
//    bubbleLayer.backgroundColor = [UIColor lightGrayColor].CGColor;
    bubbleLayer.opacity = 0.4;
    bubbleLayer.name = @"MainBubbleLayer";
    return bubbleLayer;
}

- (void)setupDefaultValuesAndLayers
{
    self.borderColor = [UIColor colorWithRed:0.15 green:0.15 blue:0.15 alpha:1.0];
//    self.gradientStartColor = [UIColor grayColor];
//    self.gradientEndColor = [UIColor blackColor];
    [self.layer addSublayer:[self bubbleLayer]];
}

@end
