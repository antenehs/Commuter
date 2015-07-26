//
//  TravelCard.m
//
//  Created by Anteneh Sahledengel on 2/7/15
//  Copyright (c) 2015 shaby ltd. All rights reserved.
//

#import "TravelCard.h"
#import "ValueState.h"
#import "PeriodProductState.h"
#import "Value.h"
#import "Tickets.h"
#import "Distance.h"
#import "InactiveReasons.h"


NSString *const kTravelCardAuthClientsName = @"AuthClientsName";
NSString *const kTravelCardInactiveReason = @"InactiveReason";
NSString *const kTravelCardValueState = @"ValueState";
NSString *const kTravelCardWaitingBalance = @"WaitingBalance";
NSString *const kTravelCardId = @"id";
NSString *const kTravelCardHasTslSupport = @"HasTslSupport";
NSString *const kTravelCardIsForbidden = @"IsForbidden";
NSString *const kTravelCardBalanceUpdateDate = @"BalanceUpdateDate";
NSString *const kTravelCardIsUsed = @"IsUsed";
NSString *const kTravelCardChildCardsList = @"ChildCardsList";
NSString *const kTravelCardMaxPeriodProductsNumber = @"MaxPeriodProductsNumber";
NSString *const kTravelCardCardID = @"CardID";
NSString *const kTravelCardCardExpiryDate = @"CardExpiryDate";
NSString *const kTravelCardTsltickets = @"tsltickets";
NSString *const kTravelCardPeriodProductState = @"PeriodProductState";
NSString *const kTravelCardValue = @"value";
NSString *const kTravelCardTickets = @"tickets";
NSString *const kTravelCardPendingProducts = @"PendingProducts";
NSString *const kTravelCardDistance = @"distance";
NSString *const kTravelCardIsParentCard = @"IsParentCard";
NSString *const kTravelCardName = @"name";
NSString *const kTravelCardIsStrogAuthCard = @"IsStrogAuthCard";
NSString *const kTravelCardUserID = @"UserID";
NSString *const kTravelCardIsAuthorized = @"IsAuthorized";
NSString *const kTravelCardAuthValidUntil = @"AuthValidUntil";
NSString *const kTravelCardRemainingMoney = @"RemainingMoney";
NSString *const kTravelCardPendingProductsAmount = @"PendingProductsAmount";
NSString *const kTravelCardWaitingProducts = @"WaitingProducts";
NSString *const kTravelCardIsValidAuthorization = @"IsValidAuthorization";
NSString *const kTravelCardBoughtPeriodProductsAmount = @"BoughtPeriodProductsAmount";
NSString *const kTravelCardWaitingBalancePurchaseDateTime = @"WaitingBalancePurchaseDateTime";
NSString *const kTravelCardUserGroupExpireDate = @"UserGroupExpireDate";
NSString *const kTravelCardIsActive = @"IsActive";
NSString *const kTravelCardInactiveReasons = @"InactiveReasons";
NSString *const kTravelCardAuthValidFrom = @"AuthValidFrom";
NSString *const kTravelCardWaitingProductsAmount = @"WaitingProductsAmount";
NSString *const kTravelCardType = @"Type";


@interface TravelCard ()

- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict;

@end

@implementation TravelCard

