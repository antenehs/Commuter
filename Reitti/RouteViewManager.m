//
//  RouteViewManager.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 10/5/15.
//  Copyright (c) 2015 Anteneh Sahledengel. All rights reserved.
//

#import "RouteViewManager.h"

@implementation RouteViewManager

+ (UIView *)viewForRoute:(Route *)route longestDuration:(CGFloat)longestDuration width:(CGFloat)totalWidth alwaysShowVehicle:(BOOL)alwaysShow
{
    float tWidth  = 70;
    float x = 0;
    float spacing = 1;
    float cornerRadius = 2;
    UIView *transportsContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, totalWidth , 36)];
    transportsContainer.clipsToBounds = YES;
    transportsContainer.tag = 1987;
    transportsContainer.layer.cornerRadius = cornerRadius;
    
    float widthDebt = 0;
    
    for (RouteLeg *leg in route.routeLegs) {
        //Check for dividing by zero. Duration could be zero
        if (longestDuration != 0) {
            if (route.isOnlyWalkingRoute) {//Leg duration of a walking leg get freaky sometimes
                tWidth = totalWidth * (([route.routeDurationInSeconds floatValue])/longestDuration);
            }else{
                tWidth = totalWidth * (([leg.legDurationInSeconds floatValue])/longestDuration);
            }
        }else{
            tWidth = 150;
        }

        Transport *transportView = [[Transport alloc] initWithRouteLeg:leg andWidth:tWidth alwaysShowVehicle:alwaysShow];
        CGRect frame = transportView.frame;
        transportView.frame = CGRectMake(x + spacing, 0, frame.size.width, frame.size.height);
        transportView.clipsToBounds = YES;
        transportView.layer.cornerRadius = cornerRadius;
        [transportsContainer addSubview:transportView];
        x += frame.size.width + spacing;
        
        //Adjusted width
        CGFloat addedWidthForIcon = frame.size.width - tWidth;
        widthDebt += addedWidthForIcon;
        
        //Append waiting view if exists
        
        float actualWatingwidth = totalWidth * (leg.waitingTimeInSeconds/longestDuration);
        
        CGFloat waitingWidth = MAX(actualWatingwidth - widthDebt , actualWatingwidth > 22 ? 22 : actualWatingwidth);
        widthDebt -= actualWatingwidth - waitingWidth; //Saved from waiting reduction
        
        if ([RouteViewManager showWaitingTimeInRoute:route forLeg:leg andWaitingWidth:waitingWidth]) {
            UIView *waitingView = [[UIView alloc] initWithFrame:CGRectMake(x + spacing, 0, waitingWidth, transportView.frame.size.height)];
            waitingView.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1];
            waitingView.clipsToBounds = YES;
            if (waitingWidth > 22) {
                UIImageView *waitingImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"sitting-filled-grey-64.png"]];
                waitingImageView.frame = CGRectMake((waitingView.frame.size.width - 20)/2, (transportsContainer.frame.size.height - 20)/2, 20, 20);
                [waitingView addSubview:waitingImageView];
            }
            waitingView.layer.cornerRadius = cornerRadius;
            [transportsContainer addSubview:waitingView];
            x += waitingWidth + spacing;
        }
    }
    transportsContainer.frame = CGRectMake(0, 0, x, 36);
    
    return transportsContainer;
}

+(BOOL)showWaitingTimeInRoute:(Route *)route forLeg:(RouteLeg *)leg andWaitingWidth:(CGFloat)width{
    //Do not show for the last leg
    if (leg.legOrder == route.routeLegs.count - 1)
        return NO;
    
    //Waiting time is got from the last loc of the leg
    if (leg.legType == LegTypeWalk) {
        return width > 22 && !route.isOnlyWalkingRoute;
    } else {
        return width > 5 && !route.isOnlyWalkingRoute;
    }
}

@end
