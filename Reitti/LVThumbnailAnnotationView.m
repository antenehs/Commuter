//
//  LVThumbnailAnnotationView.m
//  LVThumbnailAnnotationView
//
//  Created by Jean-Pierre Simard on 4/21/13.
//  Copyright (c) 2013 JP Simard. All rights reserved.
//

@import QuartzCore;
#import "LVThumbnailAnnotationView.h"
#import "LVThumbnail.h"

#define DegreesToRadians(x) ((x) * M_PI / 180.0)

NSString * const kLVThumbnailAnnotationViewReuseID = @"LVThumbnailAnnotationView";

//static CGFloat const kLVThumbnailAnnotationViewStandardWidth     = 75.0f;
static CGFloat const kLVThumbnailAnnotationViewStandardWidth     = 40.0f;
//static CGFloat const kLVThumbnailAnnotationViewStandardHeight    = 87.0f;
static CGFloat const kLVThumbnailAnnotationViewStandardHeight    = 40.0f;
static CGFloat const kLVThumbnailAnnotationViewExpandOffset      = 265.0f;
static CGFloat const kLVThumbnailAnnotationViewExpandHeightOffset= 20.0f;
static CGFloat const kLVThumbnailAnnotationViewVerticalOffset    = 21.0f;
static CGFloat const kLVThumbnailAnnotationViewAnimationDuration = 0.25f;

@interface LVThumbnailAnnotationView ()

@property (nonatomic, readwrite) CLLocationCoordinate2D coordinate;
@property (nonatomic, strong) NSString *code;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *titleLabel;
//@property (nonatomic, strong) UILabel *subtitleLabel;
////@property (nonatomic) bool selected;
//@property (nonatomic, strong) ActionBlock disclosureBlock;
//@property (nonatomic, strong) ActionBlock primaryButtonBlock;
//@property (nonatomic, strong) ActionBlock secondaryButtonBlock;

@property (nonatomic, strong) CAShapeLayer *bgLayer;
@property (nonatomic, strong) UIButton *primaryButton;
@property (nonatomic, assign) LVThumbnailAnnotationViewState state;

@property (nonatomic, strong) UIColor *systemGreenColor;

@end

@implementation LVThumbnailAnnotationView

#define SYSTEM_GREEN_COLOR [UIColor colorWithRed:51.0/255.0 green:153.0/255.0 blue:102/255.0 alpha:1.0];

#pragma mark - Setup

- (id)initWithAnnotation:(id<MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    
    if (self) {
        self.canShowCallout = NO;
        self.frame = CGRectMake(0, 0, kLVThumbnailAnnotationViewStandardWidth, kLVThumbnailAnnotationViewStandardHeight);
        self.backgroundColor = [UIColor clearColor];
//        self.centerOffset = CGPointMake(0, -kLVThumbnailAnnotationViewVerticalOffset);
        
        _state = LVThumbnailAnnotationViewStateCollapsed;
        _systemGreenColor = [UIColor colorWithRed:51/256 green:153/256 blue:102/256 alpha:1];
        [self setupView];
    }
    
    return self;
}

- (void)setupView {
    [self setupImageView];
    [self setupTitleLabel];
//    [self setupSubtitleLabel];
//    [self setupDisclosureButton];
//    [self setupPrimaryButton];
//    [self setupSecondaryButton];
    [self setLayerProperties];
    [self setDetailGroupAlpha:0.0f];
}

- (void)setupImageView {
    _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, kLVThumbnailAnnotationViewStandardWidth, kLVThumbnailAnnotationViewStandardHeight)];
//    _imageView.layer.cornerRadius = 14.5f;
    _imageView.layer.masksToBounds = YES;
//    _imageView.layer.borderColor = [[UIColor lightGrayColor] CGColor];
//    _imageView.layer.borderWidth = 0.5f;
    [self addSubview:_imageView];
}

- (void)setupTitleLabel {
    _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0f, 10.0f, kLVThumbnailAnnotationViewStandardWidth - 20, kLVThumbnailAnnotationViewStandardWidth - 20)];
    _titleLabel.textColor = [UIColor colorWithWhite:0.15 alpha:1];
    _titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:16.0f];
    _titleLabel.minimumScaleFactor = 0.3f;
    _titleLabel.adjustsFontSizeToFitWidth = YES;
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    
    [self addSubview:_titleLabel];
}

