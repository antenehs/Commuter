//
//  StaticRoute.m
//
//  Created by Anteneh Sahledengel on 6/6/15
//  Copyright (c) 2015 shaby ltd. All rights reserved.
//

#import "StaticRoute.h"


NSString *const kStaticRouteRouteUrl = @"RouteUrl";
NSString *const kStaticRouteOperator = @"Operator";
NSString *const kStaticRouteShortName = @"ShortName";
NSString *const kStaticRouteRouteType = @"RouteType";
NSString *const kStaticRouteCode = @"Code";
NSString *const kStaticRouteLongName = @"LongName";


@interface StaticRoute ()

- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict;

@end

@implementation StaticRoute

@synthesize routeUrl = _routeUrl;
@synthesize operator = _operator;
@synthesize shortName = _shortName;
@synthesize routeType = _routeType;
@synthesize code = _code;
@synthesize longName = _longName;


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
            self.routeUrl = [self objectOrNilForKey:kStaticRouteRouteUrl fromDictionary:dict];
            self.operator = [self objectOrNilForKey:kStaticRouteOperator fromDictionary:dict];
            self.shortName = [self objectOrNilForKey:kStaticRouteShortName fromDictionary:dict];
            self.routeType = [self objectOrNilForKey:kStaticRouteRouteType fromDictionary:dict];
            self.code = [self objectOrNilForKey:kStaticRouteCode fromDictionary:dict];
            self.longName = [self objectOrNilForKey:kStaticRouteLongName fromDictionary:dict];

    }
    
    return self;
    
}

- (NSDictionary *)dictionaryRepresentation
{
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
    [mutableDict setValue:self.routeUrl forKey:kStaticRouteRouteUrl];
    [mutableDict setValue:self.operator forKey:kStaticRouteOperator];
    [mutableDict setValue:self.shortName forKey:kStaticRouteShortName];
    [mutableDict setValue:self.routeType forKey:kStaticRouteRouteType];
    [mutableDict setValue:self.code forKey:kStaticRouteCode];
    [mutableDict setValue:self.longName forKey:kStaticRouteLongName];

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

    self.routeUrl = [aDecoder decodeObjectForKey:kStaticRouteRouteUrl];
    self.operator = [aDecoder decodeObjectForKey:kStaticRouteOperator];
    self.shortName = [aDecoder decodeObjectForKey:kStaticRouteShortName];
    self.routeType = [aDecoder decodeObjectForKey:kStaticRouteRouteType];
    self.code = [aDecoder decodeObjectForKey:kStaticRouteCode];
    self.longName = [aDecoder decodeObjectForKey:kStaticRouteLongName];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{

    [aCoder encodeObject:_routeUrl forKey:kStaticRouteRouteUrl];
    [aCoder encodeObject:_operator forKey:kStaticRouteOperator];
    [aCoder encodeObject:_shortName forKey:kStaticRouteShortName];
    [aCoder encodeObject:_routeType forKey:kStaticRouteRouteType];
    [aCoder encodeObject:_code forKey:kStaticRouteCode];
    [aCoder encodeObject:_longName forKey:kStaticRouteLongName];
}

- (id)copyWithZone:(NSZone *)zone
{
    StaticRoute *copy = [[StaticRoute alloc] init];
    
    if (copy) {

        copy.routeUrl = [self.routeUrl copyWithZone:zone];
        copy.operator = [self.operator copyWithZone:zone];
        copy.shortName = [self.shortName copyWithZone:zone];
        copy.routeType = [self.routeType copyWithZone:zone];
        copy.code = [self.code copyWithZone:zone];
        copy.longName = [self.longName copyWithZone:zone];
    }
    
    return copy;
}


@end
