//
//  HSLCoord.m
//
//  Created by Anteneh Sahledengel on 28/6/16
//  Copyright (c) 2016 shaby ltd. All rights reserved.
//

#import "HSLCoord.h"


NSString *const kHSLCoordX = @"x";
NSString *const kHSLCoordY = @"y";


@interface HSLCoord ()

- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict;

@end

@implementation HSLCoord

@synthesize x = _x;
@synthesize y = _y;


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
            self.x = [[self objectOrNilForKey:kHSLCoordX fromDictionary:dict] doubleValue];
            self.y = [[self objectOrNilForKey:kHSLCoordY fromDictionary:dict] doubleValue];

    }
    
    return self;
    
}

- (NSDictionary *)dictionaryRepresentation
{
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
    [mutableDict setValue:[NSNumber numberWithDouble:self.x] forKey:kHSLCoordX];
    [mutableDict setValue:[NSNumber numberWithDouble:self.y] forKey:kHSLCoordY];

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

    self.x = [aDecoder decodeDoubleForKey:kHSLCoordX];
    self.y = [aDecoder decodeDoubleForKey:kHSLCoordY];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{

    [aCoder encodeDouble:_x forKey:kHSLCoordX];
    [aCoder encodeDouble:_y forKey:kHSLCoordY];
}

- (id)copyWithZone:(NSZone *)zone
{
    HSLCoord *copy = [[HSLCoord alloc] init];
    
    if (copy) {

        copy.x = self.x;
        copy.y = self.y;
    }
    
    return copy;
}


@end
