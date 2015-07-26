//
//  GCThumbnailAnnotationView.m
//  GCThumbnailAnnotationView
//
//  Created by Jean-Pierre Simard on 4/21/13.
//  Copyright (c) 2013 JP Simard. All rights reserved.
//

@import QuartzCore;
#import "GCThumbnailAnnotationView.h"
#import "GCThumbnail.h"

NSString * const kGCThumbnailAnnotationViewReuseID = @"GCThumbnailAnnotationView";

//static CGFloat const kGCThumbnailAnnotationViewStandardWidth     = 75.0f;
static CGFloat const kGCThumbnailAnnotationViewStandardWidth     = 0.0f;
//static CGFloat const kGCThumbnailAnnotationViewStandardHeight    = 87.0f;
static CGFloat const kGCThumbnailAnnotationViewStandardHeight    = 0.0f;
static CGFloat const kGCThumbnailAnnotationViewExpandOffset      = 150.0f;
static CGFloat const kGCThumbnailAnnotationViewExpandHeightOffset= 55.0f;
static CGFloat const ASAMagicVerticalOffset    = 26.0f;
//static CGFloat const kGCThumbnailAnnotationTriangleHeight        = 14.0f;
//static CGFloat const ASAThumbnailAnnotationViewImageViewHeight    = 5.0f;
//static CGFloat const ASAThumbnailAnnotationViewImageViewWidth    = 5.0f;
//static CGFloat const kGCThumbnailAnnotationViewVerticalOffset    = 21.0f;
static CGFloat const kGCThumbnailAnnotationViewAnimationDuration = 0.25f;

@interface GCThumbnailAnnotationView ()

@property (nonatomic, readwrite) CLLocationCoordinate2D coordinate;
@property (nonatomic, strong) NSNumber *code;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *subtitleLabel;
//@property (nonatomic) bool selected;
@property (nonatomic, strong) ActionBlock disclosureBlock;
@property (nonatomic, strong) ActionBlock primaryButtonBlock;
@property (nonatomic, strong) ActionBlock secondaryButtonBlock;
@property (nonatomic, strong) ActionBlock middleButtonBlock;

@property (nonatomic, strong) CAShapeLayer *bgLayer;
@property (nonatomic, strong) UIView *firstSep;
@property (nonatomic, strong) UIView *secondSep;
@property (nonatomic, strong) UIButton *disclosureButton;
@property (nonatomic, strong) UIButton *primaryButton;
@property (nonatomic, strong) UIButton *primaryButtonSmall;
@property (nonatomic, strong) UILabel *primaryButtonLabel;
@property (nonatomic, strong) UIButton *secondaryButton;
@property (nonatomic, strong) UIButton *secondaryButtonSmall;
@property (nonatomic, strong) UILabel *secondaryButtonLabel;
@property (nonatomic, strong) UIButton *middleButton;
@property (nonatomic, assign) GCThumbnailAnnotationViewState state;

@property (nonatomic, strong) UIColor *systemGreenColor;

@end

@implementation GCThumbnailAnnotationView

#define SYSTEM_GREEN_COLOR [UIColor colorWithRed:51.0/255.0 green:153.0/255.0 blue:102/255.0 alpha:1.0];

#pragma mark - Setup

- (id)initWithAnnotation:(id<MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    
    if (self) {
        self.canShowCallout = NO;
        self.frame = CGRectMake(0, 0, 0, 0);
        self.backgroundColor = [UIColor clearColor];
//        self.centerOffset = CGPointMake(0, -kGCThumbnailAnnotationViewVerticalOffset);
        
        _state = GCThumbnailAnnotationViewStateCollapsed;
        _systemGreenColor = [UIColor colorWithRed:51/256 green:153/256 blue:102/256 alpha:1];
        [self setupView];
    }
    
    return self;
}

- (void)setupView {
    [self setupImageView];
    [self setUpSeparators];
//    [self setupTitleLabel];
//    [self setupSubtitleLabel];
//    [self setupDisclosureButton];
    [self setupPrimaryButton];
    [self setupSecondaryButton];
    [self setupMiddleButton];
    [self setLayerProperties];
    [self setDetailGroupAlpha:0.0f];
}