@synthesize authClientsName = _authClientsName;
@synthesize inactiveReason = _inactiveReason;
@synthesize valueState = _valueState;
@synthesize waitingBalance = _waitingBalance;
@synthesize internalBaseClassIdentifier = _internalBaseClassIdentifier;
@synthesize hasTslSupport = _hasTslSupport;
@synthesize isForbidden = _isForbidden;
@synthesize balanceUpdateDate = _balanceUpdateDate;
@synthesize isUsed = _isUsed;
@synthesize childCardsList = _childCardsList;
@synthesize maxPeriodProductsNumber = _maxPeriodProductsNumber;
@synthesize cardID = _cardID;
@synthesize cardExpiryDate = _cardExpiryDate;
@synthesize tsltickets = _tsltickets;
@synthesize periodProductState = _periodProductState;
@synthesize value = _value;
@synthesize tickets = _tickets;
@synthesize pendingProducts = _pendingProducts;
@synthesize distance = _distance;
@synthesize isParentCard = _isParentCard;
@synthesize name = _name;
@synthesize isStrogAuthCard = _isStrogAuthCard;
@synthesize userID = _userID;
@synthesize isAuthorized = _isAuthorized;
@synthesize authValidUntil = _authValidUntil;
@synthesize remainingMoney = _remainingMoney;
@synthesize pendingProductsAmount = _pendingProductsAmount;
@synthesize waitingProducts = _waitingProducts;
@synthesize isValidAuthorization = _isValidAuthorization;
@synthesize boughtPeriodProductsAmount = _boughtPeriodProductsAmount;
@synthesize waitingBalancePurchaseDateTime = _waitingBalancePurchaseDateTime;
@synthesize userGroupExpireDate = _userGroupExpireDate;
@synthesize isActive = _isActive;
@synthesize inactiveReasons = _inactiveReasons;
@synthesize authValidFrom = _authValidFrom;
@synthesize waitingProductsAmount = _waitingProductsAmount;
@synthesize type = _type;


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
            self.authClientsName = [self objectOrNilForKey:kTravelCardAuthClientsName fromDictionary:dict];
            self.inactiveReason = [self objectOrNilForKey:kTravelCardInactiveReason fromDictionary:dict];
            self.valueState = [ValueState modelObjectWithDictionary:[dict objectForKey:kTravelCardValueState]];
            self.waitingBalance = [[self objectOrNilForKey:kTravelCardWaitingBalance fromDictionary:dict] doubleValue];
            self.internalBaseClassIdentifier = [self objectOrNilForKey:kTravelCardId fromDictionary:dict];
            self.hasTslSupport = [[self objectOrNilForKey:kTravelCardHasTslSupport fromDictionary:dict] boolValue];
            self.isForbidden = [[self objectOrNilForKey:kTravelCardIsForbidden fromDictionary:dict] boolValue];
            self.balanceUpdateDate = [self objectOrNilForKey:kTravelCardBalanceUpdateDate fromDictionary:dict];
            self.isUsed = [[self objectOrNilForKey:kTravelCardIsUsed fromDictionary:dict] boolValue];
            self.childCardsList = [self objectOrNilForKey:kTravelCardChildCardsList fromDictionary:dict];
            self.maxPeriodProductsNumber = [[self objectOrNilForKey:kTravelCardMaxPeriodProductsNumber fromDictionary:dict] doubleValue];
            self.cardID = [self objectOrNilForKey:kTravelCardCardID fromDictionary:dict];
            self.cardExpiryDate = [self objectOrNilForKey:kTravelCardCardExpiryDate fromDictionary:dict];
            self.tsltickets = [self objectOrNilForKey:kTravelCardTsltickets fromDictionary:dict];
            self.periodProductState = [PeriodProductState modelObjectWithDictionary:[dict objectForKey:kTravelCardPeriodProductState]];
            self.value = [Value modelObjectWithDictionary:[dict objectForKey:kTravelCardValue]];
    NSObject *receivedTickets = [dict objectForKey:kTravelCardTickets];
    NSMutableArray *parsedTickets = [NSMutableArray array];
    if ([receivedTickets isKindOfClass:[NSArray class]]) {
        for (NSDictionary *item in (NSArray *)receivedTickets) {
            if ([item isKindOfClass:[NSDictionary class]]) {
                [parsedTickets addObject:[Tickets modelObjectWithDictionary:item]];
            }
       }
    } else if ([receivedTickets isKindOfClass:[NSDictionary class]]) {
       [parsedTickets addObject:[Tickets modelObjectWithDictionary:(NSDictionary *)receivedTickets]];
    }

    self.tickets = [NSArray arrayWithArray:parsedTickets];
            self.pendingProducts = [self objectOrNilForKey:kTravelCardPendingProducts fromDictionary:dict];
            self.distance = [Distance modelObjectWithDictionary:[dict objectForKey:kTravelCardDistance]];
            self.isParentCard = [[self objectOrNilForKey:kTravelCardIsParentCard fromDictionary:dict] boolValue];
            self.name = [self objectOrNilForKey:kTravelCardName fromDictionary:dict];
            self.isStrogAuthCard = [[self objectOrNilForKey:kTravelCardIsStrogAuthCard fromDictionary:dict] boolValue];
            self.userID = [self objectOrNilForKey:kTravelCardUserID fromDictionary:dict];
            self.isAuthorized = [[self objectOrNilForKey:kTravelCardIsAuthorized fromDictionary:dict] boolValue];
            self.authValidUntil = [self objectOrNilForKey:kTravelCardAuthValidUntil fromDictionary:dict];
            self.remainingMoney = [[self objectOrNilForKey:kTravelCardRemainingMoney fromDictionary:dict] doubleValue];
            self.pendingProductsAmount = [[self objectOrNilForKey:kTravelCardPendingProductsAmount fromDictionary:dict] doubleValue];
            self.waitingProducts = [self objectOrNilForKey:kTravelCardWaitingProducts fromDictionary:dict];
            self.isValidAuthorization = [[self objectOrNilForKey:kTravelCardIsValidAuthorization fromDictionary:dict] boolValue];
            self.boughtPeriodProductsAmount = [[self objectOrNilForKey:kTravelCardBoughtPeriodProductsAmount fromDictionary:dict] doubleValue];
            self.waitingBalancePurchaseDateTime = [self objectOrNilForKey:kTravelCardWaitingBalancePurchaseDateTime fromDictionary:dict];
            self.userGroupExpireDate = [self objectOrNilForKey:kTravelCardUserGroupExpireDate fromDictionary:dict];
            self.isActive = [[self objectOrNilForKey:kTravelCardIsActive fromDictionary:dict] boolValue];
            self.inactiveReasons = [InactiveReasons modelObjectWithDictionary:[dict objectForKey:kTravelCardInactiveReasons]];
            self.authValidFrom = [self objectOrNilForKey:kTravelCardAuthValidFrom fromDictionary:dict];
            self.waitingProductsAmount = [[self objectOrNilForKey:kTravelCardWaitingProductsAmount fromDictionary:dict] doubleValue];
            self.type = [[self objectOrNilForKey:kTravelCardType fromDictionary:dict] doubleValue];

    }
    
    return self;
    
}

