//
//  DigiStopShort.h
//  Reitti
//
//  Created by Anteneh Sahledengel on 12/26/16.
//  Copyright © 2016 Anteneh Sahledengel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Mapping.h"
#import "LineStop.h"
#import "EnumManager.h"

//#if MAIN_APP
#import "BusStopShort.h"
//#endif

@interface DigiStopShort : NSObject <NSCoding, NSCopying, Mappable>

-(LineStop *)reittiLineStop;

//#if MAIN_APP
-(BusStopShort *)reittiBusStopShort;
-(void)fillBusStopShortPropertiesTo:(BusStopShort *)stopShort;
//#endif

@property (nonatomic, strong) NSString *gtfsId;
@property (nonatomic, strong) NSString *code;
@property (nonatomic, strong) NSNumber *lon;
@property (nonatomic, strong) NSNumber *lat;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong) NSString *desc;
@property (nonatomic, strong) NSNumber *vehicleType;
@property (nonatomic, strong) NSString *zoneId;
//Patterns determin the direction of the routes passing through the stop
@property (nonatomic, strong) NSArray *patterns;
//Routes contain both directions of the route passing through the stop
@property (nonatomic, strong) NSArray *routes;

@property (nonatomic) StopType stopType;

-(NSString *)coordString;
-(NSNumber *)numberId;

+(NSDictionary *)mappingDictionary;
+(NSArray *)relationShips;

+ (instancetype)modelObjectWithDictionary:(NSDictionary *)dict;
- (instancetype)initWithDictionary:(NSDictionary *)dict;
- (NSDictionary *)dictionaryRepresentation;

@end
