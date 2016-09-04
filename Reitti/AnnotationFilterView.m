//
//  AnnotationFilterView.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 22/8/16.
//  Copyright © 2016 Anteneh Sahledengel. All rights reserved.
//

#import "AnnotationFilterView.h"
#import "AppManager.h"
#import "ASA_Helpers.h"

@interface OptionButton : UIButton {
    AnnotationFilterOption *_option;
}

@property(nonatomic, strong)AnnotationFilterOption *option;

@end

@implementation OptionButton

-(instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    self.tintColor = [UIColor grayColor];
    return self;
}

-(void)setOption:(AnnotationFilterOption *)option {
    [self setImage:option.image forState:UIControlStateNormal];
    
    self.layer.cornerRadius = 4;
    self.imageEdgeInsets = UIEdgeInsetsMake(4, 4, 4, 4);
    
    if (option.isEnabled) {
        self.backgroundColor = [UIColor colorWithWhite:0.95 alpha:1];
        self.alpha = 1;
    } else {
        self.backgroundColor = [UIColor clearColor];
        self.alpha = 0.35;
    }
    
    self.selected = option.isEnabled;
    
    _option = option;
}

-(AnnotationFilterOption *)option {
    return _option;
}

@end

const CGFloat kButtonSpacing = 5.;

@interface AnnotationFilterView ()

@property(nonatomic, strong)AnnotationFilter *filter;
@property(nonatomic, strong)NSMutableArray *optionButtons;

@property(nonatomic)SizeChangeBlock sizeChangeHandler;
@property(nonatomic)FilterChangeBlock filterChangeHandler;

@property(nonatomic)BOOL isShowingOptions;

@end

@implementation AnnotationFilterView

-(instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:self options:nil] firstObject];
        
        view.layer.borderWidth = 0.5;
        view.layer.borderColor = [AppManager systemGreenColor].CGColor;
        view.layer.cornerRadius = 4;
        view.frame = self.bounds;
        
        self.optionButtons = [@[] mutableCopy];
        self.isShowingOptions = NO;
        
        [self addSubview:view];
    }
    
    return self;
}

-(void)setUpWithFilter:(AnnotationFilter *)filter withFilterChangeBlock:(FilterChangeBlock)filterChangedHandler withSizeChangeHandler:(SizeChangeBlock)handler{
    self.filter = filter;
    self.filterChangeHandler = filterChangedHandler;
    self.sizeChangeHandler = handler;
    
    for (UIView *sView in optionsContainerView.subviews) {
        [sView removeFromSuperview];
    }
    
    [self.optionButtons removeAllObjects];
    
    CGFloat x = kButtonSpacing;
    for (AnnotationFilterOption *option in filter.filterOptions) {
        UIButton *optionButton = [self optionButtonWithOption:option];
        if (!optionButton) continue;
        
        CGRect frame = optionButton.frame;
        frame.origin.x = x;
        optionButton.frame = frame;
        [optionsContainerView addSubview:optionButton];
        [self.optionButtons addObject:optionButton];
        
        x += frame.size.width + kButtonSpacing;
    }
    
    [self updateShowHideButton];
    [self updateViewFrame];
}

-(void)setFilterOptionsHidden:(BOOL)hidden {
    self.isShowingOptions = !hidden;
    
    [self updateShowHideButton];
    [self updateViewFrame];
}

-(UIButton *)optionButtonWithOption:(AnnotationFilterOption *)option {
    if (!option || !option.image) return nil;
    
    CGRect frame = CGRectMake(0, 2.5, 30, 30);
    OptionButton *button = [[OptionButton alloc] initWithFrame:frame];
    button.option = option;
    
    [button addTarget:self action:@selector(filterOptionButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    return button;
}

-(void)updateShowHideButton {
    showHideFiltersButton.backgroundColor = [UIColor whiteColor];
    
    if (self.isShowingOptions) {
        [showHideFiltersButton setImage:[[UIImage imageNamed:@"close-button-white"]  imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
        showHideFiltersButton.imageEdgeInsets = UIEdgeInsetsMake(9, 9, 9, 9);
    } else {
        [showHideFiltersButton setImage:[UIImage imageNamed:@"filterFilled"] forState:UIControlStateNormal];
        showHideFiltersButton.imageEdgeInsets = UIEdgeInsetsMake(8, 8, 8, 8);
    }
    
    showHideFiltersButton.tintColor = [self.filter allOptionsEnabled] ? [AppManager systemGreenColor] : [AppManager systemYellowColor];
}

- (IBAction)showFiltersButtonTapped:(id)sender {
    self.isShowingOptions = !self.isShowingOptions;
    
    [self updateShowHideButton];
    
    [self updateViewFrame];
}

- (void)filterOptionButtonTapped:(id)sender {
    OptionButton *button = (OptionButton *)sender;
    AnnotationFilterOption *option = button.option;
    option.isEnabled = !option.isEnabled;
    button.option = option;
    
    if (self.filterChangeHandler) {
        self.filterChangeHandler(self.filter, option);
    }
    
    [self updateShowHideButton];
}

-(void)updateViewFrame {
    CGRect frame = self.frame;
    if (!self.isShowingOptions) {
        frame.size.width = 35;
    } else {
        if (self.optionButtons.count > 0) {
            frame.size.width = 35 + (kButtonSpacing * (self.optionButtons.count + 1)) + (self.optionButtons.count * 30);
        } else {
            frame.size.width = 35;
        }
    }
    
    [self asa_springAnimationWithDuration:0.3 animation:^{
        self.frame = frame;
    } completion:nil];
    
    if (self.sizeChangeHandler) {
        self.sizeChangeHandler(frame.size);
    }
}

@end
