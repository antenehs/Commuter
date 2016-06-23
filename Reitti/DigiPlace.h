//
//  DigiFrom.h
//
//  Created by Anteneh Sahledengel on 28/5/16
//  Copyright (c) 2016 shaby ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RestKit/RestKit.h>
#import <MapKit/MapKit.h>

#import "DigiIntermediateStops.h"
#import "DigiBikeRentalStation.h"

@interface DigiPlace : NSObject <NSCoding, NSCopying>

@property (nonatomic, strong) DigiBikeRentalStation *bikeRentalStation;
@property (nonatomic, strong) NSNumber *lat;
@property (nonatomic, strong) NSNumber *lon;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) DigiIntermediateStops *intermediateStop;

@property (nonatomic) CLLocationCoordinate2D coords;

+ (instancetype)modelObjectWithDictionary:(NSDictionary *)dict;
- (instancetype)initWithDictionary:(NSDictionary *)dict;
- (NSDictionary *)dictionaryRepresentation;

+(RKResponseDescriptor *)responseDiscriptorForPath:(NSString *)path;
+(RKObjectMapping *)objectMapping;

@end
