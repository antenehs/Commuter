//
//  TicketNames.m
//
//  Created by Anteneh Sahledengel on 2/7/15
//  Copyright (c) 2015 shaby ltd. All rights reserved.
//

#import "TicketNames.h"


NSString *const kTicketNamesFi = @"fi";
NSString *const kTicketNamesSv = @"sv";
NSString *const kTicketNamesEn = @"en";


@interface TicketNames ()

- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict;

@end

@implementation TicketNames

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
            self.fi = [self objectOrNilForKey:kTicketNamesFi fromDictionary:dict];
            self.sv = [self objectOrNilForKey:kTicketNamesSv fromDictionary:dict];
            self.en = [self objectOrNilForKey:kTicketNamesEn fromDictionary:dict];

    }
    
    return self;
    
}

- (NSDictionary *)dictionaryRepresentation
{
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
    [mutableDict setValue:self.fi forKey:kTicketNamesFi];
    [mutableDict setValue:self.sv forKey:kTicketNamesSv];
    [mutableDict setValue:self.en forKey:kTicketNamesEn];

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

    self.fi = [aDecoder decodeObjectForKey:kTicketNamesFi];
    self.sv = [aDecoder decodeObjectForKey:kTicketNamesSv];
    self.en = [aDecoder decodeObjectForKey:kTicketNamesEn];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{

    [aCoder encodeObject:_fi forKey:kTicketNamesFi];
    [aCoder encodeObject:_sv forKey:kTicketNamesSv];
    [aCoder encodeObject:_en forKey:kTicketNamesEn];
}

- (id)copyWithZone:(NSZone *)zone
{
    TicketNames *copy = [[TicketNames alloc] init];
    
    if (copy) {

        copy.fi = [self.fi copyWithZone:zone];
        copy.sv = [self.sv copyWithZone:zone];
        copy.en = [self.en copyWithZone:zone];
    }
    
    return copy;
}


@end
