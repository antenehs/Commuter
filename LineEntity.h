//
//  LineEntity+CoreDataClass.h
//  
//
//  Created by Anteneh Sahledengel on 8/28/17.
//
//

#import <Foundation/Foundation.h>
#import "ReittiManagedObjectBase.h"

extern NSString *kLineEntityName;

@interface LineEntity : ReittiManagedObjectBase

@property ( nonatomic, copy) NSString *code;
@property ( nonatomic, copy) NSString *codeShort;
@property ( nonatomic, copy) NSString *lineStart;
@property ( nonatomic, copy) NSString *lineEnd;
@property ( nonatomic, copy) NSString *timetableUrl;
@property ( nonatomic, copy) NSString *name;
@property ( nonatomic, copy) NSString *patternCode;
@property ( nonatomic, copy) NSNumber *patternDirectionId;
@property ( nonatomic, strong) NSArray *lineStops;
@property ( nonatomic, strong) NSArray *shapeCoordinates;
@property ( nonatomic, copy) NSNumber *lineType;

@end
