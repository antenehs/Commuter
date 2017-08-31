//
//  LineEntity+CoreDataClass.m
//  
//
//  Created by Anteneh Sahledengel on 8/28/17.
//
//

#import "LineEntity.h"

NSString *kLineEntityName = @"LineEntity";

@implementation LineEntity


#if MAIN_APP

@dynamic code;
@dynamic codeShort;
@dynamic lineStart;
@dynamic lineEnd;
@dynamic timetableUrl;
@dynamic name;
@dynamic patternCode;
@dynamic patternDirectionId;
@dynamic lineStops;
@dynamic shapeCoordinates;
@dynamic lineType;

#else



#endif

@end
