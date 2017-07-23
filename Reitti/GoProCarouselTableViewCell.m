//
//  GoProCarouselTableViewCell.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 7/22/17.
//  Copyright © 2017 Anteneh Sahledengel. All rights reserved.
//

#import "GoProCarouselTableViewCell.h"
#import "RotatingCarousel.h"
#import "FeaturePreviewView.h"
#import "AppFeatureManager.h"

@interface GoProCarouselTableViewCell () <iCarouselDataSource, iCarouselDelegate>

@property (strong, nonatomic) IBOutlet RotatingCarousel *rotatingCarousel;
@property (strong, nonatomic) IBOutlet UIButton *goProButton;
@property (strong, nonatomic) IBOutlet UIPageControl *pageControl;
@property (nonatomic, strong)NSArray<AppFeature *> *proFeatures;

@end

@implementation GoProCarouselTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.proFeatures = [[AppFeatureManager sharedManager] proOnlyFeatures];
    
    self.rotatingCarousel.backgroundColor = [UIColor clearColor];
    self.goProButton.layer.cornerRadius = 8.0;
    self.pageControl.numberOfPages = self.proFeatures.count;
    self.pageControl.currentPage = 0;
    
    self.rotatingCarousel.delegate = self;
    self.rotatingCarousel.dataSource = self;
    self.rotatingCarousel.type = iCarouselTypeCylinder;
    self.rotatingCarousel.pagingEnabled = YES;
}

- (IBAction)goProButtonTapped:(id)sender {
    if (self.buttonAction) {
        self.buttonAction();
    }
}

#pragma mark -
#pragma mark iCarousel methods

- (NSInteger)numberOfItemsInCarousel:(iCarousel *)carousel {
    //return the total number of items in the carousel
    return [_proFeatures count];
}

-(UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSInteger)index reusingView:(FeaturePreviewView *)view {
    
    //create new view if no view is available for recycling
    if (view == nil) {
        view = (FeaturePreviewView *)[[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([FeaturePreviewView class]) owner:self options:nil] firstObject];
        view.frame = self.rotatingCarousel.bounds;
        [view layoutIfNeeded];
    }
    
    [view updateWithFeature:_proFeatures[index]];
    
    return view;
}

#pragma mark - iCarousel Delegate
-(void)carouselCurrentItemIndexDidChange:(iCarousel *)carousel {
    self.pageControl.currentPage = carousel.currentItemIndex;
}


@end
