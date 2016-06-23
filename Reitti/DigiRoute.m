//
//  DigiRoute.m
//
//  Created by Anteneh Sahledengel on 19/5/16
//  Copyright (c) 2016 shaby ltd. All rights reserved.
//

#import "DigiRoute.h"


NSString *const kDigiRouteType = @"type";
NSString *const kDigiRouteShortName = @"shortName";
NSString *const kDigiRouteLongName = @"longName";


@interface DigiRoute ()

- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict;

@end

@implementation DigiRoute

@synthesize type = _type;
@synthesize shortName = _shortName;
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
            self.type = [self objectOrNilForKey:kDigiRouteType fromDictionary:dict];
            self.shortName = [self objectOrNilForKey:kDigiRouteShortName fromDictionary:dict];
            self.longName = [self objectOrNilForKey:kDigiRouteLongName fromDictionary:dict];

    }
    
    return self;
    
}

- (NSDictionary *)dictionaryRepresentation
{
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
    [mutableDict setValue:self.type forKey:kDigiRouteType];
    [mutableDict setValue:self.shortName forKey:kDigiRouteShortName];
    [mutableDict setValue:self.longName forKey:kDigiRouteLongName];

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

    self.type = [aDecoder decodeObjectForKey:kDigiRouteType];
    self.shortName = [aDecoder decodeObjectForKey:kDigiRouteShortName];
    self.longName = [aDecoder decodeObjectForKey:kDigiRouteLongName];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{

    [aCoder encodeObject:_type forKey:kDigiRouteType];
    [aCoder encodeObject:_shortName forKey:kDigiRouteShortName];
    [aCoder encodeObject:_longName forKey:kDigiRouteLongName];
}

- (id)copyWithZone:(NSZone *)zone
{
    DigiRoute *copy = [[DigiRoute alloc] init];
    
    if (copy) {

        copy.type = [self.type copyWithZone:zone];
        copy.shortName = [self.shortName copyWithZone:zone];
        copy.longName = [self.longName copyWithZone:zone];
    }
    
    return copy;
}

+(RKResponseDescriptor *)responseDiscriptorForPath:(NSString *)path {
    
    
    return [RKResponseDescriptor responseDescriptorWithMapping:[DigiRoute objectMapping]
                                                        method:RKRequestMethodAny
                                                   pathPattern:nil
                                                       keyPath:path
                                                   statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
}

+(RKObjectMapping *)objectMapping {
    RKObjectMapping* routeMapping = [RKObjectMapping mappingForClass:[DigiRoute class] ];
    [routeMapping addAttributeMappingsFromDictionary:@{
                                                       @"type" : @"type",
                                                       @"shortName" : @"shortName",
                                                       @"longName"     : @"longName",
                                                       @"gtfsId"     : @"gtfsId"
                                                       }];
    return routeMapping;
}


@end
