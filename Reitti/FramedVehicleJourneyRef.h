//
//  FramedVehicleJourneyRef.h
//
//  Created by Anteneh Sahledengel on 10/1/16
//  Copyright (c) 2016 shaby ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DataFrameRef;

@interface FramedVehicleJourneyRef : NSObject <NSCoding, NSCopying>

@property (nonatomic, strong) NSString *datedVehicleJourneyRef;
@property (nonatomic, strong) DataFrameRef *dataFrameRef;

+ (instancetype)modelObjectWithDictionary:(NSDictionary *)dict;
- (instancetype)initWithDictionary:(NSDictionary *)dict;
- (NSDictionary *)dictionaryRepresentation;

@end