- (void)setupImageView {
    _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kGCThumbnailAnnotationViewStandardWidth, kGCThumbnailAnnotationViewStandardHeight)];
//    _imageView.layer.cornerRadius = 14.5f;
    _imageView.contentMode = UIViewContentModeScaleAspectFit;
    _imageView.layer.masksToBounds = YES;
//    _imageView.layer.borderColor = [[UIColor lightGrayColor] CGColor];
//    _imageView.layer.borderWidth = 0.5f;
    [self addSubview:_imageView];
}

-(void)setUpSeparators{
    _firstSep = [[UIView alloc] initWithFrame:CGRectMake(-kGCThumbnailAnnotationViewExpandOffset/6, -ASAMagicVerticalOffset + 5, 0.5f, 35.0f)];
    _firstSep.backgroundColor = [UIColor lightGrayColor];
    _firstSep.alpha = 0.5;
    
    _secondSep = [[UIView alloc] initWithFrame:CGRectMake(kGCThumbnailAnnotationViewExpandOffset/6, -ASAMagicVerticalOffset + 5, 0.5f, 35.0f)];
    _secondSep.backgroundColor = [UIColor lightGrayColor];
    _secondSep.alpha = 0.5;
    
    [self addSubview:_firstSep];
    [self addSubview:_secondSep];
}

- (void)setupTitleLabel {
    _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(-60.0f, -48.0f, 190.0f, 20.0f)];
    _titleLabel.textColor = [UIColor blackColor];
    _titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:17.0f];
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
    _primaryButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _primaryButton.frame = CGRectMake(0, 0, 50, 50);
    
    UIView *containerView = [[UIView alloc] initWithFrame:CGRectMake(-kGCThumbnailAnnotationViewExpandOffset/2.0f, -ASAMagicVerticalOffset, 50, 50)];
    containerView.clipsToBounds = YES;
    containerView.layer.cornerRadius = 10.0;
    
    _primaryButtonSmall = [UIButton buttonWithType:UIButtonTypeSystem];
    UIImage *image = [UIImage imageNamed:@"goFromHere.png"];
    [_primaryButtonSmall setImage:image forState:UIControlStateNormal];
    _primaryButtonSmall.tintColor = SYSTEM_GREEN_COLOR;
    _primaryButtonSmall.frame = CGRectMake(12.0f, 10.0f, 25.0f, 17.0f);
    
    _primaryButtonLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 31.0f, 50.0f, 10.0f)];
    _primaryButtonLabel.textColor = [UIColor darkTextColor];
    _primaryButtonLabel.font = [UIFont fontWithName:@"HelveticaNeue-light" size:10.0f];
    _primaryButtonLabel.textAlignment = NSTextAlignmentCenter;
    _primaryButtonLabel.adjustsFontSizeToFitWidth = YES;
    _primaryButtonLabel.text = @"from here";
    
    [containerView addSubview:_primaryButton];
    [containerView addSubview:_primaryButtonSmall];
    [containerView addSubview:_primaryButtonLabel];
    
    [self addSubview:containerView];
    
    [_primaryButton addTarget:self action:@selector(didTapPrimaryButton) forControlEvents:UIControlEventTouchDown];
    [_primaryButtonSmall addTarget:self action:@selector(didTapPrimaryButton) forControlEvents:UIControlEventTouchDown];
}

