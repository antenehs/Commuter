//
//  LineEntity+Transformation.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 8/28/17.
//  Copyright © 2017 Anteneh Sahledengel. All rights reserved.
//

#import "LineEntity+Transformation.h"
#import "NSArray+Helper.h"

@implementation LineEntity (Transformation)

-(Line *)reittiLineFromEntity {
    
    Line *reittiLine = [Line new];
    
    reittiLine.code = reittiLine.code;
    reittiLine.codeShort = self.codeShort;
    reittiLine.lineStart = self.lineStart;
    reittiLine.lineEnd = self.lineEnd;
    reittiLine.timetableUrl = self.timetableUrl;
    
    reittiLine.defaultPatternCode = self.patternCode;
//    reittiLine.defaultPatternDirectionId = self.patternDirectionId;
    
//    NSArray *lineStops = [self.lineStops asa_mapWith:^id(NSDictionary *lineStopDict) {
//        return [LineStop modelObjectWithDictionary:lineStopDict];
//    }];
    
//    reittiLine.lineStops = lineStops;
//    reittiLine.shapeCoordinates = self.shapeCoordinates;
    
    reittiLine.lineType = (LineType)[self.lineType intValue];
    
    return reittiLine;
}

-(void)initFromReittiLine:(Line *)reittiLine {
    
    self.code = reittiLine.code;
    self.codeShort = reittiLine.codeShort;
    self.lineStart = reittiLine.lineStart;
    self.lineEnd = reittiLine.lineEnd;
    self.timetableUrl = reittiLine.timetableUrl;
    
    self.patternCode = reittiLine.defaultPatternCode;
//    self.patternDirectionId = reittiLine.defaultPatternDirectionId;
    
//    NSArray *dictStops = [self.lineStops asa_mapWith:^id(LineStop *lineStop) {
//        return [lineStop dictionaryRepresentation];
//    }];
//    
//    self.lineStops = dictStops;
//    self.shapeCoordinates = reittiLine.shapeCoordinates;
    
    self.lineType = [NSNumber numberWithInt:reittiLine.lineType];
}

@end
