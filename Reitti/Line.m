//
//  LineInfo.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 11/3/14.
//  Copyright (c) 2014 Anteneh Sahledengel. All rights reserved.
//

#import "Line.h"
#import "ReittiStringFormatter.h"
#import <MapKit/MapKit.h>
#import "LineStop.h"

#ifndef APPLE_WATCH
#import "MatkaStop.h"
#endif

@implementation Line

@synthesize code;
@synthesize codeShort;
@synthesize lineType;
@synthesize lineStart;
@synthesize lineEnd;
@synthesize lineStops;
@synthesize timetableUrl;
@synthesize dateFrom;
@synthesize dateTo;
@synthesize name;
@synthesize shapeCoordinates;

+(id)lineFromStopLine:(StopLine *)stopLine {
    Line *line = [[Line alloc] init];
    
    if (stopLine != nil && [stopLine isKindOfClass:[StopLine class]]) {
        line.code = stopLine.fullCode;
        line.codeShort = stopLine.code;
        line.lineType = stopLine.lineType;
        line.lineStart = stopLine.lineStart;
        line.lineEnd = stopLine.lineEnd;
        line.lineStops = @[];
        line.timetableUrl = nil;
        line.dateFrom = nil;
        line.dateTo = nil;
        line.name = stopLine.name;
        line.shapeCoordinates = @[];
        
        return line;
    }
    
    return nil;
}

#ifndef APPLE_WATCH
+(id)lineFromHSLLine:(HSLLine *)hslLine{
    Line *line = [[Line alloc] init];
    
    if (hslLine != nil && [hslLine isKindOfClass:[HSLLine class]]) {
        line.code = hslLine.code;
        line.codeShort = hslLine.codeShort;
        line.lineType = [EnumManager lineTypeForHSLLineTypeId:[NSString stringWithFormat:@"%d", (int)hslLine.transportTypeId]];
        line.lineStart = hslLine.lineStart;
        line.lineEnd = hslLine.lineEnd;
        //TODO: convert stops to Reitti stop
        line.lineStops = hslLine.lineStops;
        line.timetableUrl = hslLine.timetableUrl;
        line.dateFrom = hslLine.dateFrom;
        line.dateTo = hslLine.dateTo;
        line.name = hslLine.name;
        line.shapeCoordinates = [Line parseCoordinatesFromHSLShapeString:hslLine.lineShape];
        
        return line;
    }
    
    return nil;
}

+(id)lineFromMatkaLine:(MatkaLine *)matkaLine {
    Line *line = [[Line alloc] init];
    
    if (matkaLine != nil && [matkaLine isKindOfClass:[MatkaLine class]]) {
        line.code = matkaLine.lineId;
        line.codeShort = matkaLine.codeShort;
        line.lineType = matkaLine.lineType;
        line.lineStart = matkaLine.lineStart;
        line.lineEnd = matkaLine.lineEnd;
        line.timetableUrl = nil;
        line.dateFrom = nil;
        line.dateTo = nil;
        line.name = matkaLine.name;
        
        if (matkaLine.lineStops) {
            NSMutableArray *stops = [@[] mutableCopy];
            for (MatkaStop *matkaStop in matkaLine.lineStops) {
                LineStop *stop = [LineStop lineStopFromMatkaLineStop:matkaStop];
                if (stop) [stops addObject:stop];
            }
            
            line.lineStops = stops;
        }
    
        line.shapeCoordinates = matkaLine.shapeCoordinates ? matkaLine.shapeCoordinates : @[];
        
        return line;
    }
    
    return nil;
}
#endif
-(BOOL)isValidNow{
    if (self.parsedDateFrom && self.parsedDateTo) {
        NSDate *currentDate = [NSDate date];
        
        return ([currentDate compare:self.parsedDateTo] == NSOrderedAscending || [currentDate compare:self.parsedDateTo] == NSOrderedSame)
                && ([currentDate compare:self.parsedDateFrom] == NSOrderedDescending || [currentDate compare:self.parsedDateFrom] == NSOrderedSame);
    }
    
    return YES;
}

#pragma mark - static helpers
+(NSArray *)parseCoordinatesFromHSLShapeString:(NSString *)shapeString{
    NSMutableArray *tempArray = [@[] mutableCopy];
    
    NSArray *coordStrings = [shapeString componentsSeparatedByString:@"|"];
    
    for (NSString *coordString in coordStrings) {
        CLLocationCoordinate2D coords = [ReittiStringFormatter convertStringTo2DCoord:coordString];
        CLLocation *loc = [[CLLocation alloc] initWithLatitude:coords.latitude longitude:coords.longitude];
        [tempArray addObject:loc];
    }
    
    return tempArray;
}

@end
