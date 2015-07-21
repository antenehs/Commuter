//
//  Distance.m
//
//  Created by Anteneh Sahledengel on 2/7/15
//  Copyright (c) 2015 shaby ltd. All rights reserved.
//

#import "Distance.h"


NSString *const kDistanceDefaultDistanceRange = @"defaultDistanceRange";
NSString *const kDistanceDefaultTripLength = @"defaultTripLength";


@interface Distance ()

- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict;

@end

@implementation Distance

@synthesize defaultDistanceRange = _defaultDistanceRange;
@synthesize defaultTripLength = _defaultTripLength;


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
            self.defaultDistanceRange = [self objectOrNilForKey:kDistanceDefaultDistanceRange fromDictionary:dict];
            self.defaultTripLength = [[self objectOrNilForKey:kDistanceDefaultTripLength fromDictionary:dict] doubleValue];

    }
    
    return self;
    
}

- (NSDictionary *)dictionaryRepresentation
{
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
    NSMutableArray *tempArrayForDefaultDistanceRange = [NSMutableArray array];
    for (NSObject *subArrayObject in self.defaultDistanceRange) {
        if([subArrayObject respondsToSelector:@selector(dictionaryRepresentation)]) {
            // This class is a model object
            [tempArrayForDefaultDistanceRange addObject:[subArrayObject performSelector:@selector(dictionaryRepresentation)]];
        } else {
            // Generic object
            [tempArrayForDefaultDistanceRange addObject:subArrayObject];
        }
    }
    [mutableDict setValue:[NSArray arrayWithArray:tempArrayForDefaultDistanceRange] forKey:kDistanceDefaultDistanceRange];
    [mutableDict setValue:[NSNumber numberWithDouble:self.defaultTripLength] forKey:kDistanceDefaultTripLength];

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

    self.defaultDistanceRange = [aDecoder decodeObjectForKey:kDistanceDefaultDistanceRange];
    self.defaultTripLength = [aDecoder decodeDoubleForKey:kDistanceDefaultTripLength];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{

    [aCoder encodeObject:_defaultDistanceRange forKey:kDistanceDefaultDistanceRange];
    [aCoder encodeDouble:_defaultTripLength forKey:kDistanceDefaultTripLength];
}

- (id)copyWithZone:(NSZone *)zone
{
    Distance *copy = [[Distance alloc] init];
    
    if (copy) {

        copy.defaultDistanceRange = [self.defaultDistanceRange copyWithZone:zone];
        copy.defaultTripLength = self.defaultTripLength;
    }
    
    return copy;
}


@end
