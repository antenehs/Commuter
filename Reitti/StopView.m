//
//  StopView.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 15/2/14.
//  Copyright (c) 2014 Anteneh Sahledengel. All rights reserved.
//

#import "StopView.h"

@implementation StopView

@synthesize stopView;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    
    self.stopView = stopView;
    
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
