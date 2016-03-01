//
//  Tickets.m
//
//  Created by Anteneh Sahledengel on 2/7/15
//  Copyright (c) 2015 shaby ltd. All rights reserved.
//

#import "Tickets.h"
#import "TicketNames.h"


NSString *const kTicketsLastPurchase = @"lastPurchase";
NSString *const kTicketsTslTicketStartDate = @"tslTicketStartDate";
NSString *const kTicketsTicketType = @"ticketType";
NSString *const kTicketsIsRegional = @"IsRegional";
NSString *const kTicketsTslSupport = @"tslSupport";
NSString *const kTicketsDefaultDateRange = @"defaultDateRange";
NSString *const kTicketsTslCompanyName = @"tslCompanyName";
NSString *const kTicketsImg = @"img";
NSString *const kTicketsMaxDateRange = @"maxDateRange";
NSString *const kTicketsEndDateEnd = @"endDateEnd";
NSString *const kTicketsTicketName = @"ticketName";
NSString *const kTicketsStartDateEnd = @"startDateEnd";
NSString *const kTicketsTicketNames = @"ticketNames";
NSString *const kTicketsName = @"name";
NSString *const kTicketsTslProductId = @"tslProductId";
NSString *const kTicketsFixedPrice = @"fixedPrice";
NSString *const kTicketsId = @"id";
NSString *const kTicketsTslCompanyBusinessID = @"tslCompanyBusinessID";
NSString *const kTicketsEndDateBegin = @"endDateBegin";
NSString *const kTicketsUid = @"uid";
NSString *const kTicketsTslCompanyId = @"tslCompanyId";
NSString *const kTicketsMinDateRange = @"minDateRange";
NSString *const kTicketsUnitPrice = @"unitPrice";
NSString *const kTicketsTslTicketEndDate = @"tslTicketEndDate";
NSString *const kTicketsTslSupportType = @"tslSupportType";
NSString *const kTicketsTslCompanyBusinessIDExtension = @"tslCompanyBusinessIDExtension";
NSString *const kTicketsStartDateBegin = @"startDateBegin";


@interface Tickets ()

- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict;

@end

@implementation Tickets

