//
//  TREOnwardCalls.h
//
//  Created by Anteneh Sahledengel on 3/4/16
//  Copyright (c) 2016 shaby ltd. All rights reserved.
//

#import <Foundation/Foundation.h>



@interface TREOnwardCalls : NSObject <NSCoding, NSCopying>

@property (nonatomic, strong) NSString *expectedDepartureTime;
@property (nonatomic, strong) NSString *order;
@property (nonatomic, strong) NSString *expectedArrivalTime;
@property (nonatomic, strong) NSString *stopPointRef;

+ (instancetype)modelObjectWithDictionary:(NSDictionary *)dict;
- (instancetype)initWithDictionary:(NSDictionary *)dict;
- (NSDictionary *)dictionaryRepresentation;

@end
