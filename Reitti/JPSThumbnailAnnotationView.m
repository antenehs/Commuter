//
//  JPSThumbnailAnnotationView.m
//  JPSThumbnailAnnotationView
//
//  Created by Jean-Pierre Simard on 4/21/13.
//  Copyright (c) 2013 JP Simard. All rights reserved.
//

@import QuartzCore;
#import "JPSThumbnailAnnotationView.h"
#import "JPSThumbnail.h"

NSString * const kJPSThumbnailAnnotationViewReuseID = @"JPSThumbnailAnnotationView";

//static CGFloat const kJPSThumbnailAnnotationViewStandardWidth     = 75.0f;
static CGFloat const kJPSThumbnailAnnotationViewStandardWidth     = 35.0f;
//static CGFloat const kJPSThumbnailAnnotationViewStandardHeight    = 87.0f;
static CGFloat const kJPSThumbnailAnnotationViewStandardHeight    = 43.0f;
static CGFloat const kJPSThumbnailAnnotationViewExpandOffset      = 265.0f;
static CGFloat const kJPSThumbnailAnnotationViewExpandHeightOffset= 20.0f;
static CGFloat const kJPSThumbnailAnnotationViewVerticalOffset    = 21.0f;
static CGFloat const kJPSThumbnailAnnotationViewAnimationDuration = 0.25f;

@interface JPSThumbnailAnnotationView ()

@property (nonatomic, readwrite) CLLocationCoordinate2D coordinate;
@property (nonatomic, strong) NSNumber *code;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *subtitleLabel;
//@property (nonatomic) bool selected;
@property (nonatomic, strong) ActionBlock disclosureBlock;
@property (nonatomic, strong) ActionBlock primaryButtonBlock;
@property (nonatomic, strong) ActionBlock secondaryButtonBlock;

@property (nonatomic, strong) CAShapeLayer *bgLayer;
@property (nonatomic, strong) UIButton *disclosureButton;
@property (nonatomic, strong) UIButton *primaryButton;
@property (nonatomic, strong) UIButton *secondaryButton;
@property (nonatomic, assign) JPSThumbnailAnnotationViewState state;

@end

@implementation JPSThumbnailAnnotationView

#define SYSTEM_GREEN_COLOR [UIColor colorWithRed:39.0/255.0 green:174.0/255.0 blue:96.0/255.0 alpha:1.0];

#pragma mark - Setup

- (id)initWithAnnotation:(id<MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    
    if (self) {
        self.canShowCallout = NO;
        self.frame = CGRectMake(0, 0, kJPSThumbnailAnnotationViewStandardWidth, kJPSThumbnailAnnotationViewStandardHeight);
        self.backgroundColor = [UIColor clearColor];
        self.centerOffset = CGPointMake(0, -kJPSThumbnailAnnotationViewVerticalOffset);
        
        _state = JPSThumbnailAnnotationViewStateCollapsed;
        
        [self setupView];
    }
    
    return self;
}

- (void)setupView {
    [self setupImageView];
    [self setupTitleLabel];
    [self setupSubtitleLabel];
//    [self setupDisclosureButton];
    [self setupPrimaryButton];
    [self setupSecondaryButton];
    [self setLayerProperties];
    [self setDetailGroupAlpha:0.0f];
}

- (void)setupImageView {
    _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(-4.0f, 1.0f, 43.0f, 46.0f)];
    _imageView.layer.cornerRadius = 14.5f;
    _imageView.layer.masksToBounds = YES;
//    _imageView.layer.borderColor = [[UIColor lightGrayColor] CGColor];
//    _imageView.layer.borderWidth = 0.5f;
    [self addSubview:_imageView];
}

- (void)setupTitleLabel {
    _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(-120.0f, -12.0f, 175.0f, 20.0f)];
    _titleLabel.textColor = [UIColor whiteColor];
    _titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:18.0f];
    _titleLabel.minimumScaleFactor = 0.7f;
    _titleLabel.adjustsFontSizeToFitWidth = YES;
    [self addSubview:_titleLabel];
}

- (void)setupSubtitleLabel {
    _subtitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(-120.0f, 8.0f, 168.0f, 20.0f)];
    _subtitleLabel.textColor = [UIColor lightGrayColor];
    _subtitleLabel.font = [UIFont systemFontOfSize:12.0f];
    [self addSubview:_subtitleLabel];
}

