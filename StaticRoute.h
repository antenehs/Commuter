//
//  StaticRoute.h
//
//  Created by Anteneh Sahledengel on 6/6/15
//  Copyright (c) 2015 shaby ltd. All rights reserved.
//

#import <Foundation/Foundation.h>



@interface StaticRoute : NSObject <NSCoding, NSCopying>

@property (nonatomic, strong) NSString *routeUrl;
@property (nonatomic, strong) NSString *operator;
@property (nonatomic, strong) NSString *shortName;
@property (nonatomic, strong) NSString *routeType;
@property (nonatomic, strong) NSString *code;
@property (nonatomic, strong) NSString *longName;

+ (instancetype)modelObjectWithDictionary:(NSDictionary *)dict;
- (instancetype)initWithDictionary:(NSDictionary *)dict;
- (NSDictionary *)dictionaryRepresentation;

@end
