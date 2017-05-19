
//
//  LineInfo.h
//  Reitti
//
//  Created by Anteneh Sahledengel on 11/3/14.
//  Copyright (c) 2014 Anteneh Sahledengel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EnumManager.h"
#import "HSLLine.h"
#import "StopLine.h"
#import "MatkaLine.h"

@interface Line : NSObject

@property (nonatomic, strong) NSString *code;
@property (nonatomic, strong) NSString *codeShort;
@property (nonatomic, strong) NSString *lineStart;
@property (nonatomic, strong) NSString *lineEnd;
@property (nonatomic, strong) NSString *timetableUrl;
@property (nonatomic, strong) NSString *dateFrom;
@property (nonatomic, strong) NSString *dateTo;
@property (nonatomic, strong) NSString *name;

@property (nonatomic, strong) NSString *patternCode;
@property (nonatomic, strong) NSNumber *patternDirectionId;

@property (nonatomic, strong) NSArray *lineStops;
@property (nonatomic, strong) NSArray *shapeCoordinates;

@property (nonatomic) LineType lineType;

@property (nonatomic, strong) NSDate *parsedDateFrom;
@property (nonatomic, strong) NSDate *parsedDateTo;
@property (nonatomic, readonly) BOOL isValidNow;

+(id)lineFromStopLine:(StopLine *)stopLine;
+(id)lineFromHSLLine:(HSLLine *)hslLine;
+(id)lineFromMatkaLine:(MatkaLine *)matkaLine;

@end
