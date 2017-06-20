//
//  JPSThumbnailAnnotationView.m
//  JPSThumbnailAnnotationView
//
//  Created by Jean-Pierre Simard on 4/21/13.
//  Copyright (c) 2013 JP Simard. All rights reserved.
//

@import QuartzCore;
#import "JPSThumbnailAnnotationView.h"
#import "AnnotationThumbnail.h"
#import "AppManager.h"
#import "ASA_Helpers.h"

NSString * const kJPSThumbnailAnnotationViewReuseID = @"JPSThumbnailAnnotationView";

//static CGFloat const kJPSThumbnailAnnotationViewStandardWidth     = 75.0f;
static CGFloat const kJPSThumbnailAnnotationViewStandardWidth     = 35.0f;
//static CGFloat const kJPSThumbnailAnnotationViewStandardHeight    = 87.0f;
static CGFloat const kJPSThumbnailAnnotationViewStandardHeight    = 43.0f;
static CGFloat const kJPSThumbnailAnnotationViewExpandOffset      = 265.0f;
static CGFloat const kJPSThumbnailAnnotationViewExpandHeightOffset= 20.0f;
static CGFloat const ASAThumbnailAnnotationViewImageViewHeight    = 42.0f;
static CGFloat const kJPSThumbnailAnnotationViewVerticalOffset    = 21.0f;
static CGFloat const kJPSThumbnailAnnotationViewAnimationDuration = 0.20f;

@interface JPSThumbnailAnnotationView ()

@property (nonatomic, strong) AnnotationThumbnail *thumbnail;

@property (nonatomic, readwrite) CLLocationCoordinate2D coordinate;
@property (nonatomic, strong) NSString *code;
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
@property (nonatomic, strong) UIButton *primaryButtonSmall;
@property (nonatomic, strong) UILabel *primaryButtonLabel;
@property (nonatomic, strong) UIButton *secondaryButton;
@property (nonatomic, assign) JPSThumbnailAnnotationViewState state;

@property (nonatomic, strong) UIColor *systemGreenColor;

@end

@implementation JPSThumbnailAnnotationView

#define SYSTEM_GREEN_COLOR [UIColor colorWithRed:51.0/255.0 green:153.0/255.0 blue:102/255.0 alpha:1.0];

#pragma mark - Setup

- (id)initWithAnnotation:(id<MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier annotationSize:(JPSThumbnailAnnotationViewSize)annotationSize {
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    
    if (self) {
        self.canShowCallout = NO;
        self.frame = CGRectMake(0, 0, kJPSThumbnailAnnotationViewStandardWidth, kJPSThumbnailAnnotationViewStandardHeight);
        self.backgroundColor = [UIColor clearColor];
        self.centerOffset = CGPointMake(0, -kJPSThumbnailAnnotationViewVerticalOffset);
//        self.clipsToBounds = YES;
        
        _state = JPSThumbnailAnnotationViewStateCollapsed;
        _systemGreenColor = [UIColor colorWithRed:51/256 green:153/256 blue:102/256 alpha:1];
        
        self.annotationSize = annotationSize;
        
        [self setupView];
    }
    
    return self;
}

+(CGSize)imageSize {
    return CGSizeMake(40.0f, ASAThumbnailAnnotationViewImageViewHeight);
}

- (void)setupView {
    [self setupImageView];
    [self setupTitleLabel];
    [self setupSubtitleLabel];
    [self setupDisclosureButton];
    [self setupPrimaryButton];
    [self setupSecondaryButton];
    [self setLayerProperties];
    [self setDetailGroupAlpha:0.0f];
}

- (void)setupImageView {
    _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(-3.0f, 10.0f, 40.0f, ASAThumbnailAnnotationViewImageViewHeight)];
//    _imageView.layer.cornerRadius = 14.5f;
    _imageView.contentMode = UIViewContentModeScaleAspectFit;
    _imageView.layer.masksToBounds = YES;
//    _imageView.layer.borderColor = [[UIColor lightGrayColor] CGColor];
//    _imageView.layer.borderWidth = 0.5f;
    [self addSubview:_imageView];
}

- (void)setupTitleLabel {
    _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(-60.0f, -48.0f, 190.0f, 20.0f)];
    _titleLabel.textColor = [UIColor blackColor];
    _titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:17.0f];
    _titleLabel.minimumScaleFactor = 0.7f;
    _titleLabel.adjustsFontSizeToFitWidth = YES;
    [self addSubview:_titleLabel];
}