- (NSDictionary *)dictionaryRepresentation
{
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
    [mutableDict setValue:self.authClientsName forKey:kTravelCardAuthClientsName];
    [mutableDict setValue:self.inactiveReason forKey:kTravelCardInactiveReason];
    [mutableDict setValue:[self.valueState dictionaryRepresentation] forKey:kTravelCardValueState];
    [mutableDict setValue:[NSNumber numberWithDouble:self.waitingBalance] forKey:kTravelCardWaitingBalance];
    [mutableDict setValue:self.internalBaseClassIdentifier forKey:kTravelCardId];
    [mutableDict setValue:[NSNumber numberWithBool:self.hasTslSupport] forKey:kTravelCardHasTslSupport];
    [mutableDict setValue:[NSNumber numberWithBool:self.isForbidden] forKey:kTravelCardIsForbidden];
    [mutableDict setValue:self.balanceUpdateDate forKey:kTravelCardBalanceUpdateDate];
    [mutableDict setValue:[NSNumber numberWithBool:self.isUsed] forKey:kTravelCardIsUsed];
    [mutableDict setValue:self.childCardsList forKey:kTravelCardChildCardsList];
    [mutableDict setValue:[NSNumber numberWithDouble:self.maxPeriodProductsNumber] forKey:kTravelCardMaxPeriodProductsNumber];
    [mutableDict setValue:self.cardID forKey:kTravelCardCardID];
    [mutableDict setValue:self.cardExpiryDate forKey:kTravelCardCardExpiryDate];
    NSMutableArray *tempArrayForTsltickets = [NSMutableArray array];
    for (NSObject *subArrayObject in self.tsltickets) {
        if([subArrayObject respondsToSelector:@selector(dictionaryRepresentation)]) {
            // This class is a model object
            [tempArrayForTsltickets addObject:[subArrayObject performSelector:@selector(dictionaryRepresentation)]];
        } else {
            // Generic object
            [tempArrayForTsltickets addObject:subArrayObject];
        }
    }
    [mutableDict setValue:[NSArray arrayWithArray:tempArrayForTsltickets] forKey:kTravelCardTsltickets];
    [mutableDict setValue:[self.periodProductState dictionaryRepresentation] forKey:kTravelCardPeriodProductState];
    [mutableDict setValue:[self.value dictionaryRepresentation] forKey:kTravelCardValue];
    NSMutableArray *tempArrayForTickets = [NSMutableArray array];
    for (NSObject *subArrayObject in self.tickets) {
        if([subArrayObject respondsToSelector:@selector(dictionaryRepresentation)]) {
            // This class is a model object
            [tempArrayForTickets addObject:[subArrayObject performSelector:@selector(dictionaryRepresentation)]];
        } else {
            // Generic object
            [tempArrayForTickets addObject:subArrayObject];
        }
    }
    [mutableDict setValue:[NSArray arrayWithArray:tempArrayForTickets] forKey:kTravelCardTickets];
    NSMutableArray *tempArrayForPendingProducts = [NSMutableArray array];
    for (NSObject *subArrayObject in self.pendingProducts) {
        if([subArrayObject respondsToSelector:@selector(dictionaryRepresentation)]) {
            // This class is a model object
            [tempArrayForPendingProducts addObject:[subArrayObject performSelector:@selector(dictionaryRepresentation)]];
        } else {
            // Generic object
            [tempArrayForPendingProducts addObject:subArrayObject];
        }
    }
    [mutableDict setValue:[NSArray arrayWithArray:tempArrayForPendingProducts] forKey:kTravelCardPendingProducts];
    [mutableDict setValue:[self.distance dictionaryRepresentation] forKey:kTravelCardDistance];
    [mutableDict setValue:[NSNumber numberWithBool:self.isParentCard] forKey:kTravelCardIsParentCard];
    [mutableDict setValue:self.name forKey:kTravelCardName];
    [mutableDict setValue:[NSNumber numberWithBool:self.isStrogAuthCard] forKey:kTravelCardIsStrogAuthCard];
    [mutableDict setValue:self.userID forKey:kTravelCardUserID];
    [mutableDict setValue:[NSNumber numberWithBool:self.isAuthorized] forKey:kTravelCardIsAuthorized];
    [mutableDict setValue:self.authValidUntil forKey:kTravelCardAuthValidUntil];
    [mutableDict setValue:[NSNumber numberWithDouble:self.remainingMoney] forKey:kTravelCardRemainingMoney];
    [mutableDict setValue:[NSNumber numberWithDouble:self.pendingProductsAmount] forKey:kTravelCardPendingProductsAmount];
    NSMutableArray *tempArrayForWaitingProducts = [NSMutableArray array];
    for (NSObject *subArrayObject in self.waitingProducts) {
        if([subArrayObject respondsToSelector:@selector(dictionaryRepresentation)]) {
            // This class is a model object
            [tempArrayForWaitingProducts addObject:[subArrayObject performSelector:@selector(dictionaryRepresentation)]];
        } else {
            // Generic object
            [tempArrayForWaitingProducts addObject:subArrayObject];
        }
    }
    [mutableDict setValue:[NSArray arrayWithArray:tempArrayForWaitingProducts] forKey:kTravelCardWaitingProducts];
    [mutableDict setValue:[NSNumber numberWithBool:self.isValidAuthorization] forKey:kTravelCardIsValidAuthorization];
    [mutableDict setValue:[NSNumber numberWithDouble:self.boughtPeriodProductsAmount] forKey:kTravelCardBoughtPeriodProductsAmount];
    [mutableDict setValue:self.waitingBalancePurchaseDateTime forKey:kTravelCardWaitingBalancePurchaseDateTime];
    [mutableDict setValue:self.userGroupExpireDate forKey:kTravelCardUserGroupExpireDate];
    [mutableDict setValue:[NSNumber numberWithBool:self.isActive] forKey:kTravelCardIsActive];
    [mutableDict setValue:[self.inactiveReasons dictionaryRepresentation] forKey:kTravelCardInactiveReasons];
    [mutableDict setValue:self.authValidFrom forKey:kTravelCardAuthValidFrom];
    [mutableDict setValue:[NSNumber numberWithDouble:self.waitingProductsAmount] forKey:kTravelCardWaitingProductsAmount];
    [mutableDict setValue:[NSNumber numberWithDouble:self.type] forKey:kTravelCardType];

    return [NSDictionary dictionaryWithDictionary:mutableDict];
}

