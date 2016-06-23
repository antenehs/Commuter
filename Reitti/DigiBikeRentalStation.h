//
//  DigiBikeRentalStation.h
//
//  Created by Anteneh Sahledengel on 28/5/16
//  Copyright (c) 2016 shaby ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RestKit/RestKit.h>

@interface DigiBikeRentalStation : NSObject <NSCoding, NSCopying>

@property (nonatomic, strong) NSNumber *bikesAvailable;
@property (nonatomic, strong) NSString *stationId;
@property (nonatomic, strong) NSNumber *realtime;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSNumber *spacesAvailable;

+(RKResponseDescriptor *)responseDiscriptorForPath:(NSString *)path;
+(RKObjectMapping *)objectMapping;

+ (instancetype)modelObjectWithDictionary:(NSDictionary *)dict;
- (instancetype)initWithDictionary:(NSDictionary *)dict;
- (NSDictionary *)dictionaryRepresentation;

@end
