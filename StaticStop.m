//
//  StaticStop.m
//
//  Created by Anteneh Sahledengel on 7/6/15
//  Copyright (c) 2015 shaby ltd. All rights reserved.
//

#import "StaticStop.h"


NSString *const kStaticStopStopType = @"StopType";
NSString *const kStaticStopName = @"Name";
NSString *const kStaticStopShortCode = @"ShortCode";
NSString *const kStaticStopCode = @"Code";
NSString *const kStaticStopLineNames = @"LineNames";


@interface StaticStop ()

- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict;

@end

@implementation StaticStop

@synthesize stopType = _stopType;
@synthesize name = _name;
@synthesize shortCode = _shortCode;
@synthesize code = _code;
@synthesize lineNames = _lineNames;


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
            self.stopType = [self objectOrNilForKey:kStaticStopStopType fromDictionary:dict];
            self.name = [self objectOrNilForKey:kStaticStopName fromDictionary:dict];
            self.shortCode = [self objectOrNilForKey:kStaticStopShortCode fromDictionary:dict];
            self.code = [self objectOrNilForKey:kStaticStopCode fromDictionary:dict];
            self.lineNames = [self objectOrNilForKey:kStaticStopLineNames fromDictionary:dict];
    }
    
    return self;
}

- (NSDictionary *)dictionaryRepresentation
{
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
    [mutableDict setValue:self.stopType forKey:kStaticStopStopType];
    [mutableDict setValue:self.name forKey:kStaticStopName];
    [mutableDict setValue:self.shortCode forKey:kStaticStopShortCode];
    [mutableDict setValue:self.code forKey:kStaticStopCode];
    NSMutableArray *tempArrayForLineNames = [NSMutableArray array];
    for (NSObject *subArrayObject in self.lineNames) {
        if([subArrayObject respondsToSelector:@selector(dictionaryRepresentation)]) {
            // This class is a model object
            [tempArrayForLineNames addObject:[subArrayObject performSelector:@selector(dictionaryRepresentation)]];
        } else {
            // Generic object
            [tempArrayForLineNames addObject:subArrayObject];
        }
    }
    [mutableDict setValue:[NSArray arrayWithArray:tempArrayForLineNames] forKey:kStaticStopLineNames];

    return [NSDictionary dictionaryWithDictionary:mutableDict];
}

- (NSString *)description 
{
    return [NSString stringWithFormat:@"%@", [self dictionaryRepresentation]];
}

- (StopType)reittiStopType{
    if (self.stopType != nil) {
        return [EnumManager stopTypeForGDTypeString:self.stopType];
    }else{
        return StopTypeBus;
    }
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

    self.stopType = [aDecoder decodeObjectForKey:kStaticStopStopType];
    self.name = [aDecoder decodeObjectForKey:kStaticStopName];
    self.shortCode = [aDecoder decodeObjectForKey:kStaticStopShortCode];
    self.code = [aDecoder decodeObjectForKey:kStaticStopCode];
    self.lineNames = [aDecoder decodeObjectForKey:kStaticStopLineNames];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{

    [aCoder encodeObject:_stopType forKey:kStaticStopStopType];
    [aCoder encodeObject:_name forKey:kStaticStopName];
    [aCoder encodeObject:_shortCode forKey:kStaticStopShortCode];
    [aCoder encodeObject:_code forKey:kStaticStopCode];
    [aCoder encodeObject:_lineNames forKey:kStaticStopLineNames];
}

- (id)copyWithZone:(NSZone *)zone
{
    StaticStop *copy = [[StaticStop alloc] init];
    
    if (copy) {

        copy.stopType = [self.stopType copyWithZone:zone];
        copy.name = [self.name copyWithZone:zone];
        copy.shortCode = [self.shortCode copyWithZone:zone];
        copy.code = [self.code copyWithZone:zone];
        copy.lineNames = [self.lineNames copyWithZone:zone];
    }
    
    return copy;
}


@end
