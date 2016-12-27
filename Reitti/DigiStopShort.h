//
//  DigiStopShort.h
//  Reitti
//
//  Created by Anteneh Sahledengel on 12/26/16.
//  Copyright © 2016 Anteneh Sahledengel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RestKit/RestKit.h>

@interface DigiStopShort : NSObject <NSCoding, NSCopying>

@property (nonatomic, strong) NSString *gtfsId;
@property (nonatomic, strong) NSString *code;
@property (nonatomic, strong) NSNumber *lon;
@property (nonatomic, strong) NSNumber *lat;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong) NSString *desc;
@property (nonatomic, strong) NSNumber *vehicleType;
@property (nonatomic, strong) NSString *zoneId;

-(NSString *)coordString;
-(NSNumber *)numberId;

+(RKResponseDescriptor *)responseDiscriptorForPath:(NSString *)path;
+(RKObjectMapping *)objectMapping;
+(NSDictionary *)mappingDictionary;

+ (instancetype)modelObjectWithDictionary:(NSDictionary *)dict;
- (instancetype)initWithDictionary:(NSDictionary *)dict;
- (NSDictionary *)dictionaryRepresentation;

@end
