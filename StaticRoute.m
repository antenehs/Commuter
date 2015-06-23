//
//  StaticRoute.m
//
//  Created by Anteneh Sahledengel on 6/6/15
//  Copyright (c) 2015 shaby ltd. All rights reserved.
//

#import "StaticRoute.h"

NSString *const kBaseClassLineEnd = @"LineEnd";
NSString *const kBaseClassRouteType = @"RouteType";
NSString *const kBaseClassCode = @"Code";
NSString *const kBaseClassRouteUrl = @"RouteUrl";
NSString *const kBaseClassShortName = @"ShortName";
NSString *const kBaseClassLineStart = @"LineStart";
NSString *const kBaseClassLongName = @"LongName";
NSString *const kBaseClassOperator = @"Operator";


@interface StaticRoute ()

- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict;

@end

@implementation StaticRoute

@synthesize lineEnd = _lineEnd;
@synthesize routeType = _routeType;
@synthesize code = _code;
@synthesize routeUrl = _routeUrl;
@synthesize shortName = _shortName;
@synthesize lineStart = _lineStart;
@synthesize longName = _longName;
@synthesize operator = _operator;


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
        self.lineEnd = [self objectOrNilForKey:kBaseClassLineEnd fromDictionary:dict];
        self.routeType = [self objectOrNilForKey:kBaseClassRouteType fromDictionary:dict];
        self.code = [self objectOrNilForKey:kBaseClassCode fromDictionary:dict];
        self.routeUrl = [self objectOrNilForKey:kBaseClassRouteUrl fromDictionary:dict];
        self.shortName = [self objectOrNilForKey:kBaseClassShortName fromDictionary:dict];
        self.lineStart = [self objectOrNilForKey:kBaseClassLineStart fromDictionary:dict];
        self.longName = [self objectOrNilForKey:kBaseClassLongName fromDictionary:dict];
        self.operator = [self objectOrNilForKey:kBaseClassOperator fromDictionary:dict];
        
    }
    
    return self;
}

- (NSDictionary *)dictionaryRepresentation
{
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
    [mutableDict setValue:self.lineEnd forKey:kBaseClassLineEnd];
    [mutableDict setValue:self.routeType forKey:kBaseClassRouteType];
    [mutableDict setValue:self.code forKey:kBaseClassCode];
    [mutableDict setValue:self.routeUrl forKey:kBaseClassRouteUrl];
    [mutableDict setValue:self.shortName forKey:kBaseClassShortName];
    [mutableDict setValue:self.lineStart forKey:kBaseClassLineStart];
    [mutableDict setValue:self.longName forKey:kBaseClassLongName];
    [mutableDict setValue:self.operator forKey:kBaseClassOperator];
    
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
    
    self.lineEnd = [aDecoder decodeObjectForKey:kBaseClassLineEnd];
    self.routeType = [aDecoder decodeObjectForKey:kBaseClassRouteType];
    self.code = [aDecoder decodeObjectForKey:kBaseClassCode];
    self.routeUrl = [aDecoder decodeObjectForKey:kBaseClassRouteUrl];
    self.shortName = [aDecoder decodeObjectForKey:kBaseClassShortName];
    self.lineStart = [aDecoder decodeObjectForKey:kBaseClassLineStart];
    self.longName = [aDecoder decodeObjectForKey:kBaseClassLongName];
    self.operator = [aDecoder decodeObjectForKey:kBaseClassOperator];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    
    [aCoder encodeObject:_lineEnd forKey:kBaseClassLineEnd];
    [aCoder encodeObject:_routeType forKey:kBaseClassRouteType];
    [aCoder encodeObject:_code forKey:kBaseClassCode];
    [aCoder encodeObject:_routeUrl forKey:kBaseClassRouteUrl];
    [aCoder encodeObject:_shortName forKey:kBaseClassShortName];
    [aCoder encodeObject:_lineStart forKey:kBaseClassLineStart];
    [aCoder encodeObject:_longName forKey:kBaseClassLongName];
    [aCoder encodeObject:_operator forKey:kBaseClassOperator];
}

- (id)copyWithZone:(NSZone *)zone
{
    StaticRoute *copy = [[StaticRoute alloc] init];
    
    if (copy) {
        
        copy.lineEnd = [self.lineEnd copyWithZone:zone];
        copy.routeType = [self.routeType copyWithZone:zone];
        copy.code = [self.code copyWithZone:zone];
        copy.routeUrl = [self.routeUrl copyWithZone:zone];
        copy.shortName = [self.shortName copyWithZone:zone];
        copy.lineStart = [self.lineStart copyWithZone:zone];
        copy.longName = [self.longName copyWithZone:zone];
        copy.operator = [self.operator copyWithZone:zone];
    }
    
    return copy;
}


@end
