//
//  DigiItineraries.m
//
//  Created by Anteneh Sahledengel on 28/5/16
//  Copyright (c) 2016 shaby ltd. All rights reserved.
//

#import "DigiPlan.h"
#import "DigiLegs.h"
#import "EnumManager.h"


NSString *const kDigiItinerariesWalkDistance = @"walkDistance";
NSString *const kDigiItinerariesWalkTime = @"walkTime";
NSString *const kDigiItinerariesEndTime = @"endTime";
NSString *const kDigiItinerariesLegs = @"legs";
NSString *const kDigiItinerariesDuration = @"duration";
NSString *const kDigiItinerariesWaitingTime = @"waitingTime";
NSString *const kDigiItinerariesStartTime = @"startTime";


@interface DigiPlan ()

- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict;

@end

@implementation DigiPlan

@synthesize walkDistance = _walkDistance;
@synthesize walkTime = _walkTime;
@synthesize endTime = _endTime;
@synthesize legs = _legs;
@synthesize duration = _duration;
@synthesize waitingTime = _waitingTime;
@synthesize startTime = _startTime;


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
            self.walkDistance = [self objectOrNilForKey:kDigiItinerariesWalkDistance fromDictionary:dict];
            self.walkTime = [self objectOrNilForKey:kDigiItinerariesWalkTime fromDictionary:dict];
            self.endTime = [self objectOrNilForKey:kDigiItinerariesEndTime fromDictionary:dict];
    NSObject *receivedDigiLegs = [dict objectForKey:kDigiItinerariesLegs];
    NSMutableArray *parsedDigiLegs = [NSMutableArray array];
    if ([receivedDigiLegs isKindOfClass:[NSArray class]]) {
        for (NSDictionary *item in (NSArray *)receivedDigiLegs) {
            if ([item isKindOfClass:[NSDictionary class]]) {
                [parsedDigiLegs addObject:[DigiLegs modelObjectWithDictionary:item]];
            }
       }
    } else if ([receivedDigiLegs isKindOfClass:[NSDictionary class]]) {
       [parsedDigiLegs addObject:[DigiLegs modelObjectWithDictionary:(NSDictionary *)receivedDigiLegs]];
    }

    self.legs = [NSArray arrayWithArray:parsedDigiLegs];
            self.duration = [self objectOrNilForKey:kDigiItinerariesDuration fromDictionary:dict];
            self.waitingTime = [self objectOrNilForKey:kDigiItinerariesWaitingTime fromDictionary:dict];
            self.startTime = [self objectOrNilForKey:kDigiItinerariesStartTime fromDictionary:dict];

    }
    
    return self;
    
}

