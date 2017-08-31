//
//  LineEntity+CoreDataProperties.h
//  
//
//  Created by Anteneh Sahledengel on 8/28/17.
//
//

#import "LineEntity.h"

NS_ASSUME_NONNULL_BEGIN

extern NSString *kLineEntityName;

@interface LineEntity (CoreDataProperties)

+ (NSFetchRequest<LineEntity *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *code;
@property (nullable, nonatomic, copy) NSString *codeShort;
@property (nullable, nonatomic, copy) NSString *lineStart;
@property (nullable, nonatomic, copy) NSString *lineEnd;
@property (nullable, nonatomic, copy) NSString *timetableUrl;
@property (nullable, nonatomic, copy) NSString *name;
@property (nullable, nonatomic, copy) NSString *patternCode;
@property (nullable, nonatomic, copy) NSNumber *patternDirectionId;
@property (nullable, nonatomic, strong) NSArray *lineStops;
@property (nullable, nonatomic, strong) NSArray *shapeCoordinates;
@property (nullable, nonatomic, copy) NSNumber *lineType;

@end

NS_ASSUME_NONNULL_END
