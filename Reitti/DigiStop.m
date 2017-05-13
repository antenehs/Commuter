//
//  Stops.m
//
//  Created by Anteneh Sahledengel on 19/5/16
//  Copyright (c) 2016 shaby ltd. All rights reserved.
//

#import "DigiStop.h"
#import "DigiRoute.h"
#import "DigiStoptime.h"

NSString *const kStopsRoutes = @"routes";
NSString *const kStopsStoptimes = @"stoptimes";

@interface DigiStop ()

- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict;

@end

@implementation DigiStop

@synthesize routes = _routes;
@synthesize stoptimes = _stoptimes;


+ (instancetype)modelObjectWithDictionary:(NSDictionary *)dict
{
    return [[self alloc] initWithDictionary:dict];
}

- (instancetype)initWithDictionary:(NSDictionary *)dict
{
    self = [super initWithDictionary:dict];
    
    // This check serves to make sure that a non-NSDictionary object
    // passed into the model class doesn't break the parsing.
    if(self && [dict isKindOfClass:[NSDictionary class]]) {
        NSObject *receivedRoutes = [dict objectForKey:kStopsRoutes];
        NSMutableArray *parsedRoutes = [NSMutableArray array];
        if ([receivedRoutes isKindOfClass:[NSArray class]]) {
            for (NSDictionary *item in (NSArray *)receivedRoutes) {
                if ([item isKindOfClass:[NSDictionary class]]) {
                    [parsedRoutes addObject:[DigiRoute modelObjectWithDictionary:item]];
                }
            }
        } else if ([receivedRoutes isKindOfClass:[NSDictionary class]]) {
            [parsedRoutes addObject:[DigiRoute modelObjectWithDictionary:(NSDictionary *)receivedRoutes]];
        }
        
        self.routes = [NSArray arrayWithArray:parsedRoutes];
        
        NSObject *receivedStoptimes = [dict objectForKey:kStopsStoptimes];
        NSMutableArray *parsedStoptimes = [NSMutableArray array];
        if ([receivedStoptimes isKindOfClass:[NSArray class]]) {
            for (NSDictionary *item in (NSArray *)receivedStoptimes) {
                if ([item isKindOfClass:[NSDictionary class]]) {
                    [parsedStoptimes addObject:[DigiStoptime modelObjectWithDictionary:item]];
                }
            }
        } else if ([receivedStoptimes isKindOfClass:[NSDictionary class]]) {
            [parsedStoptimes addObject:[DigiStoptime modelObjectWithDictionary:(NSDictionary *)receivedStoptimes]];
        }
        
        self.stoptimes = [NSArray arrayWithArray:parsedStoptimes];
        
    }
    
    return self;
    
}

- (NSDictionary *)dictionaryRepresentation
{
    NSMutableDictionary *mutableDict = [[super dictionaryRepresentation] mutableCopy];
    
    NSMutableArray *tempArrayForRoutes = [NSMutableArray array];
    for (NSObject *subArrayObject in self.routes) {
        if([subArrayObject respondsToSelector:@selector(dictionaryRepresentation)]) {
            // This class is a model object
            [tempArrayForRoutes addObject:[subArrayObject performSelector:@selector(dictionaryRepresentation)]];
        } else {
            // Generic object
            [tempArrayForRoutes addObject:subArrayObject];
        }
    }
    [mutableDict setValue:[NSArray arrayWithArray:tempArrayForRoutes] forKey:kStopsRoutes];

    NSMutableArray *tempArrayForStoptimes = [NSMutableArray array];
    for (NSObject *subArrayObject in self.stoptimes) {
        if([subArrayObject respondsToSelector:@selector(dictionaryRepresentation)]) {
            // This class is a model object
            [tempArrayForStoptimes addObject:[subArrayObject performSelector:@selector(dictionaryRepresentation)]];
        } else {
            // Generic object
            [tempArrayForStoptimes addObject:subArrayObject];
        }
    }
    [mutableDict setValue:[NSArray arrayWithArray:tempArrayForStoptimes] forKey:kStopsStoptimes];
    
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
    self = [super initWithCoder:aDecoder];
    
    self.routes = [aDecoder decodeObjectForKey:kStopsRoutes];
    self.stoptimes = [aDecoder decodeObjectForKey:kStopsStoptimes];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [super encodeWithCoder:aCoder];

    [aCoder encodeObject:_routes forKey:kStopsRoutes];
    [aCoder encodeObject:_stoptimes forKey:kStopsStoptimes];
}

- (id)copyWithZone:(NSZone *)zone
{
    DigiStop *copy = [super copyWithZone:zone];
    
    if (copy) {
        copy.routes = [self.routes copyWithZone:zone];
        copy.stoptimes = [self.stoptimes copyWithZone:zone];
    }
    
    return copy;
}

#pragma mark - computed properties
-(StopType)stopType {
    if (_stopType == StopTypeUnknown) {
        if (self.routes && self.routes.count > 0) {
            DigiRoute *firstRoute = self.routes.firstObject;
            _stopType = [EnumManager stopTypeFromLineType:firstRoute.lineType];
        } else {
            _stopType = StopTypeBus;
        }
    }
    
    return _stopType;
}

#pragma mark - Object mapping
+(RKResponseDescriptor *)responseDiscriptorForPath:(NSString *)path {
    return [RKResponseDescriptor responseDescriptorWithMapping:[DigiStop objectMapping]
                                                        method:RKRequestMethodAny
                                                   pathPattern:nil
                                                       keyPath:path
                                                   statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
}

+(RKObjectMapping *)objectMapping {
    RKObjectMapping* stopMapping = [RKObjectMapping mappingForClass:[DigiStop class] ];
    [stopMapping addAttributeMappingsFromDictionary:[DigiStopShort mappingDictionary]];
    
    [stopMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"stoptimesWithoutPatterns"
                                                                                    toKeyPath:@"stoptimes"
                                                                                  withMapping:[DigiStoptime objectMapping]]];
    
    [stopMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"routes"
                                                                                toKeyPath:@"routes"
                                                                              withMapping:[DigiRoute objectMapping]]];
    
    return stopMapping;
}

@end
