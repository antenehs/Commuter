//
//  DigiTrip.h
//
//  Created by Anteneh Sahledengel on 19/5/16
//  Copyright (c) 2016 shaby ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RestKit/RestKit.h>
#import "DigiRoute.h"
#import "DigiPattern.h"

@interface DigiTrip : NSObject <NSCoding, NSCopying>

@property (nonatomic, strong) DigiRoute *route;
@property (nonatomic, strong) DigiPattern *pattern;
@property (nonatomic, strong) NSString *tripHeadsign;

+(RKResponseDescriptor *)responseDiscriptorForPath:(NSString *)path;
+(RKObjectMapping *)objectMapping;

+ (instancetype)modelObjectWithDictionary:(NSDictionary *)dict;
- (instancetype)initWithDictionary:(NSDictionary *)dict;
- (NSDictionary *)dictionaryRepresentation;

@end
