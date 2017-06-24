//
//  GroupedDepartures.h
//  Reitti
//
//  Created by Anteneh Sahledengel on 6/22/17.
//  Copyright © 2017 Anteneh Sahledengel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BusStopShort.h"
#import "StopDeparture.h"
#import "StopLine.h"
#import "ReittiObjectProtocols.h"

@interface GroupedDepartures : NSObject <ReittiPlaceAtDistance>

+(instancetype)groupedDeparutesForLine:(StopLine *)line
                               busStop:(BusStopShort *)stop
                            departures:(NSArray *)departures;

@property (nonatomic, strong) NSString *lineGtfs;

@property (nonatomic, strong) StopLine *line;
@property (nonatomic, strong) BusStopShort *stop;
@property (nonatomic, strong) NSArray *departures;

//Computed
-(NSArray *)getValidDepartures;

@end
