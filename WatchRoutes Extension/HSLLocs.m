//
//  HSLLocs.m
//
//  Created by Anteneh Sahledengel on 28/6/16
//  Copyright (c) 2016 shaby ltd. All rights reserved.
//

#import "HSLLocs.h"
#import "HSLCoord.h"


NSString *const kHSLLocsName = @"name";
NSString *const kHSLLocsArrTime = @"arrTime";
NSString *const kHSLLocsCoord = @"coord";
NSString *const kHSLLocsCode = @"code";
NSString *const kHSLLocsDepTime = @"depTime";
NSString *const kHSLLocsStopAddress = @"stopAddress";
NSString *const kHSLLocsShortCode = @"shortCode";


@interface HSLLocs ()

- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict;

@end

@implementation HSLLocs

@synthesize name = _name;
@synthesize arrTime = _arrTime;
@synthesize coord = _coord;
@synthesize code = _code;
@synthesize depTime = _depTime;
@synthesize stopAddress = _stopAddress;
@synthesize shortCode = _shortCode;


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
            self.name = [self objectOrNilForKey:kHSLLocsName fromDictionary:dict];
            self.arrTime = [self objectOrNilForKey:kHSLLocsArrTime fromDictionary:dict];
            self.coord = [HSLCoord modelObjectWithDictionary:[dict objectForKey:kHSLLocsCoord]];
            self.code = [self objectOrNilForKey:kHSLLocsCode fromDictionary:dict];
            self.depTime = [self objectOrNilForKey:kHSLLocsDepTime fromDictionary:dict];
            self.stopAddress = [self objectOrNilForKey:kHSLLocsStopAddress fromDictionary:dict];
            self.shortCode = [self objectOrNilForKey:kHSLLocsShortCode fromDictionary:dict];

    }
    
    return self;
    
}

- (NSDictionary *)dictionaryRepresentation
{
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
    [mutableDict setValue:self.name forKey:kHSLLocsName];
    [mutableDict setValue:self.arrTime forKey:kHSLLocsArrTime];
    [mutableDict setValue:[self.coord dictionaryRepresentation] forKey:kHSLLocsCoord];
    [mutableDict setValue:self.code forKey:kHSLLocsCode];
    [mutableDict setValue:self.depTime forKey:kHSLLocsDepTime];
    [mutableDict setValue:self.stopAddress forKey:kHSLLocsStopAddress];
    [mutableDict setValue:self.shortCode forKey:kHSLLocsShortCode];

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

    self.name = [aDecoder decodeObjectForKey:kHSLLocsName];
    self.arrTime = [aDecoder decodeObjectForKey:kHSLLocsArrTime];
    self.coord = [aDecoder decodeObjectForKey:kHSLLocsCoord];
    self.code = [aDecoder decodeObjectForKey:kHSLLocsCode];
    self.depTime = [aDecoder decodeObjectForKey:kHSLLocsDepTime];
    self.stopAddress = [aDecoder decodeObjectForKey:kHSLLocsStopAddress];
    self.shortCode = [aDecoder decodeObjectForKey:kHSLLocsShortCode];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{

    [aCoder encodeObject:_name forKey:kHSLLocsName];
    [aCoder encodeObject:_arrTime forKey:kHSLLocsArrTime];
    [aCoder encodeObject:_coord forKey:kHSLLocsCoord];
    [aCoder encodeObject:_code forKey:kHSLLocsCode];
    [aCoder encodeObject:_depTime forKey:kHSLLocsDepTime];
    [aCoder encodeObject:_stopAddress forKey:kHSLLocsStopAddress];
    [aCoder encodeObject:_shortCode forKey:kHSLLocsShortCode];
}

- (id)copyWithZone:(NSZone *)zone
{
    HSLLocs *copy = [[HSLLocs alloc] init];
    
    if (copy) {

        copy.name = [self.name copyWithZone:zone];
        copy.arrTime = [self.arrTime copyWithZone:zone];
        copy.coord = [self.coord copyWithZone:zone];
        copy.code = [self.code copyWithZone:zone];
        copy.depTime = [self.depTime copyWithZone:zone];
        copy.stopAddress = [self.stopAddress copyWithZone:zone];
        copy.shortCode = [self.shortCode copyWithZone:zone];
    }
    
    return copy;
}


@end
