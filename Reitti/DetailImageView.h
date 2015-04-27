//
//  DetailImageView.h
//  Reitti
//
//  Created by Anteneh Sahledengel on 25/4/15.
//  Copyright (c) 2015 Anteneh Sahledengel. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailImageView : UIView

-(id)initWithImageNamed:(NSString *)imageName title:(NSString *)ttle description:(NSString *)desc andFrame:(CGRect)frame;

-(id)initFromNib;

@property (nonatomic, strong)NSString *title;
@property (nonatomic, strong)NSString *description;
@property (nonatomic, strong)UIColor  *textColor;

@property (nonatomic, strong)UILabel  *titleLabel;
@property (nonatomic, strong)UILabel  *descLabel;
@property (nonatomic, strong)UIImageView  *imageView;

@end
