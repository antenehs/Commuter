//
//  PeriodProductState.h
//
//  Created by Anteneh Sahledengel on 2/7/15
//  Copyright (c) 2015 shaby ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ProductNames;

@interface PeriodProductState : NSObject <NSCoding, NSCopying>

@property (nonatomic, assign) double remainingTripSaldo;
@property (nonatomic, strong) NSString *startDate;
@property (nonatomic, strong) NSString *expiringDate;
@property (nonatomic, assign) double state;
@property (nonatomic, strong) ProductNames *productNames;
@property (nonatomic, assign) BOOL isSerieTicketAndTripSaldoNonZero;
@property (nonatomic, strong) NSString *productName;
@property (nonatomic, assign) id stateExplanationUIField;
@property (nonatomic, assign) double productCode;
@property (nonatomic, assign) double boughtDays;
@property (nonatomic, assign) id stateImageFilenameUIField;
@property (nonatomic, assign) id expiringDateStringUIField;

+ (instancetype)modelObjectWithDictionary:(NSDictionary *)dict;
- (instancetype)initWithDictionary:(NSDictionary *)dict;
- (NSDictionary *)dictionaryRepresentation;

@end
