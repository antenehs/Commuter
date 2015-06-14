//
//  StaticRoute.h
//
//  Created by Anteneh Sahledengel on 6/6/15
//  Copyright (c) 2015 shaby ltd. All rights reserved.
//
//0 - Tram, Streetcar, Light rail. Any light rail or street level system within a metropolitan area.
//1 - Subway, Metro. Any underground rail system within a metropolitan area.
//2 - Rail. Used for intercity or long-distance travel.
//3 - Bus. Used for short- and long-distance bus routes.
//4 - Ferry. Used for short- and long-distance boat service.
//5 - Cable car. Used for street-level cable cars where the cable runs beneath the car.
//6 - Gondola, Suspended cable car. Typically used for aerial cable cars where the car is suspended from the cable.
//7 - Funicular. Any rail system designed for steep inclines.
//

#import <Foundation/Foundation.h>



@interface StaticRoute : NSObject <NSCoding, NSCopying>

@property (nonatomic, strong) NSString *lineEnd;
@property (nonatomic, strong) NSString *routeType;
@property (nonatomic, strong) NSString *code;
@property (nonatomic, strong) NSString *routeUrl;
@property (nonatomic, strong) NSString *shortName;
@property (nonatomic, strong) NSString *lineStart;
@property (nonatomic, strong) NSString *longName;
@property (nonatomic, strong) NSString *operator;

+ (instancetype)modelObjectWithDictionary:(NSDictionary *)dict;
- (instancetype)initWithDictionary:(NSDictionary *)dict;
- (NSDictionary *)dictionaryRepresentation;

@end
