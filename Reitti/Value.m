//
//  Value.m
//
//  Created by Anteneh Sahledengel on 2/7/15
//  Copyright (c) 2015 shaby ltd. All rights reserved.
//

#import "Value.h"


NSString *const kValueMaxValue = @"maxValue";
NSString *const kValueLastPurchase = @"lastPurchase";
NSString *const kValueAvailable = @"available";
NSString *const kValueDefaultPriceRange = @"defaultPriceRange";
NSString *const kValueMinValue = @"minValue";
NSString *const kValueAlertLimit = @"alertLimit";


@interface Value ()

- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict;

@end

@implementation Value

@synthesize maxValue = _maxValue;
@synthesize lastPurchase = _lastPurchase;
@synthesize available = _available;
@synthesize defaultPriceRange = _defaultPriceRange;
@synthesize minValue = _minValue;
@synthesize alertLimit = _alertLimit;


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
            self.maxValue = [[self objectOrNilForKey:kValueMaxValue fromDictionary:dict] doubleValue];
            self.lastPurchase = [[self objectOrNilForKey:kValueLastPurchase fromDictionary:dict] doubleValue];
            self.available = [[self objectOrNilForKey:kValueAvailable fromDictionary:dict] doubleValue];
            self.defaultPriceRange = [self objectOrNilForKey:kValueDefaultPriceRange fromDictionary:dict];
            self.minValue = [[self objectOrNilForKey:kValueMinValue fromDictionary:dict] doubleValue];
            self.alertLimit = [[self objectOrNilForKey:kValueAlertLimit fromDictionary:dict] doubleValue];

    }
    
    return self;
    
}

- (NSDictionary *)dictionaryRepresentation
{
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
    [mutableDict setValue:[NSNumber numberWithDouble:self.maxValue] forKey:kValueMaxValue];
    [mutableDict setValue:[NSNumber numberWithDouble:self.lastPurchase] forKey:kValueLastPurchase];
    [mutableDict setValue:[NSNumber numberWithDouble:self.available] forKey:kValueAvailable];
    NSMutableArray *tempArrayForDefaultPriceRange = [NSMutableArray array];
    for (NSObject *subArrayObject in self.defaultPriceRange) {
        if([subArrayObject respondsToSelector:@selector(dictionaryRepresentation)]) {
            // This class is a model object
            [tempArrayForDefaultPriceRange addObject:[subArrayObject performSelector:@selector(dictionaryRepresentation)]];
        } else {
            // Generic object
            [tempArrayForDefaultPriceRange addObject:subArrayObject];
        }
    }
    [mutableDict setValue:[NSArray arrayWithArray:tempArrayForDefaultPriceRange] forKey:kValueDefaultPriceRange];
    [mutableDict setValue:[NSNumber numberWithDouble:self.minValue] forKey:kValueMinValue];
    [mutableDict setValue:[NSNumber numberWithDouble:self.alertLimit] forKey:kValueAlertLimit];

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

    self.maxValue = [aDecoder decodeDoubleForKey:kValueMaxValue];
    self.lastPurchase = [aDecoder decodeDoubleForKey:kValueLastPurchase];
    self.available = [aDecoder decodeDoubleForKey:kValueAvailable];
    self.defaultPriceRange = [aDecoder decodeObjectForKey:kValueDefaultPriceRange];
    self.minValue = [aDecoder decodeDoubleForKey:kValueMinValue];
    self.alertLimit = [aDecoder decodeDoubleForKey:kValueAlertLimit];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{

    [aCoder encodeDouble:_maxValue forKey:kValueMaxValue];
    [aCoder encodeDouble:_lastPurchase forKey:kValueLastPurchase];
    [aCoder encodeDouble:_available forKey:kValueAvailable];
    [aCoder encodeObject:_defaultPriceRange forKey:kValueDefaultPriceRange];
    [aCoder encodeDouble:_minValue forKey:kValueMinValue];
    [aCoder encodeDouble:_alertLimit forKey:kValueAlertLimit];
}

- (id)copyWithZone:(NSZone *)zone
{
    Value *copy = [[Value alloc] init];
    
    if (copy) {

        copy.maxValue = self.maxValue;
        copy.lastPurchase = self.lastPurchase;
        copy.available = self.available;
        copy.defaultPriceRange = [self.defaultPriceRange copyWithZone:zone];
        copy.minValue = self.minValue;
        copy.alertLimit = self.alertLimit;
    }
    
    return copy;
}


@end
