//
//  RouteViewManager.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 10/5/15.
//  Copyright (c) 2015 Anteneh Sahledengel. All rights reserved.
//

#import "RouteViewManager.h"

@implementation RouteViewManager

+ (UIView *)viewForRoute:(Route *)route longestDuration:(CGFloat)longestDuration width:(CGFloat)totalWidth
{
    float tWidth  = 70;
    float x = 0;
    UIView *transportsContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, totalWidth , 36)];
    transportsContainer.clipsToBounds = YES;
    transportsContainer.tag = 1987;
    transportsContainer.layer.cornerRadius = 4;
    
    for (RouteLeg *leg in route.routeLegs) {
        tWidth = totalWidth * (([leg.legDurationInSeconds floatValue])/longestDuration);
        Transport *transportView = [[Transport alloc] initWithRouteLeg:leg andWidth:tWidth*1];
        CGRect frame = transportView.frame;
        transportView.frame = CGRectMake(x, 0, frame.size.width, frame.size.height);
        transportView.clipsToBounds = YES;
        [transportsContainer addSubview:transportView];
        x += frame.size.width;
        
        //Append waiting view if exists
        if (leg.waitingTimeInSeconds > 0) {
            float waitingWidth = totalWidth * (leg.waitingTimeInSeconds/longestDuration);
            UIView *waitingView = [[UIView alloc] initWithFrame:CGRectMake(x, 0, waitingWidth, transportView.frame.size.height)];
            waitingView.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1];
            waitingView.clipsToBounds = YES;
            if (waitingWidth > 22) {
                UIImageView *waitingImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"sitting-filled-grey-64.png"]];
                waitingImageView.frame = CGRectMake((waitingView.frame.size.width - 20)/2, (transportsContainer.frame.size.height - 20)/2, 20, 20);
                [waitingView addSubview:waitingImageView];
            }
            [transportsContainer addSubview:waitingView];
            x += waitingWidth;
        }
    }
    transportsContainer.frame = CGRectMake(0, 0, x, 36);
    
    return transportsContainer;
}

@end
