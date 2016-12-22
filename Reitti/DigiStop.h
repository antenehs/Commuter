//
//  DigiStops.h
//
//  Created by Anteneh Sahledengel on 19/5/16
//  Copyright (c) 2016 shaby ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RestKit/RestKit.h>
#import "EnumManager.h"

@interface DigiStop : NSObject <NSCoding, NSCopying>

@property (nonatomic, strong) NSString *gtfsId;
@property (nonatomic, strong) NSArray *routes;
@property (nonatomic, strong) NSString *code;
@property (nonatomic, strong) NSNumber *lon;
@property (nonatomic, strong) NSNumber *lat;
@property (nonatomic, strong) NSArray *stoptimes;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong) NSString *desc;
@property (nonatomic, strong) NSNumber *vehicleType;
@property (nonatomic, strong) NSString *zoneId;

@property (nonatomic) StopType stopType;

-(NSString *)coordString;
-(NSNumber *)numberId;

+(RKResponseDescriptor *)responseDiscriptorForPath:(NSString *)path;
+(RKObjectMapping *)objectMapping;

+ (instancetype)modelObjectWithDictionary:(NSDictionary *)dict;
- (instancetype)initWithDictionary:(NSDictionary *)dict;
- (NSDictionary *)dictionaryRepresentation;

@end