- (void)setupSubtitleLabel {
    _subtitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(-60.0f, -28.0f, 180.0f, 20.0f)];
    _subtitleLabel.textColor = [UIColor darkGrayColor];
    _subtitleLabel.font = [UIFont systemFontOfSize:12.0f];
    [self addSubview:_subtitleLabel];
}

//It is the button on the left side with route
- (void)setupPrimaryButton {
    _primaryButton = [UIButton buttonWithType:UIButtonTypeSystem];
    _primaryButton.tintColor = [AppManager systemGreenColor];
    _primaryButton.backgroundColor = [UIColor colorWithWhite:0.93 alpha:1];
//    _primaryButton.backgroundColor = [UIColor clearColor];
    
    _primaryButton.frame = CGRectMake(0, 0, 55.0f, 55.5f);
    
    UIView *containerView = [[UIView alloc] initWithFrame:CGRectMake(-132.0f, -55.5f, 72.0f, 55.0f)];
    containerView.clipsToBounds = YES;
    containerView.layer.cornerRadius = 8.0;
    
    _primaryButtonSmall = [UIButton buttonWithType:UIButtonTypeSystem];
    UIImage *image = [UIImage imageNamed:@"up-right-arrow-32"];
    [_primaryButtonSmall setImage:image forState:UIControlStateNormal];
    _primaryButtonSmall.tintColor = [AppManager systemGreenColor];
    _primaryButtonSmall.frame = CGRectMake(15.0f, 15.0f, 25.0f, 25.0f);
    
    _primaryButtonLabel = [[UILabel alloc] initWithFrame:CGRectMake(8.0f, 32.0f, 40.0f, 20.0f)];
    _primaryButtonLabel.textColor = [AppManager systemGreenColor];
    _primaryButtonLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:12.0f];
    _primaryButtonLabel.textAlignment = NSTextAlignmentCenter;
    _primaryButtonLabel.adjustsFontSizeToFitWidth = YES;
    
    [containerView addSubview:_primaryButton];
    [containerView addSubview:_primaryButtonSmall];
    [containerView addSubview:_primaryButtonLabel];
    
    [self addSubview:containerView];
    
    [_primaryButton addTarget:self action:@selector(didTapPrimaryButton) forControlEvents:UIControlEventTouchDown];
    [_primaryButtonSmall addTarget:self action:@selector(didTapPrimaryButton) forControlEvents:UIControlEventTouchDown];
}

