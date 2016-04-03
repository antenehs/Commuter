//
//  TREFramedVehicleJourneyRef.h
//
//  Created by Anteneh Sahledengel on 3/4/16
//  Copyright (c) 2016 shaby ltd. All rights reserved.
//

#import <Foundation/Foundation.h>



@interface TREFramedVehicleJourneyRef : NSObject <NSCoding, NSCopying>

@property (nonatomic, strong) NSString *dateFrameRef;
@property (nonatomic, strong) NSString *datedVehicleJourneyRef;

+ (instancetype)modelObjectWithDictionary:(NSDictionary *)dict;
- (instancetype)initWithDictionary:(NSDictionary *)dict;
- (NSDictionary *)dictionaryRepresentation;

@end
