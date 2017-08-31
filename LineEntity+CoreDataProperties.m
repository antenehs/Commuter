//
//  LineEntity+CoreDataProperties.m
//  
//
//  Created by Anteneh Sahledengel on 8/28/17.
//
//

#import "LineEntity+CoreDataProperties.h"

NSString *kLineEntityName = @"LineEntity";

@implementation LineEntity (CoreDataProperties)

+ (NSFetchRequest<LineEntity *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:kLineEntityName];
}

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

@end
