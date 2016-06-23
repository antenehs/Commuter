//
//  DigiPattern.m
//
//  Created by Anteneh Sahledengel on 28/5/16
//  Copyright (c) 2016 shaby ltd. All rights reserved.
//

#import "DigiPattern.h"
#import "DigiGeometry.h"


NSString *const kDigiPatternGeometry = @"geometry";


@interface DigiPattern ()

- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict;

@end

@implementation DigiPattern

@synthesize geometry = _geometry;


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
    NSObject *receivedDigiGeometry = [dict objectForKey:kDigiPatternGeometry];
    NSMutableArray *parsedDigiGeometry = [NSMutableArray array];
    if ([receivedDigiGeometry isKindOfClass:[NSArray class]]) {
        for (NSDictionary *item in (NSArray *)receivedDigiGeometry) {
            if ([item isKindOfClass:[NSDictionary class]]) {
                [parsedDigiGeometry addObject:[DigiGeometry modelObjectWithDictionary:item]];
            }
       }
    } else if ([receivedDigiGeometry isKindOfClass:[NSDictionary class]]) {
       [parsedDigiGeometry addObject:[DigiGeometry modelObjectWithDictionary:(NSDictionary *)receivedDigiGeometry]];
    }

    self.geometry = [NSArray arrayWithArray:parsedDigiGeometry];

    }
    
    return self;
    
}

- (NSDictionary *)dictionaryRepresentation
{
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
    NSMutableArray *tempArrayForGeometry = [NSMutableArray array];
    for (NSObject *subArrayObject in self.geometry) {
        if([subArrayObject respondsToSelector:@selector(dictionaryRepresentation)]) {
            // This class is a model object
            [tempArrayForGeometry addObject:[subArrayObject performSelector:@selector(dictionaryRepresentation)]];
        } else {
            // Generic object
            [tempArrayForGeometry addObject:subArrayObject];
        }
    }
    [mutableDict setValue:[NSArray arrayWithArray:tempArrayForGeometry] forKey:kDigiPatternGeometry];

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

    self.geometry = [aDecoder decodeObjectForKey:kDigiPatternGeometry];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{

    [aCoder encodeObject:_geometry forKey:kDigiPatternGeometry];
}

- (id)copyWithZone:(NSZone *)zone
{
    DigiPattern *copy = [[DigiPattern alloc] init];
    
    if (copy) {

        copy.geometry = [self.geometry copyWithZone:zone];
    }
    
    return copy;
}

+(RKResponseDescriptor *)responseDiscriptorForPath:(NSString *)path {
    return [RKResponseDescriptor responseDescriptorWithMapping:[DigiPattern objectMapping]
                                                        method:RKRequestMethodAny
                                                   pathPattern:nil
                                                       keyPath:path
                                                   statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
}

+(RKObjectMapping *)objectMapping {
    RKObjectMapping* patternMapping = [RKObjectMapping mappingForClass:[DigiPattern class] ];
    
    [patternMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"geometry"
                                                                                   toKeyPath:@"geometry"
                                                                                 withMapping:[DigiGeometry objectMapping]]];
    
    return patternMapping;
}


@end
