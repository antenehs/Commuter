//
//  DepartureRowController.h
//  Reitti
//
//  Created by Anteneh Sahledengel on 28/8/16.
//  Copyright © 2016 Anteneh Sahledengel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WatchKit/WatchKit.h>
#import "BusStopE.h"

@interface DepartureRowController : NSObject

-(void)setupWithDepartureDictionary:(NSDictionary *)dict stop:(BusStopE *)stop isFirstDeparture:(BOOL)isFirst;

@property (strong, nonatomic) NSDictionary *departureDictionary;

@property (strong, nonatomic) IBOutlet WKInterfaceSeparator *rowSeparator;
@property (strong, nonatomic) IBOutlet WKInterfaceLabel *lineCodeLabel;
@property (strong, nonatomic) IBOutlet WKInterfaceLabel *departureTimeLabel;
@property (strong, nonatomic) IBOutlet WKInterfaceLabel *destinationLabel;


@end
