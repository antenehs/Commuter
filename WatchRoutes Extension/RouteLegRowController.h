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
-(void)setUpAsDestinationForName:(NSString *)destinationName prevLegType:(LegTransportType)prevLegType;

//Timelineviews
@property (strong, nonatomic) IBOutlet WKInterfaceGroup *previousLegLine;
@property (strong, nonatomic) IBOutlet WKInterfaceGroup *locationCircle;
@property (strong, nonatomic) IBOutlet WKInterfaceImage *legTypeImage;
@property (strong, nonatomic) IBOutlet WKInterfaceGroup *legTypeImageGroup;
@property (strong, nonatomic) IBOutlet WKInterfaceGroup *currentLegLine1;
@property (strong, nonatomic) IBOutlet WKInterfaceGroup *currentLegLine2;
@property (strong, nonatomic) IBOutlet WKInterfaceGroup *currentLegLine3;

//Leg info labels

@property (strong, nonatomic) IBOutlet WKInterfaceGroup *locationGroup;
@property (strong, nonatomic) IBOutlet WKInterfaceGroup *transportationGroup;
@property (strong, nonatomic) IBOutlet WKInterfaceLabel *transportNameLabel;
@property (strong, nonatomic) IBOutlet WKInterfaceLabel *timeLabel;
@property (strong, nonatomic) IBOutlet WKInterfaceLabel *locationLabel;
@property (strong, nonatomic) IBOutlet WKInterfaceLabel *detailLabel;

@property (strong, nonatomic) NSString *locationName;
@property (nonatomic)CLLocationCoordinate2D *locationCoords;
@property (strong, nonatomic) Route *route;
@property (strong, nonatomic) RouteLeg *routeLeg;

@end
