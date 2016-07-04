//
//  RouteLegRowController.h
//  Reitti
//
//  Created by Anteneh Sahledengel on 3/7/16.
//  Copyright © 2016 Anteneh Sahledengel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WatchKit/WatchKit.h>
#import "Route.h"

@interface RouteLegRowController : NSObject

-(void)setUpWithRouteLeg:(RouteLeg *)routeLeg inRoute:(Route *)route;

//Timelineviews
@property (strong, nonatomic) IBOutlet WKInterfaceSeparator *previousLegLine;
@property (strong, nonatomic) IBOutlet WKInterfaceImage *legTypeImage;
@property (strong, nonatomic) IBOutlet WKInterfaceGroup *legTypeImageGroup;
@property (strong, nonatomic) IBOutlet WKInterfaceSeparator *currentLegLine;

//Leg info labels
@property (strong, nonatomic) IBOutlet WKInterfaceLabel *transportNameLabel;
@property (strong, nonatomic) IBOutlet WKInterfaceLabel *timeLabel;
@property (strong, nonatomic) IBOutlet WKInterfaceLabel *locationLabel;
@property (strong, nonatomic) IBOutlet WKInterfaceLabel *detailLabel;

@property (strong, nonatomic) Route *route;
@property (strong, nonatomic) RouteLeg *routeLeg;

@end