@synthesize lastPurchase = _lastPurchase;
@synthesize tslTicketStartDate = _tslTicketStartDate;
@synthesize ticketType = _ticketType;
@synthesize isRegional = _isRegional;
@synthesize tslSupport = _tslSupport;
@synthesize defaultDateRange = _defaultDateRange;
@synthesize tslCompanyName = _tslCompanyName;
@synthesize img = _img;
@synthesize maxDateRange = _maxDateRange;
@synthesize endDateEnd = _endDateEnd;
@synthesize ticketName = _ticketName;
@synthesize startDateEnd = _startDateEnd;
@synthesize ticketNames = _ticketNames;
@synthesize name = _name;
@synthesize tslProductId = _tslProductId;
@synthesize fixedPrice = _fixedPrice;
@synthesize ticketsIdentifier = _ticketsIdentifier;
@synthesize tslCompanyBusinessID = _tslCompanyBusinessID;
@synthesize endDateBegin = _endDateBegin;
@synthesize uid = _uid;
@synthesize tslCompanyId = _tslCompanyId;
@synthesize minDateRange = _minDateRange;
@synthesize unitPrice = _unitPrice;
@synthesize tslTicketEndDate = _tslTicketEndDate;
@synthesize tslSupportType = _tslSupportType;
@synthesize tslCompanyBusinessIDExtension = _tslCompanyBusinessIDExtension;
@synthesize startDateBegin = _startDateBegin;


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
            self.lastPurchase = [[self objectOrNilForKey:kTicketsLastPurchase fromDictionary:dict] doubleValue];
            self.tslTicketStartDate = [self objectOrNilForKey:kTicketsTslTicketStartDate fromDictionary:dict];
            self.ticketType = [[self objectOrNilForKey:kTicketsTicketType fromDictionary:dict] doubleValue];
            self.isRegional = [[self objectOrNilForKey:kTicketsIsRegional fromDictionary:dict] boolValue];
            self.tslSupport = [[self objectOrNilForKey:kTicketsTslSupport fromDictionary:dict] doubleValue];
            self.defaultDateRange = [self objectOrNilForKey:kTicketsDefaultDateRange fromDictionary:dict];
            self.tslCompanyName = [self objectOrNilForKey:kTicketsTslCompanyName fromDictionary:dict];
            self.img = [self objectOrNilForKey:kTicketsImg fromDictionary:dict];
            self.maxDateRange = [[self objectOrNilForKey:kTicketsMaxDateRange fromDictionary:dict] doubleValue];
            self.endDateEnd = [self objectOrNilForKey:kTicketsEndDateEnd fromDictionary:dict];
            self.ticketName = [self objectOrNilForKey:kTicketsTicketName fromDictionary:dict];
            self.startDateEnd = [self objectOrNilForKey:kTicketsStartDateEnd fromDictionary:dict];
            self.ticketNames = [TicketNames modelObjectWithDictionary:[dict objectForKey:kTicketsTicketNames]];
            self.name = [self objectOrNilForKey:kTicketsName fromDictionary:dict];
            self.tslProductId = [[self objectOrNilForKey:kTicketsTslProductId fromDictionary:dict] doubleValue];
            self.fixedPrice = [[self objectOrNilForKey:kTicketsFixedPrice fromDictionary:dict] doubleValue];
            self.ticketsIdentifier = [[self objectOrNilForKey:kTicketsId fromDictionary:dict] doubleValue];
            self.tslCompanyBusinessID = [self objectOrNilForKey:kTicketsTslCompanyBusinessID fromDictionary:dict];
            self.endDateBegin = [self objectOrNilForKey:kTicketsEndDateBegin fromDictionary:dict];
            self.uid = [self objectOrNilForKey:kTicketsUid fromDictionary:dict];
            self.tslCompanyId = [self objectOrNilForKey:kTicketsTslCompanyId fromDictionary:dict];
            self.minDateRange = [[self objectOrNilForKey:kTicketsMinDateRange fromDictionary:dict] doubleValue];
            self.unitPrice = [[self objectOrNilForKey:kTicketsUnitPrice fromDictionary:dict] doubleValue];
            self.tslTicketEndDate = [self objectOrNilForKey:kTicketsTslTicketEndDate fromDictionary:dict];
            self.tslSupportType = [[self objectOrNilForKey:kTicketsTslSupportType fromDictionary:dict] doubleValue];
            self.tslCompanyBusinessIDExtension = [self objectOrNilForKey:kTicketsTslCompanyBusinessIDExtension fromDictionary:dict];
            self.startDateBegin = [self objectOrNilForKey:kTicketsStartDateBegin fromDictionary:dict];

    }
    
    return self;
    
}