-(NSDate *)getPeriodStartDate{
    return [self parseTimeSeries:self.periodProductState.startDate];
}
-(NSDate *)getPeriodEndDate{
    return [self parseTimeSeries:self.periodProductState.expiringDate];
}

-(NSDate *)parseTimeSeries:(NSString *)dateString{
    if (dateString == nil)
        return nil;
    
    NSRange   searchedRange = NSMakeRange(0, [dateString length]);
    NSString *pattern = @"^/Date\\(([0-9]+)\\)/$";
    NSError  *error = nil;
    
    NSRegularExpression* regex = [NSRegularExpression regularExpressionWithPattern: pattern options:0 error:&error];
    NSArray* matches = [regex matchesInString:dateString options:0 range:searchedRange];
    for (NSTextCheckingResult* match in matches) {
        @try {
            NSRange group1 = [match rangeAtIndex:1];
            NSLog(@"group1: %@", [dateString substringWithRange:group1]);
            
            NSString *timeStampString = [dateString substringWithRange:group1];
            return [NSDate dateWithTimeIntervalSince1970:[timeStampString longLongValue]/1000];
        }
        @catch (NSException *exception) {
            return nil;
        }
    }
    
    return nil;
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

    self.authClientsName = [aDecoder decodeObjectForKey:kTravelCardAuthClientsName];
    self.inactiveReason = [aDecoder decodeObjectForKey:kTravelCardInactiveReason];
    self.valueState = [aDecoder decodeObjectForKey:kTravelCardValueState];
    self.waitingBalance = [aDecoder decodeDoubleForKey:kTravelCardWaitingBalance];
    self.internalBaseClassIdentifier = [aDecoder decodeObjectForKey:kTravelCardId];
    self.hasTslSupport = [aDecoder decodeBoolForKey:kTravelCardHasTslSupport];
    self.isForbidden = [aDecoder decodeBoolForKey:kTravelCardIsForbidden];
    self.balanceUpdateDate = [aDecoder decodeObjectForKey:kTravelCardBalanceUpdateDate];
    self.isUsed = [aDecoder decodeBoolForKey:kTravelCardIsUsed];
    self.childCardsList = [aDecoder decodeObjectForKey:kTravelCardChildCardsList];
    self.maxPeriodProductsNumber = [aDecoder decodeDoubleForKey:kTravelCardMaxPeriodProductsNumber];
    self.cardID = [aDecoder decodeObjectForKey:kTravelCardCardID];
    self.cardExpiryDate = [aDecoder decodeObjectForKey:kTravelCardCardExpiryDate];
    self.tsltickets = [aDecoder decodeObjectForKey:kTravelCardTsltickets];
    self.periodProductState = [aDecoder decodeObjectForKey:kTravelCardPeriodProductState];
    self.value = [aDecoder decodeObjectForKey:kTravelCardValue];
    self.tickets = [aDecoder decodeObjectForKey:kTravelCardTickets];
    self.pendingProducts = [aDecoder decodeObjectForKey:kTravelCardPendingProducts];
    self.distance = [aDecoder decodeObjectForKey:kTravelCardDistance];
    self.isParentCard = [aDecoder decodeBoolForKey:kTravelCardIsParentCard];
    self.name = [aDecoder decodeObjectForKey:kTravelCardName];
    self.isStrogAuthCard = [aDecoder decodeBoolForKey:kTravelCardIsStrogAuthCard];
    self.userID = [aDecoder decodeObjectForKey:kTravelCardUserID];
    self.isAuthorized = [aDecoder decodeBoolForKey:kTravelCardIsAuthorized];
    self.authValidUntil = [aDecoder decodeObjectForKey:kTravelCardAuthValidUntil];
    self.remainingMoney = [aDecoder decodeDoubleForKey:kTravelCardRemainingMoney];
    self.pendingProductsAmount = [aDecoder decodeDoubleForKey:kTravelCardPendingProductsAmount];
    self.waitingProducts = [aDecoder decodeObjectForKey:kTravelCardWaitingProducts];
    self.isValidAuthorization = [aDecoder decodeBoolForKey:kTravelCardIsValidAuthorization];
    self.boughtPeriodProductsAmount = [aDecoder decodeDoubleForKey:kTravelCardBoughtPeriodProductsAmount];
    self.waitingBalancePurchaseDateTime = [aDecoder decodeObjectForKey:kTravelCardWaitingBalancePurchaseDateTime];
    self.userGroupExpireDate = [aDecoder decodeObjectForKey:kTravelCardUserGroupExpireDate];
    self.isActive = [aDecoder decodeBoolForKey:kTravelCardIsActive];
    self.inactiveReasons = [aDecoder decodeObjectForKey:kTravelCardInactiveReasons];
    self.authValidFrom = [aDecoder decodeObjectForKey:kTravelCardAuthValidFrom];
    self.waitingProductsAmount = [aDecoder decodeDoubleForKey:kTravelCardWaitingProductsAmount];
    self.type = [aDecoder decodeDoubleForKey:kTravelCardType];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{

    [aCoder encodeObject:_authClientsName forKey:kTravelCardAuthClientsName];
    [aCoder encodeObject:_inactiveReason forKey:kTravelCardInactiveReason];
    [aCoder encodeObject:_valueState forKey:kTravelCardValueState];
    [aCoder encodeDouble:_waitingBalance forKey:kTravelCardWaitingBalance];
    [aCoder encodeObject:_internalBaseClassIdentifier forKey:kTravelCardId];
    [aCoder encodeBool:_hasTslSupport forKey:kTravelCardHasTslSupport];
    [aCoder encodeBool:_isForbidden forKey:kTravelCardIsForbidden];
    [aCoder encodeObject:_balanceUpdateDate forKey:kTravelCardBalanceUpdateDate];
    [aCoder encodeBool:_isUsed forKey:kTravelCardIsUsed];
    [aCoder encodeObject:_childCardsList forKey:kTravelCardChildCardsList];
    [aCoder encodeDouble:_maxPeriodProductsNumber forKey:kTravelCardMaxPeriodProductsNumber];
    [aCoder encodeObject:_cardID forKey:kTravelCardCardID];
    [aCoder encodeObject:_cardExpiryDate forKey:kTravelCardCardExpiryDate];
    [aCoder encodeObject:_tsltickets forKey:kTravelCardTsltickets];
    [aCoder encodeObject:_periodProductState forKey:kTravelCardPeriodProductState];
    [aCoder encodeObject:_value forKey:kTravelCardValue];
    [aCoder encodeObject:_tickets forKey:kTravelCardTickets];
    [aCoder encodeObject:_pendingProducts forKey:kTravelCardPendingProducts];
    [aCoder encodeObject:_distance forKey:kTravelCardDistance];
    [aCoder encodeBool:_isParentCard forKey:kTravelCardIsParentCard];
    [aCoder encodeObject:_name forKey:kTravelCardName];
    [aCoder encodeBool:_isStrogAuthCard forKey:kTravelCardIsStrogAuthCard];
    [aCoder encodeObject:_userID forKey:kTravelCardUserID];
    [aCoder encodeBool:_isAuthorized forKey:kTravelCardIsAuthorized];
    [aCoder encodeObject:_authValidUntil forKey:kTravelCardAuthValidUntil];
    [aCoder encodeDouble:_remainingMoney forKey:kTravelCardRemainingMoney];
    [aCoder encodeDouble:_pendingProductsAmount forKey:kTravelCardPendingProductsAmount];
    [aCoder encodeObject:_waitingProducts forKey:kTravelCardWaitingProducts];
    [aCoder encodeBool:_isValidAuthorization forKey:kTravelCardIsValidAuthorization];
    [aCoder encodeDouble:_boughtPeriodProductsAmount forKey:kTravelCardBoughtPeriodProductsAmount];
    [aCoder encodeObject:_waitingBalancePurchaseDateTime forKey:kTravelCardWaitingBalancePurchaseDateTime];
    [aCoder encodeObject:_userGroupExpireDate forKey:kTravelCardUserGroupExpireDate];
    [aCoder encodeBool:_isActive forKey:kTravelCardIsActive];
    [aCoder encodeObject:_inactiveReasons forKey:kTravelCardInactiveReasons];
    [aCoder encodeObject:_authValidFrom forKey:kTravelCardAuthValidFrom];
    [aCoder encodeDouble:_waitingProductsAmount forKey:kTravelCardWaitingProductsAmount];
    [aCoder encodeDouble:_type forKey:kTravelCardType];
}

- (id)copyWithZone:(NSZone *)zone
{
    TravelCard *copy = [[TravelCard alloc] init];
    
    if (copy) {

        copy.authClientsName = [self.authClientsName copyWithZone:zone];
        copy.inactiveReason = [self.inactiveReason copyWithZone:zone];
        copy.valueState = [self.valueState copyWithZone:zone];
        copy.waitingBalance = self.waitingBalance;
        copy.internalBaseClassIdentifier = [self.internalBaseClassIdentifier copyWithZone:zone];
        copy.hasTslSupport = self.hasTslSupport;
        copy.isForbidden = self.isForbidden;
        copy.balanceUpdateDate = [self.balanceUpdateDate copyWithZone:zone];
        copy.isUsed = self.isUsed;
        copy.childCardsList = [self.childCardsList copyWithZone:zone];
        copy.maxPeriodProductsNumber = self.maxPeriodProductsNumber;
        copy.cardID = [self.cardID copyWithZone:zone];
        copy.cardExpiryDate = [self.cardExpiryDate copyWithZone:zone];
        copy.tsltickets = [self.tsltickets copyWithZone:zone];
        copy.periodProductState = [self.periodProductState copyWithZone:zone];
        copy.value = [self.value copyWithZone:zone];
        copy.tickets = [self.tickets copyWithZone:zone];
        copy.pendingProducts = [self.pendingProducts copyWithZone:zone];
        copy.distance = [self.distance copyWithZone:zone];
        copy.isParentCard = self.isParentCard;
        copy.name = [self.name copyWithZone:zone];
        copy.isStrogAuthCard = self.isStrogAuthCard;
        copy.userID = [self.userID copyWithZone:zone];
        copy.isAuthorized = self.isAuthorized;
        copy.authValidUntil = [self.authValidUntil copyWithZone:zone];
        copy.remainingMoney = self.remainingMoney;
        copy.pendingProductsAmount = self.pendingProductsAmount;
        copy.waitingProducts = [self.waitingProducts copyWithZone:zone];
        copy.isValidAuthorization = self.isValidAuthorization;
        copy.boughtPeriodProductsAmount = self.boughtPeriodProductsAmount;
        copy.waitingBalancePurchaseDateTime = [self.waitingBalancePurchaseDateTime copyWithZone:zone];
        copy.userGroupExpireDate = [self.userGroupExpireDate copyWithZone:zone];
        copy.isActive = self.isActive;
        copy.inactiveReasons = [self.inactiveReasons copyWithZone:zone];
        copy.authValidFrom = [self.authValidFrom copyWithZone:zone];
        copy.waitingProductsAmount = self.waitingProductsAmount;
        copy.type = self.type;
    }
    
    return copy;
}


@end
