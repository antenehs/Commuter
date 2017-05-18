//
//  DigiTrip.m
//
//  Created by Anteneh Sahledengel on 19/5/16
//  Copyright (c) 2016 shaby ltd. All rights reserved.
//

#import "DigiTrip.h"
#import "DigiRoute.h"


NSString *const kDigiTripRoute = @"route";
NSString *const kDigiTripTripHeadsign = @"tripHeadsign";


@interface DigiTrip ()

- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict;

@end

@implementation DigiTrip

@synthesize route = _route;
@synthesize tripHeadsign = _tripHeadsign;


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
            self.route = [DigiRoute modelObjectWithDictionary:[dict objectForKey:kDigiTripRoute]];
            self.tripHeadsign = [self objectOrNilForKey:kDigiTripTripHeadsign fromDictionary:dict];

    }
    
    return self;
    
}

- (NSDictionary *)dictionaryRepresentation
{
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
    [mutableDict setValue:[self.route dictionaryRepresentation] forKey:kDigiTripRoute];
    [mutableDict setValue:self.tripHeadsign forKey:kDigiTripTripHeadsign];

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

    self.route = [aDecoder decodeObjectForKey:kDigiTripRoute];
    self.tripHeadsign = [aDecoder decodeObjectForKey:kDigiTripTripHeadsign];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{

    [aCoder encodeObject:_route forKey:kDigiTripRoute];
    [aCoder encodeObject:_tripHeadsign forKey:kDigiTripTripHeadsign];
}

- (id)copyWithZone:(NSZone *)zone
{
    DigiTrip *copy = [[DigiTrip alloc] init];
    
    if (copy) {

        copy.route = [self.route copyWithZone:zone];
        copy.tripHeadsign = [self.tripHeadsign copyWithZone:zone];
    }
    
    return copy;
}

//+(RKResponseDescriptor *)responseDiscriptorForPath:(NSString *)path {
//    return [RKResponseDescriptor responseDescriptorWithMapping:[DigiTrip objectMapping]
//                                                        method:RKRequestMethodAny
//                                                   pathPattern:nil
//                                                       keyPath:path
//                                                   statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
//}
//
//+(RKObjectMapping *)objectMapping {
//    RKObjectMapping* tripMapping = [RKObjectMapping mappingForClass:[DigiTrip class] ];
//    [tripMapping addAttributeMappingsFromDictionary:@{
//                                                      @"tripHeadsign" : @"tripHeadsign"
//                                                      }];
//    
//    [tripMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"route"
//                                                                                toKeyPath:@"route"
//                                                                              withMapping:[DigiRoute objectMapping]]];
//    
//    [tripMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"pattern"
//                                                                                toKeyPath:@"pattern"
//                                                                              withMapping:[DigiPattern objectMapping]]];
//    
//    return tripMapping;
//}

+(MappingDescriptor *)mappingDescriptorForPath:(NSString *)path {
    MappingRelationShip *routeRelationShip = [MappingRelationShip relationShipFromKeyPath:@"route"
                                                                               toKeyPath:@"route"
                                                                        withMappingClass:[DigiRoute class]];
    
    MappingRelationShip *patternRelationShip = [MappingRelationShip relationShipFromKeyPath:@"pattern"
                                                                                toKeyPath:@"pattern"
                                                                         withMappingClass:[DigiPattern class]];
    
    return [MappingDescriptor descriptorFromPath:path forClass:[self class]
                           withMappingDictionary:@{ @"tripHeadsign" : @"tripHeadsign" }
                                andRelationShips:@[routeRelationShip, patternRelationShip]];
}

@end
