//
//  RotatingCarousel.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 7/22/17.
//  Copyright © 2017 Anteneh Sahledengel. All rights reserved.
//

#import "RotatingCarousel.h"

#define DEFAULT_VISIBLE_TIME 5.0

@interface RotatingCarousel ()

@property (nonatomic, strong)NSTimer *rotateTimer;

@end

@implementation RotatingCarousel

-(id)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super initWithCoder:aDecoder])) {
        self.visibleTime = DEFAULT_VISIBLE_TIME;
        [self resetTimer];
    }
    
    return self;
}

-(id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        self.visibleTime = DEFAULT_VISIBLE_TIME;
        [self resetTimer];
    }
    
    return self;
}

-(void)dealloc {
    [self.rotateTimer invalidate];
}

-(void)resetTimer {
    //Init timer
    if (self.rotateTimer) [self.rotateTimer invalidate];
    
    self.rotateTimer = [NSTimer scheduledTimerWithTimeInterval:_visibleTime target:self selector:@selector(stepToNext:) userInfo:nil repeats:YES];
}

-(void)stepToNext:(id)sender {
    [super scrollByNumberOfItems:1 duration:0.3];
}

-(void)setVisibleTime:(CGFloat)visibleTime {
    _visibleTime = visibleTime;
    
    [self resetTimer];
}

-(void)didEndDragging {
    [self resetTimer];
}


@end