//- (void)setupSubtitleLabel {
//    _subtitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(-60.0f, 8.0f, 168.0f, 20.0f)];
//    _subtitleLabel.textColor = [UIColor lightGrayColor];
//    _subtitleLabel.font = [UIFont systemFontOfSize:12.0f];
//    [self addSubview:_subtitleLabel];
//}

//It is the button on the left side with route
//- (void)setupPrimaryButton {
//    _primaryButton = [UIButton buttonWithType:UIButtonTypeSystem];
//    _primaryButton.tintColor = SYSTEM_GREEN_COLOR;
//    _primaryButton.backgroundColor = [UIColor colorWithWhite:0.85 alpha:1];
//    
//    _primaryButton.frame = CGRectMake(0, 0, 55.0f, 55.5f);
//    
//    UIView *containerView = [[UIView alloc] initWithFrame:CGRectMake(-132.0f, -19.5f, 72.0f, 55.0f)];
//    containerView.clipsToBounds = YES;
//    containerView.layer.cornerRadius = 17.5;
//    
//    _primaryButtonSmall = [UIButton buttonWithType:UIButtonTypeSystem];
//    UIImage *image = [UIImage imageNamed:@"bus-filled-gray-100.png"];
//    [_primaryButtonSmall setImage:image forState:UIControlStateNormal];
//    _primaryButtonSmall.tintColor = SYSTEM_GREEN_COLOR;
//    _primaryButtonSmall.frame = CGRectMake(15.0f, 15.0f, 25.0f, 25.0f);
//    
//    _primaryButtonLabel = [[UILabel alloc] initWithFrame:CGRectMake(8.0f, 32.0f, 40.0f, 20.0f)];
//    _primaryButtonLabel.textColor = SYSTEM_GREEN_COLOR;
//    _primaryButtonLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:12.0f];
//    _primaryButtonLabel.textAlignment = NSTextAlignmentCenter;
//    _primaryButtonLabel.adjustsFontSizeToFitWidth = YES;
//    
//    [containerView addSubview:_primaryButton];
//    [containerView addSubview:_primaryButtonSmall];
//    [containerView addSubview:_primaryButtonLabel];
//    
//    [self addSubview:containerView];
//    
//    [_primaryButton addTarget:self action:@selector(didTapPrimaryButton) forControlEvents:UIControlEventTouchDown];
//    [_primaryButtonSmall addTarget:self action:@selector(didTapPrimaryButton) forControlEvents:UIControlEventTouchDown];
//}

//it is going to cover the whole anotation
//- (void)setupSecondaryButton {
//    _secondaryButton = [UIButton buttonWithType:UIButtonTypeSystem];
////    UIImage *image = [UIImage imageNamed:@"calendar-50.png"];
////    [_secondaryButton setImage:image forState:UIControlStateNormal];
//    _secondaryButton.tintColor = SYSTEM_GREEN_COLOR;
////    _secondaryButton.backgroundColor = [UIColor greenColor];
//    _secondaryButton.frame = CGRectMake(-70.0f, -19.5f, 205.0f, 55.0f);
//    [self addSubview:_secondaryButton];
//    
//    [_secondaryButton addTarget:self action:@selector(didTapSecondaryButton) forControlEvents:UIControlEventTouchDown];
//}

//- (void)setupDisclosureButton {
//    BOOL iOS7 = [[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0f;
//    UIButtonType buttonType = iOS7 ? UIButtonTypeSystem : UIButtonTypeCustom;
//    _disclosureButton = [UIButton buttonWithType:buttonType];
//    _disclosureButton.tintColor = [UIColor grayColor];
//    UIImage *disclosureIndicatorImage = [LVThumbnailAnnotationView disclosureButtonImage];
//    [_disclosureButton setImage:disclosureIndicatorImage forState:UIControlStateNormal];
//    _disclosureButton.frame = CGRectMake(kLVThumbnailAnnotationViewExpandOffset/2.0f + self.frame.size.width/2.0f - 8.0f,
//                                         -1.0f,
//                                         disclosureIndicatorImage.size.width,
//                                         disclosureIndicatorImage.size.height);
//    
//    [_disclosureButton addTarget:self action:@selector(didTapDisclosureButton) forControlEvents:UIControlEventTouchDown];
//    [self addSubview:_disclosureButton];
//}

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

