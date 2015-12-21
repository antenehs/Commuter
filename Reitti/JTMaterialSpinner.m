//
//  JTMaterialSpinner.h
//  JTMaterialSpinner
//
//  Created by Jonathan Tribouharet
//

#import "JTMaterialSpinner.h"

@implementation JTMaterialSpinner

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(!self){
        return nil;
    }
    
    [self commonInit];
    
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if(!self){
        return nil;
    }
    
    [self commonInit];
    
    return self;
}

- (void)commonInit
{
    self->_circleLayer = [CAShapeLayer new];
    [self.layer addSublayer:_circleLayer];
    
    _circleLayer.fillColor = nil;
    _circleLayer.lineCap = kCALineCapRound;
    _circleLayer.lineWidth = 3;
    
    _circleLayer.strokeColor = [UIColor darkGrayColor].CGColor;
    _circleLayer.strokeStart = 0;
    _circleLayer.strokeEnd = 0;
    
    UIColor *greenColor = [UIColor colorWithRed:31.0/255.0 green:154.0/255.0 blue:57.0/255.0 alpha:1.0];
//    UIColor *orangeColor = [UIColor colorWithRed:244.0f/255 green:107.0f/255 blue:0 alpha:1];
    self.alternatingColors = @[[UIColor grayColor], greenColor];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if(!CGRectEqualToRect(self.circleLayer.frame, self.bounds)){
        [self updateCircleLayer];
    }
}

- (void)updateCircleLayer
{
    CGPoint center = CGPointMake(self.bounds.size.width / 2., self.bounds.size.height / 2.);
    CGFloat radius = CGRectGetHeight(self.bounds) / 2. - self.circleLayer.lineWidth / 2;
    CGFloat startAngle = 0;
    CGFloat endAngle = 2 * M_PI;
    
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:center
                                                        radius:radius
                                                    startAngle:startAngle
                                                      endAngle:endAngle
                                                     clockwise:YES];
    self.circleLayer.path = path.CGPath;
    self.circleLayer.frame = self.bounds;
}

- (void)beginRefreshing
{
    self.hidden = NO;
    CAKeyframeAnimation *rotateAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform.rotation"];
    rotateAnimation.values = @[
                               @0,
                               @(M_PI),
                               @(2 * M_PI)
                               ];
    
    CABasicAnimation *headAnimation = [CABasicAnimation animation];
    headAnimation.keyPath = @"strokeStart";
    headAnimation.duration = 1;
    headAnimation.fromValue = @0;
    headAnimation.toValue = @.25;
    
    CABasicAnimation *tailAnimation = [CABasicAnimation animation];
    tailAnimation.keyPath = @"strokeEnd";
    tailAnimation.duration = 1;
    tailAnimation.fromValue = @0;
    tailAnimation.toValue = @1;
    
    CABasicAnimation *endHeadAnimation = [CABasicAnimation animation];
    endHeadAnimation.keyPath = @"strokeStart";
    endHeadAnimation.beginTime = 1.;
    endHeadAnimation.duration = 1;
    endHeadAnimation.fromValue = @.25;
    endHeadAnimation.toValue = @1;
    
    CABasicAnimation *endTailAnimation = [CABasicAnimation animation];
    endTailAnimation.keyPath = @"strokeEnd";
    endTailAnimation.beginTime = 1;
    endTailAnimation.duration = 1;
    endTailAnimation.fromValue = @1;
    endTailAnimation.toValue = @1;
    
    CAAnimationGroup *animations = [CAAnimationGroup animation];
    animations.duration = 2;
    animations.animations = @[
                              rotateAnimation,
                              headAnimation,
                              tailAnimation,
                              endHeadAnimation,
                              endTailAnimation
                              ];
    animations.repeatCount = INFINITY;
        
    [self.circleLayer addAnimation:animations forKey:@"animations"];
    
    if (self.alternatingColors != nil && self.alternatingColors.count > 1) {
        NSMutableArray *colorAnims = [@[] mutableCopy];
        for (int i = 0; i < self.alternatingColors.count ; i++) {
            
            UIColor *fromColor = self.alternatingColors[i];
            UIColor *toColor = self.alternatingColors[i == self.alternatingColors.count - 1 ? 0 : i + 1];
            CABasicAnimation *colorAnimation = [CABasicAnimation animationWithKeyPath:@"strokeColor"];
            colorAnimation.duration = 1.0;
            colorAnimation.fromValue = (id)fromColor.CGColor;
            colorAnimation.toValue = (id)toColor.CGColor;
            
            [colorAnims addObject:colorAnimation];
        }
        
        CAAnimationGroup *colorAnimations = [CAAnimationGroup animation];
        colorAnimations.duration = 2;
        colorAnimations.animations = colorAnims;
        colorAnimations.repeatCount = INFINITY;
        
        [self.circleLayer addAnimation:colorAnimations forKey:@"colorAnimations"];
    }
    
    
}

- (void)endRefreshing
{
    self.hidden = YES;
    [self.circleLayer removeAnimationForKey:@"animations"];
    [self.circleLayer removeAnimationForKey:@"colorAnimations"];
}

@end
