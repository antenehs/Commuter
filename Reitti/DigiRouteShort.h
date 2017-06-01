//
//  DigiRouteShort.h
//
//  Created by Anteneh Sahledengel on 19/5/16
//  Copyright (c) 2016 shaby ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EnumManager.h"
#import "DigiPatternShort.h"
#import "Mapping.h"
#import "StopLine.h"

@interface DigiRouteShort : NSObject <NSCoding, NSCopying, Mappable, DictionaryMappable>

-(StopLine *)reittiStopLine;
-(StopLine *)reittiStopLineWithPattern:(DigiPatternShort *)patternShort;

@property (nonatomic, strong) NSString *routeIdentifier;
@property (nonatomic, strong) NSString *longName;
@property (nonatomic, strong) NSString *shortName;
@property (nonatomic, strong) NSString *bikesAllowed;
@property (nonatomic, strong) NSString *gtfsId;
@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong) NSNumber *type;
@property (nonatomic, strong) NSString *desc;
@property (nonatomic, strong) NSString *mode;
@property (nonatomic, strong) NSArray *patterns;

@property (nonatomic) LineType lineType;
@property (nonatomic, strong)NSString *lineStart;
@property (nonatomic, strong)NSString *lineEnd;

+(NSString *)routeStartFromLongName:(NSString *)routeLongName;
+(NSString *)routeDestinationFromLongName:(NSString *)routeLongName;

+(NSDictionary *)mappingDictionary;
//
//+ (instancetype)modelObjectWithDictionary:(NSDictionary *)dict;
//- (instancetype)initWithDictionary:(NSDictionary *)dict;
//- (NSDictionary *)dictionaryRepresentation;

@end
