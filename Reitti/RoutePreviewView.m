//
//  RoutePreviewView.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 11/8/14.
//  Copyright (c) 2014 Anteneh Sahledengel. All rights reserved.
//

#import "RoutePreviewView.h"
#import "ReittiStringFormatter.h"
#import "RouteLeg.h"
#import "Transport.h"
#import "ASA_Helpers.h"

@implementation RoutePreviewView

#define SYSTEM_GRAY_COLOR [UIColor colorWithWhite:0.1 alpha:1]
#define SYSTEM_WHITE_COLOR [UIColor colorWithWhite:1 alpha:1]

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        NSArray* nibViews = [[NSBundle mainBundle] loadNibNamed:@"RoutePreviewView" owner:self options:nil];
        UIView* mainView = (UIView*)[nibViews objectAtIndex:0];
        [self addSubview:mainView];
        self.frame = mainView.frame;
    }
    return self;
}

-(id)initWithRoute:(Route *)route forViewController:(UIViewController *)controller{
    self = [super init];
    if (self) {
//        self.layer.borderWidth = 0.5;
//        self.layer.borderColor = [[UIColor lightGrayColor] CGColor];
        [self setUpViewForRoute:route];
    }else{
        return nil;
    }
    
    return self;
}

-(void)setUpViewForRoute:(Route *)route{
    UILabel *timeIntervalLabel = (UILabel *)[self viewWithTag:2001];
    timeIntervalLabel.text = [[ReittiDateFormatter sharedFormatter] formatHourRangeStringFrom:route.startingTimeOfRoute toDate:route.endingTimeOfRoute];
    
    //durations
    UILabel *durationLabel = (UILabel *)[self viewWithTag:2002];
    durationLabel.text = [NSString stringWithFormat:@"%d minutes", (int)([route.routeDurationInSeconds intValue]/60)];
    
    UILabel *walkLengthLabel = (UILabel *)[self viewWithTag:2003];
    walkLengthLabel.text = [NSString stringWithFormat:@"%dm", (int)route.getTotalWalkLength];
    
    UIView *transportsContainer = (UIView *)[self viewWithTag:2004];
    
    if (route.isOnlyWalkingRoute) {
        transportsContainer.hidden = YES;
    }else{
        transportsContainer.hidden = NO;
    }
    
    int totalLegsToShow = [route.numberOfNoneWalkLegs intValue];
    float tWidth = 45;
    float space = 10;
    float total = (totalLegsToShow * tWidth) + ((totalLegsToShow -1) * space);
    float x = (transportsContainer.frame.size.width - total)/2;
    
    for (RouteLeg *leg in route.routeLegs) {
        if (leg.legType != LegTypeWalk) {
            Transport *transportView = [[Transport alloc] initWithRouteLeg:leg andWidth:1.0 alwaysShowVehicle: YES];
            CGRect frame = transportView.frame;
            transportView.frame = CGRectMake(x, 0, frame.size.width, frame.size.height);
            [transportsContainer addSubview:transportView];
            x += frame.size.width + space;
        }
    }
    
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
