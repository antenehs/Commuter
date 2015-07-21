//
//  TravelCard.h
//
//  Created by Anteneh Sahledengel on 2/7/15
//  Copyright (c) 2015 shaby ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ValueState, PeriodProductState, Value, Distance, InactiveReasons;

@interface TravelCard : NSObject <NSCoding, NSCopying>

@property (nonatomic, assign) id authClientsName;
@property (nonatomic, assign) id inactiveReason;
@property (nonatomic, strong) ValueState *valueState;
@property (nonatomic, assign) double waitingBalance;
@property (nonatomic, strong) NSString *internalBaseClassIdentifier;
@property (nonatomic, assign) BOOL hasTslSupport;
@property (nonatomic, assign) BOOL isForbidden;
@property (nonatomic, strong) NSString *balanceUpdateDate;
@property (nonatomic, assign) BOOL isUsed;
@property (nonatomic, assign) id childCardsList;
@property (nonatomic, assign) double maxPeriodProductsNumber;
@property (nonatomic, strong) NSString *cardID;
@property (nonatomic, strong) NSString *cardExpiryDate;
@property (nonatomic, strong) NSArray *tsltickets;
@property (nonatomic, strong) PeriodProductState *periodProductState;
@property (nonatomic, strong) Value *value;
@property (nonatomic, strong) NSArray *tickets;
@property (nonatomic, strong) NSArray *pendingProducts;
@property (nonatomic, strong) Distance *distance;
@property (nonatomic, assign) BOOL isParentCard;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, assign) BOOL isStrogAuthCard;
@property (nonatomic, strong) NSString *userID;
@property (nonatomic, assign) BOOL isAuthorized;
@property (nonatomic, strong) NSString *authValidUntil;
@property (nonatomic, assign) double remainingMoney;
@property (nonatomic, assign) double pendingProductsAmount;
@property (nonatomic, strong) NSArray *waitingProducts;
@property (nonatomic, assign) BOOL isValidAuthorization;
@property (nonatomic, assign) double boughtPeriodProductsAmount;
@property (nonatomic, assign) id waitingBalancePurchaseDateTime;
@property (nonatomic, strong) NSString *userGroupExpireDate;
@property (nonatomic, assign) BOOL isActive;
@property (nonatomic, strong) InactiveReasons *inactiveReasons;
@property (nonatomic, strong) NSString *authValidFrom;
@property (nonatomic, assign) double waitingProductsAmount;
@property (nonatomic, assign) double type;

+ (instancetype)modelObjectWithDictionary:(NSDictionary *)dict;
- (instancetype)initWithDictionary:(NSDictionary *)dict;
- (NSDictionary *)dictionaryRepresentation;

-(NSDate *)getPeriodStartDate;
-(NSDate *)getPeriodEndDate;

@end
