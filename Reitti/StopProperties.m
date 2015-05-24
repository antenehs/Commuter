//
//  StopProperties.m
//
//  Created by Anteneh Sahledengel on 23/5/15
//  Copyright (c) 2015 shaby ltd. All rights reserved.
//

#import "StopProperties.h"
#import "StopLines.h"


NSString *const kStopPropertiesDist = @"dist";
NSString *const kStopPropertiesId = @"id";
NSString *const kStopPropertiesCode = @"code";
NSString *const kStopPropertiesLines = @"lines";
NSString *const kStopPropertiesAddr = @"addr";
NSString *const kStopPropertiesType = @"type";
NSString *const kStopPropertiesName = @"name";


@interface StopProperties ()

- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict;

@end

@implementation StopProperties

@synthesize dist = _dist;
@synthesize propertiesIdentifier = _propertiesIdentifier;
@synthesize code = _code;
@synthesize lines = _lines;
@synthesize addr = _addr;
@synthesize type = _type;
@synthesize name = _name;


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
            self.dist = [[self objectOrNilForKey:kStopPropertiesDist fromDictionary:dict] doubleValue];
            self.propertiesIdentifier = [self objectOrNilForKey:kStopPropertiesId fromDictionary:dict];
            self.code = [self objectOrNilForKey:kStopPropertiesCode fromDictionary:dict];
    NSObject *receivedLines = [dict objectForKey:kStopPropertiesLines];
    NSMutableArray *parsedLines = [NSMutableArray array];
    if ([receivedLines isKindOfClass:[NSArray class]]) {
        for (NSDictionary *item in (NSArray *)receivedLines) {
            if ([item isKindOfClass:[NSDictionary class]]) {
                [parsedLines addObject:[StopLines modelObjectWithDictionary:item]];
            }
       }
    } else if ([receivedLines isKindOfClass:[NSDictionary class]]) {
       [parsedLines addObject:[StopLines modelObjectWithDictionary:(NSDictionary *)receivedLines]];
    }

    self.lines = [NSArray arrayWithArray:parsedLines];
            self.addr = [self objectOrNilForKey:kStopPropertiesAddr fromDictionary:dict];
            self.type = [self objectOrNilForKey:kStopPropertiesType fromDictionary:dict];
            self.name = [self objectOrNilForKey:kStopPropertiesName fromDictionary:dict];

    }
    
    return self;
    
}

- (NSDictionary *)dictionaryRepresentation
{
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
    [mutableDict setValue:[NSNumber numberWithDouble:self.dist] forKey:kStopPropertiesDist];
    [mutableDict setValue:self.propertiesIdentifier forKey:kStopPropertiesId];
    [mutableDict setValue:self.code forKey:kStopPropertiesCode];
    NSMutableArray *tempArrayForLines = [NSMutableArray array];
    for (NSObject *subArrayObject in self.lines) {
        if([subArrayObject respondsToSelector:@selector(dictionaryRepresentation)]) {
            // This class is a model object
            [tempArrayForLines addObject:[subArrayObject performSelector:@selector(dictionaryRepresentation)]];
        } else {
            // Generic object
            [tempArrayForLines addObject:subArrayObject];
        }
    }
    [mutableDict setValue:[NSArray arrayWithArray:tempArrayForLines] forKey:kStopPropertiesLines];
    [mutableDict setValue:self.addr forKey:kStopPropertiesAddr];
    [mutableDict setValue:self.type forKey:kStopPropertiesType];
    [mutableDict setValue:self.name forKey:kStopPropertiesName];

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

    self.dist = [aDecoder decodeDoubleForKey:kStopPropertiesDist];
    self.propertiesIdentifier = [aDecoder decodeObjectForKey:kStopPropertiesId];
    self.code = [aDecoder decodeObjectForKey:kStopPropertiesCode];
    self.lines = [aDecoder decodeObjectForKey:kStopPropertiesLines];
    self.addr = [aDecoder decodeObjectForKey:kStopPropertiesAddr];
    self.type = [aDecoder decodeObjectForKey:kStopPropertiesType];
    self.name = [aDecoder decodeObjectForKey:kStopPropertiesName];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{

    [aCoder encodeDouble:_dist forKey:kStopPropertiesDist];
    [aCoder encodeObject:_propertiesIdentifier forKey:kStopPropertiesId];
    [aCoder encodeObject:_code forKey:kStopPropertiesCode];
    [aCoder encodeObject:_lines forKey:kStopPropertiesLines];
    [aCoder encodeObject:_addr forKey:kStopPropertiesAddr];
    [aCoder encodeObject:_type forKey:kStopPropertiesType];
    [aCoder encodeObject:_name forKey:kStopPropertiesName];
}

- (id)copyWithZone:(NSZone *)zone
{
    StopProperties *copy = [[StopProperties alloc] init];
    
    if (copy) {

        copy.dist = self.dist;
        copy.propertiesIdentifier = [self.propertiesIdentifier copyWithZone:zone];
        copy.code = [self.code copyWithZone:zone];
        copy.lines = [self.lines copyWithZone:zone];
        copy.addr = [self.addr copyWithZone:zone];
        copy.type = [self.type copyWithZone:zone];
        copy.name = [self.name copyWithZone:zone];
    }
    
    return copy;
}


@end
