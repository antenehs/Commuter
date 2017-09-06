
//
//  LineInfo.h
//  Reitti
//
//  Created by Anteneh Sahledengel on 11/3/14.
//  Copyright (c) 2014 Anteneh Sahledengel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EnumManager.h"
#import "StopLine.h"
#import "LineStop.h"
#import "LinePattern.h"

#ifndef APPLE_WATCH
#import "HSLLine.h"
#import "MatkaLine.h"
#endif

@interface Line : NSObject

@property (nonatomic, strong) NSString *code;
@property (nonatomic, strong) NSString *codeShort;
@property (nonatomic, strong) NSString *lineStart;
@property (nonatomic, strong) NSString *lineEnd;
@property (nonatomic, strong) NSString *timetableUrl;
@property (nonatomic, strong) NSString *dateFrom;
@property (nonatomic, strong) NSString *dateTo;
@property (nonatomic, strong) NSString *name;

@property (nonatomic, strong) NSArray<LinePattern *> *patterns;

@property (nonatomic, strong) NSString *defaultPatternCode;
@property (nonatomic, strong) LinePattern *defaultPattern;

//@property (nonatomic, strong) NSString *patternCode;
//@property (nonatomic, strong) NSNumber *patternDirectionId;
//
@property (nonatomic, strong) NSArray *selectedPatternStops;
@property (nonatomic, strong) NSArray *selectedPatternShapeCoordinates;

@property (nonatomic) LineType lineType;

@property (nonatomic, strong) NSDate *parsedDateFrom;
@property (nonatomic, strong) NSDate *parsedDateTo;
@property (nonatomic, readonly) BOOL isValidNow;

@property (nonatomic) BOOL hasDetails;

+(id)lineFromStopLine:(StopLine *)stopLine;

#ifndef APPLE_WATCH
+(id)lineFromHSLLine:(HSLLine *)hslLine;
+(id)lineFromMatkaLine:(MatkaLine *)matkaLine;
#endif

@end
