//
//  Properties.h
//
//  Created by Anteneh Sahledengel on 14/5/15
//  Copyright (c) 2015 shaby ltd. All rights reserved.
//

#import <Foundation/Foundation.h>



@interface Properties : NSObject <NSCoding, NSCopying>

@property (nonatomic, strong) NSString *lineid;
@property (nonatomic, strong) NSString *propertiesIdentifier;
@property (nonatomic, assign) double bearing;
@property (nonatomic, assign) double distanceFromStart;
@property (nonatomic, strong) NSString *departure;
@property (nonatomic, strong) NSString *lastUpdate;
@property (nonatomic, strong) NSString *type;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, assign) double diff;

+ (instancetype)modelObjectWithDictionary:(NSDictionary *)dict;
- (instancetype)initWithDictionary:(NSDictionary *)dict;
- (NSDictionary *)dictionaryRepresentation;

@end