//it is going to cover the whole anotation
- (void)setupSecondaryButton {
    _secondaryButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _secondaryButton.frame = CGRectMake(0, 0, 50, 50);
    
    UIView *containerView = [[UIView alloc] initWithFrame:CGRectMake(kGCThumbnailAnnotationViewExpandOffset/6.0f, -ASAMagicVerticalOffset, 50, 50)];
    containerView.clipsToBounds = YES;
    containerView.layer.cornerRadius = 10.0;
    
    _secondaryButtonSmall = [UIButton buttonWithType:UIButtonTypeSystem];
    UIImage *image = [UIImage imageNamed:@"goToHere.png"];
    [_secondaryButtonSmall setImage:image forState:UIControlStateNormal];
    _secondaryButtonSmall.tintColor = SYSTEM_GREEN_COLOR;
    _secondaryButtonSmall.frame = CGRectMake(12.0f, 10.0f, 25.0f, 17.0f);
    
    _secondaryButtonLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 31.0f, 50.0f, 10.0f)];
    _secondaryButtonLabel.textColor = [UIColor darkTextColor];
    _secondaryButtonLabel.font = [UIFont fontWithName:@"HelveticaNeue-light" size:10.0f];
    _secondaryButtonLabel.textAlignment = NSTextAlignmentCenter;
    _secondaryButtonLabel.adjustsFontSizeToFitWidth = YES;
    _secondaryButtonLabel.text = @"to here";
    
    [containerView addSubview:_secondaryButton];
    [containerView addSubview:_secondaryButtonSmall];
    [containerView addSubview:_secondaryButtonLabel];
    
    [self addSubview:containerView];
    
    [_secondaryButton addTarget:self action:@selector(didTapSecondaryButton) forControlEvents:UIControlEventTouchDown];
    [_secondaryButtonSmall addTarget:self action:@selector(didTapSecondaryButton) forControlEvents:UIControlEventTouchDown];
}

- (void)setupMiddleButton {
    _middleButton = [UIButton buttonWithType:UIButtonTypeInfoDark];
    _middleButton.frame = CGRectMake(-11, -ASAMagicVerticalOffset + 10, 22, 22);
    _middleButton.tintColor = SYSTEM_GREEN_COLOR;
    _middleButton.enabled = NO;
    [self addSubview:_middleButton];
    
    [_middleButton addTarget:self action:@selector(didTapMiddleButton) forControlEvents:UIControlEventTouchDown];
}

