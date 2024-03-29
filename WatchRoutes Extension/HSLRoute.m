//
//  HSLRoute.m
//
//  Created by Anteneh Sahledengel on 28/6/16
//  Copyright (c) 2016 shaby ltd. All rights reserved.
//

#import "HSLRoute.h"
#import "HSLLegs.h"


NSString *const kHSLRouteLegs = @"legs";
NSString *const kHSLRouteDuration = @"duration";
NSString *const kHSLRouteLength = @"length";


@interface HSLRoute ()

- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict;

@end

@implementation HSLRoute

@synthesize legs = _legs;
@synthesize duration = _duration;
@synthesize length = _length;


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
    NSObject *receivedHSLLegs = [dict objectForKey:kHSLRouteLegs];
    NSMutableArray *parsedHSLLegs = [NSMutableArray array];
    if ([receivedHSLLegs isKindOfClass:[NSArray class]]) {
        for (NSDictionary *item in (NSArray *)receivedHSLLegs) {
            if ([item isKindOfClass:[NSDictionary class]]) {
                [parsedHSLLegs addObject:[HSLLegs modelObjectWithDictionary:item]];
            }
       }
    } else if ([receivedHSLLegs isKindOfClass:[NSDictionary class]]) {
       [parsedHSLLegs addObject:[HSLLegs modelObjectWithDictionary:(NSDictionary *)receivedHSLLegs]];
    }

    self.legs = [NSArray arrayWithArray:parsedHSLLegs];
            self.duration = [[self objectOrNilForKey:kHSLRouteDuration fromDictionary:dict] doubleValue];
            self.length = [[self objectOrNilForKey:kHSLRouteLength fromDictionary:dict] doubleValue];

    }
    
    return self;
    
}

- (NSDictionary *)dictionaryRepresentation
{
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
    NSMutableArray *tempArrayForLegs = [NSMutableArray array];
    for (NSObject *subArrayObject in self.legs) {
        if([subArrayObject respondsToSelector:@selector(dictionaryRepresentation)]) {
            // This class is a model object
            [tempArrayForLegs addObject:[subArrayObject performSelector:@selector(dictionaryRepresentation)]];
        } else {
            // Generic object
            [tempArrayForLegs addObject:subArrayObject];
        }
    }
    [mutableDict setValue:[NSArray arrayWithArray:tempArrayForLegs] forKey:kHSLRouteLegs];
    [mutableDict setValue:[NSNumber numberWithDouble:self.duration] forKey:kHSLRouteDuration];
    [mutableDict setValue:[NSNumber numberWithDouble:self.length] forKey:kHSLRouteLength];

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

    self.legs = [aDecoder decodeObjectForKey:kHSLRouteLegs];
    self.duration = [aDecoder decodeDoubleForKey:kHSLRouteDuration];
    self.length = [aDecoder decodeDoubleForKey:kHSLRouteLength];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{

    [aCoder encodeObject:_legs forKey:kHSLRouteLegs];
    [aCoder encodeDouble:_duration forKey:kHSLRouteDuration];
    [aCoder encodeDouble:_length forKey:kHSLRouteLength];
}

- (id)copyWithZone:(NSZone *)zone
{
    HSLRoute *copy = [[HSLRoute alloc] init];
    
    if (copy) {

        copy.legs = [self.legs copyWithZone:zone];
        copy.duration = self.duration;
        copy.length = self.length;
    }
    
    return copy;
}


@end