- (NSDictionary *)dictionaryRepresentation
{
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
    [mutableDict setValue:self.walkDistance forKey:kDigiItinerariesWalkDistance];
    [mutableDict setValue:self.walkTime forKey:kDigiItinerariesWalkTime];
    [mutableDict setValue:self.endTime forKey:kDigiItinerariesEndTime];
    NSMutableArray *tempArrayForLegs = [NSMutableArray array];
    for (NSObject *subArrayObject in self.legs) {
        if([subArrayObject respondsToSelector:@selector(dictionaryRepresentation)]) {
            // This class is a model object
            [tempArrayForLegs addObject:[subArrayObject performSelector:@selector(dictionaryRepresentation)]];
        } else {
            // Generic object
            [tempArrayForLegs addObject:subArrayObject];
        }
    }
    [mutableDict setValue:[NSArray arrayWithArray:tempArrayForLegs] forKey:kDigiItinerariesLegs];
    [mutableDict setValue:self.duration forKey:kDigiItinerariesDuration];
    [mutableDict setValue:self.waitingTime forKey:kDigiItinerariesWaitingTime];
    [mutableDict setValue:self.startTime forKey:kDigiItinerariesStartTime];

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

    self.walkDistance = [aDecoder decodeObjectForKey:kDigiItinerariesWalkDistance];
    self.walkTime = [aDecoder decodeObjectForKey:kDigiItinerariesWalkTime];
    self.endTime = [aDecoder decodeObjectForKey:kDigiItinerariesEndTime];
    self.legs = [aDecoder decodeObjectForKey:kDigiItinerariesLegs];
    self.duration = [aDecoder decodeObjectForKey:kDigiItinerariesDuration];
    self.waitingTime = [aDecoder decodeObjectForKey:kDigiItinerariesWaitingTime];
    self.startTime = [aDecoder decodeObjectForKey:kDigiItinerariesStartTime];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{

    [aCoder encodeObject:_walkDistance forKey:kDigiItinerariesWalkDistance];
    [aCoder encodeObject:_walkTime forKey:kDigiItinerariesWalkTime];
    [aCoder encodeObject:_endTime forKey:kDigiItinerariesEndTime];
    [aCoder encodeObject:_legs forKey:kDigiItinerariesLegs];
    [aCoder encodeObject:_duration forKey:kDigiItinerariesDuration];
    [aCoder encodeObject:_waitingTime forKey:kDigiItinerariesWaitingTime];
    [aCoder encodeObject:_startTime forKey:kDigiItinerariesStartTime];
}

- (id)copyWithZone:(NSZone *)zone
{
    DigiPlan *copy = [[DigiPlan alloc] init];
    
    if (copy) {

        copy.walkDistance = self.walkDistance;
        copy.walkTime = self.walkTime;
        copy.endTime = self.endTime;
        copy.legs = [self.legs copyWithZone:zone];
        copy.duration = self.duration;
        copy.waitingTime = self.waitingTime;
        copy.startTime = self.startTime;
    }
    
    return copy;
}

-(void)setLegs:(NSArray *)legs {
    _legs = legs;
    if (legs.count > 0) {
        for (int i = 0; i < legs.count; i++) {
            [legs[i] setLegOrder:i];
        }
    }
}

//Computed properties
-(NSNumber *)distance {
    if(!self.legs || self.legs.count == 0) return @0;
    
    double totalDistance = 0;
    for (DigiLegs *leg in self.legs) {
        totalDistance += [leg.distance doubleValue];
    }
    
    return [NSNumber numberWithDouble:totalDistance];
}

-(NSNumber *)numberOfNoneWalkLegs {
    if(!self.legs || self.legs.count == 0) return @0;
    
    int noneWalkLegs = 0;
    for (DigiLegs *leg in self.legs) {
        if (leg.legType != LegTypeWalk) {
            noneWalkLegs++;
        }
    }
    
    return [NSNumber numberWithInt:noneWalkLegs];
}

-(NSDate *)parsedStartTime {
    if (!_parsedStartTime) {
        double startTime = [self.startTime doubleValue]/1000;
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:startTime];
        if (date) _parsedStartTime = date;
    }
    
    return _parsedStartTime;
}

-(NSDate *)parsedEndTime {
    if (!_parsedEndTime) {
        double startTime = [self.endTime doubleValue]/1000;
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:startTime];
        if (date) _parsedEndTime = date;
    }
    
    return _parsedEndTime;
}

-(NSDate *)timeAtFirstStop {
    if(!self.legs || self.legs.count == 0) return self.parsedStartTime;
    
    for (DigiLegs *leg in self.legs) {
        if ([leg.transitLeg boolValue] || [leg.rentedBike boolValue]) {
            return leg.parsedStartTime;
        }
    }
    
    return self.parsedStartTime;
}

-(CLLocationCoordinate2D)startCoords {
    if (self.legs) {
        DigiLegs *firstLeg = [self.legs firstObject];
        return firstLeg.startCoords;
    }
    
    return kCLLocationCoordinate2DInvalid;
}

-(CLLocationCoordinate2D)destinationCoords {
    if (self.legs) {
        DigiLegs *lastLeg = [self.legs lastObject];
        return lastLeg.destinationCoords;
    }
    
    return kCLLocationCoordinate2DInvalid;
}

//Mapping

+(RKResponseDescriptor *)responseDiscriptorForPath:(NSString *)path {
    return [RKResponseDescriptor responseDescriptorWithMapping:[DigiPlan objectMapping]
                                                        method:RKRequestMethodAny
                                                   pathPattern:nil
                                                       keyPath:path
                                                   statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
}

+(RKObjectMapping *)objectMapping {
    RKObjectMapping* itiMapping = [RKObjectMapping mappingForClass:[DigiPlan class] ];
    [itiMapping addAttributeMappingsFromDictionary:@{
                                                      @"walkDistance" : @"walkDistance",
                                                      @"walkTime" : @"walkTime",
                                                      @"endTime" : @"endTime",
                                                      @"duration" : @"duration",
                                                      @"waitingTime" : @"waitingTime",
                                                      @"startTime" : @"startTime"
                                                      }];
    
    [itiMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"legs"
                                                                                toKeyPath:@"legs"
                                                                              withMapping:[DigiLegs objectMapping]]];
    

    
    return itiMapping;
}

@end
