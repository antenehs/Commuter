//
//  HSLLine.h
//
//  Created by Anteneh Sahledengel on 18/6/15
//  Copyright (c) 2015 shaby ltd. All rights reserved.
//

#import <Foundation/Foundation.h>



@interface HSLLine : NSObject <NSCoding, NSCopying>

@property (nonatomic, strong) NSArray *lineStops;
@property (nonatomic, strong) NSString *codeShort;
@property (nonatomic, strong) NSString *code;
@property (nonatomic, assign) int transportTypeId;
@property (nonatomic, strong) NSString *lineStart;
@property (nonatomic, strong) NSString *lineEnd;
@property (nonatomic, strong) NSString *timetableUrl;
@property (nonatomic, strong) NSString *dateFrom;
@property (nonatomic, strong) NSString *dateTo;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *lineShape;

+ (instancetype)modelObjectWithDictionary:(NSDictionary *)dict;
- (instancetype)initWithDictionary:(NSDictionary *)dict;
- (NSDictionary *)dictionaryRepresentation;

@end
