//
//  DepartureRowController.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 28/8/16.
//  Copyright © 2016 Anteneh Sahledengel. All rights reserved.
//

#import "DepartureRowController.h"
#import "ReittiStringFormatterE.h"

@implementation DepartureRowController

-(void)setupWithDepartureDictionary:(NSDictionary *)dict stop:(BusStopE *)stop isFirstDeparture:(BOOL)isFirst {
    if (!dict) return;
    
    self.departureDictionary = dict;
    [self.rowSeparator setHidden:isFirst];
    
    NSString *notParsedCode = [dict objectForKey:@"code"];
    [self.lineCodeLabel setText:[ReittiStringFormatterE parseBusNumFromLineCode:notParsedCode]];
    
    NSString *notFormattedTime = [NSString stringWithFormat:@"%d" ,[(NSNumber *)[dict objectForKey:@"time"] intValue]];
    [self.departureTimeLabel setText:[ReittiStringFormatterE formatHSLAPITimeToHumanTime:notFormattedTime]];
    
    [self.destinationLabel setText:[stop destinationForLineFullCode:notParsedCode]];
}



@end
