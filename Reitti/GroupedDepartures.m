//
//  GroupedDepartures.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 6/22/17.
//  Copyright © 2017 Anteneh Sahledengel. All rights reserved.
//

#import "GroupedDepartures.h"

@implementation GroupedDepartures

@synthesize coordinates, distance;

+(instancetype)groupedDeparutesForLine:(StopLine *)line
                               busStop:(BusStopShort *)stop
                            departures:(NSArray *)departures{
    GroupedDepartures *grpDpts = [super new];
    
    grpDpts.lineGtfs = line.code;
    grpDpts.line = line;
    grpDpts.stop = stop;
    grpDpts.departures = departures;
    
    return grpDpts;
}

//Protocol
-(CLLocationCoordinate2D)coordinates {
    return self.stop.coordinates;
}

-(NSNumber *)distance {
    return self.stop.distance;
}

//Computed
//Returns max 5 departures
-(NSArray *)getValidDepartures{
    NSMutableArray *validDepartures = [@[] mutableCopy];
    
    for (StopDeparture *departure in self.departures) {
        NSDate *departureTime = departure.departureTime;
        
        if (departureTime && [departureTime timeIntervalSinceNow] > 0) {
            [validDepartures addObject:departure];
        }
        
        if (validDepartures.count > 4) break;
    }
    
    return validDepartures;
}

@end