- (void)setupPrimaryButton {
    _primaryButton = [UIButton buttonWithType:UIButtonTypeSystem];
    UIImage *image = [UIImage imageNamed:@"bus-green-50.png"];
    [_primaryButton setImage:image forState:UIControlStateNormal];
    _primaryButton.tintColor = SYSTEM_GREEN_COLOR;
    
    _primaryButton.frame = CGRectMake(125.0f, -10.0f, 35.0f, 35.0f);
    [self addSubview:_primaryButton];
    
    [_primaryButton addTarget:self action:@selector(didTapPrimaryButton) forControlEvents:UIControlEventTouchDown];
}

- (void)setupSecondaryButton {
    _secondaryButton = [UIButton buttonWithType:UIButtonTypeSystem];
    UIImage *image = [UIImage imageNamed:@"calendar-50.png"];
    [_secondaryButton setImage:image forState:UIControlStateNormal];
    _secondaryButton.tintColor = SYSTEM_GREEN_COLOR;
    
    _secondaryButton.frame = CGRectMake(75.0f, -10.0f, 32.0f, 35.0f);
    [self addSubview:_secondaryButton];
    
    [_secondaryButton addTarget:self action:@selector(didTapSecondaryButton) forControlEvents:UIControlEventTouchDown];
}

- (void)setupDisclosureButton {
    BOOL iOS7 = [[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0f;
    UIButtonType buttonType = iOS7 ? UIButtonTypeSystem : UIButtonTypeCustom;
    _disclosureButton = [UIButton buttonWithType:buttonType];
    _disclosureButton.tintColor = [UIColor grayColor];
    UIImage *disclosureIndicatorImage = [JPSThumbnailAnnotationView disclosureButtonImage];
    [_disclosureButton setImage:disclosureIndicatorImage forState:UIControlStateNormal];
    _disclosureButton.frame = CGRectMake(kJPSThumbnailAnnotationViewExpandOffset/2.0f + self.frame.size.width/2.0f + 8.0f,
                                         26.5f,
                                         disclosureIndicatorImage.size.width,
                                         disclosureIndicatorImage.size.height);
    
    [_disclosureButton addTarget:self action:@selector(didTapDisclosureButton) forControlEvents:UIControlEventTouchDown];
    [self addSubview:_disclosureButton];
}

- (void)setLayerProperties {
    _bgLayer = [CAShapeLayer layer];
//    CGPathRef path = [self newBubbleWithRect:self.bounds];
//    _bgLayer.path = path;
//    CFRelease(path);
    _bgLayer.fillColor = [UIColor darkGrayColor].CGColor;
    
    _bgLayer.shadowColor = [UIColor blackColor].CGColor;
    _bgLayer.shadowOffset = CGSizeMake(0.0f, 2.0f);
    _bgLayer.shadowRadius = 2.0f;
    _bgLayer.shadowOpacity = 0.5f;
    
    _bgLayer.masksToBounds = NO;
    
    [self.layer insertSublayer:_bgLayer atIndex:0];
}

#pragma mark - Updating

- (void)updateWithThumbnail:(JPSThumbnail *)thumbnail {
    self.coordinate = thumbnail.coordinate;
    self.code = thumbnail.code;
    self.titleLabel.text = thumbnail.title;
    self.subtitleLabel.text = thumbnail.subtitle;
//    self.selected = thumbnail.selected;
    self.imageView.image = thumbnail.image;
    self.disclosureBlock = thumbnail.disclosureBlock;
    self.primaryButtonBlock = thumbnail.primaryButtonBlock;
    self.secondaryButtonBlock = thumbnail.secondaryButtonBlock;
    
    if (!self.primaryButtonBlock)
        self.primaryButton.hidden = YES;
    else
        self.primaryButton.hidden = NO;
    if (!self.secondaryButtonBlock)
        self.secondaryButton.hidden = YES;
    else
        self.secondaryButton.hidden = NO;
    
}

#pragma mark - JPSThumbnailAnnotationViewProtocol

- (void)didSelectAnnotationViewInMap:(MKMapView *)mapView {
    // Center map at annotation point
    [mapView setCenterCoordinate:self.coordinate animated:YES];
    [self expand];
}

- (void)didDeselectAnnotationViewInMap:(MKMapView *)mapView {
    [self shrink];
}

#pragma mark - Geometry

- (CGPathRef)newBubbleWithRect:(CGRect)rect {
    CGFloat stroke = 1.0f;
	CGFloat radius = 17.5f;
	CGMutablePathRef path = CGPathCreateMutable();
	CGFloat parentX = rect.origin.x + rect.size.width/2.0f;
    
    CGPoint curveTouchPoint;
	
	// Determine Size
	rect.size.width -= stroke;
//	rect.size.height -= stroke + 29.0f;
    rect.size.height -= stroke + 7.0f;
	rect.origin.x += stroke / 2.0f;
	rect.origin.y += stroke / 2.0f;
    
	// Create Callout Bubble Path
	CGPathMoveToPoint(path, NULL, rect.origin.x, rect.origin.y + radius);
	CGPathAddLineToPoint(path, NULL, rect.origin.x, rect.origin.y + rect.size.height - radius);
    if ((rect.size.width - 2*radius > 7.0f)) {
        CGPathAddArc(path, NULL, rect.origin.x + radius, rect.origin.y + rect.size.height - radius, radius, M_PI, M_PI_2, 1);
        CGPathAddLineToPoint(path, NULL, parentX - 7.0f, rect.origin.y + rect.size.height);
    }else{
        CGPathAddArc(path, NULL, rect.origin.x + radius, rect.origin.y + rect.size.height - radius, radius, M_PI, M_PI_2 + M_PI_4, 1);
        curveTouchPoint = CGPathGetCurrentPoint(path);
        
        
    }
	
	CGPathAddLineToPoint(path, NULL, parentX, rect.origin.y + rect.size.height + 7.0f);
    
    if ((rect.size.width - 2*radius > 7.0f)) {
        CGPathAddLineToPoint(path, NULL, parentX + 7.0f, rect.origin.y + rect.size.height);
        CGPathAddLineToPoint(path, NULL, rect.origin.x + rect.size.width - radius, rect.origin.y + rect.size.height);
        CGPathAddArc(path, NULL, rect.origin.x + rect.size.width - radius, rect.origin.y + rect.size.height - radius, radius, M_PI_2, 0.0f, 1.0f);
    }else{
        CGFloat x = rect.size.width - curveTouchPoint.x + 1;
        
        CGPathAddLineToPoint(path, NULL, x, curveTouchPoint.y);
        CGPathAddArc(path, NULL, rect.origin.x + rect.size.width - radius, rect.origin.y + rect.size.height - radius, radius, M_PI_2 - M_PI_4, 0.0f, 1.0f);
    }
	
	CGPathAddLineToPoint(path, NULL, rect.origin.x + rect.size.width, rect.origin.y + radius);
	CGPathAddArc(path, NULL, rect.origin.x + rect.size.width - radius, rect.origin.y + radius, radius, 0.0f, -M_PI_2, 1.0f);
	CGPathAddLineToPoint(path, NULL, rect.origin.x + radius, rect.origin.y);
	CGPathAddArc(path, NULL, rect.origin.x + radius, rect.origin.y + radius, radius, -M_PI_2, M_PI, 1.0f);
	CGPathCloseSubpath(path);
    return path;
}

#pragma mark - Animations

- (void)setDetailGroupAlpha:(CGFloat)alpha {
    self.disclosureButton.alpha = alpha;
    self.titleLabel.alpha = alpha;
    self.subtitleLabel.alpha = alpha;
    self.primaryButton.alpha = alpha;
    self.secondaryButton.alpha = alpha;
}

- (void)setCompactGroupAlpha:(CGFloat)alpha {
    self.imageView.alpha = alpha;
}

- (void)expand {
    if (self.state != JPSThumbnailAnnotationViewStateCollapsed) return;
    
    self.state = JPSThumbnailAnnotationViewStateAnimating;
    
    [self animateBubbleWithDirection:JPSThumbnailAnnotationViewAnimationDirectionGrow];
    [self setCompactGroupAlpha:0];
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width+kJPSThumbnailAnnotationViewExpandOffset, self.frame.size.height + kJPSThumbnailAnnotationViewExpandHeightOffset);
    self.centerOffset = CGPointMake(kJPSThumbnailAnnotationViewExpandOffset/2.0f, -kJPSThumbnailAnnotationViewExpandHeightOffset/2.0f);
    [UIView animateWithDuration:kJPSThumbnailAnnotationViewAnimationDuration/2.0f delay:kJPSThumbnailAnnotationViewAnimationDuration options:UIViewAnimationOptionCurveEaseInOut animations:^{
        [self setDetailGroupAlpha:1.0f];
    } completion:^(BOOL finished) {
        self.state = JPSThumbnailAnnotationViewStateExpanded;
    }];
}

- (void)shrink {
    if (self.state != JPSThumbnailAnnotationViewStateExpanded) return;
    
    self.state = JPSThumbnailAnnotationViewStateAnimating;

    self.frame = CGRectMake(self.frame.origin.x,
                            self.frame.origin.y,
                            self.frame.size.width - kJPSThumbnailAnnotationViewExpandOffset,
                            self.frame.size.height - kJPSThumbnailAnnotationViewExpandHeightOffset);
    
    [UIView animateWithDuration:kJPSThumbnailAnnotationViewAnimationDuration/2.0f
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         [self setDetailGroupAlpha:0.0f];
                     }
                     completion:^(BOOL finished) {
                         [self animateBubbleWithDirection:JPSThumbnailAnnotationViewAnimationDirectionShrink];
                         self.centerOffset = CGPointMake(0.0f, -kJPSThumbnailAnnotationViewVerticalOffset);
                         [UIView animateWithDuration:kJPSThumbnailAnnotationViewAnimationDuration
                                               delay:0.0f
                                             options:UIViewAnimationOptionCurveEaseInOut
                                          animations:^{
                                          }
                                          completion:^(BOOL finished) {
                                              [self setCompactGroupAlpha:1];
                                          }];
                     }];
}

