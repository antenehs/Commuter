//
//  PeriodProductState.m
//
//  Created by Anteneh Sahledengel on 2/7/15
//  Copyright (c) 2015 shaby ltd. All rights reserved.
//

#import "PeriodProductState.h"
#import "ProductNames.h"


NSString *const kPeriodProductStateRemainingTripSaldo = @"RemainingTripSaldo";
NSString *const kPeriodProductStateStartDate = @"StartDate";
NSString *const kPeriodProductStateExpiringDate = @"ExpiringDate";
NSString *const kPeriodProductStateState = @"State";
NSString *const kPeriodProductStateProductNames = @"ProductNames";
NSString *const kPeriodProductStateIsSerieTicketAndTripSaldoNonZero = @"IsSerieTicketAndTripSaldoNonZero";
NSString *const kPeriodProductStateProductName = @"ProductName";
NSString *const kPeriodProductStateStateExplanationUIField = @"StateExplanationUIField";
NSString *const kPeriodProductStateProductCode = @"ProductCode";
NSString *const kPeriodProductStateBoughtDays = @"BoughtDays";
NSString *const kPeriodProductStateStateImageFilenameUIField = @"StateImageFilenameUIField";
NSString *const kPeriodProductStateExpiringDateStringUIField = @"ExpiringDateStringUIField";


@interface PeriodProductState ()

- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict;

@end

@implementation PeriodProductState

@synthesize remainingTripSaldo = _remainingTripSaldo;
@synthesize startDate = _startDate;
@synthesize expiringDate = _expiringDate;
@synthesize state = _state;
@synthesize productNames = _productNames;
@synthesize isSerieTicketAndTripSaldoNonZero = _isSerieTicketAndTripSaldoNonZero;
@synthesize productName = _productName;
@synthesize stateExplanationUIField = _stateExplanationUIField;
@synthesize productCode = _productCode;
@synthesize boughtDays = _boughtDays;
@synthesize stateImageFilenameUIField = _stateImageFilenameUIField;
@synthesize expiringDateStringUIField = _expiringDateStringUIField;


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
            self.remainingTripSaldo = [[self objectOrNilForKey:kPeriodProductStateRemainingTripSaldo fromDictionary:dict] doubleValue];
            self.startDate = [self objectOrNilForKey:kPeriodProductStateStartDate fromDictionary:dict];
            self.expiringDate = [self objectOrNilForKey:kPeriodProductStateExpiringDate fromDictionary:dict];
            self.state = [[self objectOrNilForKey:kPeriodProductStateState fromDictionary:dict] doubleValue];
            self.productNames = [ProductNames modelObjectWithDictionary:[dict objectForKey:kPeriodProductStateProductNames]];
            self.isSerieTicketAndTripSaldoNonZero = [[self objectOrNilForKey:kPeriodProductStateIsSerieTicketAndTripSaldoNonZero fromDictionary:dict] boolValue];
            self.productName = [self objectOrNilForKey:kPeriodProductStateProductName fromDictionary:dict];
            self.stateExplanationUIField = [self objectOrNilForKey:kPeriodProductStateStateExplanationUIField fromDictionary:dict];
            self.productCode = [[self objectOrNilForKey:kPeriodProductStateProductCode fromDictionary:dict] doubleValue];
            self.boughtDays = [[self objectOrNilForKey:kPeriodProductStateBoughtDays fromDictionary:dict] doubleValue];
            self.stateImageFilenameUIField = [self objectOrNilForKey:kPeriodProductStateStateImageFilenameUIField fromDictionary:dict];
            self.expiringDateStringUIField = [self objectOrNilForKey:kPeriodProductStateExpiringDateStringUIField fromDictionary:dict];

    }
    
    return self;
    
}

