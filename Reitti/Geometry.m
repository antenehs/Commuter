//
//  Geometry.m
//
//  Created by Anteneh Sahledengel on 14/5/15
//  Copyright (c) 2015 shaby ltd. All rights reserved.
//

#import "Geometry.h"


NSString *const kGeometryType = @"type";
NSString *const kGeometryCoordinates = @"coordinates";


@interface Geometry ()

- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict;

@end

@implementation Geometry

@synthesize type = _type;
@synthesize coordinates = _coordinates;

-(NSString *)coordString {
    
    NSNumber *longitude = [self.coordinates objectAtIndex:0];
    NSNumber *latitude = [self.coordinates objectAtIndex:1];
    
    return [NSString stringWithFormat:@"%@,%@", longitude, latitude];
}

#pragma mark - Initialization and factory methods
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
            self.type = [self objectOrNilForKey:kGeometryType fromDictionary:dict];
            self.coordinates = [self objectOrNilForKey:kGeometryCoordinates fromDictionary:dict];

    }
    
    return self;
    
}

- (NSDictionary *)dictionaryRepresentation
{
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
    [mutableDict setValue:self.type forKey:kGeometryType];
    NSMutableArray *tempArrayForCoordinates = [NSMutableArray array];
    for (NSObject *subArrayObject in self.coordinates) {
        if([subArrayObject respondsToSelector:@selector(dictionaryRepresentation)]) {
            // This class is a model object
            [tempArrayForCoordinates addObject:[subArrayObject performSelector:@selector(dictionaryRepresentation)]];
        } else {
            // Generic object
            [tempArrayForCoordinates addObject:subArrayObject];
        }
    }
    [mutableDict setValue:[NSArray arrayWithArray:tempArrayForCoordinates] forKey:kGeometryCoordinates];

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

    self.type = [aDecoder decodeObjectForKey:kGeometryType];
    self.coordinates = [aDecoder decodeObjectForKey:kGeometryCoordinates];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{

    [aCoder encodeObject:_type forKey:kGeometryType];
    [aCoder encodeObject:_coordinates forKey:kGeometryCoordinates];
}

- (id)copyWithZone:(NSZone *)zone
{
    Geometry *copy = [[Geometry alloc] init];
    
    if (copy) {

        copy.type = [self.type copyWithZone:zone];
        copy.coordinates = [self.coordinates copyWithZone:zone];
    }
    
    return copy;
}

#pragma mark - Mappable protocol implemention

#ifndef APPLE_WATCH
+(RKResponseDescriptor *)responseDiscriptorForPath:(NSString *)path {
    return [RKResponseDescriptor responseDescriptorWithMapping:[Geometry objectMapping]
                                                        method:RKRequestMethodAny
                                                   pathPattern:nil
                                                       keyPath:path
                                                   statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
}

+(RKObjectMapping *)objectMapping {
    RKObjectMapping* geocodeMapping = [RKObjectMapping mappingForClass:[Geometry class] ];
    [geocodeMapping addAttributeMappingsFromDictionary:@{
                                                         @"type" : @"type",
                                                         @"coordinates" : @"coordinates"
                                                         }];
    
    return geocodeMapping;
}
#endif

@end
