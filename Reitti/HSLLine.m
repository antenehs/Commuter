//
//  HSLLine.m
//
//  Created by Anteneh Sahledengel on 18/6/15
//  Copyright (c) 2015 shaby ltd. All rights reserved.
//

#import "HSLLine.h"
#import "LineStop.h"


NSString *const kHSLLineLineStops = @"line_stops";
NSString *const kHSLLineCodeShort = @"code_short";
NSString *const kHSLLineCode = @"code";
NSString *const kHSLLineTransportTypeId = @"transport_type_id";
NSString *const kHSLLineLineStart = @"line_start";
NSString *const kHSLLineLineEnd = @"line_end";
NSString *const kHSLLineTimetableUrl = @"timetable_url";
NSString *const kHSLLineDateFrom = @"date_from";
NSString *const kHSLLineDateTo = @"date_to";
NSString *const kHSLLineName = @"name";
NSString *const kHSLLineLineShape = @"line_shape";


@interface HSLLine ()

- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict;

@end

@implementation HSLLine

@synthesize lineStops = _lineStops;
@synthesize codeShort = _codeShort;
@synthesize code = _code;
@synthesize transportTypeId = _transportTypeId;
@synthesize lineStart = _lineStart;
@synthesize lineEnd = _lineEnd;
@synthesize timetableUrl = _timetableUrl;
@synthesize dateFrom = _dateFrom;
@synthesize dateTo = _dateTo;
@synthesize name = _name;
@synthesize lineShape = _lineShape;


+ (instancetype)modelObjectWithDictionary:(NSDictionary *)dict
{
    return [[self alloc] initWithDictionary:dict];
}

- (instancetype)initWithDictionary:(NSDictionary *)dict
{
    self = [super init];
    
    // This check serves to make sure that a non-NSDictionary object
    // passed into the model class doesn't break the parsing.
    if(self && [dict isKindOfClass:[NSDictionary class]]) {
        NSObject *receivedLineStops = [dict objectForKey:kHSLLineLineStops];
        NSMutableArray *parsedLineStops = [NSMutableArray array];
        if ([receivedLineStops isKindOfClass:[NSArray class]]) {
            for (NSDictionary *item in (NSArray *)receivedLineStops) {
                if ([item isKindOfClass:[NSDictionary class]]) {
                    [parsedLineStops addObject:[LineStop modelObjectWithDictionary:item]];
                }
            }
        } else if ([receivedLineStops isKindOfClass:[NSDictionary class]]) {
            [parsedLineStops addObject:[LineStop modelObjectWithDictionary:(NSDictionary *)receivedLineStops]];
        }

        self.lineStops = [NSArray arrayWithArray:parsedLineStops];
        self.codeShort = [self objectOrNilForKey:kHSLLineCodeShort fromDictionary:dict];
        self.code = [self objectOrNilForKey:kHSLLineCode fromDictionary:dict];
        self.transportTypeId = [[self objectOrNilForKey:kHSLLineTransportTypeId fromDictionary:dict] intValue];
        self.lineStart = [self objectOrNilForKey:kHSLLineLineStart fromDictionary:dict];
        self.lineEnd = [self objectOrNilForKey:kHSLLineLineEnd fromDictionary:dict];
        self.timetableUrl = [self objectOrNilForKey:kHSLLineTimetableUrl fromDictionary:dict];
        self.dateFrom = [self objectOrNilForKey:kHSLLineDateFrom fromDictionary:dict];
        self.dateTo = [self objectOrNilForKey:kHSLLineDateTo fromDictionary:dict];
        self.name = [self objectOrNilForKey:kHSLLineName fromDictionary:dict];
        self.lineShape = [self objectOrNilForKey:kHSLLineLineShape fromDictionary:dict];

    }
    
    return self;
    
}

