//
//  RouteSummaryRowController.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 13/9/16.
//  Copyright © 2016 Anteneh Sahledengel. All rights reserved.
//

#import "RouteSummaryRowController.h"
#import "AppManager.h"
#import "ReittiDateHelper.h"

@implementation RouteSummaryRowController

-(void)setupWithRoute:(Route *)route {
    self.route = route;
    
    [self.firstLegGroup setHidden:YES];
    [self.firstArrowGroup setHidden:YES];
    [self.secondLegGroup setHidden:YES];
    [self.secondArrowGroup setHidden:YES];
    [self.thirdLegGroup setHidden:YES];
    [self.thirdArrowGroup setHidden:YES];
    
    if (route.isOnlyWalkingRoute) {        
        [self.firstLegGroup setHidden:NO];
        
        [self.firstLegImage setImage:[self imageForLeg:LegTypeWalk]];
        [self.firstLegImage setTintColor:[AppManager colorForLegType:LegTypeWalk]];
        
        [self.firstLegLabel setText:@"Walk"];
    }
    
    if (route.noneWalkingLegs.count > 0) {
        RouteLeg *routeLeg = route.noneWalkingLegs[0];
        
        [self.firstLegGroup setHidden:NO];
        
        [self.firstLegImage setImage:[self imageForLeg:routeLeg.legType]];
        [self.firstLegImage setTintColor:[AppManager colorForLegType:routeLeg.legType]];
        
        [self.firstLegLabel setText:routeLeg.lineName];
    }
    
    if (route.noneWalkingLegs.count > 1) {
        RouteLeg *routeLeg = route.noneWalkingLegs[1];
        
        [self.secondLegGroup setHidden:NO];
        [self.firstArrowGroup setHidden:NO];
        
        [self.secondLegImage setImage:[self imageForLeg:routeLeg.legType]];
        [self.secondLegImage setTintColor:[AppManager colorForLegType:routeLeg.legType]];
        
        [self.secondLegLabel setText:routeLeg.lineName];
    }
    
    if (route.noneWalkingLegs.count > 2) {
        RouteLeg *routeLeg = route.noneWalkingLegs[2];
        
        [self.thirdLegGroup setHidden:NO];
        [self.secondArrowGroup setHidden:NO];
        
        [self.thirdLegImage setImage:[self imageForLeg:routeLeg.legType]];
        [self.thirdLegImage setTintColor:[AppManager colorForLegType:routeLeg.legType]];
        
        [self.firstLegLabel setText:routeLeg.lineName];
    }
    
    if (route.noneWalkingLegs.count > 3) {
        [self.thirdArrowGroup setHidden:NO];
    }
    
    [self.detailLabel setText:[NSString stringWithFormat:@"%@ - %@",
                               [[ReittiDateHelper sharedFormatter] formatHourStringFromDate:route.startingTimeOfRoute],
                               [[ReittiDateHelper sharedFormatter] formatHourStringFromDate:route.endingTimeOfRoute]]];
}

-(UIImage *)imageForLeg:(LegTransportType)legType {
    UIImage *image = [AppManager lightColorImageForLegTransportType:legType];
    
    image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    return image;
}

@end
