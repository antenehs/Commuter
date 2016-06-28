//
//  HSLLegs.m
//
//  Created by Anteneh Sahledengel on 28/6/16
//  Copyright (c) 2016 shaby ltd. All rights reserved.
//

#import "HSLLegs.h"
#import "HSLLocs.h"


NSString *const kHSLLegsLocs = @"locs";
NSString *const kHSLLegsCode = @"code";
NSString *const kHSLLegsLength = @"length";
NSString *const kHSLLegsType = @"type";
NSString *const kHSLLegsDuration = @"duration";


@interface HSLLegs ()

- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict;

@end

@implementation HSLLegs

@synthesize locs = _locs;
@synthesize code = _code;
@synthesize length = _length;
@synthesize type = _type;
@synthesize duration = _duration;


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
    NSObject *receivedHSLLocs = [dict objectForKey:kHSLLegsLocs];
    NSMutableArray *parsedHSLLocs = [NSMutableArray array];
    if ([receivedHSLLocs isKindOfClass:[NSArray class]]) {
        for (NSDictionary *item in (NSArray *)receivedHSLLocs) {
            if ([item isKindOfClass:[NSDictionary class]]) {
                [parsedHSLLocs addObject:[HSLLocs modelObjectWithDictionary:item]];
            }
       }
    } else if ([receivedHSLLocs isKindOfClass:[NSDictionary class]]) {
       [parsedHSLLocs addObject:[HSLLocs modelObjectWithDictionary:(NSDictionary *)receivedHSLLocs]];
    }

    self.locs = [NSArray arrayWithArray:parsedHSLLocs];
            self.code = [self objectOrNilForKey:kHSLLegsCode fromDictionary:dict];
            self.length = [[self objectOrNilForKey:kHSLLegsLength fromDictionary:dict] doubleValue];
            self.type = [self objectOrNilForKey:kHSLLegsType fromDictionary:dict];
            self.duration = [[self objectOrNilForKey:kHSLLegsDuration fromDictionary:dict] doubleValue];

    }
    
    return self;
    
}

- (NSDictionary *)dictionaryRepresentation
{
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
    NSMutableArray *tempArrayForLocs = [NSMutableArray array];
    for (NSObject *subArrayObject in self.locs) {
        if([subArrayObject respondsToSelector:@selector(dictionaryRepresentation)]) {
            // This class is a model object
            [tempArrayForLocs addObject:[subArrayObject performSelector:@selector(dictionaryRepresentation)]];
        } else {
            // Generic object
            [tempArrayForLocs addObject:subArrayObject];
        }
    }
    [mutableDict setValue:[NSArray arrayWithArray:tempArrayForLocs] forKey:kHSLLegsLocs];
    [mutableDict setValue:self.code forKey:kHSLLegsCode];
    [mutableDict setValue:[NSNumber numberWithDouble:self.length] forKey:kHSLLegsLength];
    [mutableDict setValue:self.type forKey:kHSLLegsType];
    [mutableDict setValue:[NSNumber numberWithDouble:self.duration] forKey:kHSLLegsDuration];

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

    self.locs = [aDecoder decodeObjectForKey:kHSLLegsLocs];
    self.code = [aDecoder decodeObjectForKey:kHSLLegsCode];
    self.length = [aDecoder decodeDoubleForKey:kHSLLegsLength];
    self.type = [aDecoder decodeObjectForKey:kHSLLegsType];
    self.duration = [aDecoder decodeDoubleForKey:kHSLLegsDuration];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{

    [aCoder encodeObject:_locs forKey:kHSLLegsLocs];
    [aCoder encodeObject:_code forKey:kHSLLegsCode];
    [aCoder encodeDouble:_length forKey:kHSLLegsLength];
    [aCoder encodeObject:_type forKey:kHSLLegsType];
    [aCoder encodeDouble:_duration forKey:kHSLLegsDuration];
}

- (id)copyWithZone:(NSZone *)zone
{
    HSLLegs *copy = [[HSLLegs alloc] init];
    
    if (copy) {

        copy.locs = [self.locs copyWithZone:zone];
        copy.code = [self.code copyWithZone:zone];
        copy.length = self.length;
        copy.type = [self.type copyWithZone:zone];
        copy.duration = self.duration;
    }
    
    return copy;
}


@end