- (NSDictionary *)dictionaryRepresentation
{
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
    [mutableDict setValue:[NSNumber numberWithDouble:self.lastPurchase] forKey:kTicketsLastPurchase];
    [mutableDict setValue:self.tslTicketStartDate forKey:kTicketsTslTicketStartDate];
    [mutableDict setValue:[NSNumber numberWithDouble:self.ticketType] forKey:kTicketsTicketType];
    [mutableDict setValue:[NSNumber numberWithBool:self.isRegional] forKey:kTicketsIsRegional];
    [mutableDict setValue:[NSNumber numberWithDouble:self.tslSupport] forKey:kTicketsTslSupport];
    NSMutableArray *tempArrayForDefaultDateRange = [NSMutableArray array];
    for (NSObject *subArrayObject in self.defaultDateRange) {
        if([subArrayObject respondsToSelector:@selector(dictionaryRepresentation)]) {
            // This class is a model object
            [tempArrayForDefaultDateRange addObject:[subArrayObject performSelector:@selector(dictionaryRepresentation)]];
        } else {
            // Generic object
            [tempArrayForDefaultDateRange addObject:subArrayObject];
        }
    }
    [mutableDict setValue:[NSArray arrayWithArray:tempArrayForDefaultDateRange] forKey:kTicketsDefaultDateRange];
    [mutableDict setValue:self.tslCompanyName forKey:kTicketsTslCompanyName];
    [mutableDict setValue:self.img forKey:kTicketsImg];
    [mutableDict setValue:[NSNumber numberWithDouble:self.maxDateRange] forKey:kTicketsMaxDateRange];
    [mutableDict setValue:self.endDateEnd forKey:kTicketsEndDateEnd];
    [mutableDict setValue:self.ticketName forKey:kTicketsTicketName];
    [mutableDict setValue:self.startDateEnd forKey:kTicketsStartDateEnd];
    [mutableDict setValue:[self.ticketNames dictionaryRepresentation] forKey:kTicketsTicketNames];
    [mutableDict setValue:self.name forKey:kTicketsName];
    [mutableDict setValue:[NSNumber numberWithDouble:self.tslProductId] forKey:kTicketsTslProductId];
    [mutableDict setValue:[NSNumber numberWithDouble:self.fixedPrice] forKey:kTicketsFixedPrice];
    [mutableDict setValue:[NSNumber numberWithDouble:self.ticketsIdentifier] forKey:kTicketsId];
    [mutableDict setValue:self.tslCompanyBusinessID forKey:kTicketsTslCompanyBusinessID];
    [mutableDict setValue:self.endDateBegin forKey:kTicketsEndDateBegin];
    [mutableDict setValue:self.uid forKey:kTicketsUid];
    [mutableDict setValue:self.tslCompanyId forKey:kTicketsTslCompanyId];
    [mutableDict setValue:[NSNumber numberWithDouble:self.minDateRange] forKey:kTicketsMinDateRange];
    [mutableDict setValue:[NSNumber numberWithDouble:self.unitPrice] forKey:kTicketsUnitPrice];
    [mutableDict setValue:self.tslTicketEndDate forKey:kTicketsTslTicketEndDate];
    [mutableDict setValue:[NSNumber numberWithDouble:self.tslSupportType] forKey:kTicketsTslSupportType];
    [mutableDict setValue:self.tslCompanyBusinessIDExtension forKey:kTicketsTslCompanyBusinessIDExtension];
    [mutableDict setValue:self.startDateBegin forKey:kTicketsStartDateBegin];

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

    self.lastPurchase = [aDecoder decodeDoubleForKey:kTicketsLastPurchase];
    self.tslTicketStartDate = [aDecoder decodeObjectForKey:kTicketsTslTicketStartDate];
    self.ticketType = [aDecoder decodeDoubleForKey:kTicketsTicketType];
    self.isRegional = [aDecoder decodeBoolForKey:kTicketsIsRegional];
    self.tslSupport = [aDecoder decodeDoubleForKey:kTicketsTslSupport];
    self.defaultDateRange = [aDecoder decodeObjectForKey:kTicketsDefaultDateRange];
    self.tslCompanyName = [aDecoder decodeObjectForKey:kTicketsTslCompanyName];
    self.img = [aDecoder decodeObjectForKey:kTicketsImg];
    self.maxDateRange = [aDecoder decodeDoubleForKey:kTicketsMaxDateRange];
    self.endDateEnd = [aDecoder decodeObjectForKey:kTicketsEndDateEnd];
    self.ticketName = [aDecoder decodeObjectForKey:kTicketsTicketName];
    self.startDateEnd = [aDecoder decodeObjectForKey:kTicketsStartDateEnd];
    self.ticketNames = [aDecoder decodeObjectForKey:kTicketsTicketNames];
    self.name = [aDecoder decodeObjectForKey:kTicketsName];
    self.tslProductId = [aDecoder decodeDoubleForKey:kTicketsTslProductId];
    self.fixedPrice = [aDecoder decodeDoubleForKey:kTicketsFixedPrice];
    self.ticketsIdentifier = [aDecoder decodeDoubleForKey:kTicketsId];
    self.tslCompanyBusinessID = [aDecoder decodeObjectForKey:kTicketsTslCompanyBusinessID];
    self.endDateBegin = [aDecoder decodeObjectForKey:kTicketsEndDateBegin];
    self.uid = [aDecoder decodeObjectForKey:kTicketsUid];
    self.tslCompanyId = [aDecoder decodeObjectForKey:kTicketsTslCompanyId];
    self.minDateRange = [aDecoder decodeDoubleForKey:kTicketsMinDateRange];
    self.unitPrice = [aDecoder decodeDoubleForKey:kTicketsUnitPrice];
    self.tslTicketEndDate = [aDecoder decodeObjectForKey:kTicketsTslTicketEndDate];
    self.tslSupportType = [aDecoder decodeDoubleForKey:kTicketsTslSupportType];
    self.tslCompanyBusinessIDExtension = [aDecoder decodeObjectForKey:kTicketsTslCompanyBusinessIDExtension];
    self.startDateBegin = [aDecoder decodeObjectForKey:kTicketsStartDateBegin];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{

    [aCoder encodeDouble:_lastPurchase forKey:kTicketsLastPurchase];
    [aCoder encodeObject:_tslTicketStartDate forKey:kTicketsTslTicketStartDate];
    [aCoder encodeDouble:_ticketType forKey:kTicketsTicketType];
    [aCoder encodeBool:_isRegional forKey:kTicketsIsRegional];
    [aCoder encodeDouble:_tslSupport forKey:kTicketsTslSupport];
    [aCoder encodeObject:_defaultDateRange forKey:kTicketsDefaultDateRange];
    [aCoder encodeObject:_tslCompanyName forKey:kTicketsTslCompanyName];
    [aCoder encodeObject:_img forKey:kTicketsImg];
    [aCoder encodeDouble:_maxDateRange forKey:kTicketsMaxDateRange];
    [aCoder encodeObject:_endDateEnd forKey:kTicketsEndDateEnd];
    [aCoder encodeObject:_ticketName forKey:kTicketsTicketName];
    [aCoder encodeObject:_startDateEnd forKey:kTicketsStartDateEnd];
    [aCoder encodeObject:_ticketNames forKey:kTicketsTicketNames];
    [aCoder encodeObject:_name forKey:kTicketsName];
    [aCoder encodeDouble:_tslProductId forKey:kTicketsTslProductId];
    [aCoder encodeDouble:_fixedPrice forKey:kTicketsFixedPrice];
    [aCoder encodeDouble:_ticketsIdentifier forKey:kTicketsId];
    [aCoder encodeObject:_tslCompanyBusinessID forKey:kTicketsTslCompanyBusinessID];
    [aCoder encodeObject:_endDateBegin forKey:kTicketsEndDateBegin];
    [aCoder encodeObject:_uid forKey:kTicketsUid];
    [aCoder encodeObject:_tslCompanyId forKey:kTicketsTslCompanyId];
    [aCoder encodeDouble:_minDateRange forKey:kTicketsMinDateRange];
    [aCoder encodeDouble:_unitPrice forKey:kTicketsUnitPrice];
    [aCoder encodeObject:_tslTicketEndDate forKey:kTicketsTslTicketEndDate];
    [aCoder encodeDouble:_tslSupportType forKey:kTicketsTslSupportType];
    [aCoder encodeObject:_tslCompanyBusinessIDExtension forKey:kTicketsTslCompanyBusinessIDExtension];
    [aCoder encodeObject:_startDateBegin forKey:kTicketsStartDateBegin];
}

- (id)copyWithZone:(NSZone *)zone
{
    Tickets *copy = [[Tickets alloc] init];
    
    if (copy) {

        copy.lastPurchase = self.lastPurchase;
        copy.ticketType = self.ticketType;
        copy.isRegional = self.isRegional;
        copy.tslSupport = self.tslSupport;
        copy.defaultDateRange = [self.defaultDateRange copyWithZone:zone];
        copy.img = [self.img copyWithZone:zone];
        copy.maxDateRange = self.maxDateRange;
        copy.endDateEnd = [self.endDateEnd copyWithZone:zone];
        copy.startDateEnd = [self.startDateEnd copyWithZone:zone];
        copy.ticketNames = [self.ticketNames copyWithZone:zone];
        copy.name = [self.name copyWithZone:zone];
        copy.tslProductId = self.tslProductId;
        copy.fixedPrice = self.fixedPrice;
        copy.ticketsIdentifier = self.ticketsIdentifier;
        copy.endDateBegin = [self.endDateBegin copyWithZone:zone];
        copy.uid = [self.uid copyWithZone:zone];
        copy.minDateRange = self.minDateRange;
        copy.unitPrice = self.unitPrice;
        copy.tslSupportType = self.tslSupportType;
        copy.startDateBegin = [self.startDateBegin copyWithZone:zone];
    }
    
    return copy;
}


@end
