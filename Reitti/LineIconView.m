//
//  LineIconView.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 9/1/17.
//  Copyright © 2017 Anteneh Sahledengel. All rights reserved.
//

#import "LineIconView.h"
#import "AppManager.h"
#import "EnumManager.h"

@interface LineIconView ()

@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) IBOutlet UILabel *label;

@end

@implementation LineIconView

-(void)awakeFromNib {
    [super awakeFromNib];
    
    self.label.textColor = [UIColor whiteColor];
    self.imageView.tintColor = [UIColor whiteColor];
}

-(void)setupWithLine:(Line *)line {
    UIImage *image = [AppManager lightColorImageForLegTransportType:[EnumManager legTrasportTypeForLineType:line.lineType]];
    image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    self.imageView.image = image;
    self.imageView.tintColor = [UIColor whiteColor];
    
    self.label.text = line.codeShort;
    
    [self setNeedsLayout];
    [self layoutIfNeeded];
    
    //Adjust to fitting width
    CGFloat width = self.imageView.frame.size.width + 10 + self.label.intrinsicContentSize.width;
    CGRect frame = self.frame;
    frame.size.width = width;
    self.frame = frame;
}

@end
