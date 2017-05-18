//
//  Geometry.h
//
//  Created by Anteneh Sahledengel on 14/5/15
//  Copyright (c) 2015 shaby ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Mapping.h"

@interface Geometry : NSObject <NSCoding, NSCopying, Mappable>

@property (nonatomic, strong) NSString *type;
@property (nonatomic, strong) NSArray *coordinates;

@property (nonatomic, strong) NSString *coordString;

+ (instancetype)modelObjectWithDictionary:(NSDictionary *)dict;
- (instancetype)initWithDictionary:(NSDictionary *)dict;
- (NSDictionary *)dictionaryRepresentation;

@end
