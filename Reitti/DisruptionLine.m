//
//  DisruptionLine.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 16/1/16.
//  Copyright © 2016 Anteneh Sahledengel. All rights reserved.
//

#import "DisruptionLine.h"

@implementation DisruptionLine

@synthesize lineId, lineName, lineType, lineDirection;
@synthesize parsedLineType;

+(instancetype)disruptionLineFromDigiRoute:(DigiRouteShort *)digiRouteShort {
    DisruptionLine *line = [DisruptionLine new];
    
    line.lineId = digiRouteShort.gtfsId;
    line.lineName = digiRouteShort.shortName;
    line.parsedLineType = digiRouteShort.lineType;
    line.lineFullCode = digiRouteShort.gtfsId;
    line.lineDirection = @1;
    
    return line;
}

@end
