//
//  StopProperties.h
//
//  Created by Anteneh Sahledengel on 23/5/15
//  Copyright (c) 2015 shaby ltd. All rights reserved.
//

#import <Foundation/Foundation.h>



@interface StopProperties : NSObject <NSCoding, NSCopying>

@property (nonatomic, assign) double dist;
@property (nonatomic, strong) NSString *propertiesIdentifier;
@property (nonatomic, strong) NSString *code;
@property (nonatomic, strong) NSArray *lines;
@property (nonatomic, strong) NSString *addr;
@property (nonatomic, strong) NSString *type;
@property (nonatomic, strong) NSString *name;

+ (instancetype)modelObjectWithDictionary:(NSDictionary *)dict;
- (instancetype)initWithDictionary:(NSDictionary *)dict;
- (NSDictionary *)dictionaryRepresentation;

@end