//
//-(UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
//    
//    // Convert the point to the target view's coordinate system.
//    // The target view isn't necessarily the immediate subview
//    CGPoint pointForTargetView = [self.primaryButton convertPoint:point fromView:self];
//    
//    if (CGRectContainsPoint(self.primaryButton.bounds, pointForTargetView)) {
//        
//        // The target view may have its view hierarchy,
//        // so call its hitTest method to return the right hit-test view
//        return [self.primaryButton hitTest:pointForTargetView withEvent:event];
//    }
//    
//    CGPoint pointForSTargetView = [self.secondaryButton convertPoint:point fromView:self];
//    
//    if (CGRectContainsPoint(self.secondaryButton.bounds, pointForSTargetView)) {
//        
//        return [self.secondaryButton hitTest:pointForSTargetView withEvent:event];
//    }
//    
//    return [super hitTest:point withEvent:event];
//}

#pragma mark - Updating

- (void)updateWithThumbnail:(LVThumbnail *)thumbnail {
    self.coordinate = thumbnail.coordinate;
    self.code = thumbnail.code;
    self.titleLabel.text = thumbnail.title;
    if (thumbnail.title.length == 2) {
        self.titleLabel.frame = CGRectMake(10.0f, 10.5f, kLVThumbnailAnnotationViewStandardWidth - 20, kLVThumbnailAnnotationViewStandardWidth - 20);
    }else if (thumbnail.title.length == 3){
        self.titleLabel.frame = CGRectMake(10.0f, 8.5f, kLVThumbnailAnnotationViewStandardWidth - 20, kLVThumbnailAnnotationViewStandardWidth - 20);
    }
    
    self.imageView.image = thumbnail.image;
    self.imageView.transform = CGAffineTransformMakeRotation(DegreesToRadians([thumbnail.bearing doubleValue]));
    
//    self.alpha = 0.95;
}

#pragma mark - LVThumbnailAnnotationViewProtocol

- (void)didSelectAnnotationViewInMap:(MKMapView *)mapView {
//    // Center map at annotation point
//    MKCoordinateSpan span = {.latitudeDelta =  0.01, .longitudeDelta =  0.01};
//    MKCoordinateRegion region = {self.coordinate, span};
//    
//    [mapView setRegion:region animated:YES];
////    [mapView setCenterCoordinate:self.coordinate animated:YES];
//    [self expand];
}

- (void)didDeselectAnnotationViewInMap:(MKMapView *)mapView {
//    [self shrink];
//    //Return small primary button to position if it was moved
//    self.primaryButtonSmall.frame = CGRectMake(15.0f, 15.0f, 25.0f, 25.0f);
//    self.primaryButtonLabel.text = @"";
}

- (void)setGoToHereDurationString:(MKMapView *)mapView duration:(NSString *)durationString {
//    CGRect buttonFrame = self.primaryButtonSmall.frame;
//    
//    [UIView transitionWithView:self duration:0.2 options:UIViewAnimationOptionCurveEaseIn animations:^{
//        
//        self.primaryButtonSmall.frame = CGRectMake(buttonFrame.origin.x, buttonFrame.origin.y - 7, buttonFrame.size.width, buttonFrame.size.height);
//        
//    } completion:^(BOOL finished) {
//        [self.primaryButtonLabel setText:durationString];
//    }];
    
}

- (void)setGeoCodeAddress:(MKMapView *)mapView address:(NSString *)address{
//    if (address==nil) {
//        self.disclosureButton.alpha = 0;
//        self.titleLabel.frame = CGRectMake(-60.0f, -4.0f, 175.0f, 20.0f);
//    }else{
//        self.disclosureButton.alpha = 1;
//        self.titleLabel.frame = CGRectMake(-60.0f, -12.0f, 175.0f, 20.0f);
//    }
//    self.subtitleLabel.text = address;
}

- (void)setBearing:(NSNumber *)bearing;{
        [UIView transitionWithView:self duration:0.2 options:UIViewAnimationOptionCurveEaseIn animations:^{
            self.imageView.transform = CGAffineTransformMakeRotation(DegreesToRadians([bearing doubleValue]));
    
        } completion:^(BOOL finished) {}];
}

- (void)updateAnnotationImageFromThumbnail:(LVThumbnail *)thumbnail{
    self.imageView.image = thumbnail.image;
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
//    self.disclosureButton.alpha = alpha;
//    self.titleLabel.alpha = alpha;
//    self.subtitleLabel.alpha = alpha;
//    self.primaryButton.alpha = alpha;
//    self.primaryButtonSmall.alpha = alpha;
//    self.primaryButtonLabel.alpha = alpha;
//    self.secondaryButton.alpha = alpha;
}