- (void)setupDisclosureButton {
    BOOL iOS7 = [[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0f;
    UIButtonType buttonType = iOS7 ? UIButtonTypeSystem : UIButtonTypeCustom;
    _disclosureButton = [UIButton buttonWithType:buttonType];
    _disclosureButton.tintColor = [UIColor grayColor];
    UIImage *disclosureIndicatorImage = [GCThumbnailAnnotationView disclosureButtonImage];
    [_disclosureButton setImage:disclosureIndicatorImage forState:UIControlStateNormal];
    _disclosureButton.frame = CGRectMake(kGCThumbnailAnnotationViewExpandOffset/2.0f + self.frame.size.width/2.0f - 8.0f,
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
    _bgLayer.strokeColor = [UIColor colorWithWhite:0.9 alpha:1].CGColor;
    _bgLayer.borderWidth = 0.5f;
    
    _bgLayer.shadowColor = [UIColor lightGrayColor].CGColor;
    _bgLayer.shadowOffset = CGSizeMake(0.0f, 1.0f);
    _bgLayer.shadowRadius = 1.0f;
    _bgLayer.shadowOpacity = 0.3f;
    
    _bgLayer.masksToBounds = NO;
    
    [self.layer insertSublayer:_bgLayer atIndex:0];
}


-(UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    
    // Convert the point to the target view's coordinate system.
    // The target view isn't necessarily the immediate subview
    CGPoint pointForTargetView = [self.primaryButton convertPoint:point fromView:self];
    
    if (CGRectContainsPoint(self.primaryButton.bounds, pointForTargetView)) {
        
        // The target view may have its view hierarchy,
        // so call its hitTest method to return the right hit-test view
        return [self.primaryButton hitTest:pointForTargetView withEvent:event];
    }
    
    CGPoint pointForSTargetView = [self.secondaryButton convertPoint:point fromView:self];
    
    if (CGRectContainsPoint(self.secondaryButton.bounds, pointForSTargetView)) {
        
        return [self.secondaryButton hitTest:pointForSTargetView withEvent:event];
    }
    
    CGPoint pointForMTargetView = [self.middleButton convertPoint:point fromView:self];
    
    if (CGRectContainsPoint(self.middleButton.bounds, pointForMTargetView)) {
        
        return [self.middleButton hitTest:pointForMTargetView withEvent:event];
    }
    
    return [super hitTest:point withEvent:event];
}

#pragma mark - Updating

- (void)updateWithThumbnail:(GCThumbnail *)thumbnail {
    self.coordinate = thumbnail.coordinate;
    self.code = thumbnail.code;
    self.titleLabel.text = thumbnail.title;
    self.subtitleLabel.text = thumbnail.subtitle;
//    self.selected = thumbnail.selected;
    self.imageView.image = thumbnail.image;
    self.disclosureBlock = thumbnail.disclosureBlock;
    self.primaryButtonBlock = thumbnail.primaryButtonBlock;
    self.secondaryButtonBlock = thumbnail.secondaryButtonBlock;
    self.disclosureBlock = thumbnail.disclosureBlock;
    self.middleButtonBlock = thumbnail.middleButtonBlock;
    
    if (!self.primaryButtonBlock)
        self.primaryButton.hidden = YES;
    else
        self.primaryButton.hidden = NO;
    if (!self.secondaryButtonBlock)
        self.secondaryButton.hidden = YES;
    else
        self.secondaryButton.hidden = NO;
    
    [self expand];
}

#pragma mark - GCThumbnailAnnotationViewProtocol

- (void)didSelectAnnotationViewInMap:(MKMapView *)mapView {
    // Center map at annotation point
//    MKCoordinateSpan span = mapView.region.span;
//    MKCoordinateRegion region = {self.coordinate, span};
    
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
}

- (void)setGoToHereDurationString:(MKMapView *)mapView duration:(NSString *)durationString {
    CGRect buttonFrame = self.primaryButtonSmall.frame;
    
    [UIView transitionWithView:self duration:0.2 options:UIViewAnimationOptionCurveEaseIn animations:^{
        
        self.primaryButtonSmall.frame = CGRectMake(buttonFrame.origin.x, buttonFrame.origin.y - 7, buttonFrame.size.width, buttonFrame.size.height);
        
    } completion:^(BOOL finished) {
        [self.primaryButtonLabel setText:durationString];
    }];
    
}

- (void)enableAddressInfoButton{
    self.middleButton.enabled = YES;
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
    CGFloat stroke = 0.5f;
	CGFloat radius = 10.0f;
    CGFloat triangleWidth = 28.0f;
    CGFloat triangleHeight = 14.0f;
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
        CGPathAddLineToPoint(path, NULL, parentX - triangleWidth/2, rect.origin.y + rect.size.height);
    }else{
        CGPathAddArc(path, NULL, rect.origin.x + radius, rect.origin.y + rect.size.height - radius, radius, M_PI, M_PI_2 + M_PI_4, 1);
        curveTouchPoint = CGPathGetCurrentPoint(path);
    }
	
	CGPathAddLineToPoint(path, NULL, parentX, rect.origin.y + rect.size.height + triangleHeight);
    
    if ((rect.size.width - 2*radius > 7.0f)) {
        CGPathAddLineToPoint(path, NULL, parentX + triangleWidth/2, rect.origin.y + rect.size.height);
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
    self.firstSep.alpha = alpha;
    self.secondSep.alpha = alpha;
    self.primaryButton.alpha = alpha;
    self.primaryButtonSmall.alpha = alpha;
    self.primaryButtonLabel.alpha = alpha;
    self.secondaryButton.alpha = alpha;
    self.secondaryButtonSmall.alpha = alpha;
    self.secondaryButtonLabel.alpha = alpha;
    self.middleButton.alpha = alpha;
}

- (void)setCompactGroupAlpha:(CGFloat)alpha {
//    self.imageView.alpha = alpha;
}

- (void)expand {
    if (self.state != GCThumbnailAnnotationViewStateCollapsed) return;
    
    self.state = GCThumbnailAnnotationViewStateAnimating;
    
    [self animateBubbleWithDirection:GCThumbnailAnnotationViewAnimationDirectionGrow];
    [self setCompactGroupAlpha:0];
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width+kGCThumbnailAnnotationViewExpandOffset, self.frame.size.height + kGCThumbnailAnnotationViewExpandHeightOffset);
    self.centerOffset = CGPointMake(kGCThumbnailAnnotationViewExpandOffset/2.0f, 0);
    [UIView animateWithDuration:kGCThumbnailAnnotationViewAnimationDuration/2.0f delay:kGCThumbnailAnnotationViewAnimationDuration options:UIViewAnimationOptionCurveEaseInOut animations:^{
        [self setDetailGroupAlpha:1.0f];
        _bgLayer.fillColor = [UIColor colorWithWhite:1 alpha:1].CGColor;
    } completion:^(BOOL finished) {
        self.state = GCThumbnailAnnotationViewStateExpanded;
    }];
}

- (void)shrink {
    if (self.state != GCThumbnailAnnotationViewStateExpanded) return;
    
    self.state = GCThumbnailAnnotationViewStateAnimating;

    self.frame = CGRectMake(self.frame.origin.x,
                            self.frame.origin.y,
                            self.frame.size.width - kGCThumbnailAnnotationViewExpandOffset,
                            self.frame.size.height - kGCThumbnailAnnotationViewExpandHeightOffset);
    
    [UIView animateWithDuration:kGCThumbnailAnnotationViewAnimationDuration/2.0f
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         [self setDetailGroupAlpha:0.0f];
                     }
                     completion:^(BOOL finished) {
                         [self animateBubbleWithDirection:GCThumbnailAnnotationViewAnimationDirectionShrink];
//                         self.centerOffset = CGPointMake(0.0f, -kGCThumbnailAnnotationViewVerticalOffset);
                         [UIView animateWithDuration:kGCThumbnailAnnotationViewAnimationDuration
                                               delay:0.0f
                                             options:UIViewAnimationOptionCurveEaseInOut
                                          animations:^{
                                          }
                                          completion:^(BOOL finished) {
                                              [self setCompactGroupAlpha:1];
                                              _bgLayer.fillColor = [UIColor clearColor].CGColor;
                                          }];
                     }];
    
}

- (void)animateBubbleWithDirection:(GCThumbnailAnnotationViewAnimationDirection)animationDirection {
    BOOL growing = (animationDirection == GCThumbnailAnnotationViewAnimationDirectionGrow);
    // Image
    [UIView animateWithDuration:kGCThumbnailAnnotationViewAnimationDuration animations:^{
//        CGFloat xOffset = (growing ? -1 : 1) * kGCThumbnailAnnotationViewExpandOffset/2.0f;
        
//        self.imageView.frame = CGRectOffset(self.imageView.frame, xOffset, 0.0f);
    } completion:^(BOOL finished) {
        if (animationDirection == GCThumbnailAnnotationViewAnimationDirectionShrink) {
            self.state = GCThumbnailAnnotationViewStateCollapsed;
        }
    }];
    
    // Bubble
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"path"];
    
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    animation.repeatCount = 1;
    animation.removedOnCompletion = NO;
    animation.fillMode = kCAFillModeForwards;
    animation.duration = kGCThumbnailAnnotationViewAnimationDuration;
    
    // Stroke & Shadow From/To Values
    CGRect largeRect = CGRectInset(self.bounds, -kGCThumbnailAnnotationViewExpandOffset/2.0f, -kGCThumbnailAnnotationViewExpandHeightOffset/2.0f);
    largeRect = CGRectOffset(largeRect, 0, 0);
    CGPathRef fromPath = [self newBubbleWithRect:growing ? CGRectOffset(self.bounds, 0, 0) : largeRect];
    animation.fromValue = (__bridge id)fromPath;
    CGPathRelease(fromPath);
    
    CGPathRef toPath = [self newBubbleWithRect:growing ? largeRect : CGRectOffset(self.bounds, 0, 0)];
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

- (void)didTapMiddleButton {
    if (self.middleButtonBlock) self.middleButtonBlock();
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
