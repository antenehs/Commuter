//
//  Tickets.h
//
//  Created by Anteneh Sahledengel on 2/7/15
//  Copyright (c) 2015 shaby ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TicketNames;

@interface Tickets : NSObject <NSCoding, NSCopying>

@property (nonatomic, assign) double lastPurchase;
@property (nonatomic, assign) id tslTicketStartDate;
@property (nonatomic, assign) double ticketType;
@property (nonatomic, assign) BOOL isRegional;
@property (nonatomic, assign) double tslSupport;
@property (nonatomic, strong) NSArray *defaultDateRange;
@property (nonatomic, assign) id tslCompanyName;
@property (nonatomic, strong) NSString *img;
@property (nonatomic, assign) double maxDateRange;
@property (nonatomic, strong) NSString *endDateEnd;
@property (nonatomic, assign) id ticketName;
@property (nonatomic, strong) NSString *startDateEnd;
@property (nonatomic, strong) TicketNames *ticketNames;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, assign) double tslProductId;
@property (nonatomic, assign) double fixedPrice;
@property (nonatomic, assign) double ticketsIdentifier;
@property (nonatomic, assign) id tslCompanyBusinessID;
@property (nonatomic, strong) NSString *endDateBegin;
@property (nonatomic, strong) NSString *uid;
@property (nonatomic, assign) id tslCompanyId;
@property (nonatomic, assign) double minDateRange;
@property (nonatomic, assign) double unitPrice;
@property (nonatomic, assign) id tslTicketEndDate;
@property (nonatomic, assign) double tslSupportType;
@property (nonatomic, assign) id tslCompanyBusinessIDExtension;
@property (nonatomic, strong) NSString *startDateBegin;

+ (instancetype)modelObjectWithDictionary:(NSDictionary *)dict;
- (instancetype)initWithDictionary:(NSDictionary *)dict;
- (NSDictionary *)dictionaryRepresentation;

@end