- (NSDictionary *)dictionaryRepresentation
{
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
    [mutableDict setValue:[NSNumber numberWithDouble:self.remainingTripSaldo] forKey:kPeriodProductStateRemainingTripSaldo];
    [mutableDict setValue:self.startDate forKey:kPeriodProductStateStartDate];
    [mutableDict setValue:self.expiringDate forKey:kPeriodProductStateExpiringDate];
    [mutableDict setValue:[NSNumber numberWithDouble:self.state] forKey:kPeriodProductStateState];
    [mutableDict setValue:[self.productNames dictionaryRepresentation] forKey:kPeriodProductStateProductNames];
    [mutableDict setValue:[NSNumber numberWithBool:self.isSerieTicketAndTripSaldoNonZero] forKey:kPeriodProductStateIsSerieTicketAndTripSaldoNonZero];
    [mutableDict setValue:self.productName forKey:kPeriodProductStateProductName];
    [mutableDict setValue:self.stateExplanationUIField forKey:kPeriodProductStateStateExplanationUIField];
    [mutableDict setValue:[NSNumber numberWithDouble:self.productCode] forKey:kPeriodProductStateProductCode];
    [mutableDict setValue:[NSNumber numberWithDouble:self.boughtDays] forKey:kPeriodProductStateBoughtDays];
    [mutableDict setValue:self.stateImageFilenameUIField forKey:kPeriodProductStateStateImageFilenameUIField];
    [mutableDict setValue:self.expiringDateStringUIField forKey:kPeriodProductStateExpiringDateStringUIField];

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

    self.remainingTripSaldo = [aDecoder decodeDoubleForKey:kPeriodProductStateRemainingTripSaldo];
    self.startDate = [aDecoder decodeObjectForKey:kPeriodProductStateStartDate];
    self.expiringDate = [aDecoder decodeObjectForKey:kPeriodProductStateExpiringDate];
    self.state = [aDecoder decodeDoubleForKey:kPeriodProductStateState];
    self.productNames = [aDecoder decodeObjectForKey:kPeriodProductStateProductNames];
    self.isSerieTicketAndTripSaldoNonZero = [aDecoder decodeBoolForKey:kPeriodProductStateIsSerieTicketAndTripSaldoNonZero];
    self.productName = [aDecoder decodeObjectForKey:kPeriodProductStateProductName];
    self.stateExplanationUIField = [aDecoder decodeObjectForKey:kPeriodProductStateStateExplanationUIField];
    self.productCode = [aDecoder decodeDoubleForKey:kPeriodProductStateProductCode];
    self.boughtDays = [aDecoder decodeDoubleForKey:kPeriodProductStateBoughtDays];
    self.stateImageFilenameUIField = [aDecoder decodeObjectForKey:kPeriodProductStateStateImageFilenameUIField];
    self.expiringDateStringUIField = [aDecoder decodeObjectForKey:kPeriodProductStateExpiringDateStringUIField];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{

    [aCoder encodeDouble:_remainingTripSaldo forKey:kPeriodProductStateRemainingTripSaldo];
    [aCoder encodeObject:_startDate forKey:kPeriodProductStateStartDate];
    [aCoder encodeObject:_expiringDate forKey:kPeriodProductStateExpiringDate];
    [aCoder encodeDouble:_state forKey:kPeriodProductStateState];
    [aCoder encodeObject:_productNames forKey:kPeriodProductStateProductNames];
    [aCoder encodeBool:_isSerieTicketAndTripSaldoNonZero forKey:kPeriodProductStateIsSerieTicketAndTripSaldoNonZero];
    [aCoder encodeObject:_productName forKey:kPeriodProductStateProductName];
    [aCoder encodeObject:_stateExplanationUIField forKey:kPeriodProductStateStateExplanationUIField];
    [aCoder encodeDouble:_productCode forKey:kPeriodProductStateProductCode];
    [aCoder encodeDouble:_boughtDays forKey:kPeriodProductStateBoughtDays];
    [aCoder encodeObject:_stateImageFilenameUIField forKey:kPeriodProductStateStateImageFilenameUIField];
    [aCoder encodeObject:_expiringDateStringUIField forKey:kPeriodProductStateExpiringDateStringUIField];
}

- (id)copyWithZone:(NSZone *)zone
{
    PeriodProductState *copy = [[PeriodProductState alloc] init];
    
    if (copy) {

        copy.remainingTripSaldo = self.remainingTripSaldo;
        copy.startDate = [self.startDate copyWithZone:zone];
        copy.expiringDate = [self.expiringDate copyWithZone:zone];
        copy.state = self.state;
        copy.productNames = [self.productNames copyWithZone:zone];
        copy.isSerieTicketAndTripSaldoNonZero = self.isSerieTicketAndTripSaldoNonZero;
        copy.productName = [self.productName copyWithZone:zone];
        copy.productCode = self.productCode;
        copy.boughtDays = self.boughtDays;
    }
    
    return copy;
}


@end
