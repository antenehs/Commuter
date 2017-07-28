//
//  FeaturePreviewView.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 7/22/17.
//  Copyright © 2017 Anteneh Sahledengel. All rights reserved.
//

#import "FeaturePreviewView.h"
#import "UIImage+Helper.h"

@interface FeaturePreviewView ()

@property (strong, nonatomic) IBOutlet UIImageView *iconImageView;
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UILabel *detailDescLabel;

@end

@implementation FeaturePreviewView

-(instancetype)initWithCoder:(NSCoder *)aDecoder {
    return [super initWithCoder:aDecoder];
}

-(instancetype)initWithFrame:(CGRect)frame {
    return [super initWithFrame:frame];
}

-(void)updateWithFeature:(AppFeature *)feature {
    
    UIImage *iconImage = [feature.featureImage.iconImage asa_imageWithColor:[UIColor whiteColor]];
    UIImage *image = [iconImage asa_addCircleBackgroundWithColor:feature.themeColor andImageSize:self.iconImageView.frame.size andInset:CGPointMake(12, 12) andOffset:CGPointZero];
    
    self.iconImageView.image = image;
    
    self.titleLabel.text = feature.displayName;
    self.detailDescLabel.text = feature.featureDescription;
}

-(void)awakeFromNib {
    [super awakeFromNib];
    
}

@end
