//
//  ProductNames.m
//
//  Created by Anteneh Sahledengel on 2/7/15
//  Copyright (c) 2015 shaby ltd. All rights reserved.
//

#import "ProductNames.h"


NSString *const kProductNamesFi = @"fi";
NSString *const kProductNamesSv = @"sv";
NSString *const kProductNamesEn = @"en";


@interface ProductNames ()

- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict;

@end

@implementation ProductNames

@synthesize fi = _fi;
@synthesize sv = _sv;
@synthesize en = _en;


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
            self.fi = [self objectOrNilForKey:kProductNamesFi fromDictionary:dict];
            self.sv = [self objectOrNilForKey:kProductNamesSv fromDictionary:dict];
            self.en = [self objectOrNilForKey:kProductNamesEn fromDictionary:dict];

    }
    
    return self;
    
}

- (NSDictionary *)dictionaryRepresentation
{
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
    [mutableDict setValue:self.fi forKey:kProductNamesFi];
    [mutableDict setValue:self.sv forKey:kProductNamesSv];
    [mutableDict setValue:self.en forKey:kProductNamesEn];

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

    self.fi = [aDecoder decodeObjectForKey:kProductNamesFi];
    self.sv = [aDecoder decodeObjectForKey:kProductNamesSv];
    self.en = [aDecoder decodeObjectForKey:kProductNamesEn];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{

    [aCoder encodeObject:_fi forKey:kProductNamesFi];
    [aCoder encodeObject:_sv forKey:kProductNamesSv];
    [aCoder encodeObject:_en forKey:kProductNamesEn];
}

- (id)copyWithZone:(NSZone *)zone
{
    ProductNames *copy = [[ProductNames alloc] init];
    
    if (copy) {

        copy.fi = [self.fi copyWithZone:zone];
        copy.sv = [self.sv copyWithZone:zone];
        copy.en = [self.en copyWithZone:zone];
    }
    
    return copy;
}


@end
