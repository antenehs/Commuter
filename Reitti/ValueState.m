//
//  ValueState.m
//
//  Created by Anteneh Sahledengel on 2/7/15
//  Copyright (c) 2015 shaby ltd. All rights reserved.
//

#import "ValueState.h"


NSString *const kValueStateState = @"State";
NSString *const kValueStateStateExplanationUIField = @"StateExplanationUIField";
NSString *const kValueStateStateImageFilenameUIField = @"StateImageFilenameUIField";


@interface ValueState ()

- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict;

@end

@implementation ValueState

@synthesize state = _state;
@synthesize stateExplanationUIField = _stateExplanationUIField;
@synthesize stateImageFilenameUIField = _stateImageFilenameUIField;


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
            self.state = [[self objectOrNilForKey:kValueStateState fromDictionary:dict] doubleValue];
            self.stateExplanationUIField = [self objectOrNilForKey:kValueStateStateExplanationUIField fromDictionary:dict];
            self.stateImageFilenameUIField = [self objectOrNilForKey:kValueStateStateImageFilenameUIField fromDictionary:dict];

    }
    
    return self;
    
}

- (NSDictionary *)dictionaryRepresentation
{
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
    [mutableDict setValue:[NSNumber numberWithDouble:self.state] forKey:kValueStateState];
    [mutableDict setValue:self.stateExplanationUIField forKey:kValueStateStateExplanationUIField];
    [mutableDict setValue:self.stateImageFilenameUIField forKey:kValueStateStateImageFilenameUIField];

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

    self.state = [aDecoder decodeDoubleForKey:kValueStateState];
    self.stateExplanationUIField = [aDecoder decodeObjectForKey:kValueStateStateExplanationUIField];
    self.stateImageFilenameUIField = [aDecoder decodeObjectForKey:kValueStateStateImageFilenameUIField];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{

    [aCoder encodeDouble:_state forKey:kValueStateState];
    [aCoder encodeObject:_stateExplanationUIField forKey:kValueStateStateExplanationUIField];
    [aCoder encodeObject:_stateImageFilenameUIField forKey:kValueStateStateImageFilenameUIField];
}

- (id)copyWithZone:(NSZone *)zone
{
    ValueState *copy = [[ValueState alloc] init];
    
    if (copy) {

        copy.state = self.state;
        copy.stateExplanationUIField = [self.stateExplanationUIField copyWithZone:zone];
        copy.stateImageFilenameUIField = [self.stateImageFilenameUIField copyWithZone:zone];
    }
    
    return copy;
}


@end
