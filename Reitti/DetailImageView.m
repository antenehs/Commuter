//
//  DetailImageView.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 25/4/15.
//  Copyright (c) 2015 Anteneh Sahledengel. All rights reserved.
//

#import "DetailImageView.h"

@implementation DetailImageView

@synthesize title, description, textColor, titleLabel, descLabel, imageView;
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(id)initWithImageNamed:(NSString *)imageName title:(NSString *)ttle description:(NSString *)desc  andFrame:(CGRect)frame{
    self = [super init];
    if (self) {
        NSArray* nibViews = [[NSBundle mainBundle] loadNibNamed:@"DetailImageView" owner:self options:nil];
        
//        [mainView setTranslatesAutoresizingMaskIntoConstraints:NO];
        self = [nibViews objectAtIndex:0];
        self.frame = frame;
//        [self layoutSubviews];
        //self.backgroundColor = SYSTEM_GRAY_COLOR;
        
//        self.title = ttle;
//        self.description = desc;
//        self.textColor = [UIColor whiteColor];
        
        UIImageView *image = (UIImageView *)[self viewWithTag:1001];
        UILabel *tLabel = (UILabel *)[self viewWithTag:1002];
        UILabel *dLabel = (UILabel *)[self viewWithTag:1003];
        
        [image setImage:[UIImage imageNamed:imageName]];
        
        tLabel.text = ttle;
        dLabel.text = desc;
        
        tLabel.textColor = [UIColor darkTextColor];
        dLabel.textColor = [UIColor darkTextColor];
    }
    
    return self;
}

-(id)initFromNib{
    self = [super init];
    if (self) {
        NSArray* allTheViewsInMyNIB = [[NSBundle mainBundle] loadNibNamed:@"DetailImageView" owner:self options:nil];
        DetailImageView* nView = allTheViewsInMyNIB[0];
        self = nView;
    }
    
    return self;
}

-(void)setUpViewForImageNamed:(NSString *)imageName{
    self.imageView = (UIImageView *)[self viewWithTag:1001];
    self.titleLabel = (UILabel *)[self viewWithTag:1002];
    self.descLabel = (UILabel *)[self viewWithTag:1002];
    
    [self.imageView setImage:[UIImage imageNamed:imageName]];
    
    self.titleLabel.text = self.title;
    self.descLabel.text = self.description;
    
    self.titleLabel.textColor = self.textColor;
    self.descLabel.textColor = self.textColor;
    
    self.imageView.frame = CGRectMake(0, 0, 90, 90);
}

@end
