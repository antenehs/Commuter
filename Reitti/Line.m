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
#import "MatkaStop.h"
#import "LineStop.h"

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

//+(id)lineFromDigiLine:(DigiRoute *)digiLine {
//    Line *line = [[Line alloc] init];
//    
//    if (digiLine != nil && [digiLine isKindOfClass:[DigiRoute class]]) {
//        line.code = digiLine.gtfsId;
//        line.codeShort = digiLine.shortName;
//        line.lineType = digiLine.lineType;
//        
//        line.lineStart = digiLine.lineStart;
//        line.lineEnd = digiLine.lineEnd;
//        
//        line.timetableUrl = digiLine.url;
//        line.dateFrom = nil;
//        line.dateTo = nil;
//        line.name = digiLine.longName;
//        
////        if (digiLine.stops) {
////            NSMutableArray *stops = [@[] mutableCopy];
////            for (DigiStopShort *digiStop in digiLine.stops) {
////                LineStop *stop = [LineStop lineStopFromDigiStopShort:digiStop];
////                if (stop) [stops addObject:stop];
////            }
////            
////            line.lineStops = stops;
////        }
//        
//        line.shapeCoordinates = digiLine.shapeCoordinates ? digiLine.shapeCoordinates : @[];
//        
//        return line;
//    }
//    
//    return nil;
//}

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