- (void)setCompactGroupAlpha:(CGFloat)alpha {
    self.imageView.alpha = alpha;
}

- (void)expand {
    if (self.state != LVThumbnailAnnotationViewStateCollapsed) return;
    
    self.state = LVThumbnailAnnotationViewStateAnimating;
    
    [self animateBubbleWithDirection:LVThumbnailAnnotationViewAnimationDirectionGrow];
    [self setCompactGroupAlpha:0];
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width+kLVThumbnailAnnotationViewExpandOffset, self.frame.size.height + kLVThumbnailAnnotationViewExpandHeightOffset);
    self.centerOffset = CGPointMake(kLVThumbnailAnnotationViewExpandOffset/2.0f, -kLVThumbnailAnnotationViewExpandHeightOffset/2.0f);
    [UIView animateWithDuration:kLVThumbnailAnnotationViewAnimationDuration/2.0f delay:kLVThumbnailAnnotationViewAnimationDuration options:UIViewAnimationOptionCurveEaseInOut animations:^{
        [self setDetailGroupAlpha:1.0f];
    } completion:^(BOOL finished) {
        self.state = LVThumbnailAnnotationViewStateExpanded;
    }];
}

- (void)shrink {
    if (self.state != LVThumbnailAnnotationViewStateExpanded) return;
    
    self.state = LVThumbnailAnnotationViewStateAnimating;

    self.frame = CGRectMake(self.frame.origin.x,
                            self.frame.origin.y,
                            self.frame.size.width - kLVThumbnailAnnotationViewExpandOffset,
                            self.frame.size.height - kLVThumbnailAnnotationViewExpandHeightOffset);
    
    [UIView animateWithDuration:kLVThumbnailAnnotationViewAnimationDuration/2.0f
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         [self setDetailGroupAlpha:0.0f];
                     }
                     completion:^(BOOL finished) {
                         [self animateBubbleWithDirection:LVThumbnailAnnotationViewAnimationDirectionShrink];
                         self.centerOffset = CGPointMake(0.0f, -kLVThumbnailAnnotationViewVerticalOffset);
                         [UIView animateWithDuration:kLVThumbnailAnnotationViewAnimationDuration
                                               delay:0.0f
                                             options:UIViewAnimationOptionCurveEaseInOut
                                          animations:^{
                                          }
                                          completion:^(BOOL finished) {
                                              [self setCompactGroupAlpha:1];
                                          }];
                     }];
}

- (void)animateBubbleWithDirection:(LVThumbnailAnnotationViewAnimationDirection)animationDirection {
    BOOL growing = (animationDirection == LVThumbnailAnnotationViewAnimationDirectionGrow);
    // Image
    [UIView animateWithDuration:kLVThumbnailAnnotationViewAnimationDuration animations:^{
        CGFloat xOffset = (growing ? -1 : 1) * kLVThumbnailAnnotationViewExpandOffset/2.0f;
        
        self.imageView.frame = CGRectOffset(self.imageView.frame, xOffset, 0.0f);
    } completion:^(BOOL finished) {
        if (animationDirection == LVThumbnailAnnotationViewAnimationDirectionShrink) {
            self.state = LVThumbnailAnnotationViewStateCollapsed;
        }
    }];
    
    // Bubble
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"path"];
    
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    animation.repeatCount = 1;
    animation.removedOnCompletion = NO;
    animation.fillMode = kCAFillModeForwards;
    animation.duration = kLVThumbnailAnnotationViewAnimationDuration;
    
    // Stroke & Shadow From/To Values
    CGRect largeRect = CGRectInset(self.bounds, -kLVThumbnailAnnotationViewExpandOffset/2.0f, -kLVThumbnailAnnotationViewExpandHeightOffset/2.0f);
    largeRect = CGRectOffset(largeRect, 0, -kLVThumbnailAnnotationViewExpandHeightOffset/2.0f);
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
//    if (self.disclosureBlock) self.disclosureBlock();
}

- (void)didTapPrimaryButton {
//    if (self.primaryButtonBlock) self.primaryButtonBlock();
}

- (void)didTapSecondaryButton {
//    if (self.secondaryButtonBlock) self.secondaryButtonBlock();
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
