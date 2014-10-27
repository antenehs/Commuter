//
//  CommandView.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 3/8/14.
//  Copyright (c) 2014 Anteneh Sahledengel. All rights reserved.
//

#import "CommandView.h"

@implementation CommandView

#define SYSTEM_GRAY_COLOR [UIColor colorWithWhite:0.2 alpha:1]

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        NSArray* nibViews = [[NSBundle mainBundle] loadNibNamed:@"CommandView" owner:self options:nil];
        UIView* mainView = (UIView*)[nibViews objectAtIndex:0];
        [self addSubview:mainView];
        self.tintColor = SYSTEM_GRAY_COLOR;
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
