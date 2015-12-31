
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

@interface Line : NSObject

@property (nonatomic, strong) NSString *code;
@property (nonatomic, strong) NSString *codeShort;
@property (nonatomic) LineType lineType;
@property (nonatomic, strong) NSString *lineStart;
@property (nonatomic, strong) NSString *lineEnd;
@property (nonatomic, strong) NSArray *lineStops;
@property (nonatomic, strong) NSString *timetableUrl;
@property (nonatomic, strong) NSString *dateFrom;
@property (nonatomic, strong) NSString *dateTo;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSArray *shapeCoordinates;

@property (nonatomic, strong) NSDate *parsedDateFrom;
@property (nonatomic, strong) NSDate *parsedDateTo;
@property (nonatomic, readonly) BOOL isValidNow;

-(id)initFromHSLLine:(HSLLine *)hslLine;

@end
