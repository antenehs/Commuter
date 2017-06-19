//
//  DefaultAnnotationCallout.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 6/19/17.
//  Copyright © 2017 Anteneh Sahledengel. All rights reserved.
//

#import "DefaultAnnotationCallout.h"
#import "KBPopupBubbleView.h"
#import "AppManager.h"
#import "ASA_Helpers.h"

@interface DefaultAnnotationCallout ()

@property (nonatomic, strong) AnnotationThumbnail *thumbnail;
@property (nonatomic, strong) DetailAnnotationSettings *settings;
@property (nonatomic, strong) KBPopupBubbleView *bubbleView;

@property (strong, nonatomic) IBOutlet UIView *basicContainerView;

@property (strong, nonatomic) IBOutlet UIButton *primaryButton;
@property (strong, nonatomic) IBOutlet UIButton *primaryButtonSmall;
@property (strong, nonatomic) IBOutlet UILabel *primaryButtonLabel;

@property (strong, nonatomic) IBOutlet UIButton *secondaryButton;

@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UILabel *subtitleLabel;

@property (strong, nonatomic) IBOutlet UIImageView *disclosureImage;

@end

@implementation DefaultAnnotationCallout

+(instancetype)calloutForThumbnail:(AnnotationThumbnail *)thumbnail andSettings:(DetailAnnotationSettings *)settings {
    DefaultAnnotationCallout *callout = [[self alloc] initFromNib];
    
    callout.thumbnail = thumbnail;
    callout.settings = settings;
    
    [callout setupView];
    
    return callout;
}

-(instancetype)initFromNib {
    self = [super init];
    if (self) {
        self = [[[NSBundle mainBundle] loadNibNamed:@"DefaultAnnotationCallout" owner:self options:nil] firstObject];
    }
    
    return self;
}

#pragma mark - SetupView
-(void)setupView {
    
    [self setupTitleLabel];
    [self setupSubtitleLabel];
    [self setupDisclosureButton];
    [self setupPrimaryButton];
    [self setupSecondaryButton];
    [self addBubbleView];
    [self setupBasicContainerView];
    
}

- (void)setupTitleLabel {
    _titleLabel.textColor = [UIColor blackColor];
    _titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:17.0f];
    _titleLabel.minimumScaleFactor = 0.7f;
    _titleLabel.adjustsFontSizeToFitWidth = YES;
    
    _titleLabel.text = self.thumbnail.title;
}

- (void)setupSubtitleLabel {
    _subtitleLabel.textColor = [UIColor darkGrayColor];
    _subtitleLabel.font = [UIFont systemFontOfSize:12.0f];
    
    _subtitleLabel.text = self.thumbnail.subtitle;
}

//It is the button on the left side with route
- (void)setupPrimaryButton {
    _primaryButton.tintColor = [AppManager systemGreenColor];
    _primaryButton.backgroundColor = [UIColor colorWithWhite:0.93 alpha:1];
    
    UIImage *image = [UIImage imageNamed:@"up-right-arrow-32"];
    [_primaryButtonSmall setImage:image forState:UIControlStateNormal];
    _primaryButtonSmall.tintColor = [AppManager systemGreenColor];
    
    _primaryButtonLabel.textColor = [AppManager systemGreenColor];
    _primaryButtonLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:12.0f];
    _primaryButtonLabel.textAlignment = NSTextAlignmentCenter;
    _primaryButtonLabel.adjustsFontSizeToFitWidth = YES;
    _primaryButtonLabel.text = @"";
}

- (void)setupSecondaryButton {
    _secondaryButton.hidden = self.thumbnail.secondaryButtonBlock == nil;
}

- (void)setupDisclosureButton {
    _disclosureImage.tintColor = [UIColor grayColor];
    UIImage *disclosureIndicatorImage = [DefaultAnnotationCallout disclosureButtonImage];
    [_disclosureImage setImage:disclosureIndicatorImage];
    _disclosureImage.frame = CGRectMake(self.frame.size.width - 28.0f,
                                         18.0f,
                                         disclosureIndicatorImage.size.width,
                                         disclosureIndicatorImage.size.height);
    
    _disclosureImage.hidden = self.thumbnail.secondaryButtonBlock == nil;
}

-(void)addBubbleView {
    KBPopupBubbleView *bubbleView = [[KBPopupBubbleView alloc] initWithFrame:self.frame];
    bubbleView.useDropShadow = YES;
    bubbleView.shadowOffset = CGSizeMake(0, 0);
    bubbleView.shadowRadius = 0.5;
    bubbleView.shadowOpacity = 1;
    bubbleView.shadowColor = [UIColor grayColor];
    bubbleView.useBorders = NO;
    bubbleView.draggable = NO;
    bubbleView.alpha = 0.97;
    bubbleView.useRoundedCorners = self.settings.shouldRoundifyCallout;
    bubbleView.cornerRadius = self.settings.calloutCornerRadius;
    bubbleView.drawableColor = [UIColor whiteColor];
    
    bubbleView.side = kKBPopupPointerSideBottom;
    
    [bubbleView showInView:self atIndex:0 animated:NO];
    
    self.bubbleView = bubbleView;
}

-(void)setupBasicContainerView {
    self.basicContainerView.layer.cornerRadius = self.settings.calloutCornerRadius;
}

#pragma mark - Actions

- (IBAction)primaryButtonTapped:(UIButton *)sender {
    if (self.thumbnail.primaryButtonBlock) {
        self.thumbnail.primaryButtonBlock((MKAnnotationView *)[self superview]);
    }
}

- (IBAction)secondaryButtonTapped:(UIButton *)sender {
    if (self.thumbnail.secondaryButtonBlock) {
        self.thumbnail.secondaryButtonBlock((MKAnnotationView *)[self superview]);
    }
}

#pragma mark - Annotation View Delegate handlers
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

- (void)didShowCalloutView {}

- (void)didHideCalloutView {
    self.primaryButtonSmall.frame = CGRectMake(15.0f, 15.0f, 25.0f, 25.0f);
    self.primaryButtonLabel.text = @"";
}

#pragma mark - Helpers
+ (UIImage *)disclosureButtonImage {
    CGSize size = CGSizeMake(21.0f, 36.0f);
    UIGraphicsBeginImageContextWithOptions(size, NO, [[UIScreen mainScreen] scale]);
    
    UIBezierPath *bezierPath = [UIBezierPath bezierPath];
    [bezierPath moveToPoint:CGPointMake(2.0f, 2.0f)];
    [bezierPath addLineToPoint:CGPointMake(10.0f, 10.0f)];
    [bezierPath addLineToPoint:CGPointMake(2.0f, 18.0f)];
    [[UIColor grayColor] setStroke];
    bezierPath.lineWidth = 3.0f;
    [bezierPath stroke];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

@end