- (NSDictionary *)dictionaryRepresentation
{
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
    NSMutableArray *tempArrayForLineStops = [NSMutableArray array];
    for (NSObject *subArrayObject in self.lineStops) {
        if([subArrayObject respondsToSelector:@selector(dictionaryRepresentation)]) {
            // This class is a model object
            [tempArrayForLineStops addObject:[subArrayObject performSelector:@selector(dictionaryRepresentation)]];
        } else {
            // Generic object
            [tempArrayForLineStops addObject:subArrayObject];
        }
    }
    [mutableDict setValue:[NSArray arrayWithArray:tempArrayForLineStops] forKey:kHSLLineLineStops];
    [mutableDict setValue:self.codeShort forKey:kHSLLineCodeShort];
    [mutableDict setValue:self.code forKey:kHSLLineCode];
    [mutableDict setValue:[NSNumber numberWithInt:self.transportTypeId] forKey:kHSLLineTransportTypeId];
    [mutableDict setValue:self.lineStart forKey:kHSLLineLineStart];
    [mutableDict setValue:self.lineEnd forKey:kHSLLineLineEnd];
    [mutableDict setValue:self.timetableUrl forKey:kHSLLineTimetableUrl];
    [mutableDict setValue:self.dateFrom forKey:kHSLLineDateFrom];
    [mutableDict setValue:self.dateTo forKey:kHSLLineDateTo];
    [mutableDict setValue:self.name forKey:kHSLLineName];
    [mutableDict setValue:self.lineShape forKey:kHSLLineLineShape];

    return [NSDictionary dictionaryWithDictionary:mutableDict];
}

- (NSString *)description 
{
    return [NSString stringWithFormat:@"%@", [self dictionaryRepresentation]];
}

#pragma mark - Helper Method
- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict
{
    id object = [dict objectForKey:aKey];
    return [object isEqual:[NSNull null]] ? nil : object;
}


#pragma mark - NSCoding Methods

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];

    self.lineStops = [aDecoder decodeObjectForKey:kHSLLineLineStops];
    self.codeShort = [aDecoder decodeObjectForKey:kHSLLineCodeShort];
    self.code = [aDecoder decodeObjectForKey:kHSLLineCode];
    self.transportTypeId = [aDecoder decodeInt32ForKey:kHSLLineTransportTypeId];
    self.lineStart = [aDecoder decodeObjectForKey:kHSLLineLineStart];
    self.lineEnd = [aDecoder decodeObjectForKey:kHSLLineLineEnd];
    self.timetableUrl = [aDecoder decodeObjectForKey:kHSLLineTimetableUrl];
    self.dateFrom = [aDecoder decodeObjectForKey:kHSLLineDateFrom];
    self.dateTo = [aDecoder decodeObjectForKey:kHSLLineDateTo];
    self.name = [aDecoder decodeObjectForKey:kHSLLineName];
    self.lineShape = [aDecoder decodeObjectForKey:kHSLLineLineShape];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{

    [aCoder encodeObject:_lineStops forKey:kHSLLineLineStops];
    [aCoder encodeObject:_codeShort forKey:kHSLLineCodeShort];
    [aCoder encodeObject:_code forKey:kHSLLineCode];
    [aCoder encodeInt32:_transportTypeId forKey:kHSLLineTransportTypeId];
    [aCoder encodeObject:_lineStart forKey:kHSLLineLineStart];
    [aCoder encodeObject:_lineEnd forKey:kHSLLineLineEnd];
    [aCoder encodeObject:_timetableUrl forKey:kHSLLineTimetableUrl];
    [aCoder encodeObject:_dateFrom forKey:kHSLLineDateFrom];
    [aCoder encodeObject:_dateTo forKey:kHSLLineDateTo];
    [aCoder encodeObject:_name forKey:kHSLLineName];
    [aCoder encodeObject:_lineShape forKey:kHSLLineLineShape];
}

- (id)copyWithZone:(NSZone *)zone
{
    HSLLine *copy = [[HSLLine alloc] init];
    
    if (copy) {

        copy.lineStops = [self.lineStops copyWithZone:zone];
        copy.codeShort = [self.codeShort copyWithZone:zone];
        copy.code = [self.code copyWithZone:zone];
        copy.transportTypeId = self.transportTypeId;
        copy.lineStart = [self.lineStart copyWithZone:zone];
        copy.lineEnd = [self.lineEnd copyWithZone:zone];
        copy.timetableUrl = [self.timetableUrl copyWithZone:zone];
        copy.dateFrom = [self.dateFrom copyWithZone:zone];
        copy.dateTo = [self.dateTo copyWithZone:zone];
        copy.name = [self.name copyWithZone:zone];
        copy.lineShape = [self.lineShape copyWithZone:zone];
    }
    
    return copy;
}


@end