- (void)animateBubbleWithDirection:(JPSThumbnailAnnotationViewAnimationDirection)animationDirection {
    BOOL growing = (animationDirection == JPSThumbnailAnnotationViewAnimationDirectionGrow);
    // Image
    [UIView animateWithDuration:kJPSThumbnailAnnotationViewAnimationDuration animations:^{
        CGFloat xOffset = (growing ? -1 : 1) * kJPSThumbnailAnnotationViewExpandOffset/2.0f;
        
        self.imageView.frame = CGRectOffset(self.imageView.frame, xOffset, 0.0f);
    } completion:^(BOOL finished) {
        if (animationDirection == JPSThumbnailAnnotationViewAnimationDirectionShrink) {
            self.state = JPSThumbnailAnnotationViewStateCollapsed;
        }
    }];
    
    // Bubble
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"path"];
    
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    animation.repeatCount = 1;
    animation.removedOnCompletion = NO;
    animation.fillMode = kCAFillModeForwards;
    animation.duration = kJPSThumbnailAnnotationViewAnimationDuration;
    
    // Stroke & Shadow From/To Values
    CGRect largeRect = CGRectInset(self.bounds, -kJPSThumbnailAnnotationViewExpandOffset/2.0f, -kJPSThumbnailAnnotationViewExpandHeightOffset/2.0f);
    largeRect = CGRectOffset(largeRect, 0, -kJPSThumbnailAnnotationViewExpandHeightOffset/2.0f);
    CGPathRef fromPath = [self newBubbleWithRect:growing ? self.bounds : largeRect];
    animation.fromValue = (__bridge id)fromPath;
    CGPathRelease(fromPath);
    
    CGPathRef toPath = [self newBubbleWithRect:growing ? largeRect : self.bounds];
    animation.toValue = (__bridge id)toPath;
    CGPathRelease(toPath);
    
    [self.bgLayer addAnimation:animation forKey:animation.keyPath];
}

#pragma mark - Buttons

- (void)didTapDisclosureButton {
    if (self.disclosureBlock) self.disclosureBlock();
}

- (void)didTapPrimaryButton {
    if (self.primaryButtonBlock) self.primaryButtonBlock();
}

- (void)didTapSecondaryButton {
    if (self.secondaryButtonBlock) self.secondaryButtonBlock();
}

+ (UIImage *)disclosureButtonImage {
    CGSize size = CGSizeMake(21.0f, 36.0f);
    UIGraphicsBeginImageContextWithOptions(size, NO, [[UIScreen mainScreen] scale]);
    
    UIBezierPath *bezierPath = [UIBezierPath bezierPath];
    [bezierPath moveToPoint:CGPointMake(2.0f, 2.0f)];
    [bezierPath addLineToPoint:CGPointMake(10.0f, 10.0f)];
    [bezierPath addLineToPoint:CGPointMake(2.0f, 18.0f)];
    [[UIColor lightGrayColor] setStroke];
    bezierPath.lineWidth = 3.0f;
    [bezierPath stroke];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

@end