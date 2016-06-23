//
//  DigiGeometry.h
//
//  Created by Anteneh Sahledengel on 28/5/16
//  Copyright (c) 2016 shaby ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RestKit/RestKit.h>

@interface DigiGeometry : NSObject <NSCoding, NSCopying>

@property (nonatomic, strong) NSNumber *lat;
@property (nonatomic, strong) NSNumber *lon;

+ (instancetype)modelObjectWithDictionary:(NSDictionary *)dict;
- (instancetype)initWithDictionary:(NSDictionary *)dict;
- (NSDictionary *)dictionaryRepresentation;

+(RKResponseDescriptor *)responseDiscriptorForPath:(NSString *)path;
+(RKObjectMapping *)objectMapping;

@end
