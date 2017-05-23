//
//  DigiGeometry.h
//
//  Created by Anteneh Sahledengel on 28/5/16
//  Copyright (c) 2016 shaby ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "Mapping.h"

@interface DigiGeometry : NSObject <NSCoding, NSCopying, Mappable>

@property (nonatomic, strong) NSNumber *lat;
@property (nonatomic, strong) NSNumber *lon;

@property (nonatomic, strong) CLLocation *location;
@property (nonatomic) CLLocationCoordinate2D coordinate;
@property (nonatomic, strong) NSString *stringCoordinate;

+ (instancetype)modelObjectWithDictionary:(NSDictionary *)dict;
- (instancetype)initWithDictionary:(NSDictionary *)dict;
- (NSDictionary *)dictionaryRepresentation;

@end
