//
//  StopStopLines.m
//
//  Created by Anteneh Sahledengel on 23/5/15
//  Copyright (c) 2015 shaby ltd. All rights reserved.
//

#import "StopLines.h"


NSString *const kStopLinesId = @"id";
NSString *const kStopLinesType = @"type";
NSString *const kStopLinesName = @"name";


@interface StopLines ()

- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict;

@end

@implementation StopLines

@synthesize linesIdentifier = _linesIdentifier;
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
            self.linesIdentifier = [self objectOrNilForKey:kStopLinesId fromDictionary:dict];
            self.type = [self objectOrNilForKey:kStopLinesType fromDictionary:dict];
            self.name = [self objectOrNilForKey:kStopLinesName fromDictionary:dict];

    }
    
    return self;
    
}

- (NSDictionary *)dictionaryRepresentation
{
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
    [mutableDict setValue:self.linesIdentifier forKey:kStopLinesId];
    [mutableDict setValue:self.type forKey:kStopLinesType];
    [mutableDict setValue:self.name forKey:kStopLinesName];

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

    self.linesIdentifier = [aDecoder decodeObjectForKey:kStopLinesId];
    self.type = [aDecoder decodeObjectForKey:kStopLinesType];
    self.name = [aDecoder decodeObjectForKey:kStopLinesName];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{

    [aCoder encodeObject:_linesIdentifier forKey:kStopLinesId];
    [aCoder encodeObject:_type forKey:kStopLinesType];
    [aCoder encodeObject:_name forKey:kStopLinesName];
}

- (id)copyWithZone:(NSZone *)zone
{
    StopLines *copy = [[StopLines alloc] init];
    
    if (copy) {

        copy.linesIdentifier = [self.linesIdentifier copyWithZone:zone];
        copy.type = [self.type copyWithZone:zone];
        copy.name = [self.name copyWithZone:zone];
    }
    
    return copy;
}


@end