//it is going to cover the whole anotation
- (void)setupSecondaryButton {
    _secondaryButton = [UIButton buttonWithType:UIButtonTypeSystem];
//    UIImage *image = [UIImage imageNamed:@"calendar-50.png"];
//    [_secondaryButton setImage:image forState:UIControlStateNormal];
    _secondaryButton.tintColor = SYSTEM_GREEN_COLOR;
//    _secondaryButton.backgroundColor = [UIColor greenColor];
    _secondaryButton.frame = CGRectMake(-70.0f, -55.5f, 245.0f, 55.0f);
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
    _disclosureButton.frame = CGRectMake(kJPSThumbnailAnnotationViewExpandOffset/2.0f + self.frame.size.width/2.0f - 8.0f,
                                         -37.0f,
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
    _bgLayer.fillColor = [UIColor colorWithWhite:1 alpha:1].CGColor;
//    _bgLayer.strokeColor = [UIColor colorWithWhite:0.9 alpha:1].CGColor;
    
    _bgLayer.shadowColor = [UIColor darkGrayColor].CGColor;
    _bgLayer.shadowOffset = CGSizeMake(0.0f, 1.0f);
    _bgLayer.shadowRadius = 1.0f;
    _bgLayer.shadowOpacity = 0.3f;
    
    _bgLayer.masksToBounds = NO;
    
    [self.layer insertSublayer:_bgLayer atIndex:0];
}

//Required since the callout view is out of bounds and wont be tapped
-(UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    
//    UIView* hitView = [super hitTest:point withEvent:event];
//    if (hitView) {
//        NSLog(hitView);
//    }
    // Convert the point to the target view's coordinate system.
    // The target view isn't necessarily the immediate subview
    CGPoint pointForTargetView = [self.primaryButton convertPoint:point fromView:self];
    
    if (self.primaryButton.alpha != 0 && CGRectContainsPoint(self.primaryButton.bounds, pointForTargetView)) {
        
        // The target view may have its view hierarchy,
        // so call its hitTest method to return the right hit-test view
        return [self.primaryButton hitTest:pointForTargetView withEvent:event];
    }
    
    CGPoint pointForSTargetView = [self.secondaryButton convertPoint:point fromView:self];
    
    if (self.secondaryButton.alpha != 0 && CGRectContainsPoint(self.secondaryButton.bounds, pointForSTargetView)) {
        return [self.secondaryButton hitTest:pointForSTargetView withEvent:event];
    }
    
    CGPoint pointForImageTargetView = [self convertPoint:point fromView:self];
    CGRect targetArea;
    if (self.annotationSize == JPSThumbnailAnnotationViewSizeShrinked) {
        targetArea = CGRectMake(12, 14, 10, 10);
    } else {
        targetArea = self.bounds;
    }
    if (CGRectContainsPoint(targetArea, pointForImageTargetView)) {
        return nil;
    }
    
    return nil;
}

-(BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    
    CGPoint pointForImageTargetView = [self.imageView convertPoint:point fromView:self];
    CGRect targetArea;
    if (self.annotationSize == JPSThumbnailAnnotationViewSizeShrinked) {
        targetArea = CGRectMake(18, 24, 8, 8);
    } else {
        targetArea = self.imageView.bounds;
    }
    if (CGRectContainsPoint(targetArea, pointForImageTargetView)) {
        return YES;
    }
    
    return NO;
}

#pragma mark - Updating

- (void)updateWithThumbnail:(AnnotationThumbnail *)thumbnail {
    self.coordinate = thumbnail.coordinate;
    self.code = thumbnail.code;
    self.titleLabel.text = thumbnail.title;
    self.subtitleLabel.text = thumbnail.subtitle;
//    self.selected = thumbnail.selected;
    self.imageView.image = self.annotationSize == JPSThumbnailAnnotationViewSizeNormal ? thumbnail.image : thumbnail.shrinkedImage;
//    self.primaryButtonBlock = thumbnail.primaryButtonBlock;
//    self.secondaryButtonBlock = thumbnail.secondaryButtonBlock;
//    self.disclosureBlock = thumbnail.disclosureBlock;
    
    if (!self.primaryButtonBlock)
        self.primaryButton.hidden = YES;
    else
        self.primaryButton.hidden = NO;
    
    if (!self.secondaryButtonBlock)
        self.secondaryButton.hidden = YES;
    else
        self.secondaryButton.hidden = NO;
    
    if (!self.disclosureBlock)
        self.disclosureButton.hidden = YES;
    else
        self.disclosureButton.hidden = NO;
    
    self.thumbnail = thumbnail;
}

#pragma mark - JPSThumbnailAnnotationViewProtocol

- (void)didSelectAnnotationViewInMap:(MKMapView *)mapView {
    // Center map at annotation point
//    MKCoordinateSpan span = mapView.region.span;
//    MKCoordinateRegion region = {self.coordinate, span};
    
    //Always set normal size image
    self.imageView.image = self.thumbnail.image;
    
    CGPoint annotPoint = [mapView convertCoordinate:self.coordinate toPointToView:mapView];
    
    CGFloat yOffset = annotPoint.y < 160 ? 160 - annotPoint.y : 0;
    CGFloat xOffset;
    if( annotPoint.x < 170){
        xOffset = 170 - annotPoint.x;
    }else if(annotPoint.x > mapView.frame.size.width - 170){
        xOffset = mapView.frame.size.width - annotPoint.x - 170;
    }else{
        xOffset = 0;
    }
    
    CGPoint centerPoint = [mapView convertCoordinate:mapView.region.center toPointToView:mapView];
    CGPoint fakecenter = CGPointMake(centerPoint.x - xOffset, centerPoint.y - yOffset);
    CLLocationCoordinate2D coordinate = [mapView convertPoint:fakecenter toCoordinateFromView:mapView];
    [mapView setCenterCoordinate:coordinate animated:YES];
    
//    [mapView setRegion:region animated:YES];
//    [mapView setCenterCoordinate:self.coordinate animated:YES];
    [self expand];
}

- (void)didDeselectAnnotationViewInMap:(MKMapView *)mapView {
    [self shrink];
    //Return small primary button to position if it was moved
    self.primaryButtonSmall.frame = CGRectMake(15.0f, 15.0f, 25.0f, 25.0f);
    self.primaryButtonLabel.text = @"";
    
    
    self.imageView.image = self.annotationSize == JPSThumbnailAnnotationViewSizeNormal ? self.thumbnail.image : self.thumbnail.shrinkedImage;
}

- (void)setGoToHereDurationString:(MKMapView *)mapView duration:(NSString *)durationString withIconImage:(UIImage *)image {
    CGRect buttonFrame = self.primaryButtonSmall.frame;
    if (image) {
        [self.primaryButtonSmall setImageEdgeInsets:UIEdgeInsetsMake(4, 4, 4, 4)];
        [self layoutSubviews];
    }
    
    [UIView transitionWithView:self duration:0.2 options:UIViewAnimationOptionCurveEaseIn animations:^{
        self.primaryButtonSmall.frame = CGRectMake(buttonFrame.origin.x, buttonFrame.origin.y - 7, buttonFrame.size.width, buttonFrame.size.height);
        
    } completion:^(BOOL finished) {
        [self.primaryButtonLabel setText:durationString];
        
        if (image) {
            [self asa_springAnimationWithDuration:0.3 animation:^{
                [self.primaryButtonSmall setImage:image forState:UIControlStateNormal];
                [self.primaryButtonSmall setImageEdgeInsets:UIEdgeInsetsZero];
                [self layoutSubviews];
            } completion:^(BOOL finished){}];
        }
    }];
    
}

- (void)setSubtitleLabelText:(NSString *)subtitleText {
    self.subtitleLabel.text = subtitleText;
}

- (void)setGeoCodeAddress:(MKMapView *)mapView address:(NSString *)address{
    if (address==nil) {
        self.disclosureButton.alpha = 0;
        self.titleLabel.frame = CGRectMake(-60.0f, -40.0f, 175.0f, 20.0f);
    }else{
        self.disclosureButton.alpha = 1;
        self.titleLabel.frame = CGRectMake(-60.0f, -48.0f, 175.0f, 20.0f);
    }
    self.subtitleLabel.text = address;
}

#pragma mark - Geometry

- (CGPathRef)newBubbleWithRect:(CGRect)rect {
    CGFloat stroke = 1.0f;
	CGFloat radius = 8.f;
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
    self.primaryButtonSmall.alpha = alpha;
    self.primaryButtonLabel.alpha = alpha;
    self.secondaryButton.alpha = alpha;
}

- (void)setCompactGroupAlpha:(CGFloat)alpha {
//    self.imageView.alpha = alpha;
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
        _bgLayer.fillColor = [UIColor colorWithWhite:1 alpha:1].CGColor;
        _bgLayer.strokeColor = [UIColor colorWithWhite:0.9 alpha:1].CGColor;
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
                                              _bgLayer.fillColor = [UIColor clearColor].CGColor;
                                              _bgLayer.strokeColor = [UIColor clearColor].CGColor;
                                          }];
                     }];
    
}

- (void)animateBubbleWithDirection:(JPSThumbnailAnnotationViewAnimationDirection)animationDirection {
    BOOL growing = (animationDirection == JPSThumbnailAnnotationViewAnimationDirectionGrow);
    // Image
    [UIView animateWithDuration:kJPSThumbnailAnnotationViewAnimationDuration animations:^{
//        CGFloat xOffset = (growing ? -1 : 1) * kJPSThumbnailAnnotationViewExpandOffset/2.0f;
        
//        self.imageView.frame = CGRectOffset(self.imageView.frame, xOffset, 0.0f);
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
    largeRect = CGRectOffset(largeRect, 0, -ASAThumbnailAnnotationViewImageViewHeight - 4.0f);
    CGPathRef fromPath = [self newBubbleWithRect:growing ? CGRectOffset(self.bounds, 0, -ASAThumbnailAnnotationViewImageViewHeight - 4.0f) : largeRect];
    animation.fromValue = (__bridge id)fromPath;
    CGPathRelease(fromPath);
    
    CGPathRef toPath = [self newBubbleWithRect:growing ? largeRect : CGRectOffset(self.bounds, 0, -ASAThumbnailAnnotationViewImageViewHeight - 4.0f)];
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
