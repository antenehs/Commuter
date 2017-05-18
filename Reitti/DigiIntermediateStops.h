//
//  DigiIntermediateStops.h
//
//  Created by Anteneh Sahledengel on 28/5/16
//  Copyright (c) 2016 shaby ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "Mapping.h"

@interface DigiIntermediateStops : NSObject <NSCoding, NSCopying, Mappable>

@property (nonatomic, strong) NSString *gtfsId;
@property (nonatomic, strong) NSString *code;
@property (nonatomic, strong) NSNumber *lat;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSNumber *lon;

+ (instancetype)modelObjectWithDictionary:(NSDictionary *)dict;
- (instancetype)initWithDictionary:(NSDictionary *)dict;
- (NSDictionary *)dictionaryRepresentation;

@property (nonatomic)CLLocationCoordinate2D coords;




@end
