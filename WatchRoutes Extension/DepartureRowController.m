//
//  DepartureRowController.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 28/8/16.
//  Copyright © 2016 Anteneh Sahledengel. All rights reserved.
//

#import "DepartureRowController.h"
#import "ReittiStringFormatterE.h"
#import "ReittiDateHelper.h"

@implementation DepartureRowController

-(void)setupWithDeparture:(StopDeparture *)departure stop:(BusStop *)stop isFirstDeparture:(BOOL)isFirst {
    if (!departure) return;
    
    self.departure = departure;
    [self.rowSeparator setHidden:isFirst];
    
    [self.lineCodeLabel setText:departure.code];
    
    [self.departureTimeLabel setText:[[ReittiDateHelper sharedFormatter] formatHourStringFromDate:departure.parsedScheduledDate]];
    
    [self.destinationLabel setText:departure.destination];
}



@end
