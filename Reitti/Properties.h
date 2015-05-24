//
//  Properties.h
//
//  Created by Anteneh Sahledengel on 14/5/15
//  Copyright (c) 2015 shaby ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Properties : NSObject <NSCoding, NSCopying>

@property (nonatomic, strong) NSString *propertiesIdentifier;
@property (nonatomic, strong) NSString *type;
@property (nonatomic, strong) NSString *name;

//Vehicle Properties
@property (nonatomic, strong) NSString *lineid;
@property (nonatomic, assign) double bearing;
@property (nonatomic, assign) double distanceFromStart;
@property (nonatomic, strong) NSString *departure;
@property (nonatomic, strong) NSString *lastUpdate;
@property (nonatomic, assign) double diff;

//Nearby Stop properties
@property (nonatomic, assign) double dist;
@property (nonatomic, strong) NSString *code;
@property (nonatomic, strong) NSArray *lines;
@property (nonatomic, strong) NSString *addr;

+ (instancetype)modelObjectWithDictionary:(NSDictionary *)dict;
- (instancetype)initWithDictionary:(NSDictionary *)dict;
- (NSDictionary *)dictionaryRepresentation;

@end
