//
//  RouteLegRowController.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 3/7/16.
//  Copyright © 2016 Anteneh Sahledengel. All rights reserved.
//

#import "RouteLegRowController.h"
#import "ReittiDateHelper.h"
#import "ReittiStringFormatter.h"
#import "AppManager.h"

@implementation RouteLegRowController

-(void)setUpWithRouteLeg:(RouteLeg *)routeLeg inRoute:(Route *)route {
    RouteLegLocation *loc = routeLeg.legLocations.count > 0 ? routeLeg.legLocations[0] : nil;
    if (!loc) {
        NSAssert(NO, @"No location");
    }
    //Lines
    NSInteger routeLegIndex = [route.routeLegs indexOfObject:routeLeg];
    if (routeLegIndex == 0) {
        [self.previousLegLine setHidden:YES];
    } else {
        [self.previousLegLine setHidden:NO];
    }
    
    [self.currentLegLine1 setHidden:NO];
    [self.currentLegLine2 setHidden:NO];
    [self.currentLegLine3 setHidden:NO];
    
    RouteLeg *prevLeg = nil;
    RouteLeg *nextLeg = nil;
    
    if (routeLegIndex == 0) {
        if (route.routeLegs.count > 1)
            nextLeg = route.routeLegs[routeLegIndex + 1];
    } else if (routeLegIndex == route.routeLegs.count - 1) {
        if (route.routeLegs.count > 1)
            prevLeg = route.routeLegs[routeLegIndex - 1];
    } else {
        if (route.routeLegs.count > 2) {
            nextLeg = route.routeLegs[routeLegIndex + 1];
            prevLeg = route.routeLegs[routeLegIndex - 1];
        }
    }
    
    [self.locationCircle setBackgroundColor:[AppManager colorForLegType:routeLeg.legType]];
    
    if (prevLeg) {
        [self.previousLegLine setBackgroundColor:[AppManager colorForLegType:prevLeg.legType]];
        if (routeLeg.legType == LegTypeWalk) {
            [self.locationCircle setBackgroundColor:[AppManager colorForLegType:prevLeg.legType]];
        }
    }
    
    [self.currentLegLine1 setBackgroundColor:[AppManager colorForLegType:routeLeg.legType]];
    [self.currentLegLine2 setBackgroundColor:[AppManager colorForLegType:routeLeg.legType]];
    [self.currentLegLine3 setBackgroundColor:[AppManager colorForLegType:routeLeg.legType]];
    
    [self.legTypeImageGroup setBackgroundColor:[AppManager colorForLegType:routeLeg.legType]];
    
    //Transport image
    if (routeLeg.legType == LegTypeWalk) {
        [self.legTypeImage setImageNamed:@"walking-template"];
    } else {
        UIImage *image = [AppManager lightColorImageForLegTransportType:routeLeg.legType];
        image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            
        [self.legTypeImage setImage:image];
    }
    
    //Labels
    [self.transportationGroup setHidden:NO];
    [self.locationGroup setHidden:NO];
    [self.timeLabel setText:[[ReittiDateHelper sharedFormatter] formatHourStringFromDate:loc.depTime]];
    
    if (routeLegIndex == 0) {
        [self setLocationLabelText:route.fromLocationName];
    } else {
        [self setLocationLabelText:routeLeg.startLocName];
    }
    
    NSString *detailText = @"";
    if (routeLeg.legType == LegTypeWalk) {
        [self.transportNameLabel setText:@"Walk"];
        detailText = [NSString stringWithFormat:@"%ld m • %@", (long)[routeLeg.legLength integerValue], [ReittiStringFormatter formatDurationString:[routeLeg.legDurationInSeconds integerValue]]];
    } else {
        [self.transportNameLabel setText:routeLeg.lineDisplayName];
        NSString *stopsText = ([routeLeg getNumberOfStopsInLeg] - 1) > 1 ? @"stops" : @"stop";
        detailText = [NSString stringWithFormat:@"%d %@ \n%@", [routeLeg getNumberOfStopsInLeg] - 1, stopsText, [ReittiStringFormatter formatFullDurationString:[routeLeg.legDurationInSeconds integerValue]] ];
    }
    
    [self.detailLabel setText:detailText];
    
    self.routeLeg = routeLeg;
    self.route = route;
}

-(void)setUpAsDestinationForName:(NSString *)destinationName prevLegType:(LegTransportType)prevLegType {
    //For now
    [self.legTypeImageGroup setHidden:YES];
    [self.transportationGroup setHidden:YES];
    [self.locationGroup setHidden:NO];
    
    [self.currentLegLine1 setHidden:YES];
    [self.previousLegLine setBackgroundColor:[AppManager colorForLegType:prevLegType]];
    [self.locationCircle setBackgroundColor:[AppManager colorForLegType:prevLegType]];
    
    [self setLocationLabelText:destinationName];
}

#pragma mark - helpers
-(void)setLocationLabelText:(NSString *)text {
    [self.locationLabel setText:text];
    self.locationName = text;
}

@end
